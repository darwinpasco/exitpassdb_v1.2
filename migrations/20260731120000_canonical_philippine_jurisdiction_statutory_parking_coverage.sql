-- I-006 Canonical Philippine jurisdiction and statutory parking coverage model.
-- Additive, rerunnable schema migration. Reference/research/sample data are applied by separate seed scripts.

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid=t.typnamespace WHERE n.nspname='sites' AND t.typname='city_classification_enum') THEN
    CREATE TYPE sites.city_classification_enum AS ENUM ('HIGHLY_URBANIZED', 'INDEPENDENT_COMPONENT', 'COMPONENT');
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS sites.philippine_regions (
  philippine_region_id uuid NOT NULL DEFAULT gen_random_uuid(),
  psgc_code varchar(10) NOT NULL,
  correspondence_code varchar(16) NULL,
  region_code varchar(16) NOT NULL,
  official_name varchar(160) NOT NULL,
  short_name varchar(80) NULL,
  region_status sites.jurisdiction_status_enum NOT NULL DEFAULT 'ACTIVE',
  effective_from timestamptz NOT NULL,
  effective_to timestamptz NULL,
  source_reference varchar(256) NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by_user_id uuid NULL,
  created_by_service_identity_id uuid NULL,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by_user_id uuid NULL,
  updated_by_service_identity_id uuid NULL,
  row_version bigint NOT NULL DEFAULT 1,
  CONSTRAINT pk_philippine_regions PRIMARY KEY (philippine_region_id),
  CONSTRAINT uq_philippine_regions__psgc_code UNIQUE (psgc_code),
  CONSTRAINT uq_philippine_regions__region_code UNIQUE (region_code),
  CONSTRAINT ck_philippine_regions__psgc_code CHECK (psgc_code ~ '^[0-9]{10}$'),
  CONSTRAINT ck_philippine_regions__region_code CHECK (btrim(region_code) <> ''),
  CONSTRAINT ck_philippine_regions__official_name CHECK (btrim(official_name) <> ''),
  CONSTRAINT ck_philippine_regions__source_reference CHECK (btrim(source_reference) <> ''),
  CONSTRAINT ck_philippine_regions__effective_window CHECK (effective_to IS NULL OR effective_to > effective_from),
  CONSTRAINT ck_philippine_regions__row_version_positive CHECK (row_version > 0)
);
CREATE INDEX IF NOT EXISTS ix_philippine_regions__status ON sites.philippine_regions (region_status);

CREATE TABLE IF NOT EXISTS sites.philippine_provinces (
  philippine_province_id uuid NOT NULL DEFAULT gen_random_uuid(),
  philippine_region_id uuid NOT NULL REFERENCES sites.philippine_regions (philippine_region_id),
  psgc_code varchar(10) NOT NULL,
  correspondence_code varchar(16) NULL,
  province_code varchar(32) NOT NULL,
  official_name varchar(160) NOT NULL,
  province_status sites.jurisdiction_status_enum NOT NULL DEFAULT 'ACTIVE',
  effective_from timestamptz NOT NULL,
  effective_to timestamptz NULL,
  source_reference varchar(256) NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by_user_id uuid NULL,
  created_by_service_identity_id uuid NULL,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by_user_id uuid NULL,
  updated_by_service_identity_id uuid NULL,
  row_version bigint NOT NULL DEFAULT 1,
  CONSTRAINT pk_philippine_provinces PRIMARY KEY (philippine_province_id),
  CONSTRAINT uq_philippine_provinces__psgc_code UNIQUE (psgc_code),
  CONSTRAINT uq_philippine_provinces__province_code UNIQUE (province_code),
  CONSTRAINT ck_philippine_provinces__psgc_code CHECK (psgc_code ~ '^[0-9]{10}$'),
  CONSTRAINT ck_philippine_provinces__province_code CHECK (btrim(province_code) <> ''),
  CONSTRAINT ck_philippine_provinces__official_name CHECK (btrim(official_name) <> ''),
  CONSTRAINT ck_philippine_provinces__source_reference CHECK (btrim(source_reference) <> ''),
  CONSTRAINT ck_philippine_provinces__effective_window CHECK (effective_to IS NULL OR effective_to > effective_from),
  CONSTRAINT ck_philippine_provinces__row_version_positive CHECK (row_version > 0)
);
CREATE INDEX IF NOT EXISTS ix_philippine_provinces__region ON sites.philippine_provinces (philippine_region_id, province_status);

