CREATE TABLE "identity"."authentication_attempts" (
  "authentication_attempt_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "user_id" uuid NULL,
  "login_identifier_hash" character(64) NULL,
  "attempt_type" "identity"."authentication_attempt_type_enum" NOT NULL,
  "attempt_result" "identity"."authentication_attempt_result_enum" NOT NULL,
  "session_audience" "identity"."human_session_audience_enum" NOT NULL,
  "source_ip_hash" character(64) NULL,
  "user_agent_hash" character(64) NULL,
  "request_fingerprint_hash" character(64) NULL,
  "reason_code" character varying(64) NULL,
  "observed_at" timestamptz NOT NULL,
  "correlation_id" uuid NOT NULL,
  "recorded_by_service_identity_id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT "pk_authentication_attempts" PRIMARY KEY ("authentication_attempt_id"),
  CONSTRAINT "fk_authentication_attempts__user" FOREIGN KEY ("user_id") REFERENCES "identity"."users" ("user_id"),
  CONSTRAINT "fk_authentication_attempts__recorded_by_service" FOREIGN KEY ("recorded_by_service_identity_id") REFERENCES "identity"."service_identities" ("service_identity_id"),
  CONSTRAINT "ck_authentication_attempts__principal" CHECK ("user_id" IS NOT NULL OR "login_identifier_hash" IS NOT NULL),
  CONSTRAINT "ck_authentication_attempts__login_hash" CHECK ("login_identifier_hash" IS NULL OR "login_identifier_hash" ~ '^[0-9a-f]{64}$'),
  CONSTRAINT "ck_authentication_attempts__source_hash" CHECK ("source_ip_hash" IS NULL OR "source_ip_hash" ~ '^[0-9a-f]{64}$'),
  CONSTRAINT "ck_authentication_attempts__agent_hash" CHECK ("user_agent_hash" IS NULL OR "user_agent_hash" ~ '^[0-9a-f]{64}$'),
  CONSTRAINT "ck_authentication_attempts__fingerprint_hash" CHECK ("request_fingerprint_hash" IS NULL OR "request_fingerprint_hash" ~ '^[0-9a-f]{64}$')
);;

CREATE INDEX "ix_authentication_attempts__user_time" ON "identity"."authentication_attempts" ("user_id", "attempt_type", "observed_at" DESC) WHERE "user_id" IS NOT NULL;;
CREATE INDEX "ix_authentication_attempts__login_time" ON "identity"."authentication_attempts" ("login_identifier_hash", "attempt_type", "observed_at" DESC) WHERE "login_identifier_hash" IS NOT NULL;;
CREATE INDEX "ix_authentication_attempts__source_time" ON "identity"."authentication_attempts" ("source_ip_hash", "observed_at" DESC) WHERE "source_ip_hash" IS NOT NULL;;
CREATE INDEX "ix_authentication_attempts__correlation" ON "identity"."authentication_attempts" ("correlation_id");;

COMMENT ON TABLE "identity"."authentication_attempts" IS 'Privacy-bounded immutable authentication attempt evidence for password, TOTP, activation, reset, and recovery throttling. It stores no password, verifier submission, OTP code, TOTP secret, raw network address, request body, or token.';;
