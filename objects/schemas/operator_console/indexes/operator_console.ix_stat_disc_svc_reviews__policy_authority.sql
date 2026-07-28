-- Create index "ix_stat_disc_svc_reviews__policy_authority"
CREATE INDEX "ix_stat_disc_svc_reviews__policy_authority" ON "operator_console"."statutory_discount_service_channel_reviews" ("statutory_discount_decision_policy_authority_id") WHERE statutory_discount_decision_policy_authority_id IS NOT NULL;;
