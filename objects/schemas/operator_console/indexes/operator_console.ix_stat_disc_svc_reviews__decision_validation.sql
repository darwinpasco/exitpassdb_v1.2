-- Create index
CREATE INDEX "ix_stat_disc_svc_reviews__decision_validation" ON "operator_console"."statutory_discount_service_channel_reviews" ("statutory_discount_decision_command_id", "statutory_discount_validation_id") WHERE statutory_discount_validation_id IS NOT NULL;;
