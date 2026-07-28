\set ON_ERROR_STOP on

BEGIN;

-- Structural and constraint proof for the local-ordinance policy authority model.
-- The transaction is rolled back so this script never seeds production policy data.

INSERT INTO "sites"."jurisdictions" (
    "jurisdiction_id",
    "jurisdiction_code",
    "jurisdiction_type",
    "display_name",
    "province_name",
    "region_name",
    "country_code",
    "psgc_code",
    "jurisdiction_status",
    "effective_from",
    "source_reference"
) VALUES
(
    '10000000-0000-4000-8000-000000000001',
    'PH-PARANAQUE',
    'CITY',
    'Paranaque City',
    'Metro Manila',
    'National Capital Region',
    'PH',
    '137604000',
    'ACTIVE',
    '2026-01-01T00:00:00Z',
    'validation fixture'
),
(
    '10000000-0000-4000-8000-000000000002',
    'PH-MANDAUE',
    'CITY',
    'Mandaue City',
    'Cebu',
    'Central Visayas',
    'PH',
    '072230000',
    'ACTIVE',
    '2026-01-01T00:00:00Z',
    'validation fixture'
),
(
    '10000000-0000-4000-8000-000000000003',
    'PH-TAYTAY',
    'MUNICIPALITY',
    'Taytay',
    'Rizal',
    'Calabarzon',
    'PH',
    '045820000',
    'ACTIVE',
    '2026-01-01T00:00:00Z',
    'validation fixture'
),
(
    '10000000-0000-4000-8000-000000000004',
    'PH-MALOLOS',
    'CITY',
    'Malolos City',
    'Bulacan',
    'Central Luzon',
    'PH',
    '031410000',
    'ACTIVE',
    '2026-01-01T00:00:00Z',
    'validation fixture'
);

INSERT INTO "sites"."site_groups" (
    "site_group_id",
    "site_group_code",
    "site_group_name",
    "timezone_name",
    "default_currency_code",
    "site_group_status",
    "effective_from"
) VALUES (
    '20000000-0000-4000-8000-000000000001',
    'VALIDATION_GROUP',
    'Validation Site Group',
    'Asia/Manila',
    'PHP',
    'ACTIVE',
    '2026-01-01T00:00:00Z'
);

INSERT INTO "sites"."sites" (
    "site_id",
    "site_group_id",
    "site_code",
    "site_name",
    "site_type",
    "timezone_name",
    "city",
    "province",
    "country_code",
    "lgu_code",
    "site_status",
    "effective_from"
) VALUES (
    '30000000-0000-4000-8000-000000000001',
    '20000000-0000-4000-8000-000000000001',
    'VALIDATION_PARANAQUE',
    'Validation Paranaque Site',
    'MALL_PARKING',
    'Asia/Manila',
    'Paranaque City',
    'Metro Manila',
    'PH',
    'PH-PARANAQUE',
    'ACTIVE',
    '2026-01-01T00:00:00Z'
);

INSERT INTO "sites"."site_jurisdiction_assignments" (
    "site_jurisdiction_assignment_id",
    "site_id",
    "jurisdiction_id",
    "assignment_status",
    "effective_from",
    "source_reference",
    "approval_reference"
) VALUES (
    '40000000-0000-4000-8000-000000000001',
    '30000000-0000-4000-8000-000000000001',
    '10000000-0000-4000-8000-000000000001',
    'ACTIVE',
    '2026-01-01T00:00:00Z',
    'validation fixture',
    'canonical-validation'
);

