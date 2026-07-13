-- Create enum type "security_event_status_enum"
CREATE TYPE "audit"."security_event_status_enum" AS ENUM ('OPEN', 'ACKNOWLEDGED', 'UNDER_REVIEW', 'RESOLVED', 'FALSE_POSITIVE', 'ESCALATED', 'CLOSED');;

