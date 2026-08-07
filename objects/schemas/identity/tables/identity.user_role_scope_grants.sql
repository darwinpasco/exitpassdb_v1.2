CREATE TABLE "identity"."user_role_scope_grants" (
  "user_role_scope_grant_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "user_role_id" uuid NOT NULL,
  "scope_type" "identity"."authorization_scope_type_enum" NOT NULL,
  "site_id" uuid NULL,
  "site_group_id" uuid NULL,
  "grant_status" "identity"."user_role_scope_grant_status_enum" NOT NULL DEFAULT 'PENDING',
  "grant_reason_code" character varying(64) NOT NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "granted_at" timestamptz NOT NULL DEFAULT now(),
  "granted_by_user_id" uuid NULL,
  "granted_by_service_identity_id" uuid NULL,
  "revoked_at" timestamptz NULL,
  "revoked_by_user_id" uuid NULL,
  "revoked_by_service_identity_id" uuid NULL,
  "revocation_reason_code" character varying(64) NULL,
  "last_reviewed_at" timestamptz NULL,
  "last_reviewed_by_user_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_user_role_scope_grants" PRIMARY KEY ("user_role_scope_grant_id"),
  CONSTRAINT "fk_user_role_scope_grants__user_role" FOREIGN KEY ("user_role_id") REFERENCES "identity"."user_roles" ("user_role_id"),
  CONSTRAINT "fk_user_role_scope_grants__site" FOREIGN KEY ("site_id") REFERENCES "sites"."sites" ("site_id"),
  CONSTRAINT "fk_user_role_scope_grants__site_group" FOREIGN KEY ("site_group_id") REFERENCES "sites"."site_groups" ("site_group_id"),
  CONSTRAINT "fk_user_role_scope_grants__granted_user" FOREIGN KEY ("granted_by_user_id") REFERENCES "identity"."users" ("user_id"),
  CONSTRAINT "fk_user_role_scope_grants__granted_service" FOREIGN KEY ("granted_by_service_identity_id") REFERENCES "identity"."service_identities" ("service_identity_id"),
  CONSTRAINT "fk_user_role_scope_grants__revoked_user" FOREIGN KEY ("revoked_by_user_id") REFERENCES "identity"."users" ("user_id"),
  CONSTRAINT "fk_user_role_scope_grants__revoked_service" FOREIGN KEY ("revoked_by_service_identity_id") REFERENCES "identity"."service_identities" ("service_identity_id"),
  CONSTRAINT "fk_user_role_scope_grants__reviewed_user" FOREIGN KEY ("last_reviewed_by_user_id") REFERENCES "identity"."users" ("user_id"),
  CONSTRAINT "ck_user_role_scope_grants__scope_shape" CHECK (("scope_type" = 'SITE' AND "site_id" IS NOT NULL AND "site_group_id" IS NULL) OR ("scope_type" = 'SITE_GROUP' AND "site_id" IS NULL AND "site_group_id" IS NOT NULL) OR ("scope_type" = 'GLOBAL' AND "site_id" IS NULL AND "site_group_id" IS NULL)),
  CONSTRAINT "ck_user_role_scope_grants__grant_actor" CHECK (num_nonnulls("granted_by_user_id", "granted_by_service_identity_id") = 1),
  CONSTRAINT "ck_user_role_scope_grants__effective_window" CHECK ("effective_to" IS NULL OR "effective_to" > "effective_from"),
  CONSTRAINT "ck_user_role_scope_grants__revocation" CHECK (("grant_status" = 'REVOKED') = ("revoked_at" IS NOT NULL)),
  CONSTRAINT "ck_user_role_scope_grants__revocation_actor" CHECK (("revoked_at" IS NULL AND "revoked_by_user_id" IS NULL AND "revoked_by_service_identity_id" IS NULL) OR ("revoked_at" IS NOT NULL AND num_nonnulls("revoked_by_user_id", "revoked_by_service_identity_id") = 1)),
  CONSTRAINT "ck_user_role_scope_grants__review" CHECK (("last_reviewed_at" IS NULL) = ("last_reviewed_by_user_id" IS NULL)),
  CONSTRAINT "ck_user_role_scope_grants__reason" CHECK (btrim("grant_reason_code") <> ''),
  CONSTRAINT "ck_user_role_scope_grants__row_version" CHECK ("row_version" > 0)
);;

CREATE UNIQUE INDEX "ux_user_role_scope_grants__current_exact" ON "identity"."user_role_scope_grants" ("user_role_id", "scope_type", COALESCE("site_id", '00000000-0000-0000-0000-000000000000'::uuid), COALESCE("site_group_id", '00000000-0000-0000-0000-000000000000'::uuid)) WHERE "grant_status" IN ('PENDING', 'ACTIVE', 'SUSPENDED');;
CREATE INDEX "ix_user_role_scope_grants__role_effective" ON "identity"."user_role_scope_grants" ("user_role_id", "grant_status", "effective_from", "effective_to");;
CREATE INDEX "ix_user_role_scope_grants__site" ON "identity"."user_role_scope_grants" ("site_id", "grant_status", "effective_from", "effective_to") WHERE "site_id" IS NOT NULL;;
CREATE INDEX "ix_user_role_scope_grants__site_group" ON "identity"."user_role_scope_grants" ("site_group_id", "grant_status", "effective_from", "effective_to") WHERE "site_group_id" IS NOT NULL;;
CREATE INDEX "ix_user_role_scope_grants__global" ON "identity"."user_role_scope_grants" ("grant_status", "effective_from", "effective_to") WHERE "scope_type" = 'GLOBAL';;

COMMENT ON TABLE "identity"."user_role_scope_grants" IS 'Server-owned Site, Site Group, or explicit GLOBAL authority attached to one user-role assignment. Missing Site fields never imply global access, no GLOBAL grant is seeded, and runtime authorization must also validate the parent assignment status/effectivity.';;
