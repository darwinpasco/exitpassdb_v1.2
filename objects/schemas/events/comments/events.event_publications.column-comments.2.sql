-- Set comment to column: "publication_attempt_number" on table: "event_publications"
COMMENT ON COLUMN "events"."event_publications"."publication_attempt_number" IS 'Sequential attempt number for the outbox event.';;