ALTER TABLE sites.jurisdictions ADD COLUMN IF NOT EXISTS philippine_region_id uuid NULL;
ALTER TABLE sites.jurisdictions ADD COLUMN IF NOT EXISTS philippine_province_id uuid NULL;
ALTER TABLE sites.jurisdictions ADD COLUMN IF NOT EXISTS correspondence_code varchar(16) NULL;
ALTER TABLE sites.jurisdictions ADD COLUMN IF NOT EXISTS short_display_name varchar(160) NULL;
ALTER TABLE sites.jurisdictions ADD COLUMN IF NOT EXISTS city_classification sites.city_classification_enum NULL;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='fk_jurisdictions__philippine_region') THEN ALTER TABLE sites.jurisdictions ADD CONSTRAINT fk_jurisdictions__philippine_region FOREIGN KEY (philippine_region_id) REFERENCES sites.philippine_regions (philippine_region_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='fk_jurisdictions__philippine_province') THEN ALTER TABLE sites.jurisdictions ADD CONSTRAINT fk_jurisdictions__philippine_province FOREIGN KEY (philippine_province_id) REFERENCES sites.philippine_provinces (philippine_province_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='ck_jurisdictions__psgc_code_format') THEN ALTER TABLE sites.jurisdictions ADD CONSTRAINT ck_jurisdictions__psgc_code_format CHECK (psgc_code IS NULL OR psgc_code ~ '^[0-9]{10}$'); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='ck_jurisdictions__short_display_name') THEN ALTER TABLE sites.jurisdictions ADD CONSTRAINT ck_jurisdictions__short_display_name CHECK (short_display_name IS NULL OR btrim(short_display_name) <> ''); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='ck_jurisdictions__city_classification') THEN ALTER TABLE sites.jurisdictions ADD CONSTRAINT ck_jurisdictions__city_classification CHECK (jurisdiction_type = 'CITY' OR city_classification IS NULL); END IF; END $$;

ALTER TABLE sites.sites ADD COLUMN IF NOT EXISTS local_government_unit_id uuid NULL;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='fk_sites__local_government_unit') THEN ALTER TABLE sites.sites ADD CONSTRAINT fk_sites__local_government_unit FOREIGN KEY (local_government_unit_id) REFERENCES sites.jurisdictions (jurisdiction_id); END IF; END $$;
CREATE INDEX IF NOT EXISTS ix_sites__local_government_unit_id ON sites.sites (local_government_unit_id);

CREATE TABLE IF NOT EXISTS sites.metropolitan_areas (
  metropolitan_area_id uuid NOT NULL DEFAULT gen_random_uuid(),
  metropolitan_area_code varchar(64) NOT NULL,
  metropolitan_area_name varchar(160) NOT NULL,
  description text NULL,
  source_reference varchar(256) NOT NULL,
  metropolitan_area_status sites.jurisdiction_status_enum NOT NULL DEFAULT 'ACTIVE',
  effective_from timestamptz NOT NULL,
  effective_to timestamptz NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by_user_id uuid NULL,
  created_by_service_identity_id uuid NULL,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by_user_id uuid NULL,
  updated_by_service_identity_id uuid NULL,
  row_version bigint NOT NULL DEFAULT 1,
  CONSTRAINT pk_metropolitan_areas PRIMARY KEY (metropolitan_area_id),
  CONSTRAINT uq_metropolitan_areas__code UNIQUE (metropolitan_area_code),
  CONSTRAINT ck_metropolitan_areas__code CHECK (metropolitan_area_code = upper(metropolitan_area_code) AND metropolitan_area_code ~ '^[A-Z0-9][A-Z0-9_]{2,63}$'),
  CONSTRAINT ck_metropolitan_areas__name CHECK (btrim(metropolitan_area_name) <> ''),
  CONSTRAINT ck_metropolitan_areas__source_reference CHECK (btrim(source_reference) <> ''),
  CONSTRAINT ck_metropolitan_areas__effective_window CHECK (effective_to IS NULL OR effective_to > effective_from),
  CONSTRAINT ck_metropolitan_areas__row_version_positive CHECK (row_version > 0)
);
CREATE INDEX IF NOT EXISTS ix_metropolitan_areas__status ON sites.metropolitan_areas (metropolitan_area_status);

