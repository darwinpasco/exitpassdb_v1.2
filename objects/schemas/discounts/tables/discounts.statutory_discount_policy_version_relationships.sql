-- Create "statutory_discount_policy_version_relationships" table
CREATE TABLE "discounts"."statutory_discount_policy_version_relationships" (
  "statutory_discount_policy_version_relationship_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "source_policy_version_id" uuid NOT NULL,
  "target_policy_version_id" uuid NOT NULL,
  "relationship_type" "discounts"."policy_relationship_type_enum" NOT NULL,
  "effective_from" timestamptz NULL,
  "effective_to" timestamptz NULL,
  "source_reference" character varying(256) NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  CONSTRAINT "pk_sd_policy_version_relationships" PRIMARY KEY ("statutory_discount_policy_version_relationship_id"),
  CONSTRAINT "fk_sd_policy_version_relationships__source" FOREIGN KEY ("source_policy_version_id") REFERENCES "discounts"."statutory_discount_policy_versions" ("statutory_discount_policy_version_id"),
  CONSTRAINT "fk_sd_policy_version_relationships__target" FOREIGN KEY ("target_policy_version_id") REFERENCES "discounts"."statutory_discount_policy_versions" ("statutory_discount_policy_version_id"),
  CONSTRAINT "uq_sd_policy_version_relationships__edge" UNIQUE ("source_policy_version_id", "target_policy_version_id", "relationship_type"),
  CONSTRAINT "ck_sd_policy_version_relationships__no_self" CHECK (source_policy_version_id <> target_policy_version_id),
  CONSTRAINT "ck_sd_policy_version_relationships__effective_window" CHECK ((effective_to IS NULL) OR (effective_from IS NULL) OR (effective_to > effective_from))
);;
