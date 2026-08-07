CREATE TABLE "identity"."local_credentials" (
  "local_credential_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "user_id" uuid NOT NULL,
  "credential_status" "identity"."local_credential_status_enum" NOT NULL DEFAULT 'PENDING_ACTIVATION',
  "password_verifier" bytea NOT NULL,
  "verifier_salt" bytea NOT NULL,
  "verifier_algorithm_code" character varying(32) NOT NULL,
  "verifier_algorithm_version" smallint NOT NULL,
  "verifier_work_factor" integer NOT NULL,
  "verifier_memory_kib" integer NULL,
  "verifier_parallelism" smallint NULL,
  "credential_version" bigint NOT NULL DEFAULT 1,
  "activated_at" timestamptz NULL,
  "last_changed_at" timestamptz NULL,
  "revoked_at" timestamptz NULL,
  "revoked_by_user_id" uuid NULL,
  "revoked_by_service_identity_id" uuid NULL,
  "status_reason_code" character varying(64) NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_local_credentials" PRIMARY KEY ("local_credential_id"),
  CONSTRAINT "fk_local_credentials__user" FOREIGN KEY ("user_id") REFERENCES "identity"."users" ("user_id"),
  CONSTRAINT "fk_local_credentials__revoked_by_user" FOREIGN KEY ("revoked_by_user_id") REFERENCES "identity"."users" ("user_id"),
  CONSTRAINT "fk_local_credentials__revoked_by_service" FOREIGN KEY ("revoked_by_service_identity_id") REFERENCES "identity"."service_identities" ("service_identity_id"),
  CONSTRAINT "ck_local_credentials__verifier" CHECK (octet_length("password_verifier") >= 32 AND octet_length("verifier_salt") >= 16),
  CONSTRAINT "ck_local_credentials__algorithm" CHECK (btrim("verifier_algorithm_code") <> '' AND "verifier_algorithm_version" > 0),
  CONSTRAINT "ck_local_credentials__work_parameters" CHECK ("verifier_work_factor" > 0 AND ("verifier_memory_kib" IS NULL OR "verifier_memory_kib" > 0) AND ("verifier_parallelism" IS NULL OR "verifier_parallelism" > 0)),
  CONSTRAINT "ck_local_credentials__activation" CHECK ("credential_status" = 'PENDING_ACTIVATION' OR "activated_at" IS NOT NULL),
  CONSTRAINT "ck_local_credentials__revocation" CHECK (("credential_status" = 'REVOKED') = ("revoked_at" IS NOT NULL)),
  CONSTRAINT "ck_local_credentials__revocation_actor" CHECK (("revoked_at" IS NULL AND "revoked_by_user_id" IS NULL AND "revoked_by_service_identity_id" IS NULL) OR ("revoked_at" IS NOT NULL AND num_nonnulls("revoked_by_user_id", "revoked_by_service_identity_id") = 1)),
  CONSTRAINT "ck_local_credentials__changed_at" CHECK ("last_changed_at" IS NULL OR "last_changed_at" >= "created_at"),
  CONSTRAINT "ck_local_credentials__credential_version" CHECK ("credential_version" > 0),
  CONSTRAINT "ck_local_credentials__row_version" CHECK ("row_version" > 0)
);;

CREATE UNIQUE INDEX "ux_local_credentials__current_user" ON "identity"."local_credentials" ("user_id") WHERE "credential_status" IN ('PENDING_ACTIVATION', 'ACTIVE', 'CHANGE_REQUIRED', 'LOCKED');;
CREATE INDEX "ix_local_credentials__user_status" ON "identity"."local_credentials" ("user_id", "credential_status");;

COMMENT ON TABLE "identity"."local_credentials" IS 'Restricted local human credential verifier authority. Stores one-way verifier material and upgrade parameters only; it stores no plaintext or recoverable password, hint, reset token, session secret, or provider password.';;
