-- Create index "ix_dead_letter_records__outbox_event_id" to table: "dead_letter_records"
CREATE INDEX "ix_dead_letter_records__outbox_event_id" ON "events"."dead_letter_records" ("outbox_event_id");;

