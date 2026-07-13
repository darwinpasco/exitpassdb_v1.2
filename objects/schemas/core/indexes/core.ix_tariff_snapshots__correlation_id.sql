-- Create index "ix_tariff_snapshots__correlation_id" to table: "tariff_snapshots"
CREATE INDEX "ix_tariff_snapshots__correlation_id" ON "core"."tariff_snapshots" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

