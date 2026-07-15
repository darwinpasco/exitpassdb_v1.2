-- Set comment to column: "request_correlation_id" on table: "hikcentral_gate_action_audits"
COMMENT ON COLUMN "gates"."hikcentral_gate_action_audits"."request_correlation_id" IS 'Safe request correlation identifier used for cross-system tracing.';;
