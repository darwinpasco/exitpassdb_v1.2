-- Create "device_assignments" table
CREATE TABLE "sites"."device_assignments" (
  "device_assignment_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "site_id" uuid NOT NULL,
  "lane_id" uuid NULL,
  "gate_device_id" uuid NULL,
  "service_identity_id" uuid NULL,
  "assignment_type" "sites"."device_assignment_type_enum" NOT NULL,
  "assignment_status" "sites"."device_assignment_status_enum" NOT NULL,
  "assignment_reason_code" character varying(64) NULL,
  "assigned_at" timestamptz NOT NULL DEFAULT now(),
  "unassigned_at" timestamptz NULL,
  "assigned_by_user_id" uuid NULL,
  "assigned_by_service_identity_id" uuid NULL,
  "unassigned_by_user_id" uuid NULL,
  "unassigned_by_service_identity_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_device_assignments" PRIMARY KEY ("device_assignment_id")
);;

