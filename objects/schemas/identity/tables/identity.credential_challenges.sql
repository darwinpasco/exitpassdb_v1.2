CREATE TABLE "identity"."credential_challenges" (
  "credential_challenge_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "challenge_reference" uuid NOT NULL DEFAULT gen_random_uuid(),
  "user_id" uuid NOT NULL,
  "challenge_purpose" "identity"."credential_challenge_purpose_enum" NOT NULL,
  "challenge_status" "identity"."credential_challenge_status_enum" NOT NULL DEFAULT 'ISSUED',
  "challenge_secret_hash" character(64) NOT NULL,
  "issued_at" timestamptz NOT NULL,
  "expires_at" timestamptz NOT NULL,
  "consumed_at" timestamptz NULL,
  "revoked_at" timestamptz NULL,
  "requested_by_user_id" uuid NULL,
  "requested_by_service_identity_id" uuid NULL,
  "revoked_by_user_id" uuid NULL,
  "revoked_by_service_identity_id" uuid NULL,
  "reason_code" character varying(64) NULL,
  "correlation_id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_credential_challenges" PRIMARY KEY ("credential_challenge_id"),
  CONSTRAINT "uq_credential_challenges__reference" UNIQUE ("challenge_reference"),
  CONSTRAINT "uq_credential_challenges__secret_hash" UNIQUE ("challenge_secret_hash"),
  CONSTRAINT "fk_credential_challenges__user" FOREIGN KEY ("user_id") REFERENCES "identity"."users" ("user_id"),
  CONSTRAINT "fk_credential_challenges__requested_user" FOREIGN KEY ("requested_by_user_id") REFERENCES "identity"."users" ("user_id"),
  CONSTRAINT "fk_credential_challenges__requested_service" FOREIGN KEY ("requested_by_service_identity_id") REFERENCES "identity"."service_identities" ("service_identity_id"),
  CONSTRAINT "fk_credential_challenges__revoked_user" FOREIGN KEY ("revoked_by_user_id") REFERENCES "identity"."users" ("user_id"),
  CONSTRAINT "fk_credential_challenges__revoked_service" FOREIGN KEY ("revoked_by_service_identity_id") REFERENCES "identity"."service_identities" ("service_identity_id"),
  CONSTRAINT "ck_credential_challenges__secret_hash" CHECK ("challenge_secret_hash" ~ '^[0-9a-f]{64}$'),
  CONSTRAINT "ck_credential_challenges__request_actor" CHECK (num_nonnulls("requested_by_user_id", "requested_by_service_identity_id") = 1),
  CONSTRAINT "ck_credential_challenges__expiry" CHECK ("expires_at" > "issued_at"),
  CONSTRAINT "ck_credential_challenges__lifecycle" CHECK (("challenge_status" = 'ISSUED' AND "consumed_at" IS NULL AND "revoked_at" IS NULL) OR ("challenge_status" = 'CONSUMED' AND "consumed_at" IS NOT NULL AND "revoked_at" IS NULL) OR ("challenge_status" = 'REVOKED' AND "consumed_at" IS NULL AND "revoked_at" IS NOT NULL) OR ("challenge_status" = 'EXPIRED' AND "consumed_at" IS NULL AND "revoked_at" IS NULL)),
  CONSTRAINT "ck_credential_challenges__consumed_at" CHECK ("consumed_at" IS NULL OR ("consumed_at" >= "issued_at" AND "consumed_at" <= "expires_at")),
  CONSTRAINT "ck_credential_challenges__revoked_at" CHECK ("revoked_at" IS NULL OR "revoked_at" >= "issued_at"),
  CONSTRAINT "ck_credential_challenges__revocation_actor" CHECK (("revoked_at" IS NULL AND "revoked_by_user_id" IS NULL AND "revoked_by_service_identity_id" IS NULL) OR ("revoked_at" IS NOT NULL AND num_nonnulls("revoked_by_user_id", "revoked_by_service_identity_id") = 1)),
  CONSTRAINT "ck_credential_challenges__row_version" CHECK ("row_version" > 0)
);;

CREATE UNIQUE INDEX "ux_credential_challenges__issued_user_purpose" ON "identity"."credential_challenges" ("user_id", "challenge_purpose") WHERE "challenge_status" = 'ISSUED';;
CREATE INDEX "ix_credential_challenges__user_status_expiry" ON "identity"."credential_challenges" ("user_id", "challenge_status", "expires_at");;
CREATE INDEX "ix_credential_challenges__correlation" ON "identity"."credential_challenges" ("correlation_id");;

COMMENT ON TABLE "identity"."credential_challenges" IS 'Purpose-bound one-time account activation, password reset, and recovery challenges. Only a challenge-secret hash is stored; delivery channel remains unresolved runtime policy and raw activation/reset values are prohibited.';;
