\set ON_ERROR_STOP on
\pset pager off

BEGIN TRANSACTION READ ONLY;

WITH realistic_assignments AS (
  SELECT a.site_jurisdiction_assignment_id, a.site_id
  FROM sites.site_jurisdiction_assignments a
  WHERE a.source_reference LIKE 'ExitPass realistic carpark manifest %'
), realistic_sites AS (
  SELECT DISTINCT s.site_id, s.site_group_id
  FROM realistic_assignments a
  JOIN sites.sites s ON s.site_id = a.site_id
), assertions AS (
  SELECT 'canonical fixture Site Group count' AS assertion_name,
         (SELECT count(*) FROM sites.site_groups
          WHERE site_group_code = 'MNT' OR site_group_code LIKE 'SAMPLE-METRO-%') = 4 AS passed
  UNION ALL
  SELECT 'canonical fixture Site count',
         (SELECT count(*) FROM sites.sites s JOIN sites.site_groups sg ON sg.site_group_id = s.site_group_id
          WHERE sg.site_group_code = 'MNT' OR sg.site_group_code LIKE 'SAMPLE-METRO-%') = 92
  UNION ALL
  SELECT 'synthetic assignment count',
         (SELECT count(*) FROM sites.site_jurisdiction_assignments a
          JOIN sites.sites s ON s.site_id = a.site_id
          JOIN sites.site_groups sg ON sg.site_group_id = s.site_group_id
          WHERE sg.site_group_code LIKE 'SAMPLE-METRO-%') = 90
  UNION ALL
  SELECT 'MNT has no jurisdiction assignment',
         (SELECT count(*) FROM sites.site_jurisdiction_assignments a
          JOIN sites.sites s ON s.site_id = a.site_id
          JOIN sites.site_groups sg ON sg.site_group_id = s.site_group_id
          WHERE sg.site_group_code = 'MNT') = 0
  UNION ALL
  SELECT 'realistic catalog counts are 39/46/46',
         (SELECT count(DISTINCT site_group_id) FROM realistic_sites) = 39
         AND (SELECT count(*) FROM realistic_sites) = 46
         AND (SELECT count(*) FROM realistic_assignments) = 46
  UNION ALL
  SELECT 'realistic and fixture identities do not overlap',
         NOT EXISTS (
           SELECT 1 FROM realistic_sites r
           JOIN sites.sites s ON s.site_id = r.site_id
           JOIN sites.site_groups sg ON sg.site_group_id = s.site_group_id
           WHERE sg.site_group_code = 'MNT' OR sg.site_group_code LIKE 'SAMPLE-METRO-%'
         )
  UNION ALL
  SELECT 'documented realistic mapping candidates exist',
         EXISTS (SELECT 1 FROM sites.site_groups WHERE site_group_id = '1c40a4b4-a607-5942-91b2-a7f8af80671a' AND site_group_code = 'MACTAN-NEW-TOWN')
         AND EXISTS (SELECT 1 FROM sites.site_groups WHERE site_group_id = 'a6dbadf6-68b5-5bed-a7e0-a75faee70841' AND site_group_code = 'PITX')
         AND EXISTS (SELECT 1 FROM sites.sites WHERE site_id = '2d1dcdf8-f563-537c-8542-0bde7cc9da97' AND site_code = 'PITX-LEVEL-3')
  UNION ALL
  SELECT 'sample fixtures remain disabled',
         NOT EXISTS (
           SELECT 1 FROM sites.sites s JOIN sites.site_groups sg ON sg.site_group_id = s.site_group_id
           WHERE sg.site_group_code LIKE 'SAMPLE-METRO-%'
             AND (sg.site_group_status::text <> 'INACTIVE' OR sg.public_lookup_enabled OR sg.default_payment_enabled
                  OR s.site_status::text <> 'INACTIVE' OR s.public_lookup_enabled OR s.payment_enabled)
         )
  UNION ALL
  SELECT 'conditional 7700 fixture is absent from clean canonical build',
         NOT EXISTS (SELECT 1 FROM sites.site_groups WHERE site_group_id = '77000000-0000-0000-0000-000000000001')
         AND NOT EXISTS (SELECT 1 FROM sites.sites WHERE site_id = '77000000-0000-0000-0000-000000000002')
  UNION ALL
  SELECT 'PITX Level 3 canonical Paranaque assignment exists',
         EXISTS (
           SELECT 1
           FROM sites.site_jurisdiction_assignments
           WHERE site_jurisdiction_assignment_id = '2574804d-e93c-52f9-a917-81c08e44c30f'
             AND site_id = '2d1dcdf8-f563-537c-8542-0bde7cc9da97'
             AND jurisdiction_id = 'f7a1b4b9-17a9-89de-5059-f72779616f23'
         )
)
SELECT assertion_name, passed
FROM assertions
ORDER BY assertion_name;

