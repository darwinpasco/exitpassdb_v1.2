-- Create enum type "provider_status_query_status_enum"
CREATE TYPE "payments"."provider_status_query_status_enum" AS ENUM ('REQUESTED', 'COMPLETED', 'FAILED', 'TIMEOUT', 'INCONCLUSIVE');;

