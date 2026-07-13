-- Set comment to column: "retention_expires_at" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."retention_expires_at" IS 'Timestamp when evidence becomes eligible for purge or redaction.';;

