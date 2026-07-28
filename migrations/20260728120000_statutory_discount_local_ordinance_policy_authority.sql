-- ExitPass v1.3 statutory parking local-ordinance policy authority canonical promotion.
-- Additive and rerunnable: preserves existing policy, decision, validation, review, and application rows.

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'sites' AND t.typname = 'jurisdiction_type_enum') THEN
        CREATE TYPE sites.jurisdiction_type_enum AS ENUM ('CITY', 'MUNICIPALITY');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'sites' AND t.typname = 'jurisdiction_status_enum') THEN
        CREATE TYPE sites.jurisdiction_status_enum AS ENUM ('ACTIVE', 'INACTIVE', 'REPLACED', 'RETIRED', 'STATUS_UNRESOLVED');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'sites' AND t.typname = 'site_jurisdiction_assignment_status_enum') THEN
        CREATE TYPE sites.site_jurisdiction_assignment_status_enum AS ENUM ('ACTIVE', 'PENDING_APPROVAL', 'SUSPENDED', 'SUPERSEDED', 'RETIRED');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'discounts' AND t.typname = 'statutory_policy_publication_status_enum') THEN
        CREATE TYPE discounts.statutory_policy_publication_status_enum AS ENUM ('DRAFT', 'APPROVED_FOR_CONTROLLED_TRANSACTION_USE', 'ACTIVE_FOR_TRANSACTION_USE', 'SUSPENDED', 'WITHDRAWN', 'RETIRED', 'SUPERSEDED');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'discounts' AND t.typname = 'parking_service_applicability_status_enum') THEN
        CREATE TYPE discounts.parking_service_applicability_status_enum AS ENUM ('COVERED', 'EXCLUDED', 'UNRESOLVED');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'discounts' AND t.typname = 'policy_detail_verification_status_enum') THEN
        CREATE TYPE discounts.policy_detail_verification_status_enum AS ENUM ('VERIFIED', 'PARTIALLY_VERIFIED', 'UNVERIFIED', 'STATUS_UNRESOLVED');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'discounts' AND t.typname = 'policy_scope_type_enum') THEN
        CREATE TYPE discounts.policy_scope_type_enum AS ENUM ('JURISDICTION', 'SITE_GROUP', 'SITE');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'discounts' AND t.typname = 'policy_source_type_enum') THEN
        CREATE TYPE discounts.policy_source_type_enum AS ENUM ('OFFICIAL_LGU_DOCUMENT', 'OFFICIAL_LGU_CONFIRMATION', 'CONTROLLED_OFFLINE_AUTHORITY', 'SECONDARY_SOURCE', 'OPERATIONAL_OBSERVATION', 'NO_LOCAL_RULE_RECORD', 'STATUS_UNRESOLVED');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'discounts' AND t.typname = 'policy_relationship_type_enum') THEN
        CREATE TYPE discounts.policy_relationship_type_enum AS ENUM ('AMENDS', 'AMENDED_BY', 'SUPERSEDES', 'SUPERSEDED_BY', 'REPLACES', 'CLARIFIES', 'RELATED_ORDINANCE');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'discounts' AND t.typname = 'policy_effect_support_status_enum') THEN
        CREATE TYPE discounts.policy_effect_support_status_enum AS ENUM ('SUPPORTED_BY_CURRENT_CALCULATION', 'SUPPORTED_BY_FUTURE_ENGINE', 'NOT_SUPPORTED', 'UNRESOLVED');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'discounts' AND t.typname = 'policy_requirement_status_enum') THEN
        CREATE TYPE discounts.policy_requirement_status_enum AS ENUM ('REQUIRED', 'OPTIONAL', 'NOT_REQUIRED', 'UNRESOLVED');
    END IF;
END $$;

