-- Create "enqueue_outbox_event" function
CREATE FUNCTION "events"."enqueue_outbox_event" () RETURNS void LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'events.enqueue_outbox_event is a v1.2 routine placeholder and must be implemented before production use'; END; $$;;

