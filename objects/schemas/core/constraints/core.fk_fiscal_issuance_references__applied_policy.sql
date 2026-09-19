ALTER TABLE "core"."fiscal_issuance_references"
  ADD CONSTRAINT "fk_fiscal_issuance_references__applied_policy"
  FOREIGN KEY ("applied_policy_reference_id")
  REFERENCES "discounts"."discount_policy_references" ("discount_policy_reference_id") DEFERRABLE;;
