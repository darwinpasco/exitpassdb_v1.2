-- Set comment to column: "user_agent_hash" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."user_agent_hash" IS 'Hash of user agent where retained.';;

