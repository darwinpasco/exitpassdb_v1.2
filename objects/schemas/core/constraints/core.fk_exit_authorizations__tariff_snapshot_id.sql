ALTER TABLE "core"."exit_authorizations"
  ADD CONSTRAINT "fk_exit_authorizations__tariff_snapshot_id"
  FOREIGN KEY ("tariff_snapshot_id") REFERENCES "core"."tariff_snapshots" ("tariff_snapshot_id") DEFERRABLE;;
