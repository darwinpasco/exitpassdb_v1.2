\set ON_ERROR_STOP on
\pset pager off

BEGIN TRANSACTION READ ONLY;

SELECT 'fixture_summary' AS result_set,
       count(*) FILTER (WHERE sg.site_group_code = 'MNT') AS mnt_site_groups,
       count(*) FILTER (WHERE sg.site_group_code LIKE 'SAMPLE-METRO-%') AS sample_site_groups
FROM sites.site_groups sg;

SELECT 'fixture_site_summary' AS result_set,
       count(*) FILTER (WHERE sg.site_group_code = 'MNT') AS mnt_sites,
       count(*) FILTER (WHERE sg.site_group_code LIKE 'SAMPLE-METRO-%') AS sample_sites
FROM sites.sites s
JOIN sites.site_groups sg ON sg.site_group_id = s.site_group_id;

SELECT 'fixture_assignment_summary' AS result_set,
       count(*) FILTER (WHERE sg.site_group_code = 'MNT') AS mnt_assignments,
       count(*) FILTER (WHERE sg.site_group_code LIKE 'SAMPLE-METRO-%') AS sample_assignments
FROM sites.site_jurisdiction_assignments a
JOIN sites.sites s ON s.site_id = a.site_id
JOIN sites.site_groups sg ON sg.site_group_id = s.site_group_id;

SELECT 'declared_foreign_key' AS result_set,
       n1.nspname AS referencing_schema,
       c1.relname AS referencing_table,
       con.conname AS constraint_name,
       string_agg(a1.attname, ',' ORDER BY k.ord) AS referencing_columns,
       n2.nspname AS referenced_schema,
       c2.relname AS referenced_table,
       string_agg(a2.attname, ',' ORDER BY k.ord) AS referenced_columns,
       con.confdeltype AS deletion_action,
       con.confupdtype AS update_action
FROM pg_constraint con
JOIN pg_class c1 ON c1.oid = con.conrelid
JOIN pg_namespace n1 ON n1.oid = c1.relnamespace
JOIN pg_class c2 ON c2.oid = con.confrelid
JOIN pg_namespace n2 ON n2.oid = c2.relnamespace
JOIN LATERAL unnest(con.conkey) WITH ORDINALITY k(attnum, ord) ON true
JOIN LATERAL unnest(con.confkey) WITH ORDINALITY fk(attnum, ord) ON fk.ord = k.ord
JOIN pg_attribute a1 ON a1.attrelid = c1.oid AND a1.attnum = k.attnum
JOIN pg_attribute a2 ON a2.attrelid = c2.oid AND a2.attnum = fk.attnum
WHERE con.contype = 'f'
  AND con.confrelid IN (
      'sites.site_groups'::regclass,
      'sites.sites'::regclass,
      'sites.site_jurisdiction_assignments'::regclass
  )
GROUP BY n1.nspname, c1.relname, con.conname, n2.nspname, c2.relname,
         con.confdeltype, con.confupdtype
ORDER BY referenced_schema, referenced_table, referencing_schema,
         referencing_table, constraint_name;

WITH RECURSIVE foreign_key_edges AS (
  SELECT con.conrelid AS child_oid, con.confrelid AS parent_oid
  FROM pg_constraint con
  WHERE con.contype = 'f'
), dependency_walk AS (
  SELECT 'sites.site_groups'::regclass::oid AS root_oid,
         'sites.site_groups'::regclass::oid AS current_oid,
         ARRAY['sites.site_groups']::text[] AS dependency_path,
         0 AS depth
  UNION ALL
  SELECT 'sites.sites'::regclass::oid,
         'sites.sites'::regclass::oid,
         ARRAY['sites.sites']::text[],
         0
  UNION ALL
  SELECT 'sites.site_jurisdiction_assignments'::regclass::oid,
         'sites.site_jurisdiction_assignments'::regclass::oid,
         ARRAY['sites.site_jurisdiction_assignments']::text[],
         0
  UNION ALL
  SELECT walk.root_oid,
         edge.child_oid,
         walk.dependency_path || edge.child_oid::regclass::text,
         walk.depth + 1
  FROM dependency_walk walk
  JOIN foreign_key_edges edge ON edge.parent_oid = walk.current_oid
  WHERE walk.depth < 8
    AND NOT edge.child_oid::regclass::text = ANY(walk.dependency_path)
)
SELECT DISTINCT 'indirect_foreign_key_path' AS result_set,
       root_oid::regclass::text AS root_table,
       current_oid::regclass::text AS dependent_table,
       depth,
       array_to_string(dependency_path, ' -> ') AS dependency_path
FROM dependency_walk
WHERE depth > 0
ORDER BY root_table, depth, dependent_table, dependency_path;