INSERT INTO "discounts"."statutory_discount_policy_registry" (
    "statutory_discount_policy_registry_id",
    "policy_code",
    "policy_name",
    "entitlement_type",
    "policy_status",
    "verification_status",
    "policy_level",
    "policy_type",
    "policy_resolution_basis",
    "benefit_type",
    "discount_base_scope",
    "jurisdiction_id",
    "jurisdiction_code",
    "jurisdiction_name",
    "beneficiary_residency_scope",
    "required_evidence_type",
    "legal_basis_reference",
    "source_reference",
    "reviewed_by",
    "reviewed_at",
    "approved_by",
    "approved_at",
    "effective_from"
) VALUES
(
    '50000000-0000-4000-8000-000000000001',
    'PARANAQUE_SENIOR_VALIDATION',
    'Paranaque Senior Citizen Parking Benefit',
    'SENIOR_CITIZEN',
    'ACTIVE',
    'VERIFIED_ACTIVE_OPERATIONAL',
    'LOCAL_ORDINANCE',
    'LOCAL_ORDINANCE',
    'LOCAL_ORDINANCE_APPLIED',
    'FULL_FEE_EXEMPTION',
    'NOT_APPLICABLE',
    '10000000-0000-4000-8000-000000000001',
    'PH-PARANAQUE',
    'Paranaque City',
    'RESIDENT_ONLY',
    'SENIOR_CITIZEN_ID',
    'Paranaque verified active operational parking benefit',
    'validation fixture',
    'canonical-validation',
    '2026-01-01T00:00:00Z',
    'canonical-validation',
    '2026-01-01T00:00:00Z',
    '2026-01-01T00:00:00Z'
),
(
    '50000000-0000-4000-8000-000000000002',
    'PARANAQUE_PWD_VALIDATION',
    'Paranaque PWD Parking Benefit',
    'PWD',
    'ACTIVE',
    'VERIFIED_ACTIVE_OPERATIONAL',
    'LOCAL_ORDINANCE',
    'LOCAL_ORDINANCE',
    'LOCAL_ORDINANCE_APPLIED',
    'FULL_FEE_EXEMPTION',
    'NOT_APPLICABLE',
    '10000000-0000-4000-8000-000000000001',
    'PH-PARANAQUE',
    'Paranaque City',
    'RESIDENT_ONLY',
    'PWD_ID',
    'Paranaque verified active operational parking benefit',
    'validation fixture',
    'canonical-validation',
    '2026-01-01T00:00:00Z',
    'canonical-validation',
    '2026-01-01T00:00:00Z',
    '2026-01-01T00:00:00Z'
),
(
    '50000000-0000-4000-8000-000000000003',
    'MANDAUE_PWD_PROPOSED_VALIDATION',
    'Mandaue Proposed PWD Parking Measure',
    'PWD',
    'DRAFT',
    'PROPOSED',
    'LOCAL_ORDINANCE',
    'LOCAL_ORDINANCE',
    'LOCAL_ORDINANCE_APPLIED',
    'LOCAL_RULE',
    'NOT_APPLICABLE',
    '10000000-0000-4000-8000-000000000002',
    'PH-MANDAUE',
    'Mandaue City',
    'UNVERIFIED',
    'PWD_ID',
    'Proposed validation fixture',
    'validation fixture',
    'canonical-validation',
    '2026-01-01T00:00:00Z',
    NULL,
    NULL,
    '2026-01-01T00:00:00Z'
);

