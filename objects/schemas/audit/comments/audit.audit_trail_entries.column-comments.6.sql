-- Set comment to column: "before_value_hash" on table: "audit_trail_entries"
COMMENT ON COLUMN "audit"."audit_trail_entries"."before_value_hash" IS 'Hash of previous value where value is sensitive or large.';;

