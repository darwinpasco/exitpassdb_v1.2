-- Create index "ix_parking_sessions__correlation_id" to table: "parking_sessions"
CREATE INDEX "ix_parking_sessions__correlation_id" ON "core"."parking_sessions" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

