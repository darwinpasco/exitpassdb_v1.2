-- Create enum type "payment_rail_type_enum"
CREATE TYPE "payments"."payment_rail_type_enum" AS ENUM ('QRPH', 'CARD', 'EWALLET', 'HOSTED_CHECKOUT', 'BANK_TRANSFER', 'OTHER');;

