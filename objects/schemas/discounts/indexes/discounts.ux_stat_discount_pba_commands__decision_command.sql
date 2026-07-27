-- Create index
CREATE UNIQUE INDEX "ux_stat_discount_pba_commands__decision_command" ON "discounts"."statutory_discount_payable_basis_application_commands" ("statutory_discount_decision_command_id");;
