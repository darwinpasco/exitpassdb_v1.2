-- Create index "ux_statutory_discount_decision_commands__idempotency"
CREATE UNIQUE INDEX "ux_statutory_discount_decision_commands__idempotency" ON "discounts"."statutory_discount_decision_commands" ("idempotency_scope", "idempotency_key");;
