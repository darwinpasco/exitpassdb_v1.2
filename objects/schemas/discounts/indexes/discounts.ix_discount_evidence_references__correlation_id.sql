-- Create index "ix_discount_evidence_references__correlation_id" to table: "discount_evidence_references"
CREATE INDEX "ix_discount_evidence_references__correlation_id" ON "discounts"."discount_evidence_references" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

