CREATE UNIQUE INDEX "ux_fiscal_issuance_references__active_statutory_application"
  ON "core"."fiscal_issuance_references" ("statutory_discount_payable_basis_application_command_id")
  WHERE is_active AND NOT is_superseded
    AND statutory_discount_payable_basis_application_command_id IS NOT NULL;;
