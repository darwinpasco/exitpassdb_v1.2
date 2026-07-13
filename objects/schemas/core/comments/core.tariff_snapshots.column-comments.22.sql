-- Set comment to column: "row_version" on table: "tariff_snapshots"
COMMENT ON COLUMN "core"."tariff_snapshots"."row_version" IS 'Optimistic concurrency version.';;

