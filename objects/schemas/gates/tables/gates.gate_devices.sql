-- Create "gate_devices" table
CREATE TABLE "gates"."gate_devices" (
  "gate_device_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "site_id" uuid NOT NULL,
  "lane_id" uuid NULL,
  "service_identity_id" uuid NULL,
  "device_code" character varying(64) NOT NULL,
  "device_name" character varying(128) NOT NULL,
  "device_type" "gates"."gate_device_type_enum" NOT NULL,
  "vendor_device_ref" character varying(128) NULL,
  "serial_number" character varying(128) NULL,
  "device_status" "gates"."gate_device_status_enum" NOT NULL,
  "installed_at" timestamptz NULL,
  "activated_at" timestamptz NULL,
  "retired_at" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_gate_devices" PRIMARY KEY ("gate_device_id"),
  CONSTRAINT "uq_gate_devices__site_device_code" UNIQUE ("site_id", "device_code")
);;

