-- Create index "ix_tariff_snapshots__superseded_by_tariff_snapshot_id" to table: "tariff_snapshots"
CREATE INDEX "ix_tariff_snapshots__superseded_by_tariff_snapshot_id" ON "core"."tariff_snapshots" ("superseded_by_tariff_snapshot_id");;

