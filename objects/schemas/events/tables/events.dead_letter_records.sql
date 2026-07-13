-- Create "dead_letter_records" table
CREATE TABLE "events"."dead_letter_records" (
  "dead_letter_record_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "outbox_event_id" uuid NULL,
  "event_publication_id" uuid NULL,
  "consumer_name" character varying(128) NULL,
  "dead_letter_type" "events"."dead_letter_type_enum" NOT NULL,
  "dead_letter_status" "events"."dead_letter_status_enum" NOT NULL,
  "failure_reason_code" character varying(64) NOT NULL,
  "failure_detail_ref" character varying(256) NULL,
  "payload_hash" character(64) NULL,
  "dead_lettered_at" timestamptz NOT NULL DEFAULT now(),
  "resolved_at" timestamptz NULL,
  "resolved_by_user_id" uuid NULL,
  "resolved_by_service_identity_id" uuid NULL,
  "resolution_reason_code" character varying(64) NULL,
  "replay_requested_at" timestamptz NULL,
  "replay_requested_by_user_id" uuid NULL,
  "replay_requested_by_service_identity_id" uuid NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_dead_letter_records" PRIMARY KEY ("dead_letter_record_id")
);;

