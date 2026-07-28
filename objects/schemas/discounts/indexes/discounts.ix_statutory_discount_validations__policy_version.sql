-- Create index "ix_statutory_discount_validations__policy_version"
CREATE INDEX "ix_statutory_discount_validations__policy_version" ON "discounts"."statutory_discount_validations" ("statutory_discount_policy_version_id") WHERE statutory_discount_policy_version_id IS NOT NULL;;
