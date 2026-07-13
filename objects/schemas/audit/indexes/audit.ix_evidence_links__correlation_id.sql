-- Create index "ix_evidence_links__correlation_id" to table: "evidence_links"
CREATE INDEX "ix_evidence_links__correlation_id" ON "audit"."evidence_links" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

