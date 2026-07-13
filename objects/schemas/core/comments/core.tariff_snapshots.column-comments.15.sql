-- Set comment to column: "expires_at" on table: "tariff_snapshots"
COMMENT ON COLUMN "core"."tariff_snapshots"."expires_at" IS 'Timestamp after which the snapshot may no longer create a payment attempt.';;

