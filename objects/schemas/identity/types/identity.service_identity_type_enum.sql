-- Create enum type "service_identity_type_enum"
CREATE TYPE "identity"."service_identity_type_enum" AS ENUM ('INTERNAL_SERVICE', 'EXTERNAL_CLIENT', 'ADAPTER', 'BACKGROUND_WORKER', 'SCHEDULED_JOB', 'WEBHOOK_RECEIVER', 'DEVICE', 'GATEWAY', 'OTHER');;

