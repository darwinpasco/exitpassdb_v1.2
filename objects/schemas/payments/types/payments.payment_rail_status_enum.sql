-- Create enum type "payment_rail_status_enum"
CREATE TYPE "payments"."payment_rail_status_enum" AS ENUM ('DRAFT', 'ACTIVE', 'SUSPENDED', 'MAINTENANCE', 'DEPRECATED', 'RETIRED');;

