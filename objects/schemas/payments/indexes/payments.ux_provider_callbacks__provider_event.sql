-- Create index "ux_provider_callbacks__provider_event" to table: "provider_callbacks"
CREATE UNIQUE INDEX "ux_provider_callbacks__provider_event" ON "payments"."provider_callbacks" ("payment_rail_id", "provider_event_ref") WHERE (provider_event_ref IS NOT NULL);;

