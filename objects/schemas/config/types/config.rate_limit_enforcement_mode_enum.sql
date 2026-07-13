-- Create enum type "rate_limit_enforcement_mode_enum"
CREATE TYPE "config"."rate_limit_enforcement_mode_enum" AS ENUM ('MONITOR_ONLY', 'ENFORCE', 'BLOCK', 'CHALLENGE', 'DISABLED');;

