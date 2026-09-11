-- TEST-ONLY: I-006 disabled synthetic metropolitan sample Site Groups and Sites.
WITH seed(seed_key, site_group_code, site_group_name, description) AS (
  VALUES
  ('METRO_MANILA','SAMPLE-METRO-MANILA','Synthetic Sample Metro Manila Site Group','Disabled synthetic Site Group spanning Metro Manila LGUs for jurisdiction coverage proof only.'),
  ('METRO_CEBU','SAMPLE-METRO-CEBU','Synthetic Sample Metro Cebu Site Group','Disabled synthetic Site Group spanning Metro Cebu LGUs for jurisdiction coverage proof only.'),
  ('METRO_DAVAO','SAMPLE-METRO-DAVAO','Synthetic Sample Metropolitan Davao Site Group','Disabled synthetic Site Group spanning Metropolitan Davao LGUs for jurisdiction coverage proof only.')
), prepared AS (
  SELECT (substr(md5('exitpass:i006:sample-site-group:' || seed_key),1,8)||'-'||substr(md5('exitpass:i006:sample-site-group:' || seed_key),9,4)||'-'||substr(md5('exitpass:i006:sample-site-group:' || seed_key),13,4)||'-'||substr(md5('exitpass:i006:sample-site-group:' || seed_key),17,4)||'-'||substr(md5('exitpass:i006:sample-site-group:' || seed_key),21,12))::uuid AS site_group_id,
         site_group_code, site_group_name, description
  FROM seed
)
INSERT INTO sites.site_groups (site_group_id, site_group_code, site_group_name, business_label, description, operator_entity_name, timezone_name, default_currency_code, site_group_status, public_lookup_enabled, default_payment_enabled, effective_from, created_by_service_identity_id, updated_by_service_identity_id)
SELECT site_group_id, site_group_code, site_group_name, 'Synthetic sample', description, 'Synthetic non-production reference', 'Asia/Manila', 'PHP', 'INACTIVE', false, false, '2026-07-28T00:00:00+08'::timestamptz, '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978', '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
FROM prepared
ON CONFLICT ON CONSTRAINT uq_site_groups__site_group_code DO UPDATE SET
  site_group_name = EXCLUDED.site_group_name,
  business_label = EXCLUDED.business_label,
  description = EXCLUDED.description,
  operator_entity_name = EXCLUDED.operator_entity_name,
  site_group_status = 'INACTIVE',
  public_lookup_enabled = false,
  default_payment_enabled = false,
  updated_at = now(),
  updated_by_service_identity_id = EXCLUDED.updated_by_service_identity_id;

WITH members AS (
  SELECT ma.metropolitan_area_code, ma.metropolitan_area_name, sg.site_group_id, j.jurisdiction_id, j.psgc_code, j.display_name, j.short_display_name, j.province_name
  FROM sites.metropolitan_areas ma
  JOIN sites.metropolitan_area_jurisdictions maj ON maj.metropolitan_area_id = ma.metropolitan_area_id AND maj.membership_status = 'ACTIVE'
  JOIN sites.jurisdictions j ON j.jurisdiction_id = maj.jurisdiction_id
  JOIN sites.site_groups sg ON sg.site_group_code = 'SAMPLE-' || replace(ma.metropolitan_area_code, '_', '-')
  WHERE ma.metropolitan_area_code IN ('METRO_MANILA','METRO_CEBU','METRO_DAVAO')
), samples AS (
  SELECT members.*, sample_no,
         'SAMPLE-' || replace(metropolitan_area_code, '_', '-') || '-' || psgc_code || '-' || lpad(sample_no::text, 2, '0') AS site_code
  FROM members CROSS JOIN (VALUES (1),(2)) AS n(sample_no)
), prepared AS (
  SELECT (substr(md5('exitpass:i006:sample-site:' || site_code),1,8)||'-'||substr(md5('exitpass:i006:sample-site:' || site_code),9,4)||'-'||substr(md5('exitpass:i006:sample-site:' || site_code),13,4)||'-'||substr(md5('exitpass:i006:sample-site:' || site_code),17,4)||'-'||substr(md5('exitpass:i006:sample-site:' || site_code),21,12))::uuid AS site_id,
         site_group_id, jurisdiction_id, psgc_code, display_name, short_display_name, province_name, site_code, sample_no
  FROM samples
)
INSERT INTO sites.sites (site_id, site_group_id, site_code, site_name, site_description, site_type, timezone_name, address_line1, city, province, country_code, lgu_code, local_government_unit_id, site_status, public_lookup_enabled, payment_enabled, effective_from, created_by_service_identity_id, updated_by_service_identity_id)
SELECT site_id, site_group_id, site_code, 'Synthetic ' || short_display_name || ' Sample Site ' || sample_no, 'Disabled synthetic Site for I-006 jurisdiction coverage proof only. No real operator, address, POS, payment, fiscal, lane, or device configuration.', 'OPEN_LOT', 'Asia/Manila', 'Synthetic sample only - no real address', display_name, province_name, 'PH', psgc_code, jurisdiction_id, 'INACTIVE', false, false, '2026-07-28T00:00:00+08'::timestamptz, '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978', '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
FROM prepared
ON CONFLICT ON CONSTRAINT uq_sites__site_group_site_code DO UPDATE SET
  site_name = EXCLUDED.site_name,
  site_description = EXCLUDED.site_description,
  site_type = EXCLUDED.site_type,
  timezone_name = EXCLUDED.timezone_name,
  address_line1 = EXCLUDED.address_line1,
  city = EXCLUDED.city,
  province = EXCLUDED.province,
  country_code = EXCLUDED.country_code,
  lgu_code = EXCLUDED.lgu_code,
  local_government_unit_id = EXCLUDED.local_government_unit_id,
  site_status = 'INACTIVE',
  public_lookup_enabled = false,
  payment_enabled = false,
  updated_at = now(),
  updated_by_service_identity_id = EXCLUDED.updated_by_service_identity_id;

INSERT INTO sites.site_jurisdiction_assignments (site_jurisdiction_assignment_id, site_id, jurisdiction_id, assignment_status, effective_from, source_reference, approval_reference, created_by_service_identity_id, updated_by_service_identity_id)
SELECT (substr(md5('exitpass:i006:sample-site-jurisdiction:' || s.site_code),1,8)||'-'||substr(md5('exitpass:i006:sample-site-jurisdiction:' || s.site_code),9,4)||'-'||substr(md5('exitpass:i006:sample-site-jurisdiction:' || s.site_code),13,4)||'-'||substr(md5('exitpass:i006:sample-site-jurisdiction:' || s.site_code),17,4)||'-'||substr(md5('exitpass:i006:sample-site-jurisdiction:' || s.site_code),21,12))::uuid,
       s.site_id, s.local_government_unit_id, 'ACTIVE', '2026-07-28T00:00:00+08'::timestamptz, 'I-006 synthetic sample Site LGU assignment.', 'I-006 synthetic sample seed', '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978', '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
FROM sites.sites s
JOIN sites.site_groups sg ON sg.site_group_id = s.site_group_id
WHERE sg.site_group_code IN ('SAMPLE-METRO-MANILA','SAMPLE-METRO-CEBU','SAMPLE-METRO-DAVAO') AND s.local_government_unit_id IS NOT NULL
ON CONFLICT DO NOTHING;