ALTER TYPE discounts.policy_verification_status_enum ADD VALUE IF NOT EXISTS 'VERIFIED_ACTIVE_OPERATIONAL' AFTER 'VERIFIED_OFFICIAL';
ALTER TYPE discounts.policy_verification_status_enum ADD VALUE IF NOT EXISTS 'PROPOSED' AFTER 'PROPOSED_ONLY';
ALTER TYPE discounts.policy_verification_status_enum ADD VALUE IF NOT EXISTS 'NO_LOCAL_RULE_FOUND' AFTER 'PROPOSED';
ALTER TYPE discounts.policy_verification_status_enum ADD VALUE IF NOT EXISTS 'STATUS_UNRESOLVED' AFTER 'NO_LOCAL_RULE_FOUND';

ALTER TABLE discounts.statutory_discount_policy_registry
    DROP CONSTRAINT IF EXISTS ck_sd_policy_registry__local_scope_reference;

ALTER TABLE discounts.statutory_discount_policy_registry
    ADD CONSTRAINT ck_sd_policy_registry__local_scope_reference
    CHECK (
        (
            policy_level::text <> 'LOCAL_ORDINANCE'
            AND policy_resolution_basis::text <> 'LOCAL_ORDINANCE_APPLIED'
        )
        OR (
            jurisdiction_id IS NOT NULL
            OR btrim(COALESCE(jurisdiction_code, '')::text) <> ''
            OR site_group_id IS NOT NULL
            OR site_id IS NOT NULL
        )
    );

CREATE TABLE IF NOT EXISTS sites.jurisdictions (
  jurisdiction_id uuid NOT NULL DEFAULT gen_random_uuid(),
  jurisdiction_code character varying(64) NOT NULL,
  jurisdiction_type sites.jurisdiction_type_enum NOT NULL,
  display_name character varying(160) NOT NULL,
  province_name character varying(128) NULL,
  region_name character varying(128) NULL,
  country_code character(2) NOT NULL DEFAULT 'PH',
  psgc_code character varying(16) NULL,
  jurisdiction_status sites.jurisdiction_status_enum NOT NULL DEFAULT 'ACTIVE',
  effective_from timestamptz NULL,
  effective_to timestamptz NULL,
  replaced_by_jurisdiction_id uuid NULL,
  source_reference character varying(256) NULL,
  source_provenance text NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by_user_id uuid NULL,
  created_by_service_identity_id uuid NULL,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by_user_id uuid NULL,
  updated_by_service_identity_id uuid NULL,
  row_version bigint NOT NULL DEFAULT 1,
  CONSTRAINT pk_jurisdictions PRIMARY KEY (jurisdiction_id),
  CONSTRAINT uq_jurisdictions__code UNIQUE (jurisdiction_code),
  CONSTRAINT uq_jurisdictions__psgc_code UNIQUE (psgc_code),
  CONSTRAINT fk_jurisdictions__replaced_by FOREIGN KEY (replaced_by_jurisdiction_id) REFERENCES sites.jurisdictions(jurisdiction_id),
  CONSTRAINT ck_jurisdictions__code_format CHECK (jurisdiction_code = upper(jurisdiction_code) AND jurisdiction_code ~ '^[A-Z]{2}[-_A-Z0-9]{2,63}$'),
  CONSTRAINT ck_jurisdictions__display_name CHECK (btrim(display_name) <> ''),
  CONSTRAINT ck_jurisdictions__country_code CHECK (country_code = upper(country_code)),
  CONSTRAINT ck_jurisdictions__effective_window CHECK (effective_to IS NULL OR effective_from IS NULL OR effective_to > effective_from),
  CONSTRAINT ck_jurisdictions__no_self_replacement CHECK (replaced_by_jurisdiction_id IS NULL OR replaced_by_jurisdiction_id <> jurisdiction_id),
  CONSTRAINT ck_jurisdictions__row_version_positive CHECK (row_version > 0)
);

