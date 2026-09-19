ALTER TABLE "core"."exit_authorizations"
  ADD CONSTRAINT "fk_exit_authorizations__statutory_application"
  FOREIGN KEY ("statutory_discount_payable_basis_application_command_id")
  REFERENCES "discounts"."statutory_discount_payable_basis_application_commands" ("statutory_discount_payable_basis_application_command_id") DEFERRABLE;;
