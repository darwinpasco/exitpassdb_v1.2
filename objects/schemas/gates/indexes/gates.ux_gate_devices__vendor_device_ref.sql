-- Create index "ux_gate_devices__vendor_device_ref" to table: "gate_devices"
CREATE UNIQUE INDEX "ux_gate_devices__vendor_device_ref" ON "gates"."gate_devices" ("site_id", "vendor_device_ref") WHERE (vendor_device_ref IS NOT NULL);;

