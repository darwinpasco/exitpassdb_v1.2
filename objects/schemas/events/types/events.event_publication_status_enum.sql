-- Create enum type "event_publication_status_enum"
CREATE TYPE "events"."event_publication_status_enum" AS ENUM ('STARTED', 'PUBLISHED', 'FAILED', 'TIMEOUT', 'REJECTED', 'CANCELLED');;