CREATE TABLE IF NOT EXISTS sites.metropolitan_area_jurisdictions (
  metropolitan_area_jurisdiction_id uuid NOT NULL DEFAULT gen_random_uuid(),
  metropolitan_area_id uuid NOT NULL REFERENCES sites.metropolitan_areas (metropolitan_area_id),
  jurisdiction_id uuid NOT NULL REFERENCES sites.jurisdictions (jurisdiction_id),
  membership_classification varchar(64) NOT NULL,
  source_reference varchar(256) NOT NULL,
  membership_status sites.jurisdiction_status_enum NOT NULL DEFAULT 'ACTIVE',
  effective_from timestamptz NOT NULL,
  effective_to timestamptz NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by_user_id uuid NULL,
  created_by_service_identity_id uuid NULL,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by_user_id uuid NULL,
  updated_by_service_identity_id uuid NULL,
  row_version bigint NOT NULL DEFAULT 1,
  CONSTRAINT pk_metropolitan_area_jurisdictions PRIMARY KEY (metropolitan_area_jurisdiction_id),
  CONSTRAINT ck_metropolitan_area_jurisdictions__classification CHECK (btrim(membership_classification) <> ''),
  CONSTRAINT ck_metropolitan_area_jurisdictions__source_reference CHECK (btrim(source_reference) <> ''),
  CONSTRAINT ck_metropolitan_area_jurisdictions__effective_window CHECK (effective_to IS NULL OR effective_to > effective_from),
  CONSTRAINT ck_metropolitan_area_jurisdictions__row_version_positive CHECK (row_version > 0)
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_metropolitan_area_jurisdictions__active ON sites.metropolitan_area_jurisdictions (metropolitan_area_id, jurisdiction_id) WHERE membership_status = 'ACTIVE' AND effective_to IS NULL;
CREATE INDEX IF NOT EXISTS ix_metropolitan_area_jurisdictions__jurisdiction ON sites.metropolitan_area_jurisdictions (jurisdiction_id, membership_status);

ALTER TABLE discounts.statutory_discount_policy_registry ADD COLUMN IF NOT EXISTS local_government_unit_id uuid NULL;
ALTER TABLE discounts.statutory_discount_policy_registry ADD COLUMN IF NOT EXISTS coverage_available boolean NOT NULL DEFAULT false;
ALTER TABLE discounts.statutory_discount_policy_registry ADD COLUMN IF NOT EXISTS auto_application_allowed boolean NOT NULL DEFAULT false;
ALTER TABLE discounts.statutory_discount_policy_registry ADD COLUMN IF NOT EXISTS source_scan_date date NULL;
ALTER TABLE discounts.statutory_discount_policy_registry ADD COLUMN IF NOT EXISTS source_document_available boolean NULL;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='fk_sd_policy_registry__local_government_unit') THEN ALTER TABLE discounts.statutory_discount_policy_registry ADD CONSTRAINT fk_sd_policy_registry__local_government_unit FOREIGN KEY (local_government_unit_id) REFERENCES sites.jurisdictions (jurisdiction_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='ck_sd_policy_registry__lgu_consistency') THEN ALTER TABLE discounts.statutory_discount_policy_registry ADD CONSTRAINT ck_sd_policy_registry__lgu_consistency CHECK (local_government_unit_id IS NULL OR jurisdiction_id IS NULL OR local_government_unit_id = jurisdiction_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='ck_sd_policy_registry__no_rule_not_available') THEN ALTER TABLE discounts.statutory_discount_policy_registry ADD CONSTRAINT ck_sd_policy_registry__no_rule_not_available CHECK (verification_status <> 'NO_LOCAL_RULE_FOUND' OR coverage_available = false); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='ck_sd_policy_registry__auto_requires_active_verified') THEN ALTER TABLE discounts.statutory_discount_policy_registry ADD CONSTRAINT ck_sd_policy_registry__auto_requires_active_verified CHECK (auto_application_allowed = false OR (coverage_available = true AND policy_status = 'ACTIVE' AND verification_status IN ('VERIFIED_OFFICIAL','VERIFIED_ACTIVE_OPERATIONAL','ACTIVE_APPROVED'))); END IF; END $$;
CREATE INDEX IF NOT EXISTS ix_sd_policy_registry__local_government_unit_id ON discounts.statutory_discount_policy_registry (local_government_unit_id, entitlement_type, policy_status, verification_status, effective_from, effective_to);
CREATE UNIQUE INDEX IF NOT EXISTS ux_sd_policy_registry__active_lgu_policy ON discounts.statutory_discount_policy_registry (local_government_unit_id, entitlement_type, policy_code) WHERE local_government_unit_id IS NOT NULL AND policy_status = 'ACTIVE' AND effective_to IS NULL;

