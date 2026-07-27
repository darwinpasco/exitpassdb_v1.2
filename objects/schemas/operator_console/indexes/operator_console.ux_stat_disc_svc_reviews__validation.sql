-- Create index
CREATE UNIQUE INDEX "ux_stat_disc_svc_reviews__validation" ON "operator_console"."statutory_discount_service_channel_reviews" ("statutory_discount_validation_id") WHERE statutory_discount_validation_id IS NOT NULL;;
