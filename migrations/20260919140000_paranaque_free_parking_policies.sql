-- Canonical transaction-active City of Paranaque statutory free-parking policies.
-- The controlled source establishes operational use, not VERIFIED_OFFICIAL status.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM sites.jurisdictions
    WHERE jurisdiction_id = 'f7a1b4b9-17a9-89de-5059-f72779616f23'::uuid
      AND display_name = 'City of Parañaque'
      AND psgc_code = '1381000000'
  ) THEN
    RAISE EXCEPTION 'Canonical City of Paranaque jurisdiction is missing or inconsistent.';
  END IF;
END $$;

WITH policy AS (
  SELECT *
  FROM (VALUES
    (
      '0afacef1-5dd5-009d-32dd-e93a2ea8e4bb'::uuid,
      'PH_PARANAQUE_SENIOR_FREE_PARKING',
      'Parañaque Senior Citizen Free Parking',
      'SENIOR_CITIZEN'::discounts.statutory_entitlement_type_enum,
      'SENIOR_CITIZEN_ID'::discounts.discount_evidence_type_enum,
      NULL::varchar,
      'I-006 controlled research scan 2026-07-28: Parañaque Senior Citizen verified active operational parking benefit; ordinance number and controlled official text are not retained.'
    ),
    (
      'd08bee33-972d-8214-c409-6e0ffef264d5'::uuid,
      'PH_PARANAQUE_PWD_FREE_PARKING',
      'Parañaque PWD Free Parking',
      'PWD'::discounts.statutory_entitlement_type_enum,
      'PWD_ID'::discounts.discount_evidence_type_enum,
      'City Ordinance No. 48'::varchar,
      'I-006 controlled research scan 2026-07-28: Parañaque PWD verified active operational parking benefit; City Ordinance No. 48 is retained as the authority reference, without a controlled full ordinance source.'
    )
  ) AS v(registry_id, policy_code, policy_name, entitlement_type, evidence_type, authority_reference, source_reference)
)
INSERT INTO discounts.statutory_discount_policy_registry (
  statutory_discount_policy_registry_id, policy_code, policy_name, policy_description,
  entitlement_type, policy_status, verification_status, policy_level, policy_type,
  policy_resolution_basis, benefit_type, discount_base_scope, jurisdiction_id,
  local_government_unit_id, jurisdiction_code, jurisdiction_name, beneficiary_residency_scope,
  facility_scope, free_duration_minutes, initial_rate_exempt, full_fee_exempt,
  coverage_available, auto_application_allowed, source_scan_date, source_document_available,
  requires_evidence, required_evidence_type, requires_operator_validation,
  legal_basis_reference, ordinance_reference, source_reference, reviewed_by, reviewed_at,
  approved_by, approved_at, effective_from, notes, correlation_id, created_at,
  created_by_service_identity_id, updated_at, updated_by_service_identity_id, row_version)
SELECT
  registry_id, policy_code, policy_name,
  'Resident-only full parking-fee exemption for an eligible City of Parañaque beneficiary. Review and evidence validation remain required.',
  entitlement_type, 'ACTIVE', 'VERIFIED_ACTIVE_OPERATIONAL', 'LOCAL_ORDINANCE', 'LOCAL_ORDINANCE',
  'LOCAL_ORDINANCE_APPLIED', 'FULL_FEE_EXEMPTION', 'NOT_APPLICABLE',
  'f7a1b4b9-17a9-89de-5059-f72779616f23', 'f7a1b4b9-17a9-89de-5059-f72779616f23',
  'PARANAQUE', 'City of Parañaque', 'RESIDENT_ONLY',
  'Parking service at a Site assigned to the City of Parañaque jurisdiction.',
  NULL, false, true, true, false, '2026-07-28', false,
  true, evidence_type, true, authority_reference, authority_reference, source_reference,
  'I-006 controlled research scan', '2026-07-28T00:00:00+08'::timestamptz,
  'ExitPass v1.3 approved operational policy decision', '2026-09-19T00:00:00+08'::timestamptz,
  '2026-09-19T00:00:00+08'::timestamptz,
  'Transaction use is review-mediated. Operational verification does not claim that a controlled official ordinance source was reviewed.',
  '0f8a1b4b-917a-489d-9050-9f72779616f2'::uuid,
  '2026-09-19T00:00:00+08'::timestamptz, '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978',
  '2026-09-19T00:00:00+08'::timestamptz, '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978', 1
