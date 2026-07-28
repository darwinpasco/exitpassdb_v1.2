COMMENT ON COLUMN "sites"."site_jurisdiction_assignments"."site_id" IS 'Authoritative Site whose parking sessions resolve to this jurisdiction assignment.';;
COMMENT ON COLUMN "sites"."site_jurisdiction_assignments"."jurisdiction_id" IS 'Canonical city or municipality assigned to the Site for the effective window.';;
COMMENT ON COLUMN "sites"."site_jurisdiction_assignments"."effective_from" IS 'Start of assignment authority. Future transactions use this; historical transactions keep the authority frozen on their decision.';;
COMMENT ON COLUMN "sites"."site_jurisdiction_assignments"."effective_to" IS 'End of assignment authority. Null means currently open-ended, not permanent legal certainty.';;
COMMENT ON COLUMN "sites"."site_jurisdiction_assignments"."source_reference" IS 'Safe controlled source or approval reference for the assignment; no raw evidence or secrets.';;