ALTER TABLE discounts.statutory_discount_policy_versions ADD COLUMN IF NOT EXISTS local_government_unit_id uuid NULL;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='fk_sd_policy_versions__local_government_unit') THEN ALTER TABLE discounts.statutory_discount_policy_versions ADD CONSTRAINT fk_sd_policy_versions__local_government_unit FOREIGN KEY (local_government_unit_id) REFERENCES sites.jurisdictions (jurisdiction_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='ck_sd_policy_versions__lgu_consistency') THEN ALTER TABLE discounts.statutory_discount_policy_versions ADD CONSTRAINT ck_sd_policy_versions__lgu_consistency CHECK (local_government_unit_id IS NULL OR local_government_unit_id = jurisdiction_id); END IF; END $$;
CREATE INDEX IF NOT EXISTS ix_sd_policy_versions__local_government_unit ON discounts.statutory_discount_policy_versions (local_government_unit_id, entitlement_type, transaction_publication_status, transaction_use_effective_from, transaction_use_effective_to);

CREATE TABLE IF NOT EXISTS discounts.statutory_discount_policy_registry_lgu_scopes (
  statutory_discount_policy_registry_lgu_scope_id uuid NOT NULL DEFAULT gen_random_uuid(),
  statutory_discount_policy_registry_id uuid NOT NULL REFERENCES discounts.statutory_discount_policy_registry (statutory_discount_policy_registry_id),
  local_government_unit_id uuid NOT NULL REFERENCES sites.jurisdictions (jurisdiction_id),
  coverage_available boolean NOT NULL DEFAULT false,
  auto_application_allowed boolean NOT NULL DEFAULT false,
  source_scan_date date NOT NULL,
  source_reference text NOT NULL,
  scope_status discounts.discount_policy_status_enum NOT NULL DEFAULT 'DRAFT',
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by_user_id uuid NULL,
  created_by_service_identity_id uuid NULL,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by_user_id uuid NULL,
  updated_by_service_identity_id uuid NULL,
  row_version bigint NOT NULL DEFAULT 1,
  CONSTRAINT pk_sd_policy_registry_lgu_scopes PRIMARY KEY (statutory_discount_policy_registry_lgu_scope_id),
  CONSTRAINT uq_sd_policy_registry_lgu_scopes__registry_lgu UNIQUE (statutory_discount_policy_registry_id, local_government_unit_id),
  CONSTRAINT ck_sd_policy_registry_lgu_scopes__source_reference CHECK (btrim(source_reference) <> ''),
  CONSTRAINT ck_sd_policy_registry_lgu_scopes__auto_requires_active CHECK (auto_application_allowed = false OR (coverage_available = true AND scope_status = 'ACTIVE')),
  CONSTRAINT ck_sd_policy_registry_lgu_scopes__row_version_positive CHECK (row_version > 0)
);
CREATE INDEX IF NOT EXISTS ix_sd_policy_registry_lgu_scopes__lgu ON discounts.statutory_discount_policy_registry_lgu_scopes (local_government_unit_id, coverage_available, auto_application_allowed, scope_status);
CREATE UNIQUE INDEX IF NOT EXISTS ux_sd_policy_registry_lgu_scopes__active_entitlement ON discounts.statutory_discount_policy_registry_lgu_scopes (local_government_unit_id, statutory_discount_policy_registry_id) WHERE scope_status = 'ACTIVE';

