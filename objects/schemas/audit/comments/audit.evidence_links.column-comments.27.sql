-- Set comment to column: "row_version" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."row_version" IS 'Optimistic concurrency version.';;

