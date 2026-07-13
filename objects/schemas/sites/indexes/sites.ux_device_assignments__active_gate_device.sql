-- Create index "ux_device_assignments__active_gate_device" to table: "device_assignments"
CREATE UNIQUE INDEX "ux_device_assignments__active_gate_device" ON "sites"."device_assignments" ("gate_device_id") WHERE ((assignment_status = 'ACTIVE'::sites.device_assignment_status_enum) AND (gate_device_id IS NOT NULL));;

