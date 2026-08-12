-- I-006 metropolitan-area and LGU membership seed.
WITH seed(seed_key, area_code, area_name, description, source_reference) AS (
  VALUES
  ('METRO_MANILA','METRO_MANILA','Metro Manila','National Capital Region metropolitan area containing the 16 cities and Municipality of Pateros.','I-006 controlled metropolitan reference seed; NCR LGUs from PSGC.'),
  ('METRO_CEBU','METRO_CEBU','Expanded Metro Cebu','Controlled Expanded Metro Cebu membership for statutory coverage sample scope.','I-006 controlled metropolitan reference seed.'),
  ('METRO_DAVAO','METRO_DAVAO','Metropolitan Davao','Metropolitan Davao membership under Republic Act No. 11708.','Republic Act No. 11708; I-006 controlled seed.')
), prepared AS (
  SELECT (substr(md5('exitpass:i006:metro:' || seed_key),1,8)||'-'||substr(md5('exitpass:i006:metro:' || seed_key),9,4)||'-'||substr(md5('exitpass:i006:metro:' || seed_key),13,4)||'-'||substr(md5('exitpass:i006:metro:' || seed_key),17,4)||'-'||substr(md5('exitpass:i006:metro:' || seed_key),21,12))::uuid AS metropolitan_area_id,
         area_code, area_name, description, source_reference
  FROM seed
)
INSERT INTO sites.metropolitan_areas (metropolitan_area_id, metropolitan_area_code, metropolitan_area_name, description, source_reference, metropolitan_area_status, effective_from, created_by_service_identity_id, updated_by_service_identity_id)
SELECT metropolitan_area_id, area_code, area_name, description, source_reference, 'ACTIVE', '2026-07-28T00:00:00+08'::timestamptz, '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978', '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
FROM prepared
ON CONFLICT ON CONSTRAINT uq_metropolitan_areas__code DO UPDATE SET
  metropolitan_area_name = EXCLUDED.metropolitan_area_name,
  description = EXCLUDED.description,
  source_reference = EXCLUDED.source_reference,
  updated_at = now(),
  updated_by_service_identity_id = EXCLUDED.updated_by_service_identity_id;

