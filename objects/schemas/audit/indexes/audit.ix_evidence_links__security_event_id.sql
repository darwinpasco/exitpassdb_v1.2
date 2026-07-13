-- Create index "ix_evidence_links__security_event_id" to table: "evidence_links"
CREATE INDEX "ix_evidence_links__security_event_id" ON "audit"."evidence_links" ("security_event_id");;

