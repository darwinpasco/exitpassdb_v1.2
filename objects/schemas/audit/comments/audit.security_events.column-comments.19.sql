-- Set comment to column: "resolved_by_user_id" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."resolved_by_user_id" IS 'User who resolved or reviewed the event.';;

