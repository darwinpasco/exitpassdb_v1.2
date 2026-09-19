ALTER TABLE "core"."exit_authorizations"
  ADD CONSTRAINT "fk_exit_authorizations__applied_policy"
  FOREIGN KEY ("applied_policy_reference_id")
  REFERENCES "discounts"."discount_policy_references" ("discount_policy_reference_id") DEFERRABLE;;
