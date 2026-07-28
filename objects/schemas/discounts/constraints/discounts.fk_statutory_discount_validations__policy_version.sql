-- Add foreign key "fk_statutory_discount_validations__policy_version"
ALTER TABLE "discounts"."statutory_discount_validations"
  ADD CONSTRAINT "fk_statutory_discount_validations__policy_version"
  FOREIGN KEY ("statutory_discount_policy_version_id")
  REFERENCES "discounts"."statutory_discount_policy_versions" ("statutory_discount_policy_version_id");;
