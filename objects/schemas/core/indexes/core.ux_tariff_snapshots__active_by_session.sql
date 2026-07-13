-- Create index "ux_tariff_snapshots__active_by_session" to table: "tariff_snapshots"
CREATE UNIQUE INDEX "ux_tariff_snapshots__active_by_session" ON "core"."tariff_snapshots" ("parking_session_id") WHERE (snapshot_status = 'ACTIVE'::core.tariff_snapshot_status_enum);;

