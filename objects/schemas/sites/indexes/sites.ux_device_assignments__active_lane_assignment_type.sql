-- Create index "ux_device_assignments__active_lane_assignment_type" to table: "device_assignments"
CREATE UNIQUE INDEX "ux_device_assignments__active_lane_assignment_type" ON "sites"."device_assignments" ("site_id", "lane_id", "assignment_type") WHERE ((assignment_status = 'ACTIVE'::sites.device_assignment_status_enum) AND (lane_id IS NOT NULL));;

