-- Create index
CREATE UNIQUE INDEX "ux_stat_discount_pba_commands__business_identity" ON "discounts"."statutory_discount_payable_basis_application_commands" ("business_identity");;