CREATE TABLE IF NOT EXISTS sites.site_jurisdiction_assignments (
  site_jurisdiction_assignment_id uuid NOT NULL DEFAULT gen_random_uuid(),
  site_id uuid NOT NULL,
  jurisdiction_id uuid NOT NULL,
  assignment_status sites.site_jurisdiction_assignment_status_enum NOT NULL DEFAULT 'ACTIVE',
  effective_from timestamptz NOT NULL,
  effective_to timestamptz NULL,
  source_reference character varying(256) NULL,
  approval_reference character varying(256) NULL,
  correction_reason character varying(256) NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by_user_id uuid NULL,
  created_by_service_identity_id uuid NULL,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by_user_id uuid NULL,
  updated_by_service_identity_id uuid NULL,
  row_version bigint NOT NULL DEFAULT 1,
  CONSTRAINT pk_site_jurisdiction_assignments PRIMARY KEY (site_jurisdiction_assignment_id),
  CONSTRAINT fk_site_jurisdiction_assignments__site FOREIGN KEY (site_id) REFERENCES sites.sites(site_id),
  CONSTRAINT fk_site_jurisdiction_assignments__jurisdiction FOREIGN KEY (jurisdiction_id) REFERENCES sites.jurisdictions(jurisdiction_id),
  CONSTRAINT ck_site_jurisdiction_assignments__effective_window CHECK (effective_to IS NULL OR effective_to > effective_from),
  CONSTRAINT ck_site_jurisdiction_assignments__row_version_positive CHECK (row_version > 0)
);

