-- Create index "ix_security_events__incident_record_id" to table: "security_events"
CREATE INDEX "ix_security_events__incident_record_id" ON "audit"."security_events" ("incident_record_id");;

