-- Create index "ux_device_assignments__active_service_identity" to table: "device_assignments"
CREATE UNIQUE INDEX "ux_device_assignments__active_service_identity" ON "sites"."device_assignments" ("service_identity_id") WHERE ((assignment_status = 'ACTIVE'::sites.device_assignment_status_enum) AND (service_identity_id IS NOT NULL));;

