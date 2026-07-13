-- Set comment to column: "penalty_seconds" on table: "rate_limit_policies"
COMMENT ON COLUMN "config"."rate_limit_policies"."penalty_seconds" IS 'Lockout or penalty duration after violation.';;

