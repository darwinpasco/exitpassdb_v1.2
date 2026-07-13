-- Create index "ix_dead_letter_records__dead_letter_status" to table: "dead_letter_records"
CREATE INDEX "ix_dead_letter_records__dead_letter_status" ON "events"."dead_letter_records" ("dead_letter_status");;

