ALTER TABLE "core"."exit_authorizations"
  ADD CONSTRAINT "fk_exit_authorizations__statutory_validation"
  FOREIGN KEY ("statutory_discount_validation_id")
  REFERENCES "discounts"."statutory_discount_validations" ("statutory_discount_validation_id") DEFERRABLE;;
