COMMENT ON COLUMN "sites"."jurisdictions"."jurisdiction_id" IS 'Stable canonical jurisdiction identifier for city or municipality policy authority.';;
COMMENT ON COLUMN "sites"."jurisdictions"."jurisdiction_code" IS 'Canonical jurisdiction code. This is not a display name and may be mapped to PSGC when available.';;
COMMENT ON COLUMN "sites"."jurisdictions"."jurisdiction_type" IS 'City or municipality classification for current parking-policy scope.';;
COMMENT ON COLUMN "sites"."jurisdictions"."psgc_code" IS 'Official PSGC or equivalent code when available; null means not yet assigned, not that no jurisdiction exists.';;
COMMENT ON COLUMN "sites"."jurisdictions"."replaced_by_jurisdiction_id" IS 'Historical correction or replacement pointer. Runtime must not rewrite past transaction authority when this value changes.';;
