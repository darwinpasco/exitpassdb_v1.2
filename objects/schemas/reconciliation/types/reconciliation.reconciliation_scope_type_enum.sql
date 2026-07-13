-- Create enum type "reconciliation_scope_type_enum"
CREATE TYPE "reconciliation"."reconciliation_scope_type_enum" AS ENUM ('TIME_WINDOW', 'SITE', 'SITE_GROUP', 'INCIDENT', 'SOURCE_BATCH', 'PAYMENT_RAIL', 'VENDOR_SYSTEM', 'MIXED');;

