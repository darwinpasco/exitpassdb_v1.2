-- Set comment to column: "payment_confirmation_id" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."payment_confirmation_id" IS 'Recorded payment confirmation for PAYMENT_FINALITY; null for statutory zero-payable completion.';;

