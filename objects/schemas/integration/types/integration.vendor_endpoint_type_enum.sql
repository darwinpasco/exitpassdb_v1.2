-- Create enum type "vendor_endpoint_type_enum"
CREATE TYPE "integration"."vendor_endpoint_type_enum" AS ENUM ('SESSION_LOOKUP', 'TARIFF_QUERY', 'PAYMENT_CREATE', 'PAYMENT_STATUS', 'WEBHOOK_RECEIVE', 'GATE_COMMAND', 'HEALTH_CHECK', 'TOKEN_REQUEST', 'EVIDENCE_UPLOAD', 'OTHER');;

