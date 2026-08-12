-- I-006 statutory parking research mapping seed.
-- Research-derived rows do not authorize production automation.
WITH lgu AS (
  SELECT jurisdiction_id, jurisdiction_code, psgc_code, display_name
  FROM sites.jurisdictions
  WHERE source_reference LIKE 'I-006 controlled PSGC LGU seed%'
), ent(entitlement_type, evidence_type, entitlement_label, suffix) AS (
  VALUES ('SENIOR_CITIZEN'::discounts.statutory_entitlement_type_enum, 'SENIOR_CITIZEN_ID'::discounts.discount_evidence_type_enum, 'Senior Citizen', 'SC'),
         ('PWD'::discounts.statutory_entitlement_type_enum, 'PWD_ID'::discounts.discount_evidence_type_enum, 'PWD', 'PWD')
), prepared AS (
  SELECT CASE
           WHEN lgu.psgc_code = '0731100000' AND ent.suffix = 'SC'
             THEN 'a216d952-6bf6-e518-c91c-08cbcb608e1c'::uuid
           WHEN lgu.psgc_code = '0731100000' AND ent.suffix = 'PWD'
             THEN '42c440a6-a93c-7ac5-e6e6-3096e41808fc'::uuid
           ELSE (substr(md5('exitpass:i006:policy:' || lgu.psgc_code || ':' || ent.suffix),1,8)||'-'||substr(md5('exitpass:i006:policy:' || lgu.psgc_code || ':' || ent.suffix),9,4)||'-'||substr(md5('exitpass:i006:policy:' || lgu.psgc_code || ':' || ent.suffix),13,4)||'-'||substr(md5('exitpass:i006:policy:' || lgu.psgc_code || ':' || ent.suffix),17,4)||'-'||substr(md5('exitpass:i006:policy:' || lgu.psgc_code || ':' || ent.suffix),21,12))::uuid
         END AS registry_id,
         ('I006_' || replace(lgu.psgc_code, '-', '_') || '_' || ent.suffix) AS policy_code,
         lgu.display_name || ' ' || ent.entitlement_label || ' statutory parking research mapping' AS policy_name,
         'No local parking rule found in current controlled research scan; not an absolute legal declaration.' AS policy_description,
         ent.entitlement_type, ent.evidence_type, lgu.jurisdiction_id, lgu.jurisdiction_code, lgu.display_name
  FROM lgu CROSS JOIN ent
)
INSERT INTO discounts.statutory_discount_policy_registry (
  statutory_discount_policy_registry_id, policy_code, policy_name, policy_description, entitlement_type, policy_status, verification_status,
  policy_level, policy_type, policy_resolution_basis, benefit_type, discount_base_scope, jurisdiction_id, local_government_unit_id,
  jurisdiction_code, jurisdiction_name, beneficiary_residency_scope, requires_evidence, required_evidence_type, requires_operator_validation,
  source_reference, source_scan_date, source_document_available, coverage_available, auto_application_allowed, effective_from,
  created_by_service_identity_id, updated_by_service_identity_id)
SELECT registry_id, policy_code, policy_name, policy_description, entitlement_type, 'DRAFT', 'NO_LOCAL_RULE_FOUND',
       'LOCAL_ORDINANCE', 'LOCAL_ORDINANCE', 'LOCAL_ORDINANCE_APPLIED', 'MANUAL_REVIEW', 'NOT_APPLICABLE', jurisdiction_id, jurisdiction_id,
       jurisdiction_code, display_name, 'NOT_APPLICABLE', false, NULL, false,
       'I-006 controlled research scan dated 2026-07-28. No local statutory parking measure identified in this scan.', '2026-07-28', NULL, false, false, '2026-07-28T00:00:00+08'::timestamptz,
       '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978', '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