CREATE TABLE IF NOT EXISTS discounts.statutory_discount_policy_versions (
  statutory_discount_policy_version_id uuid NOT NULL DEFAULT gen_random_uuid(),
  statutory_discount_policy_registry_id uuid NOT NULL REFERENCES discounts.statutory_discount_policy_registry(statutory_discount_policy_registry_id),
  policy_code character varying(128) NOT NULL,
  policy_version character varying(64) NOT NULL,
  policy_version_label character varying(160) NULL,
  entitlement_type discounts.statutory_entitlement_type_enum NOT NULL,
  jurisdiction_id uuid NOT NULL REFERENCES sites.jurisdictions(jurisdiction_id),
  jurisdiction_code character varying(64) NOT NULL,
  jurisdiction_display_name character varying(160) NOT NULL,
  policy_scope_type discounts.policy_scope_type_enum NOT NULL,
  site_group_id uuid NULL REFERENCES sites.site_groups(site_group_id),
  site_id uuid NULL REFERENCES sites.sites(site_id),
  policy_level discounts.discount_policy_level_enum NOT NULL,
  policy_type discounts.discount_policy_type_enum NOT NULL,
  policy_resolution_basis discounts.policy_resolution_basis_enum NOT NULL DEFAULT 'LOCAL_ORDINANCE_APPLIED',
  source_verification_status discounts.policy_verification_status_enum NOT NULL,
  transaction_publication_status discounts.statutory_policy_publication_status_enum NOT NULL DEFAULT 'DRAFT',
  detailed_rule_verification_status discounts.policy_detail_verification_status_enum NOT NULL DEFAULT 'STATUS_UNRESOLVED',
  parking_service_applicability discounts.parking_service_applicability_status_enum NOT NULL DEFAULT 'UNRESOLVED',
  benefit_type discounts.parking_benefit_type_enum NOT NULL,
  policy_effect_support_status discounts.policy_effect_support_status_enum NOT NULL DEFAULT 'UNRESOLVED',
  discount_base_scope discounts.discount_base_scope_enum NOT NULL,
  beneficiary_residency_scope discounts.beneficiary_residency_scope_enum NOT NULL,
  official_source_identified boolean NULL,
  official_source_available boolean NULL,
  ordinance_text_available boolean NULL,
  ordinance_number_available boolean NULL,
  ordinance_title_available boolean NULL,
  ordinance_number character varying(128) NULL,
  ordinance_title character varying(256) NULL,
  legal_basis_reference character varying(256) NULL,
  source_type discounts.policy_source_type_enum NOT NULL DEFAULT 'STATUS_UNRESOLVED',
  source_reference text NOT NULL,
  source_document_reference character varying(512) NULL,
  source_document_hash character varying(128) NULL,
  source_retrieved_at timestamptz NULL,
  source_verified_at timestamptz NULL,
  unresolved_policy_facts text NULL,
  safe_channel_summary text NULL,
  safe_reviewer_guidance text NULL,
  facility_scope text NULL,
  standalone_parking_excluded boolean NULL,
  valet_excluded boolean NULL,
  overnight_excluded boolean NULL,
  driver_or_passenger_required boolean NULL,
  discount_percentage_basis_points integer NULL,
  free_duration_minutes integer NULL,
  cap_amount_minor_units bigint NULL,
  cap_currency_code character(3) NULL,
  full_fee_exempt boolean NULL,
  initial_rate_exempt boolean NULL,
  enactment_date date NULL,
  legal_effective_from timestamptz NULL,
  legal_effective_to timestamptz NULL,
  operational_confirmed_at timestamptz NULL,
  transaction_use_effective_from timestamptz NULL,
  transaction_use_effective_to timestamptz NULL,
  suspension_starts_at timestamptz NULL,
  suspension_ends_at timestamptz NULL,
  withdrawn_at timestamptz NULL,
  retired_at timestamptz NULL,
  supersedes_policy_version_id uuid NULL REFERENCES discounts.statutory_discount_policy_versions(statutory_discount_policy_version_id),
  superseded_by_policy_version_id uuid NULL REFERENCES discounts.statutory_discount_policy_versions(statutory_discount_policy_version_id),
  precedence_rank integer NOT NULL DEFAULT 1000,
  conflict_group_key character varying(160) NULL,
  policy_semantic_hash character varying(80) NOT NULL,
  policy_semantic_hash_source_version character varying(80) NOT NULL DEFAULT 'statutory-parking-policy-authority:sha256:v1',
  reviewed_by_user_id uuid NULL,
  reviewed_by character varying(128) NULL,
  reviewed_at timestamptz NULL,
  approved_by_user_id uuid NULL,
  approved_by character varying(128) NULL,
  approved_at timestamptz NULL,
  correlation_id uuid NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by_user_id uuid NULL,
  created_by_service_identity_id uuid NULL,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by_user_id uuid NULL,
  updated_by_service_identity_id uuid NULL,
  row_version bigint NOT NULL DEFAULT 1,
  CONSTRAINT pk_statutory_discount_policy_versions PRIMARY KEY (statutory_discount_policy_version_id),
  CONSTRAINT uq_sd_policy_versions__code_version UNIQUE (policy_code, policy_version),
  CONSTRAINT ck_sd_policy_versions__policy_code_format CHECK (policy_code = upper(policy_code) AND policy_code ~ '^[A-Z0-9][A-Z0-9_]{2,127}$'),
  CONSTRAINT ck_sd_policy_versions__jurisdiction_code_format CHECK (jurisdiction_code = upper(jurisdiction_code) AND jurisdiction_code ~ '^[A-Z]{2}[-_A-Z0-9]{2,63}$'),
  CONSTRAINT ck_sd_policy_versions__source_reference_required CHECK (btrim(source_reference) <> ''),
  CONSTRAINT ck_sd_policy_versions__hash CHECK (policy_semantic_hash ~ '^sha256:[0-9a-f]{64}$'),
  CONSTRAINT ck_sd_policy_versions__hash_version CHECK (policy_semantic_hash_source_version = 'statutory-parking-policy-authority:sha256:v1'),
  CONSTRAINT ck_sd_policy_versions__scope CHECK ((policy_scope_type = 'JURISDICTION' AND site_group_id IS NULL AND site_id IS NULL) OR (policy_scope_type = 'SITE_GROUP' AND site_group_id IS NOT NULL AND site_id IS NULL) OR (policy_scope_type = 'SITE' AND site_id IS NOT NULL)),
  CONSTRAINT ck_sd_policy_versions__local_resolution CHECK (policy_level = 'LOCAL_ORDINANCE' AND policy_resolution_basis = 'LOCAL_ORDINANCE_APPLIED'),
  CONSTRAINT ck_sd_policy_versions__transaction_active_verification CHECK (transaction_publication_status::text <> 'ACTIVE_FOR_TRANSACTION_USE' OR source_verification_status::text IN ('VERIFIED_OFFICIAL', 'VERIFIED_ACTIVE_OPERATIONAL', 'ACTIVE_APPROVED')),
  CONSTRAINT ck_sd_policy_versions__proposed_unverified_not_active CHECK (transaction_publication_status::text <> 'ACTIVE_FOR_TRANSACTION_USE' OR source_verification_status::text NOT IN ('LEAD_UNVERIFIED', 'VERIFIED_SECONDARY', 'PROPOSED_ONLY', 'PROPOSED', 'NO_LOCAL_RULE_FOUND', 'STATUS_UNRESOLVED', 'REJECTED')),
  CONSTRAINT ck_sd_policy_versions__active_parking_covered CHECK (transaction_publication_status::text <> 'ACTIVE_FOR_TRANSACTION_USE' OR parking_service_applicability::text = 'COVERED'),
  CONSTRAINT ck_sd_policy_versions__active_approved CHECK (transaction_publication_status <> 'ACTIVE_FOR_TRANSACTION_USE' OR (approved_at IS NOT NULL AND (approved_by_user_id IS NOT NULL OR btrim(COALESCE(approved_by, '')) <> ''))),
  CONSTRAINT ck_sd_policy_versions__transaction_window CHECK (transaction_use_effective_to IS NULL OR transaction_use_effective_from IS NULL OR transaction_use_effective_to > transaction_use_effective_from),
  CONSTRAINT ck_sd_policy_versions__legal_window CHECK (legal_effective_to IS NULL OR legal_effective_from IS NULL OR legal_effective_to > legal_effective_from),
  CONSTRAINT ck_sd_policy_versions__suspension_window CHECK (suspension_ends_at IS NULL OR suspension_starts_at IS NULL OR suspension_ends_at > suspension_starts_at),
  CONSTRAINT ck_sd_policy_versions__suspended_status CHECK (transaction_publication_status::text <> 'SUSPENDED' OR suspension_starts_at IS NOT NULL),
  CONSTRAINT ck_sd_policy_versions__withdrawn_status CHECK (transaction_publication_status::text <> 'WITHDRAWN' OR withdrawn_at IS NOT NULL),
  CONSTRAINT ck_sd_policy_versions__retired_status CHECK (transaction_publication_status::text <> 'RETIRED' OR retired_at IS NOT NULL),
  CONSTRAINT ck_sd_policy_versions__superseded_status CHECK (transaction_publication_status::text <> 'SUPERSEDED' OR superseded_by_policy_version_id IS NOT NULL),
  CONSTRAINT ck_sd_policy_versions__no_self_supersession CHECK ((supersedes_policy_version_id IS NULL OR supersedes_policy_version_id <> statutory_discount_policy_version_id) AND (superseded_by_policy_version_id IS NULL OR superseded_by_policy_version_id <> statutory_discount_policy_version_id)),
  CONSTRAINT ck_sd_policy_versions__percentage_range CHECK (discount_percentage_basis_points IS NULL OR discount_percentage_basis_points BETWEEN 0 AND 10000),
  CONSTRAINT ck_sd_policy_versions__free_duration_non_negative CHECK (free_duration_minutes IS NULL OR free_duration_minutes >= 0),
  CONSTRAINT ck_sd_policy_versions__cap_non_negative CHECK (cap_amount_minor_units IS NULL OR cap_amount_minor_units >= 0),
  CONSTRAINT ck_sd_policy_versions__cap_currency CHECK (cap_amount_minor_units IS NULL OR cap_currency_code IS NOT NULL),
  CONSTRAINT ck_sd_policy_versions__full_fee_flag CHECK (benefit_type::text <> 'FULL_FEE_EXEMPTION' OR full_fee_exempt IS NULL OR full_fee_exempt = true),
  CONSTRAINT ck_sd_policy_versions__unknown_not_zero CHECK ((free_duration_minutes IS NULL OR free_duration_minutes > 0) AND (cap_amount_minor_units IS NULL OR cap_amount_minor_units > 0)),
  CONSTRAINT ck_sd_policy_versions__row_version_positive CHECK (row_version > 0)
);

