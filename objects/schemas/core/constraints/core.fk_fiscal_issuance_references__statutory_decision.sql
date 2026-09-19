ALTER TABLE "core"."fiscal_issuance_references"
  ADD CONSTRAINT "fk_fiscal_issuance_references__statutory_decision"
  FOREIGN KEY ("statutory_discount_decision_command_id")
  REFERENCES "discounts"."statutory_discount_decision_commands" ("statutory_discount_decision_command_id") DEFERRABLE;;
