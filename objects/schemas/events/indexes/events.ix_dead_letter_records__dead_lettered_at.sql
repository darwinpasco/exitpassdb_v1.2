-- Create index "ix_dead_letter_records__dead_lettered_at" to table: "dead_letter_records"
CREATE INDEX "ix_dead_letter_records__dead_lettered_at" ON "events"."dead_letter_records" ("dead_lettered_at");;

