-- Set comment to column: "row_version" on table: "service_identities"
COMMENT ON COLUMN "identity"."service_identities"."row_version" IS 'Optimistic concurrency version.';;

