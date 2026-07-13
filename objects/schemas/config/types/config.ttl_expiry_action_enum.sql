-- Create enum type "ttl_expiry_action_enum"
CREATE TYPE "config"."ttl_expiry_action_enum" AS ENUM ('EXPIRE_RECORD', 'INVALIDATE_RECORD', 'RELEASE_RESERVATION', 'REQUIRE_RECHECK', 'BLOCK_USE', 'PURGE_OR_ARCHIVE', 'NOTIFY_ONLY', 'CUSTOM_WORKFLOW');;

