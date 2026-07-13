-- Create enum type "dead_letter_status_enum"
CREATE TYPE "events"."dead_letter_status_enum" AS ENUM ('OPEN', 'UNDER_REVIEW', 'REPLAY_REQUESTED', 'REPLAYED', 'RESOLVED', 'REJECTED', 'CLOSED', 'CANCELLED');;

