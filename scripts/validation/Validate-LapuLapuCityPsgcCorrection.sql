BEGIN TRANSACTION READ ONLY;
SET LOCAL default_transaction_read_only = on;

DO $$
DECLARE
  target_jurisdiction_id constant uuid := '23104fc9-a144-381c-4347-ccb2aa1a2998';
  expected_seed_id uuid;
  failure text;
BEGIN
  expected_seed_id := (
    substr(md5('exitpass:i006:lgu:LAPU_LAPU'), 1, 8) || '-' ||
    substr(md5('exitpass:i006:lgu:LAPU_LAPU'), 9, 4) || '-' ||
    substr(md5('exitpass:i006:lgu:LAPU_LAPU'), 13, 4) || '-' ||
    substr(md5('exitpass:i006:lgu:LAPU_LAPU'), 17, 4) || '-' ||
    substr(md5('exitpass:i006:lgu:LAPU_LAPU'), 21, 12)
  )::uuid;

  IF expected_seed_id <> target_jurisdiction_id THEN
    failure := 'stable LAPU_LAPU seed identity changed';
  ELSIF (SELECT count(*) FROM sites.jurisdictions WHERE jurisdiction_id = target_jurisdiction_id) <> 1 THEN
    failure := 'expected canonical City of Lapu-Lapu jurisdiction identity is missing or duplicated';
  ELSIF (SELECT count(*) FROM sites.jurisdictions WHERE display_name = 'City of Lapu-Lapu' AND jurisdiction_status = 'ACTIVE') <> 1 THEN
    failure := 'exactly one active canonical City of Lapu-Lapu row is required';
  ELSIF NOT EXISTS (
    SELECT 1
    FROM sites.jurisdictions j
    JOIN sites.philippine_regions r ON r.philippine_region_id = j.philippine_region_id
    WHERE j.jurisdiction_id = target_jurisdiction_id
      AND j.jurisdiction_code = 'PH-PSGC-0731100000'
      AND j.psgc_code = '0731100000'
      AND j.correspondence_code = '072226000'
      AND j.display_name = 'City of Lapu-Lapu'
      AND j.short_display_name = 'Lapu-Lapu'
      AND j.jurisdiction_type = 'CITY'
      AND j.city_classification = 'HIGHLY_URBANIZED'
      AND j.philippine_province_id IS NULL
      AND j.province_name IS NULL
      AND r.region_code = 'REGION_VII'
      AND r.official_name = 'Region VII (Central Visayas)'
  ) THEN
    failure := 'canonical City of Lapu-Lapu PSGC, correspondence code, classification, or Region VII topology is incorrect';
  ELSIF EXISTS (
    SELECT 1 FROM sites.jurisdictions
    WHERE psgc_code = '0730110000' OR jurisdiction_code = 'PH-PSGC-0730110000'
  ) THEN
    failure := 'retired incorrect Lapu-Lapu PSGC remains active in canonical jurisdiction data';
  ELSIF EXISTS (
    SELECT psgc_code FROM sites.jurisdictions WHERE psgc_code IS NOT NULL GROUP BY psgc_code HAVING count(*) > 1
  ) THEN
    failure := 'duplicate current jurisdiction PSGC code exists';
  ELSIF EXISTS (
    SELECT jurisdiction_code FROM sites.jurisdictions GROUP BY jurisdiction_code HAVING count(*) > 1
  ) THEN
    failure := 'duplicate current jurisdiction code exists';
  ELSIF NOT EXISTS (
    SELECT 1
    FROM sites.metropolitan_area_jurisdictions m
    JOIN sites.metropolitan_areas a ON a.metropolitan_area_id = m.metropolitan_area_id
    WHERE m.metropolitan_area_jurisdiction_id = 'fb97785d-eed4-39b4-eb89-52bb20265fdd'
      AND m.jurisdiction_id = target_jurisdiction_id
      AND a.metropolitan_area_code = 'METRO_CEBU'
      AND m.membership_status = 'ACTIVE'
      AND m.effective_to IS NULL
  ) THEN
    failure := 'preserved Metro Cebu membership identity or relationship is missing';
  ELSIF (SELECT count(*) FROM sites.metropolitan_area_jurisdictions WHERE jurisdiction_id = target_jurisdiction_id AND membership_status = 'ACTIVE' AND effective_to IS NULL) <> 1 THEN
    failure := 'City of Lapu-Lapu must have exactly one active metropolitan-area membership';
  ELSIF NOT EXISTS (
    SELECT 1 FROM discounts.statutory_discount_policy_registry
    WHERE statutory_discount_policy_registry_id = 'a216d952-6bf6-e518-c91c-08cbcb608e1c'
      AND jurisdiction_id = target_jurisdiction_id
      AND local_government_unit_id = target_jurisdiction_id
      AND entitlement_type = 'SENIOR_CITIZEN'
      AND policy_code = 'I006_0731100000_SC'
      AND jurisdiction_code = 'PH-PSGC-0731100000'
  ) THEN
    failure := 'preserved Senior Citizen policy registry identity or corrected reference is missing';
  ELSIF NOT EXISTS (
    SELECT 1 FROM discounts.statutory_discount_policy_registry
    WHERE statutory_discount_policy_registry_id = '42c440a6-a93c-7ac5-e6e6-3096e41808fc'
      AND jurisdiction_id = target_jurisdiction_id
      AND local_government_unit_id = target_jurisdiction_id
      AND entitlement_type = 'PWD'
      AND policy_code = 'I006_0731100000_PWD'
      AND jurisdiction_code = 'PH-PSGC-0731100000'
  ) THEN
    failure := 'preserved PWD policy registry identity or corrected reference is missing';
  ELSIF NOT EXISTS (
    SELECT 1 FROM discounts.statutory_discount_policy_registry_lgu_scopes
    WHERE statutory_discount_policy_registry_lgu_scope_id = 'c336d25f-e95d-bb35-6c79-42b7f4b68e19'
      AND statutory_discount_policy_registry_id = 'a216d952-6bf6-e518-c91c-08cbcb608e1c'
      AND local_government_unit_id = target_jurisdiction_id
  ) THEN
    failure := 'preserved Senior Citizen policy scope identity is missing';
  ELSIF NOT EXISTS (
    SELECT 1 FROM discounts.statutory_discount_policy_registry_lgu_scopes
    WHERE statutory_discount_policy_registry_lgu_scope_id = '11e203f6-6a63-0174-086d-d2d6ce0b7e8a'
      AND statutory_discount_policy_registry_id = '42c440a6-a93c-7ac5-e6e6-3096e41808fc'
      AND local_government_unit_id = target_jurisdiction_id
  ) THEN
    failure := 'preserved PWD policy scope identity is missing';
  END IF;

  IF failure IS NOT NULL THEN
    RAISE EXCEPTION 'City of Lapu-Lapu PSGC validation failed: %.', failure;
  END IF;
END $$;

SELECT
  j.jurisdiction_id,
  j.jurisdiction_code,
  j.psgc_code,
  j.correspondence_code,
  j.display_name,
  j.jurisdiction_type,
  j.city_classification,
  r.region_code,
  (j.philippine_province_id IS NULL) AS independent_huc_province_is_null
FROM sites.jurisdictions j
JOIN sites.philippine_regions r ON r.philippine_region_id = j.philippine_region_id
WHERE j.jurisdiction_id = '23104fc9-a144-381c-4347-ccb2aa1a2998';

SELECT 'City of Lapu-Lapu canonical PSGC correction validation passed.' AS validation_result;

ROLLBACK;
