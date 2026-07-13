-- Create "lanes" table
CREATE TABLE "sites"."lanes" (
  "lane_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "site_id" uuid NOT NULL,
  "lane_code" character varying(64) NOT NULL,
  "lane_name" character varying(128) NOT NULL,
  "lane_description" text NULL,
  "lane_type" "sites"."lane_type_enum" NOT NULL,
  "lane_direction" "sites"."lane_direction_enum" NOT NULL,
  "lane_status" "sites"."lane_status_enum" NOT NULL,
  "display_order" integer NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_lanes" PRIMARY KEY ("lane_id"),
  CONSTRAINT "uq_lanes__site_lane_code" UNIQUE ("site_id", "lane_code")
);;