FROM policy
ON CONFLICT ON CONSTRAINT uq_sd_policy_registry__policy_code DO UPDATE SET
  policy_name = EXCLUDED.policy_name,
  policy_description = EXCLUDED.policy_description,
  entitlement_type = EXCLUDED.entitlement_type,
  policy_status = EXCLUDED.policy_status,
  verification_status = EXCLUDED.verification_status,
  policy_level = EXCLUDED.policy_level,
  policy_type = EXCLUDED.policy_type,
  policy_resolution_basis = EXCLUDED.policy_resolution_basis,
  benefit_type = EXCLUDED.benefit_type,
  discount_base_scope = EXCLUDED.discount_base_scope,
  jurisdiction_id = EXCLUDED.jurisdiction_id,
  local_government_unit_id = EXCLUDED.local_government_unit_id,
  jurisdiction_code = EXCLUDED.jurisdiction_code,
  jurisdiction_name = EXCLUDED.jurisdiction_name,
  beneficiary_residency_scope = EXCLUDED.beneficiary_residency_scope,
  facility_scope = EXCLUDED.facility_scope,
  free_duration_minutes = EXCLUDED.free_duration_minutes,
  initial_rate_exempt = EXCLUDED.initial_rate_exempt,
  full_fee_exempt = EXCLUDED.full_fee_exempt,
  coverage_available = EXCLUDED.coverage_available,
  auto_application_allowed = EXCLUDED.auto_application_allowed,
  source_scan_date = EXCLUDED.source_scan_date,
  source_document_available = EXCLUDED.source_document_available,
  requires_evidence = EXCLUDED.requires_evidence,
  required_evidence_type = EXCLUDED.required_evidence_type,
  requires_operator_validation = EXCLUDED.requires_operator_validation,
  legal_basis_reference = EXCLUDED.legal_basis_reference,
  ordinance_reference = EXCLUDED.ordinance_reference,
  source_reference = EXCLUDED.source_reference,
  reviewed_by = EXCLUDED.reviewed_by,
  reviewed_at = EXCLUDED.reviewed_at,
  approved_by = EXCLUDED.approved_by,
  approved_at = EXCLUDED.approved_at,
  effective_from = EXCLUDED.effective_from,
  notes = EXCLUDED.notes,
  correlation_id = EXCLUDED.correlation_id,
  updated_at = EXCLUDED.updated_at,
  updated_by_service_identity_id = EXCLUDED.updated_by_service_identity_id
WHERE (
  discounts.statutory_discount_policy_registry.policy_name,
  discounts.statutory_discount_policy_registry.policy_description,
  discounts.statutory_discount_policy_registry.entitlement_type,
  discounts.statutory_discount_policy_registry.policy_status,
  discounts.statutory_discount_policy_registry.verification_status,
  discounts.statutory_discount_policy_registry.benefit_type,
  discounts.statutory_discount_policy_registry.discount_base_scope,
  discounts.statutory_discount_policy_registry.jurisdiction_id,
  discounts.statutory_discount_policy_registry.beneficiary_residency_scope,
  discounts.statutory_discount_policy_registry.full_fee_exempt,
  discounts.statutory_discount_policy_registry.coverage_available,
  discounts.statutory_discount_policy_registry.required_evidence_type,
  discounts.statutory_discount_policy_registry.legal_basis_reference,
  discounts.statutory_discount_policy_registry.source_reference,
  discounts.statutory_discount_policy_registry.effective_from
) IS DISTINCT FROM (
  EXCLUDED.policy_name, EXCLUDED.policy_description, EXCLUDED.entitlement_type,
  EXCLUDED.policy_status, EXCLUDED.verification_status, EXCLUDED.benefit_type,
  EXCLUDED.discount_base_scope, EXCLUDED.jurisdiction_id, EXCLUDED.beneficiary_residency_scope,
  EXCLUDED.full_fee_exempt, EXCLUDED.coverage_available, EXCLUDED.required_evidence_type,
  EXCLUDED.legal_basis_reference, EXCLUDED.source_reference, EXCLUDED.effective_from
);

