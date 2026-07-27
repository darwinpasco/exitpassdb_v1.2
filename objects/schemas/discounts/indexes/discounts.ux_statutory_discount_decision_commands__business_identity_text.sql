-- Create index "ux_statutory_discount_decision_commands__business_identity_text"
CREATE UNIQUE INDEX "ux_statutory_discount_decision_commands__business_identity_text" ON "discounts"."statutory_discount_decision_commands" ("business_identity") WHERE business_identity IS NOT NULL;;
