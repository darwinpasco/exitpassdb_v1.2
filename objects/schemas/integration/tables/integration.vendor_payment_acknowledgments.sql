-- Create "vendor_payment_acknowledgments" table
CREATE TABLE "integration"."vendor_payment_acknowledgments" (
  "vendor_payment_acknowledgment_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "payment_attempt_id" uuid NOT NULL,
  "payment_confirmation_id" uuid NOT NULL,
  "parking_session_id" uuid NULL,
  "vendor_system_code" text NOT NULL,
  "vendor_session_ref" text NULL,
  "ticket_number" text NULL,
  "card_num" text NULL,
  "acknowledgment_status" "integration"."vendor_payment_acknowledgment_status_enum" NOT NULL,
  "vendor_code" text NULL,
  "vendor_message" text NULL,
  "request_fee_minor_units" bigint NULL,
  "request_currency_code" text NULL,
  "confirmed_fee_minor_units" bigint NULL,
  "vendor_confirmed_at" timestamptz NULL,
  "attempt_count" integer NOT NULL DEFAULT 0,
  "last_attempted_at" timestamptz NULL,
  "next_retry_at" timestamptz NULL,
  "idempotency_key" text NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT "pk_vendor_payment_acknowledgments" PRIMARY KEY ("vendor_payment_acknowledgment_id"),
  CONSTRAINT "uq_vendor_payment_ack__payment_confirmation_vendor" UNIQUE ("payment_confirmation_id", "vendor_system_code")
);;

