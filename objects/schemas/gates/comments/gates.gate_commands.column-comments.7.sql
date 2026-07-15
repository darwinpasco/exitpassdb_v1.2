-- Set comment to column: "parking_session_id" on table: "gate_commands"
COMMENT ON COLUMN "gates"."gate_commands"."parking_session_id" IS 'Copied transaction trace identifier for the parking session associated with the command.';;
