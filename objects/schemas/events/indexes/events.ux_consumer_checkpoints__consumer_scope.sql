-- Create index "ux_consumer_checkpoints__consumer_scope" to table: "consumer_checkpoints"
CREATE UNIQUE INDEX "ux_consumer_checkpoints__consumer_scope" ON "events"."consumer_checkpoints" ("consumer_name", (COALESCE(consumer_group, ''::character varying)), (COALESCE(subscription_name, ''::character varying)), (COALESCE(event_type, ''::character varying)), (COALESCE(aggregate_type, ''::character varying)));;

