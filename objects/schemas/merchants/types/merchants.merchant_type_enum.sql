-- Create enum type "merchant_type_enum"
CREATE TYPE "merchants"."merchant_type_enum" AS ENUM ('TENANT', 'ANCHOR_TENANT', 'PROPERTY_OPERATOR', 'INSTITUTION', 'SERVICE_PROVIDER', 'PROMOTIONAL_PARTNER', 'OTHER');;

