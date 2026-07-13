-- Create "tariff_snapshots" table
CREATE TABLE "core"."tariff_snapshots" (
  "tariff_snapshot_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "parking_session_id" uuid NOT NULL,
  "superseded_by_tariff_snapshot_id" uuid NULL,
  "vendor_system_id" uuid NOT NULL,
  "vendor_tariff_ref" character varying(128) NULL,
  "tariff_version_reference" character varying(128) NULL,
  "currency_code" character(3) NOT NULL,
  "gross_amount" numeric(18,2) NOT NULL,
  "statutory_discount_amount" numeric(18,2) NOT NULL,
  "coupon_discount_amount" numeric(18,2) NOT NULL,
  "net_amount" numeric(18,2) NOT NULL,
  "statutory_discount_validation_id" uuid NULL,
  "coupon_application_id" uuid NULL,
  "snapshot_status" "core"."tariff_snapshot_status_enum" NOT NULL,
  "calculated_at" timestamptz NOT NULL,
  "expires_at" timestamptz NOT NULL,
  "consumed_at" timestamptz NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_tariff_snapshots" PRIMARY KEY ("tariff_snapshot_id")
);;