CREATE TABLE IF NOT EXISTS discounts.statutory_discount_policy_version_evidence_requirements (
  statutory_discount_policy_version_evidence_requirement_id uuid NOT NULL DEFAULT gen_random_uuid(),
  statutory_discount_policy_version_id uuid NOT NULL REFERENCES discounts.statutory_discount_policy_versions(statutory_discount_policy_version_id),
  evidence_type discounts.discount_evidence_type_enum NOT NULL,
  requirement_status discounts.policy_requirement_status_enum NOT NULL DEFAULT 'REQUIRED',
  safe_requirement_label character varying(160) NOT NULL,
  safe_requirement_notes character varying(512) NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by_user_id uuid NULL,
  created_by_service_identity_id uuid NULL,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by_user_id uuid NULL,
  updated_by_service_identity_id uuid NULL,
  CONSTRAINT pk_sd_policy_version_evidence_requirements PRIMARY KEY (statutory_discount_policy_version_evidence_requirement_id),
  CONSTRAINT uq_sd_policy_version_evidence_requirements__type UNIQUE (statutory_discount_policy_version_id, evidence_type),
  CONSTRAINT ck_sd_policy_version_evidence_requirements__label CHECK (btrim(safe_requirement_label) <> '')
);

CREATE TABLE IF NOT EXISTS discounts.statutory_discount_policy_version_relationships (
  statutory_discount_policy_version_relationship_id uuid NOT NULL DEFAULT gen_random_uuid(),
  source_policy_version_id uuid NOT NULL REFERENCES discounts.statutory_discount_policy_versions(statutory_discount_policy_version_id),
  target_policy_version_id uuid NOT NULL REFERENCES discounts.statutory_discount_policy_versions(statutory_discount_policy_version_id),
  relationship_type discounts.policy_relationship_type_enum NOT NULL,
  effective_from timestamptz NULL,
  effective_to timestamptz NULL,
  source_reference character varying(256) NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by_user_id uuid NULL,
  created_by_service_identity_id uuid NULL,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by_user_id uuid NULL,
  updated_by_service_identity_id uuid NULL,
  CONSTRAINT pk_sd_policy_version_relationships PRIMARY KEY (statutory_discount_policy_version_relationship_id),
  CONSTRAINT uq_sd_policy_version_relationships__edge UNIQUE (source_policy_version_id, target_policy_version_id, relationship_type),
  CONSTRAINT ck_sd_policy_version_relationships__no_self CHECK (source_policy_version_id <> target_policy_version_id),
  CONSTRAINT ck_sd_policy_version_relationships__effective_window CHECK (effective_to IS NULL OR effective_from IS NULL OR effective_to > effective_from)
);

