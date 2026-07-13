-- Set comment to column: "source_ip_hash" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."source_ip_hash" IS 'Hash of source IP where retained.';;

