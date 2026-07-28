-- Create index "ix_site_jurisdiction_assignments__site_effective"
CREATE INDEX "ix_site_jurisdiction_assignments__site_effective" ON "sites"."site_jurisdiction_assignments" ("site_id", "assignment_status", "effective_from", "effective_to");;
