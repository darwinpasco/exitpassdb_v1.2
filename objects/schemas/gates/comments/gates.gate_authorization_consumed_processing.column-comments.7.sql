-- Set comment to column: "parking_session_id" on table: "gate_authorization_consumed_processing"
COMMENT ON COLUMN "gates"."gate_authorization_consumed_processing"."parking_session_id" IS 'Copied transaction trace identifier for the parking session associated with the consume event.';;
