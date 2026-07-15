-- Set comment to column: "retryable" on table: "hikcentral_gate_action_audits"
COMMENT ON COLUMN "gates"."hikcentral_gate_action_audits"."retryable" IS 'Indicates whether the observed failure classification may be retried by a separate command executor.';;
