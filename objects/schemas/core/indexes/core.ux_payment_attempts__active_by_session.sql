-- Create index "ux_payment_attempts__active_by_session" to table: "payment_attempts"
CREATE UNIQUE INDEX "ux_payment_attempts__active_by_session" ON "core"."payment_attempts" ("parking_session_id") WHERE (attempt_status = ANY (ARRAY['REQUESTED'::core.payment_attempt_status_enum, 'PENDING_PROVIDER'::core.payment_attempt_status_enum, 'PENDING_FINALIZATION'::core.payment_attempt_status_enum]));;

