-- Create index "ix_evidence_links__retention_expires_at" to table: "evidence_links"
CREATE INDEX "ix_evidence_links__retention_expires_at" ON "audit"."evidence_links" ("retention_expires_at");;

