-- Set comment to column: "statutory_discount_policy_registry_id" on table: "statutory_discount_policy_registry"
COMMENT ON COLUMN "discounts"."statutory_discount_policy_registry"."statutory_discount_policy_registry_id" IS 'Canonical identifier of the statutory discount policy registry row.';;

COMMENT ON COLUMN "discounts"."statutory_discount_policy_registry"."local_government_unit_id" IS 'Canonical city/municipality LGU scope for statutory parking research and future policy inheritance; jurisdiction_id remains compatibility for existing runtime.';;
COMMENT ON COLUMN "discounts"."statutory_discount_policy_registry"."coverage_available" IS 'Controlled research result indicating whether current policy research found a local statutory parking measure. This is not transaction-use publication.';;
COMMENT ON COLUMN "discounts"."statutory_discount_policy_registry"."auto_application_allowed" IS 'Production auto-application authorization flag. I-006 research-derived seed rows keep this false.';;
