-- Create index "ux_tariff_snapshots__superseded_by" to table: "tariff_snapshots"
CREATE UNIQUE INDEX "ux_tariff_snapshots__superseded_by" ON "core"."tariff_snapshots" ("superseded_by_tariff_snapshot_id") WHERE (superseded_by_tariff_snapshot_id IS NOT NULL);;

