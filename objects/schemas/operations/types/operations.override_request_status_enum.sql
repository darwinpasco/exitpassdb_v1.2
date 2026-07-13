-- Create enum type "override_request_status_enum"
CREATE TYPE "operations"."override_request_status_enum" AS ENUM ('REQUESTED', 'PENDING_APPROVAL', 'APPROVED', 'REJECTED', 'CANCELLED', 'EXPIRED', 'EXECUTED', 'CLOSED');;

