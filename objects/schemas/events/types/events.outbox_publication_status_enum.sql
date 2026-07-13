-- Create enum type "outbox_publication_status_enum"
CREATE TYPE "events"."outbox_publication_status_enum" AS ENUM ('PENDING', 'LOCKED', 'PUBLISHED', 'FAILED', 'RETRY_PENDING', 'DEAD_LETTERED', 'CANCELLED');;

