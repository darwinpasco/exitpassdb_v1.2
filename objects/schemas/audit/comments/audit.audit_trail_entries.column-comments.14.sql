-- Set comment to column: "changed_by_service_identity_id" on table: "audit_trail_entries"
COMMENT ON COLUMN "audit"."audit_trail_entries"."changed_by_service_identity_id" IS 'Service actor responsible for change.';;

