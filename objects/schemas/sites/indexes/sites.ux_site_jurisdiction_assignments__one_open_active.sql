-- Create unique index "ux_site_jurisdiction_assignments__one_open_active"
CREATE UNIQUE INDEX "ux_site_jurisdiction_assignments__one_open_active" ON "sites"."site_jurisdiction_assignments" ("site_id") WHERE ((assignment_status = 'ACTIVE'::sites.site_jurisdiction_assignment_status_enum) AND (effective_to IS NULL));;