SELECT format(
  'WITH fixture_groups AS (SELECT site_group_id FROM sites.site_groups WHERE site_group_code = ''MNT'' OR site_group_code LIKE ''SAMPLE-METRO-%%'') SELECT %L AS result_set, %L AS table_name, %L AS column_name, count(*)::bigint AS row_count, count(DISTINCT r.%I)::bigint AS fixture_count FROM %I.%I r JOIN fixture_groups f ON r.%I = f.site_group_id HAVING count(*) > 0',
  'site_group_reference', table_schema || '.' || table_name, column_name,
  column_name, table_schema, table_name, column_name
)
FROM information_schema.columns
WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
  AND udt_name = 'uuid'
  AND column_name IN ('site_group_id', 'requested_site_group_id')
ORDER BY table_schema, table_name, column_name
\gexec

SELECT format(
  'WITH fixture_sites AS (SELECT s.site_id FROM sites.sites s JOIN sites.site_groups sg ON sg.site_group_id = s.site_group_id WHERE sg.site_group_code = ''MNT'' OR sg.site_group_code LIKE ''SAMPLE-METRO-%%'') SELECT %L AS result_set, %L AS table_name, %L AS column_name, count(*)::bigint AS row_count, count(DISTINCT r.%I)::bigint AS fixture_count FROM %I.%I r JOIN fixture_sites f ON r.%I = f.site_id HAVING count(*) > 0',
  'site_reference', table_schema || '.' || table_name, column_name,
  column_name, table_schema, table_name, column_name
)
FROM information_schema.columns
WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
  AND udt_name = 'uuid'
  AND column_name IN ('site_id', 'requested_site_id')
ORDER BY table_schema, table_name, column_name
\gexec

SELECT format(
  'WITH fixture_assignments AS (SELECT a.site_jurisdiction_assignment_id FROM sites.site_jurisdiction_assignments a JOIN sites.sites s ON s.site_id = a.site_id JOIN sites.site_groups sg ON sg.site_group_id = s.site_group_id WHERE sg.site_group_code LIKE ''SAMPLE-METRO-%%'') SELECT %L AS result_set, %L AS table_name, %L AS column_name, count(*)::bigint AS row_count, count(DISTINCT r.%I)::bigint AS fixture_count FROM %I.%I r JOIN fixture_assignments f ON r.%I = f.site_jurisdiction_assignment_id HAVING count(*) > 0',
  'assignment_reference', table_schema || '.' || table_name, column_name,
  column_name, table_schema, table_name, column_name
)
FROM information_schema.columns
WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
  AND udt_name = 'uuid'
  AND column_name = 'site_jurisdiction_assignment_id'
ORDER BY table_schema, table_name, column_name
\gexec

SELECT format(
$query$
WITH fixture_tokens(token) AS (
  SELECT site_group_id::text FROM sites.site_groups WHERE site_group_code = 'MNT' OR site_group_code LIKE 'SAMPLE-METRO-%%'
  UNION SELECT site_group_code FROM sites.site_groups WHERE site_group_code = 'MNT' OR site_group_code LIKE 'SAMPLE-METRO-%%'
  UNION SELECT s.site_id::text FROM sites.sites s JOIN sites.site_groups sg ON sg.site_group_id = s.site_group_id WHERE sg.site_group_code = 'MNT' OR sg.site_group_code LIKE 'SAMPLE-METRO-%%'
  UNION SELECT s.site_code FROM sites.sites s JOIN sites.site_groups sg ON sg.site_group_id = s.site_group_id WHERE sg.site_group_code = 'MNT' OR sg.site_group_code LIKE 'SAMPLE-METRO-%%'
  UNION SELECT a.site_jurisdiction_assignment_id::text FROM sites.site_jurisdiction_assignments a JOIN sites.sites s ON s.site_id = a.site_id JOIN sites.site_groups sg ON sg.site_group_id = s.site_group_id WHERE sg.site_group_code LIKE 'SAMPLE-METRO-%%'
  UNION VALUES ('77000000-0000-0000-0000-000000000001'), ('77000000-0000-0000-0000-000000000002')
)
SELECT %L AS result_set, %L AS table_name, %L AS column_name,
       count(*)::bigint AS match_pairs,
       count(DISTINCT token)::bigint AS matched_tokens
FROM %I.%I row_data
JOIN fixture_tokens ON row_data.%I::text LIKE '%%' || token || '%%'
HAVING count(*) > 0
$query$,
  'controlled_text_or_json_reference',
  table_schema || '.' || table_name,
  column_name,
  table_schema,
  table_name,
  column_name
)
FROM information_schema.columns
WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
  AND data_type IN ('text', 'character varying', 'character', 'json', 'jsonb')
ORDER BY table_schema, table_name, column_name
\gexec

COMMIT;