INSERT INTO "discounts"."statutory_discount_policy_versions" (
    "statutory_discount_policy_version_id",
    "statutory_discount_policy_registry_id",
    "policy_code",
    "policy_version",
    "policy_version_label",
    "entitlement_type",
    "jurisdiction_id",
    "jurisdiction_code",
    "jurisdiction_display_name",
    "policy_scope_type",
    "policy_level",
    "policy_type",
    "policy_resolution_basis",
    "source_verification_status",
    "transaction_publication_status",
    "detailed_rule_verification_status",
    "parking_service_applicability",
    "benefit_type",
    "policy_effect_support_status",
    "discount_base_scope",
    "beneficiary_residency_scope",
    "official_source_identified",
    "official_source_available",
    "ordinance_text_available",
    "ordinance_number_available",
    "ordinance_title_available",
    "source_type",
    "source_reference",
    "unresolved_policy_facts",
    "safe_channel_summary",
    "safe_reviewer_guidance",
    "full_fee_exempt",
    "operational_confirmed_at",
    "transaction_use_effective_from",
    "precedence_rank",
    "conflict_group_key",
    "policy_semantic_hash",
    "approved_by",
    "approved_at"
) VALUES
(
    '60000000-0000-4000-8000-000000000001',
    '50000000-0000-4000-8000-000000000001',
    'PARANAQUE_SENIOR_VALIDATION',
    '2026.1',
    'Paranaque senior verified active operational fixture',
    'SENIOR_CITIZEN',
    '10000000-0000-4000-8000-000000000001',
    'PH-PARANAQUE',
    'Paranaque City',
    'JURISDICTION',
    'LOCAL_ORDINANCE',
    'LOCAL_ORDINANCE',
    'LOCAL_ORDINANCE_APPLIED',
    'VERIFIED_ACTIVE_OPERATIONAL',
    'ACTIVE_FOR_TRANSACTION_USE',
    'PARTIALLY_VERIFIED',
    'COVERED',
    'FULL_FEE_EXEMPTION',
    'NOT_SUPPORTED',
    'NOT_APPLICABLE',
    'RESIDENT_ONLY',
    true,
    false,
    false,
    false,
    false,
    'CONTROLLED_OFFLINE_AUTHORITY',
    'validation fixture',
    'Senior Citizen ordinance number and online text unavailable; detailed restrictions unresolved.',
    'Paranaque resident Senior Citizen free-parking benefit requires controlled review.',
    'Review valid Senior Citizen proof and residency evidence; do not invent missing ordinance details.',
    true,
    '2026-01-01T00:00:00Z',
    '2026-01-01T00:00:00Z',
    100,
    'PH-PARANAQUE:SENIOR_CITIZEN:PARKING',
    'sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    'canonical-validation',
    '2026-01-01T00:00:00Z'
),
(
    '60000000-0000-4000-8000-000000000002',
    '50000000-0000-4000-8000-000000000002',
    'PARANAQUE_PWD_VALIDATION',
    '2026.1',
    'Paranaque PWD verified active operational fixture',
    'PWD',
    '10000000-0000-4000-8000-000000000001',
    'PH-PARANAQUE',
    'Paranaque City',
    'JURISDICTION',
    'LOCAL_ORDINANCE',
    'LOCAL_ORDINANCE',
    'LOCAL_ORDINANCE_APPLIED',
    'VERIFIED_ACTIVE_OPERATIONAL',
    'ACTIVE_FOR_TRANSACTION_USE',
    'PARTIALLY_VERIFIED',
    'COVERED',
    'FULL_FEE_EXEMPTION',
    'NOT_SUPPORTED',
    'NOT_APPLICABLE',
    'RESIDENT_ONLY',
    true,
    false,
    false,
    true,
    false,
    'CONTROLLED_OFFLINE_AUTHORITY',
    'validation fixture',
    'Online ordinance text and some detailed restrictions unresolved.',
    'Paranaque resident PWD free-parking benefit requires controlled review.',
    'Review valid PWD proof and residency evidence; do not invent missing ordinance details.',
    true,
    '2026-01-01T00:00:00Z',
    '2026-01-01T00:00:00Z',
    100,
    'PH-PARANAQUE:PWD:PARKING',
    'sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
    'canonical-validation',
    '2026-01-01T00:00:00Z'
),
(
    '60000000-0000-4000-8000-000000000003',
    '50000000-0000-4000-8000-000000000003',
    'MANDAUE_PWD_PROPOSED_VALIDATION',
    '2026.1',
    'Mandaue proposed PWD fixture',
    'PWD',
    '10000000-0000-4000-8000-000000000002',
    'PH-MANDAUE',
    'Mandaue City',
    'JURISDICTION',
    'LOCAL_ORDINANCE',
    'LOCAL_ORDINANCE',
    'LOCAL_ORDINANCE_APPLIED',
    'PROPOSED',
    'DRAFT',
    'UNVERIFIED',
    'UNRESOLVED',
    'LOCAL_RULE',
    'UNRESOLVED',
    'NOT_APPLICABLE',
    'UNVERIFIED',
    false,
    false,
    false,
    false,
    false,
    'SECONDARY_SOURCE',
    'validation fixture',
    'Proposed measure only.',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    100,
    'PH-MANDAUE:PWD:PARKING',
    'sha256:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc',
    NULL,
    NULL
);

INSERT INTO "discounts"."statutory_discount_policy_version_evidence_requirements" (
    "statutory_discount_policy_version_evidence_requirement_id",
    "statutory_discount_policy_version_id",
    "evidence_type",
    "requirement_status",
    "safe_requirement_label",
    "safe_requirement_notes"
) VALUES
(
    '70000000-0000-4000-8000-000000000001',
    '60000000-0000-4000-8000-000000000001',
    'SENIOR_CITIZEN_ID',
    'REQUIRED',
    'Senior Citizen proof',
    'Senior Citizen proof is required after policy eligibility is confirmed.'
),
(
    '70000000-0000-4000-8000-000000000002',
    '60000000-0000-4000-8000-000000000002',
    'PWD_ID',
    'REQUIRED',
    'PWD proof',
    'PWD proof is required after policy eligibility is confirmed.'
),
(
    '70000000-0000-4000-8000-000000000003',
    '60000000-0000-4000-8000-000000000001',
    'SUPPORTING_DOCUMENT',
    'REQUIRED',
    'Residency proof',
    'Residency evidence is required for the resident-only local benefit.'
);

DO $$
DECLARE
    v_count integer;
