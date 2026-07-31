COMMENT ON COLUMN "sites"."jurisdictions"."jurisdiction_id" IS 'Stable canonical jurisdiction identifier for city or municipality policy authority.';;
COMMENT ON COLUMN "sites"."jurisdictions"."jurisdiction_code" IS 'Canonical jurisdiction code. This is not a display name and may be mapped to PSGC when available.';;
COMMENT ON COLUMN "sites"."jurisdictions"."jurisdiction_type" IS 'City or municipality classification for current parking-policy scope.';;
COMMENT ON COLUMN "sites"."jurisdictions"."psgc_code" IS 'Official PSGC or equivalent code when available; null means not yet assigned, not that no jurisdiction exists.';;
COMMENT ON COLUMN "sites"."jurisdictions"."replaced_by_jurisdiction_id" IS 'Historical correction or replacement pointer. Runtime must not rewrite past transaction authority when this value changes.';;
COMMENT ON COLUMN "sites"."jurisdictions"."philippine_region_id" IS 'Canonical Philippine region parent for city or municipality LGUs; nullable only for legacy unresolved rows.';;
COMMENT ON COLUMN "sites"."jurisdictions"."philippine_province_id" IS 'Canonical Philippine province parent when official PSGC hierarchy has one; null for NCR LGUs and administratively independent highly urbanized cities.';;
COMMENT ON COLUMN "sites"."jurisdictions"."city_classification" IS 'Controlled classification for city LGUs, preserving HUC and independent-component semantics where known.';;
