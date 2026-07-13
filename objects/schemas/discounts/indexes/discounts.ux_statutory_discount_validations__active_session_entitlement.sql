-- Create index "ux_statutory_discount_validations__active_session_entitlement" to table: "statutory_discount_validations"
CREATE UNIQUE INDEX "ux_statutory_discount_validations__active_session_entitlement" ON "discounts"."statutory_discount_validations" ("parking_session_id", "entitlement_type") WHERE (validation_status = ANY (ARRAY['REQUESTED'::discounts.statutory_discount_validations_status_enum, 'PENDING_OPERATOR_REVIEW'::discounts.statutory_discount_validations_status_enum, 'APPROVED'::discounts.statutory_discount_validations_status_enum]));;

