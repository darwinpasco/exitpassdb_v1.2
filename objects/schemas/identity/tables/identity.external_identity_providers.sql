CREATE TABLE "identity"."external_identity_providers" (
  "external_identity_provider_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "provider_code" character varying(64) NOT NULL,
  "provider_name" character varying(128) NOT NULL,
  "issuer_identifier_hash" character(64) NOT NULL,
  "provider_status" "identity"."external_identity_provider_status_enum" NOT NULL DEFAULT 'DISABLED',
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_external_identity_providers" PRIMARY KEY ("external_identity_provider_id"),
  CONSTRAINT "uq_external_identity_providers__code" UNIQUE ("provider_code"),
  CONSTRAINT "uq_external_identity_providers__issuer_hash" UNIQUE ("issuer_identifier_hash"),
  CONSTRAINT "ck_external_identity_providers__code" CHECK (btrim("provider_code") <> ''),
  CONSTRAINT "ck_external_identity_providers__name" CHECK (btrim("provider_name") <> ''),
  CONSTRAINT "ck_external_identity_providers__issuer_hash" CHECK ("issuer_identifier_hash" ~ '^[0-9a-f]{64}$'),
  CONSTRAINT "ck_external_identity_providers__effective_window" CHECK ("effective_to" IS NULL OR "effective_to" > "effective_from"),
  CONSTRAINT "ck_external_identity_providers__row_version" CHECK ("row_version" > 0)
);;

CREATE INDEX "ix_external_identity_providers__status" ON "identity"."external_identity_providers" ("provider_status", "effective_from", "effective_to");;

COMMENT ON TABLE "identity"."external_identity_providers" IS 'Optional external authentication provider identity. I-019 seeds no provider and stores no endpoint, client secret, token, assertion, or authorization mapping.';;
