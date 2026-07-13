-- Create index "ix_override_approvals__correlation_id" to table: "override_approvals"
CREATE INDEX "ix_override_approvals__correlation_id" ON "operations"."override_approvals" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

