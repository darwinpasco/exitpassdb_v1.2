-- Database-owned membership boundary for the approved Professional Parking Site Group catalog.
CREATE TABLE "sites"."real_carpark_catalog_site_groups" (
  "site_group_id" uuid NOT NULL,
  "catalog_code" character varying(64) NOT NULL,
  "source_reference" text NOT NULL,
  "source_sha256" character(64) NOT NULL,
  "registered_at" timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT "pk_real_carpark_catalog_site_groups" PRIMARY KEY ("site_group_id"),
  CONSTRAINT "fk_real_carpark_catalog_site_groups__site_group" FOREIGN KEY ("site_group_id") REFERENCES "sites"."site_groups" ("site_group_id"),
  CONSTRAINT "ck_real_carpark_catalog_site_groups__catalog_code" CHECK ("catalog_code" = 'PROFESSIONAL_PARKING_REAL_CARPARK_V1'),
  CONSTRAINT "ck_real_carpark_catalog_site_groups__source_sha256" CHECK ("source_sha256" ~ '^[A-F0-9]{64}$')
);
