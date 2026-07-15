-- Set comment to column: "payment_attempt_id" on table: "gate_commands"
COMMENT ON COLUMN "gates"."gate_commands"."payment_attempt_id" IS 'Copied transaction trace identifier for the payment attempt supporting the consumed authorization.';;