WITH realistic_assignments AS (
  SELECT a.site_jurisdiction_assignment_id, a.site_id
  FROM sites.site_jurisdiction_assignments a
  WHERE a.source_reference LIKE 'ExitPass realistic carpark manifest %'
), realistic_sites AS (
  SELECT DISTINCT s.site_id, s.site_group_id
  FROM realistic_assignments a JOIN sites.sites s ON s.site_id = a.site_id
), assertions AS (
  SELECT (SELECT count(*) FROM sites.site_groups WHERE site_group_code = 'MNT' OR site_group_code LIKE 'SAMPLE-METRO-%') = 4 AS passed
  UNION ALL SELECT (SELECT count(*) FROM sites.sites s JOIN sites.site_groups sg ON sg.site_group_id=s.site_group_id WHERE sg.site_group_code='MNT' OR sg.site_group_code LIKE 'SAMPLE-METRO-%') = 92
  UNION ALL SELECT (SELECT count(*) FROM sites.site_jurisdiction_assignments a JOIN sites.sites s ON s.site_id=a.site_id JOIN sites.site_groups sg ON sg.site_group_id=s.site_group_id WHERE sg.site_group_code LIKE 'SAMPLE-METRO-%') = 90
  UNION ALL SELECT (SELECT count(*) FROM sites.site_jurisdiction_assignments a JOIN sites.sites s ON s.site_id=a.site_id JOIN sites.site_groups sg ON sg.site_group_id=s.site_group_id WHERE sg.site_group_code='MNT') = 0
  UNION ALL SELECT (SELECT count(*) FROM realistic_assignments) = 46 AND (SELECT count(*) FROM realistic_sites) = 46 AND (SELECT count(DISTINCT site_group_id) FROM realistic_sites) = 39
  UNION ALL SELECT NOT EXISTS (SELECT 1 FROM realistic_sites r JOIN sites.sites s ON s.site_id=r.site_id JOIN sites.site_groups sg ON sg.site_group_id=s.site_group_id WHERE sg.site_group_code='MNT' OR sg.site_group_code LIKE 'SAMPLE-METRO-%')
  UNION ALL SELECT EXISTS (SELECT 1 FROM sites.site_groups WHERE site_group_id='1c40a4b4-a607-5942-91b2-a7f8af80671a' AND site_group_code='MACTAN-NEW-TOWN') AND EXISTS (SELECT 1 FROM sites.site_groups WHERE site_group_id='a6dbadf6-68b5-5bed-a7e0-a75faee70841' AND site_group_code='PITX') AND EXISTS (SELECT 1 FROM sites.sites WHERE site_id='2d1dcdf8-f563-537c-8542-0bde7cc9da97' AND site_code='PITX-LEVEL-3')
  UNION ALL SELECT NOT EXISTS (SELECT 1 FROM sites.sites s JOIN sites.site_groups sg ON sg.site_group_id=s.site_group_id WHERE sg.site_group_code LIKE 'SAMPLE-METRO-%' AND (sg.site_group_status::text<>'INACTIVE' OR sg.public_lookup_enabled OR sg.default_payment_enabled OR s.site_status::text<>'INACTIVE' OR s.public_lookup_enabled OR s.payment_enabled))
  UNION ALL SELECT NOT EXISTS (SELECT 1 FROM sites.site_groups WHERE site_group_id='77000000-0000-0000-0000-000000000001') AND NOT EXISTS (SELECT 1 FROM sites.sites WHERE site_id='77000000-0000-0000-0000-000000000002')
  UNION ALL SELECT EXISTS (SELECT 1 FROM sites.site_jurisdiction_assignments WHERE site_jurisdiction_assignment_id='2574804d-e93c-52f9-a917-81c08e44c30f' AND site_id='2d1dcdf8-f563-537c-8542-0bde7cc9da97' AND jurisdiction_id='f7a1b4b9-17a9-89de-5059-f72779616f23')
)
SELECT bool_or(NOT passed)::text AS validation_failed
FROM assertions
\gset

\if :validation_failed
  \echo 'Synthetic carpark fixture reconciliation database validation failed.'
  \quit 3
\endif

COMMIT;
\echo 'Synthetic carpark fixture reconciliation database validation passed.'
