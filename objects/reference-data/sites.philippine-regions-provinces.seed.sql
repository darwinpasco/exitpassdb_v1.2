-- I-006 canonical Philippine region and province seed.
WITH seed(seed_key, psgc_code, correspondence_code, region_code, official_name, short_name) AS (
  VALUES
  ('NCR','1300000000',NULL,'NCR','National Capital Region','NCR'),
  ('REGION_III','0300000000',NULL,'REGION_III','Region III (Central Luzon)','Central Luzon'),
  ('REGION_IV_A','0400000000',NULL,'REGION_IV_A','Region IV-A (CALABARZON)','CALABARZON'),
  ('REGION_VII','0700000000',NULL,'REGION_VII','Region VII (Central Visayas)','Central Visayas'),
  ('REGION_XI','1100000000',NULL,'REGION_XI','Region XI (Davao Region)','Davao Region')
), prepared AS (
  SELECT (substr(md5('exitpass:i006:region:' || seed_key),1,8)||'-'||substr(md5('exitpass:i006:region:' || seed_key),9,4)||'-'||substr(md5('exitpass:i006:region:' || seed_key),13,4)||'-'||substr(md5('exitpass:i006:region:' || seed_key),17,4)||'-'||substr(md5('exitpass:i006:region:' || seed_key),21,12))::uuid AS philippine_region_id,
         psgc_code, correspondence_code, region_code, official_name, short_name
  FROM seed
)
INSERT INTO sites.philippine_regions (philippine_region_id, psgc_code, correspondence_code, region_code, official_name, short_name, region_status, effective_from, source_reference, created_by_service_identity_id, updated_by_service_identity_id)
SELECT philippine_region_id, psgc_code, correspondence_code, region_code, official_name, short_name, 'ACTIVE', '2026-07-28T00:00:00+08'::timestamptz, 'I-006 controlled PSGC reference seed; validate against current PSA PSGC before production use.', '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978', '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
FROM prepared
ON CONFLICT ON CONSTRAINT uq_philippine_regions__psgc_code DO UPDATE SET
  correspondence_code = EXCLUDED.correspondence_code,
  region_code = EXCLUDED.region_code,
  official_name = EXCLUDED.official_name,
  short_name = EXCLUDED.short_name,
  source_reference = EXCLUDED.source_reference,
  updated_at = now(),
  updated_by_service_identity_id = EXCLUDED.updated_by_service_identity_id;

WITH seed(seed_key, region_code, psgc_code, correspondence_code, province_code, official_name) AS (
  VALUES
  ('BULACAN','REGION_III','0314000000',NULL,'BULACAN','Bulacan'),
  ('RIZAL','REGION_IV_A','0458000000',NULL,'RIZAL','Rizal'),
  ('LAGUNA','REGION_IV_A','0434000000',NULL,'LAGUNA','Laguna'),
  ('CEBU','REGION_VII','0722000000',NULL,'CEBU','Cebu'),
  ('DAVAO_DEL_NORTE','REGION_XI','1123000000',NULL,'DAVAO_DEL_NORTE','Davao del Norte'),
  ('DAVAO_DEL_SUR','REGION_XI','1124000000',NULL,'DAVAO_DEL_SUR','Davao del Sur'),
  ('DAVAO_ORIENTAL','REGION_XI','1125000000',NULL,'DAVAO_ORIENTAL','Davao Oriental'),
  ('DAVAO_DE_ORO','REGION_XI','1182000000',NULL,'DAVAO_DE_ORO','Davao de Oro'),
  ('DAVAO_OCCIDENTAL','REGION_XI','1186000000',NULL,'DAVAO_OCCIDENTAL','Davao Occidental')
), prepared AS (
  SELECT (substr(md5('exitpass:i006:province:' || seed_key),1,8)||'-'||substr(md5('exitpass:i006:province:' || seed_key),9,4)||'-'||substr(md5('exitpass:i006:province:' || seed_key),13,4)||'-'||substr(md5('exitpass:i006:province:' || seed_key),17,4)||'-'||substr(md5('exitpass:i006:province:' || seed_key),21,12))::uuid AS philippine_province_id,
         r.philippine_region_id, s.psgc_code, s.correspondence_code, s.province_code, s.official_name
  FROM seed s
  JOIN sites.philippine_regions r ON r.region_code = s.region_code
)
INSERT INTO sites.philippine_provinces (philippine_province_id, philippine_region_id, psgc_code, correspondence_code, province_code, official_name, province_status, effective_from, source_reference, created_by_service_identity_id, updated_by_service_identity_id)
SELECT philippine_province_id, philippine_region_id, psgc_code, correspondence_code, province_code, official_name, 'ACTIVE', '2026-07-28T00:00:00+08'::timestamptz, 'I-006 controlled PSGC reference seed; Metro Manila is intentionally not a province.', '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978', '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
FROM prepared
ON CONFLICT ON CONSTRAINT uq_philippine_provinces__psgc_code DO UPDATE SET
  philippine_region_id = EXCLUDED.philippine_region_id,
  correspondence_code = EXCLUDED.correspondence_code,
  province_code = EXCLUDED.province_code,
  official_name = EXCLUDED.official_name,
  source_reference = EXCLUDED.source_reference,
  updated_at = now(),
  updated_by_service_identity_id = EXCLUDED.updated_by_service_identity_id;