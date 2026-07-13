-- Set comment to column: "plate_number_hash" on table: "parking_sessions"
COMMENT ON COLUMN "core"."parking_sessions"."plate_number_hash" IS 'Hash of normalized plate number for lookup and privacy-aware traceability.';;