CREATE TABLE IF NOT EXISTS discounts.statutory_discount_decision_policy_authorities (
  statutory_discount_decision_command_id uuid NOT NULL REFERENCES discounts.statutory_discount_decision_commands(statutory_discount_decision_command_id),
  statutory_discount_policy_version_id uuid NOT NULL REFERENCES discounts.statutory_discount_policy_versions(statutory_discount_policy_version_id),
  jurisdiction_id uuid NOT NULL REFERENCES sites.jurisdictions(jurisdiction_id),
  jurisdiction_code character varying(64) NOT NULL,
  jurisdiction_display_name character varying(160) NOT NULL,
  policy_code character varying(128) NOT NULL,
  policy_version character varying(64) NOT NULL,
  entitlement_type character varying(64) NOT NULL,
  source_verification_status discounts.policy_verification_status_enum NOT NULL,
  transaction_publication_status discounts.statutory_policy_publication_status_enum NOT NULL,
  detailed_rule_verification_status discounts.policy_detail_verification_status_enum NOT NULL,
  parking_service_applicability discounts.parking_service_applicability_status_enum NOT NULL,
  benefit_type discounts.parking_benefit_type_enum NOT NULL,
  beneficiary_residency_scope discounts.beneficiary_residency_scope_enum NOT NULL,
  official_source_available boolean NULL,
  ordinance_text_available boolean NULL,
  ordinance_number_available boolean NULL,
  ordinance_number character varying(128) NULL,
  ordinance_title character varying(256) NULL,
  legal_basis_reference character varying(256) NULL,
  source_reference text NOT NULL,
  transaction_use_effective_from timestamptz NULL,
  transaction_use_effective_to timestamptz NULL,
  resolved_at timestamptz NOT NULL DEFAULT now(),
  policy_authority_semantic_hash character varying(80) NOT NULL,
  policy_authority_semantic_hash_source_version character varying(80) NOT NULL DEFAULT 'statutory-decision-policy-authority:sha256:v1',
  correlation_id uuid NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT pk_statutory_discount_decision_policy_authorities PRIMARY KEY (statutory_discount_decision_command_id),
  CONSTRAINT ck_sd_decision_policy_authorities__entitlement CHECK (entitlement_type IN ('SENIOR_CITIZEN', 'PWD')),
  CONSTRAINT ck_sd_decision_policy_authorities__source_reference CHECK (btrim(source_reference) <> ''),
  CONSTRAINT ck_sd_decision_policy_authorities__hash CHECK (policy_authority_semantic_hash ~ '^sha256:[0-9a-f]{64}$'),
  CONSTRAINT ck_sd_decision_policy_authorities__hash_version CHECK (policy_authority_semantic_hash_source_version = 'statutory-decision-policy-authority:sha256:v1'),
  CONSTRAINT ck_sd_decision_policy_authorities__active_authority CHECK (transaction_publication_status::text = 'ACTIVE_FOR_TRANSACTION_USE' AND parking_service_applicability::text = 'COVERED')
);

