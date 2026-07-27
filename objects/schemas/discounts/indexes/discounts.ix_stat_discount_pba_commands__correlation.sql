-- Create index
CREATE INDEX "ix_stat_discount_pba_commands__correlation" ON "discounts"."statutory_discount_payable_basis_application_commands" ("original_correlation_id");;
