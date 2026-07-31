-- Create index "ix_philippine_provinces__region"
CREATE INDEX "ix_philippine_provinces__region" ON "sites"."philippine_provinces" ("philippine_region_id", "province_status");;