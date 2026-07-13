-- Create index "ux_gate_devices__serial_number" to table: "gate_devices"
CREATE UNIQUE INDEX "ux_gate_devices__serial_number" ON "gates"."gate_devices" ("serial_number") WHERE (serial_number IS NOT NULL);;

