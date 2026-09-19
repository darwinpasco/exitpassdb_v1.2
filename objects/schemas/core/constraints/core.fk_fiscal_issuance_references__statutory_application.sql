ALTER TABLE "core"."fiscal_issuance_references"
  ADD CONSTRAINT "fk_fiscal_issuance_references__statutory_application"
  FOREIGN KEY ("statutory_discount_payable_basis_application_command_id")
  REFERENCES "discounts"."statutory_discount_payable_basis_application_commands" ("statutory_discount_payable_basis_application_command_id") DEFERRABLE;;
