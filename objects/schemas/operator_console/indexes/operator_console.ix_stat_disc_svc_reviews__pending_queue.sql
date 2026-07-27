-- Create index
CREATE INDEX "ix_stat_disc_svc_reviews__pending_queue" ON "operator_console"."statutory_discount_service_channel_reviews" ("review_status", "site_id", "submitted_at", "statutory_discount_decision_command_id") WHERE review_status = 'PENDING_REVIEW';;
