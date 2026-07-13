-- Create "domain_events" table
CREATE TABLE "events"."domain_events" (
  "domain_event_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "source_schema" character varying(64) NOT NULL,
  "source_table" character varying(96) NULL,
  "event_type" character varying(128) NOT NULL,
  "event_version" integer NOT NULL DEFAULT 1,
  "aggregate_type" character varying(96) NOT NULL,
  "aggregate_id" uuid NOT NULL,
  "related_entity_type" character varying(96) NULL,
  "related_entity_id" uuid NULL,
  "event_status" "events"."domain_event_status_enum" NOT NULL,
  "payload_ref" character varying(256) NULL,
  "payload_hash" character(64) NULL,
  "metadata_ref" character varying(256) NULL,
  "occurred_at" timestamptz NOT NULL,
  "recorded_at" timestamptz NOT NULL DEFAULT now(),
  "actor_user_id" uuid NULL,
  "actor_service_identity_id" uuid NULL,
  "correlation_id" uuid NULL,
  "causation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NULL,
  CONSTRAINT "pk_domain_events" PRIMARY KEY ("domain_event_id")
);;

