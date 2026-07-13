-- Create index "ix_session_identifier_indexes__correlation_id" to table: "session_identifier_indexes"
CREATE INDEX "ix_session_identifier_indexes__correlation_id" ON "sessions"."session_identifier_indexes" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

