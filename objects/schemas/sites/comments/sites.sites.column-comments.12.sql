-- Set comment to column: "lgu_code" on table: "sites"
COMMENT ON COLUMN "sites"."sites"."lgu_code" IS 'Compatibility LGU or jurisdiction code projection for older statutory discount policy lookups. Authoritative future resolution uses sites.site_jurisdiction_assignments and sites.jurisdictions; existing values must not be silently reinterpreted.';;

