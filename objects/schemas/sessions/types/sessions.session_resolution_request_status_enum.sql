-- Create enum type "session_resolution_request_status_enum"
CREATE TYPE "sessions"."session_resolution_request_status_enum" AS ENUM ('REQUESTED', 'PROCESSING', 'COMPLETED', 'FAILED', 'EXPIRED', 'CANCELLED');;

