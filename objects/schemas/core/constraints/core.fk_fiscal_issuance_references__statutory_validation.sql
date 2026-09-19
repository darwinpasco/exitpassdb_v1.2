ALTER TABLE "core"."fiscal_issuance_references"
  ADD CONSTRAINT "fk_fiscal_issuance_references__statutory_validation"
  FOREIGN KEY ("statutory_discount_validation_id")
  REFERENCES "discounts"."statutory_discount_validations" ("statutory_discount_validation_id") DEFERRABLE;;
