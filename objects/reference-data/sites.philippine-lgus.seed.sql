-- I-006 canonical Philippine city and municipality LGU seed.
WITH seed(seed_key, region_code, province_code, psgc_code, jurisdiction_code, official_name, short_display_name, jurisdiction_type, city_classification) AS (
  VALUES
  ('CALOOCAN','NCR',NULL,'1380100000','PH-PSGC-1380100000','City of Caloocan','Caloocan','CITY','HIGHLY_URBANIZED'),
  ('LAS_PINAS','NCR',NULL,'1380200000','PH-PSGC-1380200000','City of Las Piñas','Las Piñas','CITY','HIGHLY_URBANIZED'),
  ('MAKATI','NCR',NULL,'1380300000','PH-PSGC-1380300000','City of Makati','Makati','CITY','HIGHLY_URBANIZED'),
  ('MALABON','NCR',NULL,'1380400000','PH-PSGC-1380400000','City of Malabon','Malabon','CITY','HIGHLY_URBANIZED'),
  ('MANDALUYONG','NCR',NULL,'1380500000','PH-PSGC-1380500000','City of Mandaluyong','Mandaluyong','CITY','HIGHLY_URBANIZED'),
  ('MANILA','NCR',NULL,'1380600000','PH-PSGC-1380600000','City of Manila','Manila','CITY','HIGHLY_URBANIZED'),
  ('MARIKINA','NCR',NULL,'1380700000','PH-PSGC-1380700000','City of Marikina','Marikina','CITY','HIGHLY_URBANIZED'),
  ('MUNTINLUPA','NCR',NULL,'1380800000','PH-PSGC-1380800000','City of Muntinlupa','Muntinlupa','CITY','HIGHLY_URBANIZED'),
  ('NAVOTAS','NCR',NULL,'1380900000','PH-PSGC-1380900000','City of Navotas','Navotas','CITY','HIGHLY_URBANIZED'),
  ('PARANAQUE','NCR',NULL,'1381000000','PH-PSGC-1381000000','City of Parañaque','Parañaque','CITY','HIGHLY_URBANIZED'),
  ('PASAY','NCR',NULL,'1381100000','PH-PSGC-1381100000','Pasay City','Pasay','CITY','HIGHLY_URBANIZED'),
  ('PASIG','NCR',NULL,'1381200000','PH-PSGC-1381200000','City of Pasig','Pasig','CITY','HIGHLY_URBANIZED'),
  ('QUEZON_CITY','NCR',NULL,'1381300000','PH-PSGC-1381300000','Quezon City','Quezon City','CITY','HIGHLY_URBANIZED'),
  ('SAN_JUAN','NCR',NULL,'1381400000','PH-PSGC-1381400000','City of San Juan','San Juan','CITY','HIGHLY_URBANIZED'),
  ('TAGUIG','NCR',NULL,'1381500000','PH-PSGC-1381500000','City of Taguig','Taguig','CITY','HIGHLY_URBANIZED'),
  ('VALENZUELA','NCR',NULL,'1381600000','PH-PSGC-1381600000','City of Valenzuela','Valenzuela','CITY','HIGHLY_URBANIZED'),
  ('PATEROS','NCR',NULL,'1381700000','PH-PSGC-1381700000','Municipality of Pateros','Pateros','MUNICIPALITY',NULL),
  ('CARCAR','REGION_VII','CEBU','0722140000','PH-PSGC-0722140000','City of Carcar','Carcar','CITY','COMPONENT'),
  ('CEBU_CITY','REGION_VII',NULL,'0730600000','PH-PSGC-0730600000','City of Cebu','Cebu City','CITY','HIGHLY_URBANIZED'),
  ('DANAO','REGION_VII','CEBU','0722170000','PH-PSGC-0722170000','City of Danao','Danao','CITY','COMPONENT'),
  ('LAPU_LAPU','REGION_VII',NULL,'0731100000','PH-PSGC-0731100000','City of Lapu-Lapu','Lapu-Lapu','CITY','HIGHLY_URBANIZED'),
  ('MANDAUE','REGION_VII',NULL,'0730220000','PH-PSGC-0730220000','City of Mandaue','Mandaue','CITY','HIGHLY_URBANIZED'),
  ('NAGA_CEBU','REGION_VII','CEBU','0722340000','PH-PSGC-0722340000','City of Naga','Naga','CITY','COMPONENT'),
  ('TALISAY_CEBU','REGION_VII','CEBU','0722500000','PH-PSGC-0722500000','City of Talisay','Talisay','CITY','COMPONENT'),
  ('COMPOSTELA_CEBU','REGION_VII','CEBU','0722180000','PH-PSGC-0722180000','Municipality of Compostela','Compostela','MUNICIPALITY',NULL),
  ('CONSOLACION','REGION_VII','CEBU','0722190000','PH-PSGC-0722190000','Municipality of Consolacion','Consolacion','MUNICIPALITY',NULL),
  ('CORDOVA','REGION_VII','CEBU','0722220000','PH-PSGC-0722220000','Municipality of Cordova','Cordova','MUNICIPALITY',NULL),
  ('LILOAN','REGION_VII','CEBU','0722270000','PH-PSGC-0722270000','Municipality of Liloan','Liloan','MUNICIPALITY',NULL),
  ('MINGLANILLA','REGION_VII','CEBU','0722310000','PH-PSGC-0722310000','Municipality of Minglanilla','Minglanilla','MUNICIPALITY',NULL),
  ('SAN_FERNANDO_CEBU','REGION_VII','CEBU','0722410000','PH-PSGC-0722410000','Municipality of San Fernando','San Fernando','MUNICIPALITY',NULL),
  ('DAVAO_CITY','REGION_XI',NULL,'1130700000','PH-PSGC-1130700000','Davao City','Davao City','CITY','HIGHLY_URBANIZED'),
  ('PANABO','REGION_XI','DAVAO_DEL_NORTE','1123150000','PH-PSGC-1123150000','City of Panabo','Panabo','CITY','COMPONENT'),
  ('TAGUM','REGION_XI','DAVAO_DEL_NORTE','1123190000','PH-PSGC-1123190000','City of Tagum','Tagum','CITY','COMPONENT'),
  ('SAMAL','REGION_XI','DAVAO_DEL_NORTE','1123170000','PH-PSGC-1123170000','Island Garden City of Samal','Samal','CITY','COMPONENT'),
  ('DIGOS','REGION_XI','DAVAO_DEL_SUR','1124030000','PH-PSGC-1124030000','City of Digos','Digos','CITY','COMPONENT'),
  ('MATI','REGION_XI','DAVAO_ORIENTAL','1125090000','PH-PSGC-1125090000','City of Mati','Mati','CITY','COMPONENT'),
  ('SANTA_CRUZ_DAVAO_SUR','REGION_XI','DAVAO_DEL_SUR','1124110000','PH-PSGC-1124110000','Municipality of Santa Cruz','Santa Cruz','MUNICIPALITY',NULL),
  ('HAGONOY_DAVAO_SUR','REGION_XI','DAVAO_DEL_SUR','1124040000','PH-PSGC-1124040000','Municipality of Hagonoy','Hagonoy','MUNICIPALITY',NULL),
  ('PADADA','REGION_XI','DAVAO_DEL_SUR','1124070000','PH-PSGC-1124070000','Municipality of Padada','Padada','MUNICIPALITY',NULL),
  ('MALALAG','REGION_XI','DAVAO_DEL_SUR','1124060000','PH-PSGC-1124060000','Municipality of Malalag','Malalag','MUNICIPALITY',NULL),
  ('SULOP','REGION_XI','DAVAO_DEL_SUR','1124140000','PH-PSGC-1124140000','Municipality of Sulop','Sulop','MUNICIPALITY',NULL),
  ('CARMEN_DAVAO_NORTE','REGION_XI','DAVAO_DEL_NORTE','1123030000','PH-PSGC-1123030000','Municipality of Carmen','Carmen','MUNICIPALITY',NULL),
  ('MACO','REGION_XI','DAVAO_DE_ORO','1182040000','PH-PSGC-1182040000','Municipality of Maco','Maco','MUNICIPALITY',NULL),
  ('MALITA','REGION_XI','DAVAO_OCCIDENTAL','1186030000','PH-PSGC-1186030000','Municipality of Malita','Malita','MUNICIPALITY',NULL),
  ('SANTA_MARIA_DAVAO_OCC','REGION_XI','DAVAO_OCCIDENTAL','1186040000','PH-PSGC-1186040000','Municipality of Santa Maria','Santa Maria','MUNICIPALITY',NULL),
  ('ANTIPOLO','REGION_IV_A','RIZAL','0458020000','PH-PSGC-0458020000','City of Antipolo','Antipolo','CITY','COMPONENT'),
  ('TAYTAY_RIZAL','REGION_IV_A','RIZAL','0458130000','PH-PSGC-0458130000','Municipality of Taytay','Taytay','MUNICIPALITY',NULL),
  ('MALOLOS','REGION_III','BULACAN','0314100000','PH-PSGC-0314100000','City of Malolos','Malolos','CITY','COMPONENT'),
  ('MARILAO','REGION_III','BULACAN','0314120000','PH-PSGC-0314120000','Municipality of Marilao','Marilao','MUNICIPALITY',NULL),
  ('SANTA_ROSA_LAGUNA','REGION_IV_A','LAGUNA','0434280000','PH-PSGC-0434280000','City of Santa Rosa','Santa Rosa','CITY','COMPONENT')
), prepared AS (
  SELECT (substr(md5('exitpass:i006:lgu:' || seed_key),1,8)||'-'||substr(md5('exitpass:i006:lgu:' || seed_key),9,4)||'-'||substr(md5('exitpass:i006:lgu:' || seed_key),13,4)||'-'||substr(md5('exitpass:i006:lgu:' || seed_key),17,4)||'-'||substr(md5('exitpass:i006:lgu:' || seed_key),21,12))::uuid AS jurisdiction_id,
         r.philippine_region_id,
         p.philippine_province_id,
         seed.psgc_code,
         CASE WHEN seed.seed_key = 'LAPU_LAPU' THEN '072226000' ELSE NULL END AS correspondence_code,
         seed.jurisdiction_code,
         seed.official_name,
         seed.short_display_name,
         seed.jurisdiction_type::sites.jurisdiction_type_enum AS jurisdiction_type,
         seed.city_classification::sites.city_classification_enum AS city_classification,
         r.official_name AS region_name,
         p.official_name AS province_name,
         CASE WHEN seed.seed_key = 'LAPU_LAPU'
              THEN 'I-006 controlled PSGC LGU seed; PSA PSGC as of 30 June 2026, accessed 2026-08-12.'
              ELSE 'I-006 controlled PSGC LGU seed; validate against current PSA PSGC before production use.'
         END AS source_reference,
         CASE WHEN seed.seed_key = 'LAPU_LAPU'
              THEN 'Canonical City of Lapu-Lapu identity corrected to current PSA PSGC 0731100000; correspondence code 072226000 is stored separately. Independent HUC province_id remains null.'
              ELSE 'Canonical LGU seed for statutory parking jurisdiction coverage. NCR and independent HUCs have null province_id.'
         END AS source_provenance
  FROM seed
  JOIN sites.philippine_regions r ON r.region_code = seed.region_code
  LEFT JOIN sites.philippine_provinces p ON p.province_code = seed.province_code
)
INSERT INTO sites.jurisdictions (jurisdiction_id, jurisdiction_code, jurisdiction_type, philippine_region_id, philippine_province_id, short_display_name, city_classification, display_name, province_name, region_name, country_code, psgc_code, correspondence_code, jurisdiction_status, effective_from, source_reference, source_provenance, created_by_service_identity_id, updated_by_service_identity_id)
SELECT jurisdiction_id, jurisdiction_code, jurisdiction_type, philippine_region_id, philippine_province_id, short_display_name, city_classification, official_name, province_name, region_name, 'PH', psgc_code, correspondence_code, 'ACTIVE', '2026-07-28T00:00:00+08'::timestamptz, source_reference, source_provenance, '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978', '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
FROM prepared
ON CONFLICT ON CONSTRAINT uq_jurisdictions__code DO UPDATE SET
  jurisdiction_type = EXCLUDED.jurisdiction_type,
  philippine_region_id = EXCLUDED.philippine_region_id,
  philippine_province_id = EXCLUDED.philippine_province_id,
  short_display_name = EXCLUDED.short_display_name,
  city_classification = EXCLUDED.city_classification,
  display_name = EXCLUDED.display_name,
  province_name = EXCLUDED.province_name,
  region_name = EXCLUDED.region_name,
  psgc_code = EXCLUDED.psgc_code,
  correspondence_code = COALESCE(EXCLUDED.correspondence_code, sites.jurisdictions.correspondence_code),
  source_reference = EXCLUDED.source_reference,
  source_provenance = EXCLUDED.source_provenance,
  updated_at = now(),
  updated_by_service_identity_id = EXCLUDED.updated_by_service_identity_id;
