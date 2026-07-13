-- Set comment to table: "statutory_discount_policy_import_review_history"
COMMENT ON TABLE "discounts"."statutory_discount_policy_import_review_history" IS 'Review-only event history for statutory discount policy import candidate workflow. Payloads must be sanitized and must not contain raw CSV, raw evidence, personal data, secrets, or credentials.';;

