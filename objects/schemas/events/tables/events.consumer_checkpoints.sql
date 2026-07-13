-- Create "consumer_checkpoints" table
CREATE TABLE "events"."consumer_checkpoints" (
  "consumer_checkpoint_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "consumer_name" character varying(128) NOT NULL,
  "consumer_group" character varying(128) NULL,
  "subscription_name" character varying(128) NULL,
  "event_type" character varying(128) NULL,
  "aggregate_type" character varying(96) NULL,
  "last_outbox_event_id" uuid NULL,
  "last_domain_event_id" uuid NULL,
  "last_broker_offset" character varying(128) NULL,
  "checkpoint_status" "events"."consumer_checkpoint_status_enum" NOT NULL,
  "processed_count" bigint NOT NULL DEFAULT 0,
  "failure_count" bigint NOT NULL DEFAULT 0,
  "last_processed_at" timestamptz NULL,
  "last_failed_at" timestamptz NULL,
  "failure_reason_code" character varying(64) NULL,
  "locked_at" timestamptz NULL,
  "locked_by_service_identity_id" uuid NULL,
  "updated_by_service_identity_id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "correlation_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_consumer_checkpoints" PRIMARY KEY ("consumer_checkpoint_id")
);;

