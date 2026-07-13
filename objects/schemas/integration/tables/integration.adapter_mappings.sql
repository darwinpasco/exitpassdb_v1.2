-- Create "adapter_mappings" table
CREATE TABLE "integration"."adapter_mappings" (
  "adapter_mapping_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "vendor_system_id" uuid NOT NULL,
  "mapping_type" "integration"."adapter_mapping_type_enum" NOT NULL,
  "site_group_id" uuid NULL,
  "site_id" uuid NULL,
  "lane_id" uuid NULL,
  "gate_device_id" uuid NULL,
  "payment_rail_id" uuid NULL,
  "vendor_object_type" character varying(64) NOT NULL,
  "vendor_object_ref" character varying(128) NOT NULL,
  "vendor_object_name" character varying(128) NULL,
  "mapping_status" "integration"."adapter_mapping_status_enum" NOT NULL,
  "mapping_confidence" "integration"."adapter_mapping_confidence_enum" NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_adapter_mappings" PRIMARY KEY ("adapter_mapping_id")
);;