ALTER TABLE discounts.statutory_discount_validations ADD COLUMN IF NOT EXISTS statutory_discount_policy_version_id uuid NULL;
ALTER TABLE discounts.statutory_discount_payable_basis_application_commands ADD COLUMN IF NOT EXISTS statutory_discount_policy_version_id uuid NULL;
ALTER TABLE discounts.statutory_discount_payable_basis_application_commands ADD COLUMN IF NOT EXISTS statutory_discount_decision_policy_authority_id uuid NULL;
ALTER TABLE operator_console.statutory_discount_service_channel_reviews ADD COLUMN IF NOT EXISTS statutory_discount_policy_version_id uuid NULL;
ALTER TABLE operator_console.statutory_discount_service_channel_reviews ADD COLUMN IF NOT EXISTS statutory_discount_decision_policy_authority_id uuid NULL;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_statutory_discount_validations__policy_version') THEN
        ALTER TABLE discounts.statutory_discount_validations ADD CONSTRAINT fk_statutory_discount_validations__policy_version FOREIGN KEY (statutory_discount_policy_version_id) REFERENCES discounts.statutory_discount_policy_versions(statutory_discount_policy_version_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_stat_discount_pba_commands__policy_version') THEN
        ALTER TABLE discounts.statutory_discount_payable_basis_application_commands ADD CONSTRAINT fk_stat_discount_pba_commands__policy_version FOREIGN KEY (statutory_discount_policy_version_id) REFERENCES discounts.statutory_discount_policy_versions(statutory_discount_policy_version_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_stat_discount_pba_commands__decision_policy_authority') THEN
        ALTER TABLE discounts.statutory_discount_payable_basis_application_commands ADD CONSTRAINT fk_stat_discount_pba_commands__decision_policy_authority FOREIGN KEY (statutory_discount_decision_policy_authority_id) REFERENCES discounts.statutory_discount_decision_policy_authorities(statutory_discount_decision_command_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ck_stat_discount_pba_commands__policy_authority_matches_decision') THEN
        ALTER TABLE discounts.statutory_discount_payable_basis_application_commands ADD CONSTRAINT ck_stat_discount_pba_commands__policy_authority_matches_decision CHECK (statutory_discount_decision_policy_authority_id IS NULL OR statutory_discount_decision_policy_authority_id = statutory_discount_decision_command_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_stat_disc_svc_reviews__policy_version') THEN
        ALTER TABLE operator_console.statutory_discount_service_channel_reviews ADD CONSTRAINT fk_stat_disc_svc_reviews__policy_version FOREIGN KEY (statutory_discount_policy_version_id) REFERENCES discounts.statutory_discount_policy_versions(statutory_discount_policy_version_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_stat_disc_svc_reviews__decision_policy_authority') THEN
        ALTER TABLE operator_console.statutory_discount_service_channel_reviews ADD CONSTRAINT fk_stat_disc_svc_reviews__decision_policy_authority FOREIGN KEY (statutory_discount_decision_policy_authority_id) REFERENCES discounts.statutory_discount_decision_policy_authorities(statutory_discount_decision_command_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ck_stat_disc_svc_reviews__policy_authority_matches_decision') THEN
        ALTER TABLE operator_console.statutory_discount_service_channel_reviews ADD CONSTRAINT ck_stat_disc_svc_reviews__policy_authority_matches_decision CHECK (statutory_discount_decision_policy_authority_id IS NULL OR statutory_discount_decision_policy_authority_id = statutory_discount_decision_command_id);
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS ix_jurisdictions__status ON sites.jurisdictions (jurisdiction_status, jurisdiction_type);
CREATE INDEX IF NOT EXISTS ix_site_jurisdiction_assignments__site_effective ON sites.site_jurisdiction_assignments (site_id, assignment_status, effective_from, effective_to);
CREATE UNIQUE INDEX IF NOT EXISTS ux_site_jurisdiction_assignments__one_open_active ON sites.site_jurisdiction_assignments (site_id) WHERE assignment_status = 'ACTIVE' AND effective_to IS NULL;
CREATE INDEX IF NOT EXISTS ix_sd_policy_versions__active_lookup ON discounts.statutory_discount_policy_versions (entitlement_type, jurisdiction_id, policy_scope_type, site_group_id, site_id, transaction_publication_status, parking_service_applicability, transaction_use_effective_from, transaction_use_effective_to);
CREATE INDEX IF NOT EXISTS ix_sd_policy_versions__jurisdiction ON discounts.statutory_discount_policy_versions (jurisdiction_id, jurisdiction_code);
CREATE INDEX IF NOT EXISTS ix_sd_policy_versions__publication ON discounts.statutory_discount_policy_versions (transaction_publication_status, source_verification_status, parking_service_applicability);
CREATE INDEX IF NOT EXISTS ix_sd_policy_versions__supersession ON discounts.statutory_discount_policy_versions (supersedes_policy_version_id, superseded_by_policy_version_id);
CREATE INDEX IF NOT EXISTS ix_sd_policy_versions__semantic_hash ON discounts.statutory_discount_policy_versions (policy_semantic_hash);
CREATE INDEX IF NOT EXISTS ix_sd_policy_version_evidence__version ON discounts.statutory_discount_policy_version_evidence_requirements (statutory_discount_policy_version_id);
CREATE INDEX IF NOT EXISTS ix_sd_policy_version_relationships__target ON discounts.statutory_discount_policy_version_relationships (target_policy_version_id, relationship_type);
CREATE INDEX IF NOT EXISTS ix_sd_decision_policy_authorities__policy_version ON discounts.statutory_discount_decision_policy_authorities (statutory_discount_policy_version_id);
CREATE INDEX IF NOT EXISTS ix_sd_decision_policy_authorities__jurisdiction ON discounts.statutory_discount_decision_policy_authorities (jurisdiction_id, entitlement_type);
CREATE INDEX IF NOT EXISTS ix_statutory_discount_validations__policy_version ON discounts.statutory_discount_validations (statutory_discount_policy_version_id) WHERE statutory_discount_policy_version_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_stat_discount_pba_commands__policy_authority ON discounts.statutory_discount_payable_basis_application_commands (statutory_discount_decision_policy_authority_id) WHERE statutory_discount_decision_policy_authority_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_stat_disc_svc_reviews__policy_authority ON operator_console.statutory_discount_service_channel_reviews (statutory_discount_decision_policy_authority_id) WHERE statutory_discount_decision_policy_authority_id IS NOT NULL;