CREATE OR REPLACE VIEW sites.site_group_lgu_scopes AS
SELECT sg.site_group_id, sg.site_group_code, sg.site_group_name, j.jurisdiction_id AS local_government_unit_id, j.jurisdiction_code AS local_government_unit_code, j.psgc_code, j.display_name AS local_government_unit_name, ma.metropolitan_area_id, ma.metropolitan_area_code, ma.metropolitan_area_name, count(DISTINCT s.site_id) AS site_count
FROM sites.site_groups sg JOIN sites.sites s ON s.site_group_id=sg.site_group_id JOIN sites.jurisdictions j ON j.jurisdiction_id=s.local_government_unit_id
LEFT JOIN sites.metropolitan_area_jurisdictions maj ON maj.jurisdiction_id=j.jurisdiction_id AND maj.membership_status='ACTIVE' AND maj.effective_from <= now() AND (maj.effective_to IS NULL OR maj.effective_to > now())
LEFT JOIN sites.metropolitan_areas ma ON ma.metropolitan_area_id=maj.metropolitan_area_id
GROUP BY sg.site_group_id, sg.site_group_code, sg.site_group_name, j.jurisdiction_id, j.jurisdiction_code, j.psgc_code, j.display_name, ma.metropolitan_area_id, ma.metropolitan_area_code, ma.metropolitan_area_name;

CREATE OR REPLACE VIEW discounts.statutory_parking_lgu_policy_coverage AS
SELECT s.local_government_unit_id, j.jurisdiction_code AS local_government_unit_code, j.psgc_code, j.display_name AS local_government_unit_name, r.statutory_discount_policy_registry_id, r.policy_code, r.policy_name, r.entitlement_type, r.verification_status, r.policy_status, r.benefit_type, r.beneficiary_residency_scope, r.ordinance_reference, r.source_reference, r.coverage_available, r.auto_application_allowed, r.source_scan_date, r.effective_from, r.effective_to,
CASE WHEN r.auto_application_allowed=true AND r.coverage_available=true AND r.policy_status='ACTIVE' THEN 'AUTO_APPLICATION_ALLOWED' WHEN r.coverage_available=true THEN 'RESEARCH_COVERAGE_IDENTIFIED' ELSE 'NO_ACTIVE_LOCAL_COVERAGE' END AS coverage_resolution_status
FROM discounts.statutory_discount_policy_registry r JOIN discounts.statutory_discount_policy_registry_lgu_scopes s ON s.statutory_discount_policy_registry_id=r.statutory_discount_policy_registry_id JOIN sites.jurisdictions j ON j.jurisdiction_id=s.local_government_unit_id;

CREATE OR REPLACE VIEW discounts.statutory_parking_site_policy_coverage AS
SELECT site.site_id, site.site_code, site.site_group_id, coverage.*
FROM sites.sites site JOIN discounts.statutory_parking_lgu_policy_coverage coverage ON coverage.local_government_unit_id=site.local_government_unit_id;