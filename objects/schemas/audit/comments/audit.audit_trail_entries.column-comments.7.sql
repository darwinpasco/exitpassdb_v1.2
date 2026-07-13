-- Set comment to column: "after_value_hash" on table: "audit_trail_entries"
COMMENT ON COLUMN "audit"."audit_trail_entries"."after_value_hash" IS 'Hash of new value where value is sensitive or large.';;

