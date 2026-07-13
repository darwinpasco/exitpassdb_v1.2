-- Create enum type "manual_gate_action_type_enum"
CREATE TYPE "operations"."manual_gate_action_type_enum" AS ENUM ('MANUAL_OPEN', 'MANUAL_RELEASE', 'EMERGENCY_OPEN', 'MOPS_RELEASE', 'SUPERVISOR_RELEASE', 'DEVICE_FAILURE_RELEASE', 'INCIDENT_RELEASE');;

