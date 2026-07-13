-- Set comment to column: "grace_period_seconds" on table: "ttl_policies"
COMMENT ON COLUMN "config"."ttl_policies"."grace_period_seconds" IS 'Optional grace period for support or cleanup, not validity extension unless domain allows.';;

