-- Create "event_publications" table
CREATE TABLE "events"."event_publications" (
  "event_publication_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "outbox_event_id" uuid NOT NULL,
  "publication_attempt_number" integer NOT NULL,
  "publisher_service_identity_id" uuid NOT NULL,
  "broker_type" "events"."event_broker_type_enum" NOT NULL,
  "exchange_name" character varying(128) NULL,
  "routing_key" character varying(160) NULL,
  "publication_status" "events"."event_publication_status_enum" NOT NULL,
  "broker_message_id" character varying(128) NULL,
  "broker_acknowledged" boolean NULL,
  "failure_reason_code" character varying(64) NULL,
  "failure_detail_ref" character varying(256) NULL,
  "started_at" timestamptz NOT NULL DEFAULT now(),
  "completed_at" timestamptz NULL,
  "duration_ms" integer NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT "pk_event_publications" PRIMARY KEY ("event_publication_id")
);;