WITH seed(area_code, jurisdiction_code, membership_classification) AS (
  VALUES
  ('METRO_MANILA','PH-PSGC-1380100000','NCR_LGU'),('METRO_MANILA','PH-PSGC-1380200000','NCR_LGU'),('METRO_MANILA','PH-PSGC-1380300000','NCR_LGU'),('METRO_MANILA','PH-PSGC-1380400000','NCR_LGU'),('METRO_MANILA','PH-PSGC-1380500000','NCR_LGU'),('METRO_MANILA','PH-PSGC-1380600000','NCR_LGU'),('METRO_MANILA','PH-PSGC-1380700000','NCR_LGU'),('METRO_MANILA','PH-PSGC-1380800000','NCR_LGU'),('METRO_MANILA','PH-PSGC-1380900000','NCR_LGU'),('METRO_MANILA','PH-PSGC-1381000000','NCR_LGU'),('METRO_MANILA','PH-PSGC-1381100000','NCR_LGU'),('METRO_MANILA','PH-PSGC-1381200000','NCR_LGU'),('METRO_MANILA','PH-PSGC-1381300000','NCR_LGU'),('METRO_MANILA','PH-PSGC-1381400000','NCR_LGU'),('METRO_MANILA','PH-PSGC-1381500000','NCR_LGU'),('METRO_MANILA','PH-PSGC-1381600000','NCR_LGU'),('METRO_MANILA','PH-PSGC-1381700000','NCR_LGU'),
  ('METRO_CEBU','PH-PSGC-0722140000','EXPANDED_METRO_CEBU_LGU'),('METRO_CEBU','PH-PSGC-0730600000','EXPANDED_METRO_CEBU_LGU'),('METRO_CEBU','PH-PSGC-0722170000','EXPANDED_METRO_CEBU_LGU'),('METRO_CEBU','PH-PSGC-0731100000','EXPANDED_METRO_CEBU_LGU'),('METRO_CEBU','PH-PSGC-0730220000','EXPANDED_METRO_CEBU_LGU'),('METRO_CEBU','PH-PSGC-0722340000','EXPANDED_METRO_CEBU_LGU'),('METRO_CEBU','PH-PSGC-0722500000','EXPANDED_METRO_CEBU_LGU'),('METRO_CEBU','PH-PSGC-0722180000','EXPANDED_METRO_CEBU_LGU'),('METRO_CEBU','PH-PSGC-0722190000','EXPANDED_METRO_CEBU_LGU'),('METRO_CEBU','PH-PSGC-0722220000','EXPANDED_METRO_CEBU_LGU'),('METRO_CEBU','PH-PSGC-0722270000','EXPANDED_METRO_CEBU_LGU'),('METRO_CEBU','PH-PSGC-0722310000','EXPANDED_METRO_CEBU_LGU'),('METRO_CEBU','PH-PSGC-0722410000','EXPANDED_METRO_CEBU_LGU'),
  ('METRO_DAVAO','PH-PSGC-1130700000','RA_11708_LGU'),('METRO_DAVAO','PH-PSGC-1123150000','RA_11708_LGU'),('METRO_DAVAO','PH-PSGC-1123190000','RA_11708_LGU'),('METRO_DAVAO','PH-PSGC-1123170000','RA_11708_LGU'),('METRO_DAVAO','PH-PSGC-1124030000','RA_11708_LGU'),('METRO_DAVAO','PH-PSGC-1125090000','RA_11708_LGU'),('METRO_DAVAO','PH-PSGC-1124110000','RA_11708_LGU'),('METRO_DAVAO','PH-PSGC-1124040000','RA_11708_LGU'),('METRO_DAVAO','PH-PSGC-1124070000','RA_11708_LGU'),('METRO_DAVAO','PH-PSGC-1124060000','RA_11708_LGU'),('METRO_DAVAO','PH-PSGC-1124140000','RA_11708_LGU'),('METRO_DAVAO','PH-PSGC-1123030000','RA_11708_LGU'),('METRO_DAVAO','PH-PSGC-1182040000','RA_11708_LGU'),('METRO_DAVAO','PH-PSGC-1186030000','RA_11708_LGU'),('METRO_DAVAO','PH-PSGC-1186040000','RA_11708_LGU')
), prepared AS (
  SELECT CASE
           WHEN seed.area_code = 'METRO_CEBU' AND seed.jurisdiction_code = 'PH-PSGC-0731100000'
             THEN 'fb97785d-eed4-39b4-eb89-52bb20265fdd'::uuid
           ELSE (substr(md5('exitpass:i006:metro-member:' || seed.area_code || ':' || seed.jurisdiction_code),1,8)||'-'||substr(md5('exitpass:i006:metro-member:' || seed.area_code || ':' || seed.jurisdiction_code),9,4)||'-'||substr(md5('exitpass:i006:metro-member:' || seed.area_code || ':' || seed.jurisdiction_code),13,4)||'-'||substr(md5('exitpass:i006:metro-member:' || seed.area_code || ':' || seed.jurisdiction_code),17,4)||'-'||substr(md5('exitpass:i006:metro-member:' || seed.area_code || ':' || seed.jurisdiction_code),21,12))::uuid
         END AS metropolitan_area_jurisdiction_id,
         ma.metropolitan_area_id, j.jurisdiction_id, seed.membership_classification
  FROM seed
  JOIN sites.metropolitan_areas ma ON ma.metropolitan_area_code = seed.area_code
  JOIN sites.jurisdictions j ON j.jurisdiction_code = seed.jurisdiction_code
)
INSERT INTO sites.metropolitan_area_jurisdictions (metropolitan_area_jurisdiction_id, metropolitan_area_id, jurisdiction_id, membership_classification, source_reference, membership_status, effective_from, created_by_service_identity_id, updated_by_service_identity_id)
SELECT metropolitan_area_jurisdiction_id, metropolitan_area_id, jurisdiction_id, membership_classification, 'I-006 controlled metropolitan membership seed.', 'ACTIVE', '2026-07-28T00:00:00+08'::timestamptz, '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978', '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
FROM prepared
ON CONFLICT DO NOTHING;
