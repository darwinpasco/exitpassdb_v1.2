-- Create index
CREATE INDEX "ix_stat_disc_svc_reviews__source_status" ON "operator_console"."statutory_discount_service_channel_reviews" ("source_channel", "review_status", "submitted_at");;
