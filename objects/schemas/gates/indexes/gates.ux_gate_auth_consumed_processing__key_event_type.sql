-- Create index "ux_gate_auth_consumed_processing__key_event_type" to table: "gate_authorization_consumed_processing"
CREATE UNIQUE INDEX "ux_gate_auth_consumed_processing__key_event_type" ON "gates"."gate_authorization_consumed_processing" ("processing_key", "event_type");;
