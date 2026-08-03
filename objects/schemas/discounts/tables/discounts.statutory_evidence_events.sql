CREATE TABLE "discounts"."statutory_evidence_events" (
  "statutory_evidence_event_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "event_type" "discounts"."statutory_evidence_event_type_enum" NOT NULL,
  "event_result" "discounts"."statutory_evidence_event_result_enum" NOT NULL,
  "statutory_evidence_set_id" uuid NULL,
  "statutory_evidence_item_id" uuid NULL,
  "statutory_evidence_operation_id" uuid NULL,
  "safe_reason_code" character varying(128) NULL,
  "source_channel" character varying(64) NULL,
  "site_id" uuid NULL,
  "site_group_id" uuid NULL,
  "parking_session_id" uuid NULL,
  "actor_user_id" uuid NULL,
  "actor_service_identity_id" uuid NULL,
  "correlation_id" uuid NOT NULL,
  "occurred_at" timestamptz NOT NULL DEFAULT now(),
  "created_at" timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT "pk_statutory_evidence_events" PRIMARY KEY ("statutory_evidence_event_id"),
  CONSTRAINT "fk_statutory_evidence_events__set" FOREIGN KEY ("statutory_evidence_set_id") REFERENCES "discounts"."statutory_evidence_sets" ("statutory_evidence_set_id"),
  CONSTRAINT "fk_statutory_evidence_events__item" FOREIGN KEY ("statutory_evidence_item_id") REFERENCES "discounts"."statutory_evidence_items" ("statutory_evidence_item_id"),
  CONSTRAINT "fk_statutory_evidence_events__operation" FOREIGN KEY ("statutory_evidence_operation_id") REFERENCES "discounts"."statutory_evidence_operations" ("statutory_evidence_operation_id"),
  CONSTRAINT "fk_statutory_evidence_events__site" FOREIGN KEY ("site_id") REFERENCES "sites"."sites" ("site_id"),
  CONSTRAINT "fk_statutory_evidence_events__site_group" FOREIGN KEY ("site_group_id") REFERENCES "sites"."site_groups" ("site_group_id"),
  CONSTRAINT "fk_statutory_evidence_events__parking_session" FOREIGN KEY ("parking_session_id") REFERENCES "core"."parking_sessions" ("parking_session_id"),
  CONSTRAINT "ck_statutory_evidence_events__source_channel" CHECK (source_channel IS NULL OR source_channel IN ('WEBPAY', 'ASSISTED_PAYMENT_TERMINAL', 'OPERATOR_CONSOLE', 'CENTRAL_PMS'))
);;

CREATE INDEX "ix_statutory_evidence_events__set" ON "discounts"."statutory_evidence_events" ("statutory_evidence_set_id", "occurred_at");;
CREATE INDEX "ix_statutory_evidence_events__correlation" ON "discounts"."statutory_evidence_events" ("correlation_id");;
CREATE INDEX "ix_statutory_evidence_events__site_scope" ON "discounts"."statutory_evidence_events" ("site_id", "site_group_id", "event_type");;
COMMENT ON TABLE "discounts"."statutory_evidence_events" IS 'Append-only privacy-safe statutory evidence lifecycle, access, denial, and security events. It stores no evidence bytes, signed URLs, object keys, raw request bodies, or checksums.';;
