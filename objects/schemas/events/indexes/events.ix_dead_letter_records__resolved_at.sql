-- Create index "ix_dead_letter_records__resolved_at" to table: "dead_letter_records"
CREATE INDEX "ix_dead_letter_records__resolved_at" ON "events"."dead_letter_records" ("resolved_at");;

