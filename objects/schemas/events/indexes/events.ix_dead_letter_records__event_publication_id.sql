-- Create index "ix_dead_letter_records__event_publication_id" to table: "dead_letter_records"
CREATE INDEX "ix_dead_letter_records__event_publication_id" ON "events"."dead_letter_records" ("event_publication_id");;