FROM prepared
ON CONFLICT ON CONSTRAINT uq_sd_policy_registry__policy_code DO UPDATE SET
  policy_name = EXCLUDED.policy_name,
  policy_description = EXCLUDED.policy_description,
  policy_status = EXCLUDED.policy_status,
  verification_status = EXCLUDED.verification_status,
  jurisdiction_id = EXCLUDED.jurisdiction_id,
  local_government_unit_id = EXCLUDED.local_government_unit_id,
  jurisdiction_code = EXCLUDED.jurisdiction_code,
  jurisdiction_name = EXCLUDED.jurisdiction_name,
  beneficiary_residency_scope = EXCLUDED.beneficiary_residency_scope,
  requires_evidence = EXCLUDED.requires_evidence,
  required_evidence_type = EXCLUDED.required_evidence_type,
  source_reference = EXCLUDED.source_reference,
  source_scan_date = EXCLUDED.source_scan_date,
  source_document_available = EXCLUDED.source_document_available,
  coverage_available = EXCLUDED.coverage_available,
  auto_application_allowed = EXCLUDED.auto_application_allowed,
  updated_at = now(),
  updated_by_service_identity_id = EXCLUDED.updated_by_service_identity_id;

WITH override(psgc_code, entitlement_type, verification_status, coverage_available, ordinance_reference, benefit_type, residency_scope, free_duration_minutes, initial_rate_exempt, full_fee_exempt, overnight_excluded, valet_excluded, standalone_excluded, driver_passenger_required, source_document_available, policy_description, source_reference) AS (
  VALUES
  ('1381300000','SENIOR_CITIZEN','VERIFIED_SECONDARY',true,'SP-2472, S-2015 or related senior parking ordinance','LOCAL_RULE','UNVERIFIED',NULL,false,false,false,false,false,false,NULL,'Coverage identified; resident scope pending source review.','I-006 research scan 2026-07-28: Quezon City senior parking ordinance secondary reference.'),
  ('1381300000','PWD','VERIFIED_SECONDARY',true,'SP-3234, S-2023','LOCAL_RULE','RESIDENT_ONLY',NULL,false,false,false,false,false,false,NULL,'Coverage identified; city-government-owned parking scope appears limited.','I-006 research scan 2026-07-28: Quezon City PWD parking ordinance secondary reference.'),
  ('1380600000','SENIOR_CITIZEN','VERIFIED_SECONDARY',true,'Ordinance No. 8559, S-2019','INITIAL_RATE_EXEMPTION','NON_RESIDENT_ALLOWED',NULL,true,false,NULL,NULL,NULL,NULL,NULL,'Free initial parking rate; residency not clearly limited to residents.','I-006 research scan 2026-07-28: Manila Ordinance No. 8559 secondary reference.'),
  ('1380600000','PWD','VERIFIED_SECONDARY',true,'Ordinance No. 8559, S-2019','INITIAL_RATE_EXEMPTION','NON_RESIDENT_ALLOWED',NULL,true,false,NULL,NULL,NULL,NULL,NULL,'Free initial parking rate; overnight and driver/passenger conditions require source review.','I-006 research scan 2026-07-28: Manila Ordinance No. 8559 secondary reference.'),
  ('1380500000','SENIOR_CITIZEN','VERIFIED_SECONDARY',true,'Ordinance No. 726, S-2019 and Ordinance No. 738, S-2019','LOCAL_RULE','MIXED_OR_CONFLICTING',NULL,false,false,NULL,NULL,NULL,NULL,NULL,'Coverage identified; mixed residency interpretation requires source review.','I-006 research scan 2026-07-28: Mandaluyong senior parking secondary reference.'),
  ('1380200000','SENIOR_CITIZEN','VERIFIED_SECONDARY',true,'City Ordinance No. 1623-19, S-2019','FREE_DURATION','RESIDENT_ONLY',180,false,false,NULL,NULL,NULL,NULL,NULL,'Likely resident-only; commonly reported first three hours free.','I-006 research scan 2026-07-28: Las Piñas Ordinance No. 1623-19 secondary reference.'),
  ('1380200000','PWD','VERIFIED_SECONDARY',true,'City Ordinance No. 1623-19, S-2019','FREE_DURATION','RESIDENT_ONLY',180,false,false,NULL,NULL,NULL,NULL,NULL,'Likely resident-only; commonly reported first three hours free.','I-006 research scan 2026-07-28: Las Piñas Ordinance No. 1623-19 secondary reference.'),
  ('1380800000','SENIOR_CITIZEN','VERIFIED_SECONDARY',true,'Ordinance No. 17-050; amended by Ordinance Nos. 2022-022 and 2023-129','LOCAL_RULE','NON_RESIDENT_ALLOWED',NULL,false,false,true,NULL,NULL,true,NULL,'Valid IDs from any government agency appear accepted; exclusions require source review.','I-006 research scan 2026-07-28: Muntinlupa ordinance secondary reference.'),
  ('1380800000','PWD','VERIFIED_SECONDARY',true,'Ordinance No. 17-050; amended by Ordinance Nos. 2022-022 and 2023-129','LOCAL_RULE','NON_RESIDENT_ALLOWED',NULL,false,false,true,NULL,NULL,true,NULL,'Valid IDs from any government agency appear accepted; exclusions require source review.','I-006 research scan 2026-07-28: Muntinlupa ordinance secondary reference.'),
  ('1381000000','SENIOR_CITIZEN','VERIFIED_ACTIVE_OPERATIONAL',true,NULL,'FULL_FEE_EXEMPTION','RESIDENT_ONLY',NULL,false,true,NULL,NULL,NULL,NULL,false,'Coverage exists and is active in practice; ordinance number and official online text unavailable.','I-006 research scan 2026-07-28: Parañaque Senior Citizen verified active operational parking benefit.'),
  ('1381000000','PWD','VERIFIED_ACTIVE_OPERATIONAL',true,'City Ordinance No. 48','FULL_FEE_EXEMPTION','RESIDENT_ONLY',NULL,false,true,NULL,NULL,NULL,NULL,NULL,'Coverage verified and active; detailed facility scope still requires authoritative review.','I-006 research scan 2026-07-28: Parañaque PWD verified active operational parking benefit.'),
  ('1380700000','SENIOR_CITIZEN','LEAD_UNVERIFIED',true,'City Ordinance No. 028, S-2026','FREE_DURATION','RESIDENT_ONLY',120,false,false,NULL,NULL,NULL,NULL,NULL,'Reported two-hour free parking; lead remains unverified.','I-006 research scan 2026-07-28: Marikina senior parking lead.'),
  ('0730600000','SENIOR_CITIZEN','VERIFIED_SECONDARY',true,'City Ordinance No. 2326; City Ordinance No. 2711','FREE_DURATION','MIXED_OR_CONFLICTING',NULL,false,false,NULL,NULL,NULL,NULL,NULL,'Mixed residency and entitlement scope; commonly reported initial free-parking period.','I-006 research scan 2026-07-28: Cebu City ordinances secondary reference.'),
  ('0730600000','PWD','VERIFIED_SECONDARY',true,'City Ordinance No. 2326; City Ordinance No. 2711','FREE_DURATION','MIXED_OR_CONFLICTING',NULL,false,false,NULL,NULL,NULL,NULL,NULL,'Mixed residency and entitlement scope; commonly reported initial free-parking period.','I-006 research scan 2026-07-28: Cebu City ordinances secondary reference.'),
  ('0730220000','PWD','PROPOSED',false,'2025 proposed free-parking ordinance','FULL_FEE_EXEMPTION','UNVERIFIED',NULL,false,true,NULL,NULL,NULL,NULL,NULL,'Proposed PWD free-parking ordinance reported in 2025; not transaction-active.','I-006 research scan 2026-07-28: Mandaue PWD proposed measure.'),
  ('1123190000','SENIOR_CITIZEN','LEAD_UNVERIFIED',true,'City Ordinance No. 736, S-2016','LOCAL_RULE','UNVERIFIED',NULL,false,false,NULL,NULL,NULL,NULL,NULL,'Exact parking scope requires official source review.','I-006 research scan 2026-07-28: Tagum ordinance lead.'),
  ('1123190000','PWD','LEAD_UNVERIFIED',true,'City Ordinance No. 736, S-2016','LOCAL_RULE','UNVERIFIED',NULL,false,false,NULL,NULL,NULL,NULL,NULL,'Exact parking scope requires official source review.','I-006 research scan 2026-07-28: Tagum ordinance lead.'),
  ('0458020000','SENIOR_CITIZEN','LEAD_UNVERIFIED',true,'City Ordinance 2019-917 or City Ordinance No. 2023-1089','LOCAL_RULE','UNVERIFIED',NULL,false,false,NULL,NULL,NULL,NULL,NULL,'Local measure reported; ordinance mapping requires official review.','I-006 research scan 2026-07-28: Antipolo lead.'),
  ('0458020000','PWD','LEAD_UNVERIFIED',true,'City Ordinance 2019-917 or City Ordinance No. 2023-1089','LOCAL_RULE','UNVERIFIED',NULL,false,false,NULL,NULL,NULL,NULL,NULL,'Local measure reported; ordinance mapping requires official review.','I-006 research scan 2026-07-28: Antipolo lead.'),
  ('0458130000','SENIOR_CITIZEN','LEAD_UNVERIFIED',true,NULL,'FULL_FEE_EXEMPTION','UNVERIFIED',NULL,false,true,NULL,NULL,NULL,NULL,NULL,'Local free-parking measure reported; ordinance number not verified.','I-006 research scan 2026-07-28: Taytay lead.'),
  ('0458130000','PWD','LEAD_UNVERIFIED',true,NULL,'FULL_FEE_EXEMPTION','UNVERIFIED',NULL,false,true,NULL,NULL,NULL,NULL,NULL,'Local free-parking measure reported; ordinance number not verified.','I-006 research scan 2026-07-28: Taytay lead.'),
  ('0314120000','SENIOR_CITIZEN','LEAD_UNVERIFIED',true,'Municipal Ordinance No. 1085-2026','LOCAL_RULE','UNVERIFIED',NULL,false,false,NULL,NULL,NULL,NULL,NULL,'Source text requires review.','I-006 research scan 2026-07-28: Marilao lead.'),
  ('0314120000','PWD','LEAD_UNVERIFIED',true,'Municipal Ordinance No. 1085-2026','LOCAL_RULE','UNVERIFIED',NULL,false,false,NULL,NULL,NULL,NULL,NULL,'Source text requires review.','I-006 research scan 2026-07-28: Marilao lead.'),
  ('0314100000','SENIOR_CITIZEN','LEAD_UNVERIFIED',false,'Robinsons Place Malolos related measure','LOCAL_RULE','UNVERIFIED',NULL,false,false,NULL,NULL,NULL,NULL,NULL,'Facility-limited scope; not seeded as citywide coverage.','I-006 research scan 2026-07-28: Malolos limited-scope lead.'),
  ('0314100000','PWD','LEAD_UNVERIFIED',false,'Robinsons Place Malolos related measure','LOCAL_RULE','UNVERIFIED',NULL,false,false,NULL,NULL,NULL,NULL,NULL,'Facility-limited scope; not seeded as citywide coverage.','I-006 research scan 2026-07-28: Malolos limited-scope lead.'),
  ('0434280000','SENIOR_CITIZEN','VERIFIED_SECONDARY',true,'City Ordinance No. 2202, S-2023','LOCAL_RULE','NON_RESIDENT_ALLOWED',NULL,false,false,true,true,true,NULL,NULL,'Reported to include non-residents and visitors; exclusions require official review.','I-006 research scan 2026-07-28: Santa Rosa ordinance secondary reference.'),
  ('0434280000','PWD','VERIFIED_SECONDARY',true,'City Ordinance No. 2202, S-2023','LOCAL_RULE','NON_RESIDENT_ALLOWED',NULL,false,false,true,true,true,NULL,NULL,'Reported to include non-residents and visitors; exclusions require official review.','I-006 research scan 2026-07-28: Santa Rosa ordinance secondary reference.')
), keyed AS (
  SELECT 'I006_' || o.psgc_code || '_' || CASE WHEN o.entitlement_type = 'SENIOR_CITIZEN' THEN 'SC' ELSE 'PWD' END AS policy_code, o.*
  FROM override o
)
UPDATE discounts.statutory_discount_policy_registry r
SET policy_description = keyed.policy_description,
    verification_status = keyed.verification_status::discounts.policy_verification_status_enum,
    coverage_available = keyed.coverage_available,
    ordinance_reference = keyed.ordinance_reference,
    legal_basis_reference = keyed.ordinance_reference,
    benefit_type = keyed.benefit_type::discounts.parking_benefit_type_enum,
    beneficiary_residency_scope = keyed.residency_scope::discounts.beneficiary_residency_scope_enum,
    free_duration_minutes = keyed.free_duration_minutes,
    initial_rate_exempt = keyed.initial_rate_exempt,
    full_fee_exempt = keyed.full_fee_exempt,
    overnight_excluded = COALESCE(keyed.overnight_excluded, false),
    valet_excluded = COALESCE(keyed.valet_excluded, false),
    standalone_parking_excluded = COALESCE(keyed.standalone_excluded, false),
    driver_or_passenger_required = COALESCE(keyed.driver_passenger_required, false),
    requires_evidence = keyed.coverage_available,
    required_evidence_type = CASE WHEN keyed.coverage_available AND keyed.entitlement_type = 'SENIOR_CITIZEN' THEN 'SENIOR_CITIZEN_ID'::discounts.discount_evidence_type_enum WHEN keyed.coverage_available THEN 'PWD_ID'::discounts.discount_evidence_type_enum ELSE NULL END,
    requires_operator_validation = keyed.coverage_available,
    source_reference = keyed.source_reference,
    source_document_available = keyed.source_document_available,
    reviewed_by = 'I-006 controlled research scan',
    reviewed_at = '2026-07-28T00:00:00+08'::timestamptz,
    updated_at = now(),
    updated_by_service_identity_id = '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
