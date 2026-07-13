-- Create index "ux_provider_sessions__provider_ref" to table: "provider_sessions"
CREATE UNIQUE INDEX "ux_provider_sessions__provider_ref" ON "payments"."provider_sessions" ("payment_rail_id", "provider_session_ref") WHERE (provider_session_ref IS NOT NULL);;

