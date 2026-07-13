-- Create index "ux_gate_devices__service_identity" to table: "gate_devices"
CREATE UNIQUE INDEX "ux_gate_devices__service_identity" ON "gates"."gate_devices" ("service_identity_id") WHERE (service_identity_id IS NOT NULL);;

