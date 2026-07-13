-- Create index "ux_provider_sessions__active_by_attempt_rail" to table: "provider_sessions"
CREATE UNIQUE INDEX "ux_provider_sessions__active_by_attempt_rail" ON "payments"."provider_sessions" ("payment_attempt_id", "payment_rail_id") WHERE (session_status = ANY (ARRAY['CREATED'::payments.provider_session_status_enum, 'ACTIVE'::payments.provider_session_status_enum, 'PENDING'::payments.provider_session_status_enum]));;

