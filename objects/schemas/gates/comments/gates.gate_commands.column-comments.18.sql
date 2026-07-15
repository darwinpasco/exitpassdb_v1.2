-- Set comment to column: "retry_policy_code" on table: "gate_commands"
COMMENT ON COLUMN "gates"."gate_commands"."retry_policy_code" IS 'Retry policy code governing bounded retry behavior for this command.';;
