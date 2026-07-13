-- Create index "ix_evidence_links__purged_by_user_id" to table: "evidence_links"
CREATE INDEX "ix_evidence_links__purged_by_user_id" ON "audit"."evidence_links" ("purged_by_user_id");;

