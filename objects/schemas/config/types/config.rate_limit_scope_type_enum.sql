-- Create enum type "rate_limit_scope_type_enum"
CREATE TYPE "config"."rate_limit_scope_type_enum" AS ENUM ('PUBLIC_LOOKUP', 'PAYMENT_CREATE', 'PROVIDER_CALLBACK', 'GATE_CONSUME', 'ADMIN_API', 'SUPPORT_TOOL', 'EVIDENCE_ACCESS', 'SERVICE_TO_SERVICE', 'MERCHANT_USER', 'DEVICE', 'CUSTOM');;

