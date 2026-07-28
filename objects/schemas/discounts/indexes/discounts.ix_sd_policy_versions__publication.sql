-- Create index "ix_sd_policy_versions__publication"
CREATE INDEX "ix_sd_policy_versions__publication" ON "discounts"."statutory_discount_policy_versions" ("transaction_publication_status", "source_verification_status", "parking_service_applicability");;
