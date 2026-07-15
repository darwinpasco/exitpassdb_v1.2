-- Set comment to column: "payment_attempt_id" on table: "gate_authorization_consumed_processing"
COMMENT ON COLUMN "gates"."gate_authorization_consumed_processing"."payment_attempt_id" IS 'Copied transaction trace identifier for the payment attempt supporting the consumed authorization.';;
