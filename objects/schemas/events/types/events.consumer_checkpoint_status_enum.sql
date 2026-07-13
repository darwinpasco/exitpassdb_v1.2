-- Create enum type "consumer_checkpoint_status_enum"
CREATE TYPE "events"."consumer_checkpoint_status_enum" AS ENUM ('ACTIVE', 'LOCKED', 'FAILED', 'PAUSED', 'REPLAYING', 'RESET', 'RETIRED');;

