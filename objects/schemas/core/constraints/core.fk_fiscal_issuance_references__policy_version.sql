ALTER TABLE "core"."fiscal_issuance_references"
  ADD CONSTRAINT "fk_fiscal_issuance_references__policy_version"
  FOREIGN KEY ("statutory_discount_policy_version_id")
  REFERENCES "discounts"."statutory_discount_policy_versions" ("statutory_discount_policy_version_id") DEFERRABLE;;