-- Semantic-hash material (UTF-8, exact field order):
-- policyCode|policyVersion|entitlementType|jurisdictionId|publication|verification|parking|
-- benefit|residency|discountBase|evidence|ordinance|fullFeeExempt|freeDuration|discountPercent.
WITH version AS (
  SELECT * FROM (VALUES
    ('3a22b6e2-5433-9a8b-cc60-139cf2a89a8e'::uuid, '0afacef1-5dd5-009d-32dd-e93a2ea8e4bb'::uuid,
     'PH_PARANAQUE_SENIOR_FREE_PARKING', 'SENIOR_CITIZEN'::discounts.statutory_entitlement_type_enum,
     NULL::varchar, 'SENIOR_CITIZEN_ID'::discounts.discount_evidence_type_enum,
     'sha256:d8bea52915fb948caa5d65c7ac56dd671c8a280aa76f8f08feef611a7d85a560',
     'I-006 controlled research scan 2026-07-28: Parañaque Senior Citizen verified active operational parking benefit; ordinance number and controlled official text are not retained.'),
    ('4c7c504c-6ac1-8e79-3f88-4fbeae06f00d'::uuid, 'd08bee33-972d-8214-c409-6e0ffef264d5'::uuid,
     'PH_PARANAQUE_PWD_FREE_PARKING', 'PWD'::discounts.statutory_entitlement_type_enum,
     'City Ordinance No. 48'::varchar, 'PWD_ID'::discounts.discount_evidence_type_enum,
     'sha256:92b871fe9f4b018c0f91a2675761b1b6920365a8917ef06f62578330eabcd268',
     'I-006 controlled research scan 2026-07-28: Parañaque PWD verified active operational parking benefit; City Ordinance No. 48 is retained as the authority reference, without a controlled full ordinance source.')
  ) AS v(version_id, registry_id, policy_code, entitlement_type, authority_reference, evidence_type, semantic_hash, source_reference)
)
INSERT INTO discounts.statutory_discount_policy_versions (
  statutory_discount_policy_version_id, statutory_discount_policy_registry_id, policy_code,
  policy_version, policy_version_label, entitlement_type, jurisdiction_id,
  local_government_unit_id, jurisdiction_code, jurisdiction_display_name, policy_scope_type,
  policy_level, policy_type, policy_resolution_basis, source_verification_status,
  transaction_publication_status, detailed_rule_verification_status,
  parking_service_applicability, benefit_type, policy_effect_support_status,
  discount_base_scope, beneficiary_residency_scope, official_source_identified,
  official_source_available, ordinance_text_available, ordinance_number_available,
  ordinance_number, legal_basis_reference, source_type, source_reference,
  source_verified_at, unresolved_policy_facts, safe_channel_summary, safe_reviewer_guidance,
  facility_scope, discount_percentage_basis_points, free_duration_minutes, full_fee_exempt,
  operational_confirmed_at, transaction_use_effective_from, precedence_rank,
  conflict_group_key, policy_semantic_hash, policy_semantic_hash_source_version,
  reviewed_by, reviewed_at, approved_by, approved_at, correlation_id, created_at,
  created_by_service_identity_id, updated_at, updated_by_service_identity_id, row_version)
SELECT
  version_id, registry_id, policy_code, '2026.09.1', 'Parañaque operational free-parking policy v2026.09.1',
  entitlement_type, 'f7a1b4b9-17a9-89de-5059-f72779616f23',
  'f7a1b4b9-17a9-89de-5059-f72779616f23', 'PARANAQUE', 'City of Parañaque', 'JURISDICTION',
  'LOCAL_ORDINANCE', 'LOCAL_ORDINANCE', 'LOCAL_ORDINANCE_APPLIED',
  'VERIFIED_ACTIVE_OPERATIONAL', 'ACTIVE_FOR_TRANSACTION_USE', 'PARTIALLY_VERIFIED',
  'COVERED', 'FULL_FEE_EXEMPTION', 'SUPPORTED_BY_CURRENT_CALCULATION',
  'NOT_APPLICABLE', 'RESIDENT_ONLY', false, false, false,
  authority_reference IS NOT NULL, authority_reference, authority_reference,
  'OPERATIONAL_OBSERVATION', source_reference, '2026-07-28T00:00:00+08'::timestamptz,
  CASE WHEN authority_reference IS NULL
    THEN 'A controlled official ordinance number and full ordinance text are not retained.'
    ELSE 'The authority reference is retained, but a controlled full ordinance text is not retained.' END,
  'Qualified Parañaque residents may receive free parking after evidence validation and authorized review.',
  'Verify the statutory ID and Parañaque residency using privacy-safe evidence metadata before supervisor decision.',
  'Parking service at a Site assigned to the City of Parañaque jurisdiction.',
  NULL, NULL, true, '2026-07-28T00:00:00+08'::timestamptz,
  '2026-09-19T00:00:00+08'::timestamptz, 100,
  'PARANAQUE_' || entitlement_type::text || '_PARKING', semantic_hash,
  'statutory-parking-policy-authority:sha256:v1',
  'I-006 controlled research scan', '2026-07-28T00:00:00+08'::timestamptz,
  'ExitPass v1.3 approved operational policy decision', '2026-09-19T00:00:00+08'::timestamptz,
  '0f8a1b4b-917a-489d-9050-9f72779616f2',
  '2026-09-19T00:00:00+08'::timestamptz, '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978',
  '2026-09-19T00:00:00+08'::timestamptz, '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978', 1
