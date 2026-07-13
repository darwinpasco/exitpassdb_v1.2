-- Create index "ix_statutory_discount_validations__correlation_id" to table: "statutory_discount_validations"
CREATE INDEX "ix_statutory_discount_validations__correlation_id" ON "discounts"."statutory_discount_validations" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

