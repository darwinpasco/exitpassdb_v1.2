-- Create index "ux_gate_auth_consumed_processing__event_id" to table: "gate_authorization_consumed_processing"
CREATE UNIQUE INDEX "ux_gate_auth_consumed_processing__event_id" ON "gates"."gate_authorization_consumed_processing" ("event_id") WHERE ("event_id" IS NOT NULL);;
