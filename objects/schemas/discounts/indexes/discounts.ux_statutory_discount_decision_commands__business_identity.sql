-- Create index "ux_statutory_discount_decision_commands__business_identity"
CREATE UNIQUE INDEX "ux_statutory_discount_decision_commands__business_identity" ON "discounts"."statutory_discount_decision_commands" ("parking_session_id", "entitlement_type");;