BEGIN
    SELECT COUNT(*)
      INTO v_count
      FROM "discounts"."statutory_discount_policy_versions"
     WHERE "jurisdiction_code" = 'PH-PARANAQUE'
       AND "source_verification_status" = 'VERIFIED_ACTIVE_OPERATIONAL'
       AND "transaction_publication_status" = 'ACTIVE_FOR_TRANSACTION_USE'
       AND "parking_service_applicability" = 'COVERED'
       AND "beneficiary_residency_scope" = 'RESIDENT_ONLY'
       AND "benefit_type" = 'FULL_FEE_EXEMPTION'
       AND "official_source_available" = false
       AND "ordinance_text_available" = false
       AND "policy_effect_support_status" = 'NOT_SUPPORTED';

    IF v_count <> 2 THEN
        RAISE EXCEPTION 'Expected two active operational Paranaque policy versions, found %', v_count;
    END IF;

    IF EXISTS (
        SELECT 1
          FROM "discounts"."statutory_discount_policy_versions"
         WHERE "jurisdiction_code" = 'PH-PARANAQUE'
           AND "entitlement_type" = 'SENIOR_CITIZEN'
           AND ("ordinance_number_available" <> false OR "ordinance_number" IS NOT NULL)
    ) THEN
        RAISE EXCEPTION 'Paranaque Senior Citizen ordinance number was fabricated.';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM "discounts"."statutory_discount_policy_versions"
         WHERE "jurisdiction_code" = 'PH-MANDAUE'
           AND "source_verification_status" = 'PROPOSED'
           AND "transaction_publication_status" = 'ACTIVE_FOR_TRANSACTION_USE'
    ) THEN
        RAISE EXCEPTION 'Proposed Mandaue policy became transaction-active.';
    END IF;
END $$;

DO $$
BEGIN
    INSERT INTO "discounts"."statutory_discount_policy_versions" (
        "statutory_discount_policy_registry_id",
        "policy_code",
        "policy_version",
        "entitlement_type",
        "jurisdiction_id",
        "jurisdiction_code",
        "jurisdiction_display_name",
        "policy_scope_type",
        "policy_level",
        "policy_type",
        "policy_resolution_basis",
        "source_verification_status",
        "transaction_publication_status",
        "parking_service_applicability",
        "benefit_type",
        "policy_effect_support_status",
        "discount_base_scope",
        "beneficiary_residency_scope",
        "source_reference",
        "policy_semantic_hash",
        "approved_by",
        "approved_at"
    ) VALUES (
        '50000000-0000-4000-8000-000000000003',
        'MANDAUE_ACTIVE_PROPOSED_REJECTED',
        '2026.1',
        'PWD',
        '10000000-0000-4000-8000-000000000002',
        'PH-MANDAUE',
        'Mandaue City',
        'JURISDICTION',
        'LOCAL_ORDINANCE',
        'LOCAL_ORDINANCE',
        'LOCAL_ORDINANCE_APPLIED',
        'PROPOSED',
        'ACTIVE_FOR_TRANSACTION_USE',
        'COVERED',
        'LOCAL_RULE',
        'UNRESOLVED',
        'NOT_APPLICABLE',
        'UNVERIFIED',
        'validation fixture',
        'sha256:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd',
        'canonical-validation',
        '2026-01-01T00:00:00Z'
    );

    RAISE EXCEPTION 'Proposed policy was incorrectly accepted as transaction-active.';
EXCEPTION
    WHEN check_violation THEN
        NULL;
END $$;

DO $$
BEGIN
    INSERT INTO "discounts"."statutory_discount_policy_versions" (
        "statutory_discount_policy_registry_id",
        "policy_code",
        "policy_version",
        "entitlement_type",
        "jurisdiction_id",
        "jurisdiction_code",
        "jurisdiction_display_name",
        "policy_scope_type",
        "policy_level",
        "policy_type",
        "policy_resolution_basis",
        "source_verification_status",
        "transaction_publication_status",
        "parking_service_applicability",
        "benefit_type",
        "policy_effect_support_status",
        "discount_base_scope",
        "beneficiary_residency_scope",
        "source_reference",
        "policy_semantic_hash",
        "approved_by",
        "approved_at"
    ) VALUES (
        '50000000-0000-4000-8000-000000000003',
        'NO_LOCAL_RULE_ACTIVE_REJECTED',
        '2026.1',
        'PWD',
        '10000000-0000-4000-8000-000000000002',
        'PH-MANDAUE',
        'Mandaue City',
        'JURISDICTION',
        'LOCAL_ORDINANCE',
        'LOCAL_ORDINANCE',
        'LOCAL_ORDINANCE_APPLIED',
        'NO_LOCAL_RULE_FOUND',
        'ACTIVE_FOR_TRANSACTION_USE',
        'COVERED',
        'LOCAL_RULE',
        'UNRESOLVED',
        'NOT_APPLICABLE',
        'UNVERIFIED',
        'validation fixture',
        'sha256:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee',
        'canonical-validation',
        '2026-01-01T00:00:00Z'
    );

    RAISE EXCEPTION 'NO_LOCAL_RULE_FOUND policy was incorrectly accepted as a transaction-active benefit.';
EXCEPTION
    WHEN check_violation THEN
        NULL;
END $$;

ROLLBACK;

SELECT 'Statutory discount local-ordinance policy authority validation passed.' AS validation_result;
