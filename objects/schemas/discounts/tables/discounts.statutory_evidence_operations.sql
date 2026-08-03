CREATE TABLE "discounts"."statutory_evidence_operations" (
  "statutory_evidence_operation_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "operation_type" "discounts"."statutory_evidence_operation_type_enum" NOT NULL,
  "operation_status" "discounts"."statutory_evidence_operation_status_enum" NOT NULL,
  "idempotency_scope" character varying(256) NOT NULL,
  "idempotency_key" character varying(128) NOT NULL,
  "semantic_request_hash" character varying(80) NOT NULL,
  "semantic_hash_source_version" character varying(64) NOT NULL,
  "statutory_evidence_set_id" uuid NULL,
  "statutory_evidence_item_id" uuid NULL,
  "safe_result_classification" character varying(64) NOT NULL,
  "correlation_id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  CONSTRAINT "pk_statutory_evidence_operations" PRIMARY KEY ("statutory_evidence_operation_id"),
  CONSTRAINT "uq_statutory_evidence_operations__idempotency" UNIQUE ("idempotency_scope", "idempotency_key"),
  CONSTRAINT "fk_statutory_evidence_operations__set" FOREIGN KEY ("statutory_evidence_set_id") REFERENCES "discounts"."statutory_evidence_sets" ("statutory_evidence_set_id"),
  CONSTRAINT "fk_statutory_evidence_operations__item" FOREIGN KEY ("statutory_evidence_item_id") REFERENCES "discounts"."statutory_evidence_items" ("statutory_evidence_item_id"),
  CONSTRAINT "ck_statutory_evidence_operations__hash" CHECK (semantic_request_hash ~ '^sha256:[0-9a-f]{64}$'),
  CONSTRAINT "ck_statutory_evidence_operations__version" CHECK (semantic_hash_source_version IN ('statutory-evidence-metadata:sha256:v1'))
);;

CREATE INDEX "ix_statutory_evidence_operations__set" ON "discounts"."statutory_evidence_operations" ("statutory_evidence_set_id", "operation_type", "created_at");;
COMMENT ON TABLE "discounts"."statutory_evidence_operations" IS 'Idempotency ledger for statutory evidence metadata operations.';;
