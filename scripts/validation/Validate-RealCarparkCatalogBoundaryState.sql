\set ON_ERROR_STOP on

\if :{?expected_total_groups}
\else
  \echo 'expected_total_groups is required'
  \quit 3
\endif
\if :{?expected_total_sites}
\else
  \echo 'expected_total_sites is required'
  \quit 3
\endif
\if :{?expect_synthetic_fixture}
\else
  \echo 'expect_synthetic_fixture is required'
  \quit 3
\endif

BEGIN;

CREATE TEMP TABLE ep_real_carpark_boundary_expectation (
  expected_total_groups integer NOT NULL,
  expected_total_sites integer NOT NULL,
  expect_synthetic_fixture boolean NOT NULL
) ON COMMIT DROP;

INSERT INTO ep_real_carpark_boundary_expectation
VALUES (:expected_total_groups, :expected_total_sites, :expect_synthetic_fixture);

DO $boundary$
DECLARE
  expected record;
  group_digest text;
  site_digest text;
BEGIN
  SELECT * INTO STRICT expected FROM ep_real_carpark_boundary_expectation;

  IF (SELECT count(*) FROM sites.site_groups) <> expected.expected_total_groups
     OR (SELECT count(*) FROM sites.sites) <> expected.expected_total_sites THEN
    RAISE EXCEPTION 'Real carpark boundary failed: topology totals differ from expected %/% groups/sites.',
      expected.expected_total_groups, expected.expected_total_sites;
  END IF;

  IF (SELECT count(*) FROM sites.real_carpark_catalog_site_groups) <> 39
     OR (SELECT count(*) FROM sites.real_carpark_catalog_sites) <> 46 THEN
    RAISE EXCEPTION 'Real carpark boundary failed: canonical membership is not 39/46.';
  END IF;

  IF EXISTS (
    SELECT 1 FROM sites.real_carpark_catalog_site_groups
    WHERE catalog_code <> 'PROFESSIONAL_PARKING_REAL_CARPARK_V1'
       OR source_reference <> 'D:\Docs\Carparks.xlsx'
       OR source_sha256 <> '63C20CD3ABA3E13D6F9FC022083507C0BC43A2AB9C751E9084DD19C59969359A'
  ) OR EXISTS (
    SELECT 1 FROM sites.real_carpark_catalog_sites
    WHERE catalog_code <> 'PROFESSIONAL_PARKING_REAL_CARPARK_V1'
       OR source_reference <> 'D:\Docs\Carparks.xlsx'
       OR source_sha256 <> '63C20CD3ABA3E13D6F9FC022083507C0BC43A2AB9C751E9084DD19C59969359A'
  ) THEN
    RAISE EXCEPTION 'Real carpark boundary failed: catalog provenance changed.';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM sites.real_carpark_catalog_site_groups c
    LEFT JOIN sites.site_groups g ON g.site_group_id = c.site_group_id
    WHERE g.site_group_id IS NULL
  ) OR EXISTS (
    SELECT 1
    FROM sites.real_carpark_catalog_sites c
    LEFT JOIN sites.sites s ON s.site_id = c.site_id
    LEFT JOIN sites.real_carpark_catalog_site_groups cg ON cg.site_group_id = c.site_group_id
    WHERE s.site_id IS NULL OR s.site_group_id <> c.site_group_id OR cg.site_group_id IS NULL
  ) THEN
    RAISE EXCEPTION 'Real carpark boundary failed: canonical membership is orphaned or has a wrong Site Group parent.';
  END IF;

  SELECT encode(digest(string_agg(
      concat_ws('|', g.site_group_id::text, g.site_group_code, g.site_group_name),
      E'\n' ORDER BY g.site_group_id), 'sha256'), 'hex')
  INTO group_digest
  FROM sites.real_carpark_catalog_site_groups c
  JOIN sites.site_groups g USING (site_group_id);

  SELECT encode(digest(string_agg(
      concat_ws('|', s.site_id::text, s.site_group_id::text, s.site_code, s.site_name),
      E'\n' ORDER BY s.site_id), 'sha256'), 'hex')
  INTO site_digest
  FROM sites.real_carpark_catalog_sites c
  JOIN sites.sites s USING (site_id);

  IF group_digest <> '07cd3935bca24073bbc9b02db527e306af809ed1c01be21b06512f695933eefe'
     OR site_digest <> 'd2d70d585261a9e1f78a2fab6c290e283ddac5872c13be7d8b1c2614159fed53' THEN
    RAISE EXCEPTION 'Real carpark boundary failed: approved UUID/code/name/parent mapping changed.';
  END IF;

  IF (SELECT count(*) FROM sites.site_groups
      WHERE site_group_id = 'a6dbadf6-68b5-5bed-a7e0-a75faee70841'
        AND site_group_code = 'PITX' AND site_group_name = 'PITX'
        AND site_group_status = 'DRAFT') <> 1
     OR (SELECT count(*) FROM sites.sites
         WHERE site_id = '2d1dcdf8-f563-537c-8542-0bde7cc9da97'
           AND site_group_id = 'a6dbadf6-68b5-5bed-a7e0-a75faee70841'
           AND site_code = 'PITX-LEVEL-3' AND site_name = 'PITX Level 3'
           AND site_status = 'DRAFT') <> 1
     OR (SELECT count(*) FROM sites.sites
         WHERE site_id = 'b336964f-3b84-5404-8690-97ead0929b1f'
           AND site_group_id = 'a6dbadf6-68b5-5bed-a7e0-a75faee70841'
           AND site_code = 'PITX-OPEN-LOT' AND site_name = 'PITX Open Lot'
           AND site_status = 'DRAFT') <> 1 THEN
    RAISE EXCEPTION 'Real carpark boundary failed: protected PITX identities or clean-build activation semantics changed.';
  END IF;

  IF expected.expect_synthetic_fixture THEN
    IF (SELECT count(*) FROM sites.site_groups g
        WHERE NOT EXISTS (SELECT 1 FROM sites.real_carpark_catalog_site_groups c WHERE c.site_group_id = g.site_group_id)) <> 4
       OR (SELECT count(*) FROM sites.sites s
           WHERE NOT EXISTS (SELECT 1 FROM sites.real_carpark_catalog_sites c WHERE c.site_id = s.site_id)) <> 92 THEN
      RAISE EXCEPTION 'Real carpark boundary failed: explicit fixture is not exactly 4 groups/92 sites.';
    END IF;

    IF (SELECT count(*) FROM sites.site_groups
        WHERE site_group_code IN ('SAMPLE-METRO-MANILA','SAMPLE-METRO-CEBU','SAMPLE-METRO-DAVAO')
          AND site_group_status = 'INACTIVE') <> 3
       OR (SELECT count(*) FROM sites.sites s
           JOIN sites.site_groups g USING (site_group_id)
           WHERE g.site_group_code IN ('SAMPLE-METRO-MANILA','SAMPLE-METRO-CEBU','SAMPLE-METRO-DAVAO')
             AND s.site_status = 'INACTIVE') <> 90
       OR (SELECT count(*) FROM sites.site_groups
           WHERE site_group_id = '594afaf3-6f55-54be-933d-c6572f4e02ec'
             AND site_group_code = 'MNT' AND site_group_name = 'Mactan Newtown') <> 1
       OR (SELECT count(*) FROM sites.sites
           WHERE site_group_id = '594afaf3-6f55-54be-933d-c6572f4e02ec'
             AND site_id IN ('110a07ad-773f-5018-b18a-d4d78e2ae6dd','db5f423b-ed17-59d4-a5be-e7440aca5b21')) <> 2 THEN
      RAISE EXCEPTION 'Real carpark boundary failed: explicit synthetic fixture identities or lifecycle changed.';
    END IF;
  ELSE
    IF EXISTS (
      SELECT 1 FROM sites.site_groups g
      WHERE NOT EXISTS (SELECT 1 FROM sites.real_carpark_catalog_site_groups c WHERE c.site_group_id = g.site_group_id)
    ) OR EXISTS (
      SELECT 1 FROM sites.sites s
      WHERE NOT EXISTS (SELECT 1 FROM sites.real_carpark_catalog_sites c WHERE c.site_id = s.site_id)
    ) THEN
      RAISE EXCEPTION 'Real carpark boundary failed: synthetic topology is reachable through normal construction.';
    END IF;
  END IF;
END
$boundary$;

SELECT 'Real carpark catalog boundary state validation passed.' AS validation_result;
ROLLBACK;
