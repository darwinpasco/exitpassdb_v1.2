ALTER TABLE "core"."exit_authorizations"
  ADD CONSTRAINT "fk_exit_authorizations__statutory_decision"
  FOREIGN KEY ("statutory_discount_decision_command_id")
  REFERENCES "discounts"."statutory_discount_decision_commands" ("statutory_discount_decision_command_id") DEFERRABLE;;
