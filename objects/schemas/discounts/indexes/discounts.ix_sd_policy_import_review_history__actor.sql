-- Create index "ix_sd_policy_import_review_history__actor" to table: "statutory_discount_policy_import_review_history"
CREATE INDEX "ix_sd_policy_import_review_history__actor" ON "discounts"."statutory_discount_policy_import_review_history" ("actor_operator_user_id") WHERE (actor_operator_user_id IS NOT NULL);;

