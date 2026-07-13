-- Create index "ux_discount_evidence_references__evidence_hash" to table: "discount_evidence_references"
CREATE UNIQUE INDEX "ux_discount_evidence_references__evidence_hash" ON "discounts"."discount_evidence_references" ("evidence_hash") WHERE (evidence_hash IS NOT NULL);;

