-- Set comment to column: "request_path" on table: "hikcentral_gate_action_audits"
COMMENT ON COLUMN "gates"."hikcentral_gate_action_audits"."request_path" IS 'Safe request path metadata; no host, credential, header, or body payload is stored.';;
