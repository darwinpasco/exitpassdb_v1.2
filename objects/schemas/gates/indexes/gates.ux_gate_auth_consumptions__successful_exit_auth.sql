-- Create index "ux_gate_auth_consumptions__successful_exit_auth" to table: "gate_authorization_consumptions"
CREATE UNIQUE INDEX "ux_gate_auth_consumptions__successful_exit_auth" ON "gates"."gate_authorization_consumptions" ("exit_authorization_id") WHERE (consume_status = 'CONSUMED'::gates.gate_authorization_consumption_status_enum);;

