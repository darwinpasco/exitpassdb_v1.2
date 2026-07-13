-- Create enum type "gate_command_result_status_enum"
CREATE TYPE "gates"."gate_command_result_status_enum" AS ENUM ('NOT_REQUESTED', 'REQUESTED', 'ACKNOWLEDGED', 'OPENED', 'FAILED', 'TIMEOUT', 'UNKNOWN');;

