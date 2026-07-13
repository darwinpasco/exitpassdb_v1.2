-- Create index "ix_evidence_links__linked_by_user_id" to table: "evidence_links"
CREATE INDEX "ix_evidence_links__linked_by_user_id" ON "audit"."evidence_links" ("linked_by_user_id");;

