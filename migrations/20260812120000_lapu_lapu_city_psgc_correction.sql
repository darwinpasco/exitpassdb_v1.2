-- Correct the current City of Lapu-Lapu PSGC reference while preserving its canonical identity.
-- This forward correction is intentionally a no-op when canonical jurisdiction reference data
-- has not yet been seeded; the corrected declarative seed owns clean-database creation.
BEGIN;

DO $$
DECLARE
  target_jurisdiction_id constant uuid := '23104fc9-a144-381c-4347-ccb2aa1a2998';
  target_region_id uuid;
  target_count integer;
BEGIN
  IF EXISTS (
    SELECT 1
    FROM sites.jurisdictions
    WHERE (psgc_code = '0731100000' OR jurisdiction_code = 'PH-PSGC-0731100000')
      AND jurisdiction_id <> target_jurisdiction_id
  ) THEN
    RAISE EXCEPTION 'City of Lapu-Lapu correction refused: corrected PSGC identity is already assigned to another jurisdiction.';
  END IF;

  SELECT count(*) INTO target_count
  FROM sites.jurisdictions
  WHERE jurisdiction_id = target_jurisdiction_id;

  IF target_count = 0 THEN
    IF EXISTS (
      SELECT 1
      FROM sites.jurisdictions
      WHERE display_name = 'City of Lapu-Lapu'
         OR short_display_name = 'Lapu-Lapu'
         OR psgc_code IN ('0730110000', '0731100000')
         OR jurisdiction_code IN ('PH-PSGC-0730110000', 'PH-PSGC-0731100000')
    ) THEN
      RAISE EXCEPTION 'City of Lapu-Lapu correction refused: a candidate identity exists under an unexpected jurisdiction ID.';
    END IF;

    RETURN;
  END IF;

  SELECT philippine_region_id INTO target_region_id
  FROM sites.philippine_regions
  WHERE region_code = 'REGION_VII';

  IF target_region_id IS NULL THEN
    RAISE EXCEPTION 'City of Lapu-Lapu correction refused: canonical Region VII is missing.';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM sites.jurisdictions
    WHERE jurisdiction_id = target_jurisdiction_id
      AND display_name = 'City of Lapu-Lapu'
      AND short_display_name = 'Lapu-Lapu'
      AND jurisdiction_type = 'CITY'
      AND city_classification = 'HIGHLY_URBANIZED'
      AND philippine_region_id = target_region_id
      AND philippine_province_id IS NULL
      AND psgc_code IN ('0730110000', '0731100000')
      AND jurisdiction_code IN ('PH-PSGC-0730110000', 'PH-PSGC-0731100000')
  ) THEN
    RAISE EXCEPTION 'City of Lapu-Lapu correction refused: the existing canonical identity or topology is inconsistent.';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM discounts.statutory_discount_policy_registry
    WHERE policy_code IN ('I006_0731100000_SC', 'I006_0731100000_PWD')
      AND statutory_discount_policy_registry_id NOT IN (
        'a216d952-6bf6-e518-c91c-08cbcb608e1c',
        '42c440a6-a93c-7ac5-e6e6-3096e41808fc'
      )
  ) THEN
    RAISE EXCEPTION 'City of Lapu-Lapu correction refused: corrected policy code is assigned to another registry identity.';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM discounts.statutory_discount_policy_registry
    WHERE statutory_discount_policy_registry_id IN (
            'a216d952-6bf6-e518-c91c-08cbcb608e1c',
            '42c440a6-a93c-7ac5-e6e6-3096e41808fc'
          )
      AND NOT (
        jurisdiction_id = target_jurisdiction_id
        AND local_government_unit_id = target_jurisdiction_id
        AND (
          (statutory_discount_policy_registry_id = 'a216d952-6bf6-e518-c91c-08cbcb608e1c' AND entitlement_type = 'SENIOR_CITIZEN')
          OR
          (statutory_discount_policy_registry_id = '42c440a6-a93c-7ac5-e6e6-3096e41808fc' AND entitlement_type = 'PWD')
        )
      )
  ) THEN
    RAISE EXCEPTION 'City of Lapu-Lapu correction refused: a preserved policy identity has conflicting ownership or entitlement.';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM discounts.statutory_discount_policy_registry
    WHERE (
            statutory_discount_policy_registry_id = 'a216d952-6bf6-e518-c91c-08cbcb608e1c'
            AND policy_code NOT IN ('I006_0730110000_SC', 'I006_0731100000_SC')
          )
       OR (
            statutory_discount_policy_registry_id = '42c440a6-a93c-7ac5-e6e6-3096e41808fc'
            AND policy_code NOT IN ('I006_0730110000_PWD', 'I006_0731100000_PWD')
          )
       OR (
            jurisdiction_id = target_jurisdiction_id
            AND (jurisdiction_code = 'PH-PSGC-0730110000' OR policy_code IN ('I006_0730110000_SC', 'I006_0730110000_PWD'))
            AND statutory_discount_policy_registry_id NOT IN (
              'a216d952-6bf6-e518-c91c-08cbcb608e1c',
              '42c440a6-a93c-7ac5-e6e6-3096e41808fc'
            )
          )
  ) THEN
    RAISE EXCEPTION 'City of Lapu-Lapu correction refused: policy-code ownership is inconsistent.';
  END IF;

  UPDATE discounts.statutory_discount_policy_registry
  SET policy_code = CASE statutory_discount_policy_registry_id
                      WHEN 'a216d952-6bf6-e518-c91c-08cbcb608e1c'::uuid THEN 'I006_0731100000_SC'
                      WHEN '42c440a6-a93c-7ac5-e6e6-3096e41808fc'::uuid THEN 'I006_0731100000_PWD'
                    END,
      jurisdiction_code = 'PH-PSGC-0731100000',
      updated_at = now(),
      updated_by_service_identity_id = '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
  WHERE statutory_discount_policy_registry_id IN (
          'a216d952-6bf6-e518-c91c-08cbcb608e1c',
          '42c440a6-a93c-7ac5-e6e6-3096e41808fc'
        )
    AND jurisdiction_id = target_jurisdiction_id
    AND local_government_unit_id = target_jurisdiction_id
    AND policy_code IN (
          'I006_0730110000_SC', 'I006_0730110000_PWD',
          'I006_0731100000_SC', 'I006_0731100000_PWD'
        )
    AND (
      jurisdiction_code IS DISTINCT FROM 'PH-PSGC-0731100000'
      OR policy_code IS DISTINCT FROM CASE statutory_discount_policy_registry_id
                                        WHEN 'a216d952-6bf6-e518-c91c-08cbcb608e1c'::uuid THEN 'I006_0731100000_SC'
                                        WHEN '42c440a6-a93c-7ac5-e6e6-3096e41808fc'::uuid THEN 'I006_0731100000_PWD'
                                      END
    );

  UPDATE sites.jurisdictions
  SET psgc_code = '0731100000',
      correspondence_code = '072226000',
      jurisdiction_code = 'PH-PSGC-0731100000',
      source_reference = 'I-006 controlled PSGC LGU seed; PSA PSGC as of 30 June 2026, accessed 2026-08-12.',
      source_provenance = 'Canonical City of Lapu-Lapu identity corrected to current PSA PSGC 0731100000; correspondence code 072226000 is stored separately. Independent HUC province_id remains null.',
      updated_at = now(),
      updated_by_service_identity_id = '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
  WHERE jurisdiction_id = target_jurisdiction_id
    AND (
      psgc_code IS DISTINCT FROM '0731100000'
      OR correspondence_code IS DISTINCT FROM '072226000'
      OR jurisdiction_code IS DISTINCT FROM 'PH-PSGC-0731100000'
      OR source_reference IS DISTINCT FROM 'I-006 controlled PSGC LGU seed; PSA PSGC as of 30 June 2026, accessed 2026-08-12.'
      OR source_provenance IS DISTINCT FROM 'Canonical City of Lapu-Lapu identity corrected to current PSA PSGC 0731100000; correspondence code 072226000 is stored separately. Independent HUC province_id remains null.'
    );

  IF NOT EXISTS (
    SELECT 1
    FROM sites.jurisdictions
    WHERE jurisdiction_id = target_jurisdiction_id
      AND psgc_code = '0731100000'
      AND correspondence_code = '072226000'
      AND jurisdiction_code = 'PH-PSGC-0731100000'
  ) THEN
    RAISE EXCEPTION 'City of Lapu-Lapu correction failed post-update validation.';
  END IF;
END $$;

COMMIT;
