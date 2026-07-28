-- Create "statutory_discount_policy_version_evidence_requirements" table
CREATE TABLE "discounts"."statutory_discount_policy_version_evidence_requirements" (
  "statutory_discount_policy_version_evidence_requirement_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "statutory_discount_policy_version_id" uuid NOT NULL,
  "evidence_type" "discounts"."discount_evidence_type_enum" NOT NULL,
  "requirement_status" "discounts"."policy_requirement_status_enum" NOT NULL DEFAULT 'REQUIRED',
  "safe_requirement_label" character varying(160) NOT NULL,
  "safe_requirement_notes" character varying(512) NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  CONSTRAINT "pk_sd_policy_version_evidence_requirements" PRIMARY KEY ("statutory_discount_policy_version_evidence_requirement_id"),
  CONSTRAINT "fk_sd_policy_version_evidence_requirements__version" FOREIGN KEY ("statutory_discount_policy_version_id") REFERENCES "discounts"."statutory_discount_policy_versions" ("statutory_discount_policy_version_id"),
  CONSTRAINT "uq_sd_policy_version_evidence_requirements__type" UNIQUE ("statutory_discount_policy_version_id", "evidence_type"),
  CONSTRAINT "ck_sd_policy_version_evidence_requirements__label" CHECK (btrim((safe_requirement_label)::text) <> ''::text)
);;
