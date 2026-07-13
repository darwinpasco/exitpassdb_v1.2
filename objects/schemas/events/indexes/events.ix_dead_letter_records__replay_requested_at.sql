-- Create index "ix_dead_letter_records__replay_requested_at" to table: "dead_letter_records"
CREATE INDEX "ix_dead_letter_records__replay_requested_at" ON "events"."dead_letter_records" ("replay_requested_at");;

