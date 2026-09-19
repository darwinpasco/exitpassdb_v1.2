-- Set comment to column: "payment_attempt_id" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."payment_attempt_id" IS 'Confirmed payment attempt for PAYMENT_FINALITY; null for statutory zero-payable completion.';;

