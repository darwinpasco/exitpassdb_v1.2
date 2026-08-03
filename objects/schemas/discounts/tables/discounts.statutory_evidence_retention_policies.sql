CREATE TABLE "discounts"."statutory_evidence_retention_policies" (
  "retention_class_code" character varying(64) NOT NULL,
  "retention_policy_version" character varying(64) NOT NULL,
  "policy_status" character varying(32) NOT NULL,
  "environment_scope" character varying(32) NOT NULL,
  "purpose_code" character varying(64) NOT NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_statutory_evidence_retention_policies" PRIMARY KEY ("retention_class_code", "retention_policy_version"),
  CONSTRAINT "ck_stat_ev_retention_policies__status" CHECK (policy_status IN ('DRAFT', 'APPROVED_ENABLED', 'APPROVED_DISABLED', 'RETIRED')),
  CONSTRAINT "ck_stat_ev_retention_policies__environment" CHECK (environment_scope IN ('LOCAL_TEST', 'CONTROLLED_UAT', 'PRODUCTION')),
  CONSTRAINT "ck_stat_ev_retention_policies__effective_window" CHECK (effective_to IS NULL OR effective_to > effective_from),
  CONSTRAINT "ck_stat_ev_retention_policies__row_version" CHECK (row_version > 0)
);;

COMMENT ON TABLE "discounts"."statutory_evidence_retention_policies" IS 'Approved server-side retention policy metadata for statutory evidence. No default production duration is implied.';;
