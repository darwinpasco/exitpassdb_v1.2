CREATE TABLE "identity"."privileged_access_decisions" (
  "privileged_access_decision_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "privileged_access_request_id" uuid NOT NULL,
  "decision_sequence" integer NOT NULL,
  "decision" "identity"."privileged_access_decision_enum" NOT NULL,
  "decision_reason_code" character varying(64) NOT NULL,
  "decided_at" timestamptz NOT NULL,
  "decided_by_user_id" uuid NOT NULL,
  "decider_human_session_id" uuid NOT NULL,
  "correlation_id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NULL,
  CONSTRAINT "pk_privileged_access_decisions" PRIMARY KEY ("privileged_access_decision_id"),
  CONSTRAINT "uq_privileged_access_decisions__sequence" UNIQUE ("privileged_access_request_id", "decision_sequence"),
  CONSTRAINT "uq_privileged_access_decisions__decider" UNIQUE ("privileged_access_request_id", "decided_by_user_id"),
  CONSTRAINT "fk_privileged_access_decisions__request" FOREIGN KEY ("privileged_access_request_id") REFERENCES "identity"."privileged_access_requests" ("privileged_access_request_id"),
  CONSTRAINT "fk_privileged_access_decisions__decider" FOREIGN KEY ("decided_by_user_id") REFERENCES "identity"."users" ("user_id"),
  CONSTRAINT "fk_privileged_access_decisions__session" FOREIGN KEY ("decider_human_session_id") REFERENCES "identity"."human_sessions" ("human_session_id"),
  CONSTRAINT "fk_privileged_access_decisions__created_service" FOREIGN KEY ("created_by_service_identity_id") REFERENCES "identity"."service_identities" ("service_identity_id"),
  CONSTRAINT "ck_privileged_access_decisions__sequence" CHECK ("decision_sequence" > 0),
  CONSTRAINT "ck_privileged_access_decisions__reason" CHECK (btrim("decision_reason_code") <> '')
);;

CREATE INDEX "ix_privileged_access_decisions__request_time" ON "identity"."privileged_access_decisions" ("privileged_access_request_id", "decided_at");;
CREATE INDEX "ix_privileged_access_decisions__decider_time" ON "identity"."privileged_access_decisions" ("decided_by_user_id", "decided_at" DESC);;
CREATE INDEX "ix_privileged_access_decisions__correlation" ON "identity"."privileged_access_decisions" ("correlation_id");;

COMMENT ON TABLE "identity"."privileged_access_decisions" IS 'Immutable independent decision evidence for a privileged access request, bound to the deciding human session. Runtime policy determines required approver count and independence; absence of an approved decision never grants authority.';;
