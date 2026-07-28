-- Create index "ix_jurisdictions__status"
CREATE INDEX "ix_jurisdictions__status" ON "sites"."jurisdictions" ("jurisdiction_status", "jurisdiction_type");;
