-- Set comment to column: "request_hash" on table: "hikcentral_gate_action_audits"
COMMENT ON COLUMN "gates"."hikcentral_gate_action_audits"."request_hash" IS 'Lowercase SHA-256 hash of the safe canonical request body representation; raw body content is not stored.';;
