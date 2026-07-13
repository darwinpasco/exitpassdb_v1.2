-- Create enum type "domain_event_status_enum"
CREATE TYPE "events"."domain_event_status_enum" AS ENUM ('RECORDED', 'SUPERSEDED', 'CANCELLED', 'IGNORED');;