FROM version
ON CONFLICT ON CONSTRAINT uq_sd_policy_versions__code_version DO UPDATE SET
  transaction_publication_status = EXCLUDED.transaction_publication_status,
  source_verification_status = EXCLUDED.source_verification_status,
  detailed_rule_verification_status = EXCLUDED.detailed_rule_verification_status,
  parking_service_applicability = EXCLUDED.parking_service_applicability,
  benefit_type = EXCLUDED.benefit_type,
  policy_effect_support_status = EXCLUDED.policy_effect_support_status,
  discount_base_scope = EXCLUDED.discount_base_scope,
  beneficiary_residency_scope = EXCLUDED.beneficiary_residency_scope,
  ordinance_number_available = EXCLUDED.ordinance_number_available,
  ordinance_number = EXCLUDED.ordinance_number,
  legal_basis_reference = EXCLUDED.legal_basis_reference,
  source_reference = EXCLUDED.source_reference,
  unresolved_policy_facts = EXCLUDED.unresolved_policy_facts,
  safe_channel_summary = EXCLUDED.safe_channel_summary,
  safe_reviewer_guidance = EXCLUDED.safe_reviewer_guidance,
  discount_percentage_basis_points = NULL,
  free_duration_minutes = NULL,
  full_fee_exempt = true,
  transaction_use_effective_from = EXCLUDED.transaction_use_effective_from,
  policy_semantic_hash = EXCLUDED.policy_semantic_hash,
  approved_by = EXCLUDED.approved_by,
  approved_at = EXCLUDED.approved_at,
  updated_at = EXCLUDED.updated_at,
  updated_by_service_identity_id = EXCLUDED.updated_by_service_identity_id
WHERE (
  discounts.statutory_discount_policy_versions.transaction_publication_status,
  discounts.statutory_discount_policy_versions.source_verification_status,
  discounts.statutory_discount_policy_versions.parking_service_applicability,
  discounts.statutory_discount_policy_versions.benefit_type,
  discounts.statutory_discount_policy_versions.policy_effect_support_status,
  discounts.statutory_discount_policy_versions.discount_base_scope,
  discounts.statutory_discount_policy_versions.beneficiary_residency_scope,
  discounts.statutory_discount_policy_versions.ordinance_number,
  discounts.statutory_discount_policy_versions.policy_semantic_hash
) IS DISTINCT FROM (
  EXCLUDED.transaction_publication_status, EXCLUDED.source_verification_status,
  EXCLUDED.parking_service_applicability, EXCLUDED.benefit_type,
  EXCLUDED.policy_effect_support_status, EXCLUDED.discount_base_scope,
  EXCLUDED.beneficiary_residency_scope, EXCLUDED.ordinance_number,
  EXCLUDED.policy_semantic_hash
);

INSERT INTO discounts.statutory_discount_policy_version_evidence_requirements (
  statutory_discount_policy_version_evidence_requirement_id,
  statutory_discount_policy_version_id, evidence_type, requirement_status,
  safe_requirement_label, safe_requirement_notes, created_at,
  created_by_service_identity_id, updated_at, updated_by_service_identity_id)
VALUES
  ('0beb4ceb-638e-9811-e45a-9a63013103e9', '3a22b6e2-5433-9a8b-cc60-139cf2a89a8e', 'SENIOR_CITIZEN_ID', 'REQUIRED',
   'Valid Senior Citizen ID', 'Record privacy-safe verification metadata only; do not store a full ID number or raw document image.',
   '2026-09-19T00:00:00+08', '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978', '2026-09-19T00:00:00+08', '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'),
  ('cb62d837-7c07-f52e-1609-6af98f5820d5', '4c7c504c-6ac1-8e79-3f88-4fbeae06f00d', 'PWD_ID', 'REQUIRED',
   'Valid PWD ID', 'Record privacy-safe verification metadata only; do not store a full ID number or raw document image.',
   '2026-09-19T00:00:00+08', '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978', '2026-09-19T00:00:00+08', '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978')
ON CONFLICT ON CONSTRAINT uq_sd_policy_version_evidence_requirements__type DO UPDATE SET
  requirement_status = EXCLUDED.requirement_status,
  safe_requirement_label = EXCLUDED.safe_requirement_label,
  safe_requirement_notes = EXCLUDED.safe_requirement_notes,
  updated_at = EXCLUDED.updated_at,
  updated_by_service_identity_id = EXCLUDED.updated_by_service_identity_id
WHERE (
  discounts.statutory_discount_policy_version_evidence_requirements.requirement_status,
  discounts.statutory_discount_policy_version_evidence_requirements.safe_requirement_label,
  discounts.statutory_discount_policy_version_evidence_requirements.safe_requirement_notes
) IS DISTINCT FROM (
  EXCLUDED.requirement_status, EXCLUDED.safe_requirement_label, EXCLUDED.safe_requirement_notes
);
