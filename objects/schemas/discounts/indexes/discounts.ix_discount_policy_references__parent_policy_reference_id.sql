-- Create index "ix_discount_policy_references__parent_policy_reference_id" to table: "discount_policy_references"
CREATE INDEX "ix_discount_policy_references__parent_policy_reference_id" ON "discounts"."discount_policy_references" ("parent_policy_reference_id");;

