-- Create index
CREATE UNIQUE INDEX "ux_stat_discount_pba_commands__idempotency" ON "discounts"."statutory_discount_payable_basis_application_commands" ("idempotency_scope", "idempotency_key");;
