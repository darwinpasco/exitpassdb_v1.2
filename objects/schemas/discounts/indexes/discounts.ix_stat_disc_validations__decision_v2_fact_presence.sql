-- Create index "ix_stat_disc_validations__decision_v2_fact_presence" to table: "statutory_discount_validations"
CREATE INDEX "ix_stat_disc_validations__decision_v2_fact_presence" ON "discounts"."statutory_discount_validations" ("statutory_discount_validation_id") WHERE id_document_type IS NOT NULL OR masked_id_reference IS NOT NULL OR requester_attestation IS NOT NULL;;
