-- Create enum type "incident_status_enum"
CREATE TYPE "operations"."incident_status_enum" AS ENUM ('OPEN', 'ACKNOWLEDGED', 'INVESTIGATING', 'MITIGATED', 'RESOLVED', 'CLOSED', 'CANCELLED');;

