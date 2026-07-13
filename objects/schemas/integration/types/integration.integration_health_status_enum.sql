-- Create enum type "integration_health_status_enum"
CREATE TYPE "integration"."integration_health_status_enum" AS ENUM ('AVAILABLE', 'DEGRADED', 'UNAVAILABLE', 'ERROR', 'UNKNOWN');;

