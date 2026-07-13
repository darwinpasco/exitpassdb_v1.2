-- Create enum type "integration_health_check_type_enum"
CREATE TYPE "integration"."integration_health_check_type_enum" AS ENUM ('SCHEDULED_HEALTH_CHECK', 'ON_DEMAND_CHECK', 'REQUEST_FAILURE', 'CALLBACK_FAILURE', 'LATENCY_OBSERVATION', 'RECOVERY_OBSERVATION', 'MANUAL_OBSERVATION');;

