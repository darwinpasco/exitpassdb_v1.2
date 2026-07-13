-- Create enum type "gate_event_status_enum"
CREATE TYPE "gates"."gate_event_status_enum" AS ENUM ('RECORDED', 'SUCCESS', 'FAILED', 'ERROR', 'ABNORMAL', 'IGNORED', 'DUPLICATE');;

