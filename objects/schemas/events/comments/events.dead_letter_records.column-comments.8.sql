-- Set comment to column: "payload_hash" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."payload_hash" IS 'Payload hash associated with dead-lettered event.';;

