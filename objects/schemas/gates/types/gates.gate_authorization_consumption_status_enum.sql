-- Create enum type "gate_authorization_consumption_status_enum"
CREATE TYPE "gates"."gate_authorization_consumption_status_enum" AS ENUM ('REQUESTED', 'VALIDATED', 'CONSUMED', 'DENIED', 'EXPIRED', 'INVALID', 'REPLAYED', 'MISMATCHED', 'FAILED');;

