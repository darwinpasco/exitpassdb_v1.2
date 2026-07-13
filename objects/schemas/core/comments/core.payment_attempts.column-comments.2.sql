-- Set comment to column: "tariff_snapshot_id" on table: "payment_attempts"
COMMENT ON COLUMN "core"."payment_attempts"."tariff_snapshot_id" IS 'Immutable payable basis used by this attempt.';;

