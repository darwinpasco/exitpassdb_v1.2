-- Create index "ix_dead_letter_records__correlation_id" to table: "dead_letter_records"
CREATE INDEX "ix_dead_letter_records__correlation_id" ON "events"."dead_letter_records" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

