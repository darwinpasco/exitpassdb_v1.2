-- Create enum type "session_resolution_result_status_enum"
CREATE TYPE "sessions"."session_resolution_result_status_enum" AS ENUM ('RESOLVED_SINGLE', 'NOT_FOUND', 'AMBIGUOUS', 'FAILED', 'EXPIRED', 'CANCELLED');;

