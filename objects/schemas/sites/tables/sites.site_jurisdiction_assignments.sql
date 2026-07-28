-- Create "site_jurisdiction_assignments" table
CREATE TABLE "sites"."site_jurisdiction_assignments" (
  "site_jurisdiction_assignment_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "site_id" uuid NOT NULL,
  "jurisdiction_id" uuid NOT NULL,
  "assignment_status" "sites"."site_jurisdiction_assignment_status_enum" NOT NULL DEFAULT 'ACTIVE',
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "source_reference" character varying(256) NULL,
  "approval_reference" character varying(256) NULL,
  "correction_reason" character varying(256) NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_site_jurisdiction_assignments" PRIMARY KEY ("site_jurisdiction_assignment_id"),
  CONSTRAINT "fk_site_jurisdiction_assignments__site" FOREIGN KEY ("site_id") REFERENCES "sites"."sites" ("site_id"),
  CONSTRAINT "fk_site_jurisdiction_assignments__jurisdiction" FOREIGN KEY ("jurisdiction_id") REFERENCES "sites"."jurisdictions" ("jurisdiction_id"),
  CONSTRAINT "ck_site_jurisdiction_assignments__effective_window" CHECK ((effective_to IS NULL) OR (effective_to > effective_from)),
  CONSTRAINT "ck_site_jurisdiction_assignments__row_version_positive" CHECK (row_version > 0)
);;