FROM keyed
WHERE r.policy_code = keyed.policy_code;

INSERT INTO discounts.statutory_discount_policy_registry_lgu_scopes (statutory_discount_policy_registry_lgu_scope_id, statutory_discount_policy_registry_id, local_government_unit_id, coverage_available, auto_application_allowed, source_scan_date, source_reference, scope_status, created_by_service_identity_id, updated_by_service_identity_id)
SELECT CASE
         WHEN r.policy_code = 'I006_0731100000_SC' THEN 'c336d25f-e95d-bb35-6c79-42b7f4b68e19'::uuid
         WHEN r.policy_code = 'I006_0731100000_PWD' THEN '11e203f6-6a63-0174-086d-d2d6ce0b7e8a'::uuid
         ELSE (substr(md5('exitpass:i006:policy-lgu-scope:' || r.policy_code),1,8)||'-'||substr(md5('exitpass:i006:policy-lgu-scope:' || r.policy_code),9,4)||'-'||substr(md5('exitpass:i006:policy-lgu-scope:' || r.policy_code),13,4)||'-'||substr(md5('exitpass:i006:policy-lgu-scope:' || r.policy_code),17,4)||'-'||substr(md5('exitpass:i006:policy-lgu-scope:' || r.policy_code),21,12))::uuid
       END,
       r.statutory_discount_policy_registry_id, r.local_government_unit_id, r.coverage_available, false, '2026-07-28', r.source_reference, 'DRAFT', '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978', '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
FROM discounts.statutory_discount_policy_registry r
WHERE r.policy_code LIKE 'I006_%' AND r.local_government_unit_id IS NOT NULL
ON CONFLICT ON CONSTRAINT uq_sd_policy_registry_lgu_scopes__registry_lgu DO UPDATE SET
  coverage_available = EXCLUDED.coverage_available,
  auto_application_allowed = false,
  source_scan_date = EXCLUDED.source_scan_date,
  source_reference = EXCLUDED.source_reference,
  scope_status = 'DRAFT',
  updated_at = now(),
  updated_by_service_identity_id = EXCLUDED.updated_by_service_identity_id;
