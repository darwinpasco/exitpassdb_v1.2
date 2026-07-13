-- Set comment to column: "audit_event_id" on table: "audit_trail_entries"
COMMENT ON COLUMN "audit"."audit_trail_entries"."audit_event_id" IS 'Parent audit event, where applicable.';;

