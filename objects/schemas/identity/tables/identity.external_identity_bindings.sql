CREATE TABLE "identity"."external_identity_bindings" (
  "external_identity_binding_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "user_id" uuid NOT NULL,
  "external_identity_provider_id" uuid NOT NULL,
  "external_subject_hash" character(64) NOT NULL,
  "binding_status" "identity"."external_identity_binding_status_enum" NOT NULL DEFAULT 'PENDING',
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "revoked_at" timestamptz NULL,
  "revoked_by_user_id" uuid NULL,
  "revoked_by_service_identity_id" uuid NULL,
  "revocation_reason_code" character varying(64) NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_external_identity_bindings" PRIMARY KEY ("external_identity_binding_id"),
  CONSTRAINT "fk_external_identity_bindings__user" FOREIGN KEY ("user_id") REFERENCES "identity"."users" ("user_id"),
  CONSTRAINT "fk_external_identity_bindings__provider" FOREIGN KEY ("external_identity_provider_id") REFERENCES "identity"."external_identity_providers" ("external_identity_provider_id"),
  CONSTRAINT "fk_external_identity_bindings__revoked_by_user" FOREIGN KEY ("revoked_by_user_id") REFERENCES "identity"."users" ("user_id"),
  CONSTRAINT "fk_external_identity_bindings__revoked_by_service" FOREIGN KEY ("revoked_by_service_identity_id") REFERENCES "identity"."service_identities" ("service_identity_id"),
  CONSTRAINT "ck_external_identity_bindings__subject_hash" CHECK ("external_subject_hash" ~ '^[0-9a-f]{64}$'),
  CONSTRAINT "ck_external_identity_bindings__effective_window" CHECK ("effective_to" IS NULL OR "effective_to" > "effective_from"),
  CONSTRAINT "ck_external_identity_bindings__revocation" CHECK (("binding_status" = 'REVOKED') = ("revoked_at" IS NOT NULL)),
  CONSTRAINT "ck_external_identity_bindings__revocation_actor" CHECK (("revoked_at" IS NULL AND "revoked_by_user_id" IS NULL AND "revoked_by_service_identity_id" IS NULL) OR ("revoked_at" IS NOT NULL AND num_nonnulls("revoked_by_user_id", "revoked_by_service_identity_id") = 1)),
  CONSTRAINT "ck_external_identity_bindings__row_version" CHECK ("row_version" > 0)
);;

CREATE UNIQUE INDEX "ux_external_identity_bindings__current_subject" ON "identity"."external_identity_bindings" ("external_identity_provider_id", "external_subject_hash") WHERE "binding_status" IN ('PENDING', 'ACTIVE', 'SUSPENDED');;
CREATE UNIQUE INDEX "ux_external_identity_bindings__current_user_provider" ON "identity"."external_identity_bindings" ("user_id", "external_identity_provider_id") WHERE "binding_status" IN ('PENDING', 'ACTIVE', 'SUSPENDED');;
CREATE INDEX "ix_external_identity_bindings__user_status" ON "identity"."external_identity_bindings" ("user_id", "binding_status");;

COMMENT ON TABLE "identity"."external_identity_bindings" IS 'Optional binding from an ExitPass human user to a configured provider and immutable external-subject hash. Email, provider groups, tokens, and assertions are not identity or authorization authority here.';;
