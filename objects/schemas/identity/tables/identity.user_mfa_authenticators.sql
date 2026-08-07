CREATE TABLE "identity"."user_mfa_authenticators" (
  "user_mfa_authenticator_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "user_id" uuid NOT NULL,
  "authenticator_type" "identity"."mfa_authenticator_type_enum" NOT NULL DEFAULT 'TOTP',
  "authenticator_status" "identity"."mfa_authenticator_status_enum" NOT NULL DEFAULT 'PENDING_ENROLLMENT',
  "protected_secret_envelope" bytea NOT NULL,
  "protection_key_reference" character varying(256) NOT NULL,
  "protection_key_version" character varying(64) NOT NULL,
  "envelope_format_version" smallint NOT NULL,
  "enrollment_started_at" timestamptz NOT NULL DEFAULT now(),
  "activated_at" timestamptz NULL,
  "last_successfully_used_at" timestamptz NULL,
  "last_successfully_used_time_step" bigint NULL,
  "reset_at" timestamptz NULL,
  "revoked_at" timestamptz NULL,
  "reset_or_revoked_by_user_id" uuid NULL,
  "reset_or_revoked_by_service_identity_id" uuid NULL,
  "status_reason_code" character varying(64) NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_user_mfa_authenticators" PRIMARY KEY ("user_mfa_authenticator_id"),
  CONSTRAINT "fk_user_mfa_authenticators__user" FOREIGN KEY ("user_id") REFERENCES "identity"."users" ("user_id"),
  CONSTRAINT "fk_user_mfa_authenticators__reset_user" FOREIGN KEY ("reset_or_revoked_by_user_id") REFERENCES "identity"."users" ("user_id"),
  CONSTRAINT "fk_user_mfa_authenticators__reset_service" FOREIGN KEY ("reset_or_revoked_by_service_identity_id") REFERENCES "identity"."service_identities" ("service_identity_id"),
  CONSTRAINT "ck_user_mfa_authenticators__protected_envelope" CHECK (octet_length("protected_secret_envelope") >= 32),
  CONSTRAINT "ck_user_mfa_authenticators__key_metadata" CHECK (btrim("protection_key_reference") <> '' AND btrim("protection_key_version") <> '' AND "envelope_format_version" > 0),
  CONSTRAINT "ck_user_mfa_authenticators__activation" CHECK (("authenticator_status" = 'PENDING_ENROLLMENT' AND "activated_at" IS NULL) OR ("authenticator_status" <> 'PENDING_ENROLLMENT' AND "activated_at" IS NOT NULL)),
  CONSTRAINT "ck_user_mfa_authenticators__last_use" CHECK (("last_successfully_used_at" IS NULL) = ("last_successfully_used_time_step" IS NULL) AND ("last_successfully_used_time_step" IS NULL OR "last_successfully_used_time_step" >= 0)),
  CONSTRAINT "ck_user_mfa_authenticators__termination" CHECK (("authenticator_status" = 'REVOKED') = ("revoked_at" IS NOT NULL)),
  CONSTRAINT "ck_user_mfa_authenticators__reset" CHECK (("authenticator_status" = 'RESET_REQUIRED' AND "reset_at" IS NOT NULL AND "revoked_at" IS NULL) OR ("authenticator_status" <> 'RESET_REQUIRED' AND "reset_at" IS NULL)),
  CONSTRAINT "ck_user_mfa_authenticators__reset_actor" CHECK (("reset_at" IS NULL AND "revoked_at" IS NULL AND "reset_or_revoked_by_user_id" IS NULL AND "reset_or_revoked_by_service_identity_id" IS NULL) OR (("reset_at" IS NOT NULL OR "revoked_at" IS NOT NULL) AND num_nonnulls("reset_or_revoked_by_user_id", "reset_or_revoked_by_service_identity_id") = 1)),
  CONSTRAINT "ck_user_mfa_authenticators__termination_reason" CHECK ("authenticator_status" NOT IN ('RESET_REQUIRED', 'REVOKED') OR ("status_reason_code" IS NOT NULL AND btrim("status_reason_code") <> '')),
  CONSTRAINT "ck_user_mfa_authenticators__row_version" CHECK ("row_version" > 0)
);;

CREATE UNIQUE INDEX "ux_user_mfa_authenticators__current_type" ON "identity"."user_mfa_authenticators" ("user_id", "authenticator_type") WHERE "authenticator_status" IN ('PENDING_ENROLLMENT', 'ACTIVE', 'SUSPENDED', 'RESET_REQUIRED');;
CREATE INDEX "ix_user_mfa_authenticators__user_status" ON "identity"."user_mfa_authenticators" ("user_id", "authenticator_status");;

COMMENT ON TABLE "identity"."user_mfa_authenticators" IS 'Restricted TOTP authenticator authority. The protected_secret_envelope is application-encrypted opaque ciphertext; encryption keys remain outside ordinary database access. No plaintext seed, OTP code, provisioning URI, QR payload, app export, WebAuthn credential, passkey, or recovery-code plaintext is stored.';;
