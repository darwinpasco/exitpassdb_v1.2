-- Authoritative compatibility between human user types and canonical roles.
CREATE TABLE "identity"."role_user_type_compatibility" (
  "role_id" uuid NOT NULL,
  "user_type" "identity"."user_type_enum" NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NULL,
  CONSTRAINT "pk_role_user_type_compatibility" PRIMARY KEY ("role_id", "user_type"),
  CONSTRAINT "fk_role_user_type_compatibility__role_id" FOREIGN KEY ("role_id")
    REFERENCES "identity"."roles" ("role_id") ON UPDATE NO ACTION ON DELETE RESTRICT,
  CONSTRAINT "ck_role_user_type_compatibility__human_role" CHECK ("user_type" IS NOT NULL)
);;

COMMENT ON TABLE "identity"."role_user_type_compatibility" IS
  'Database-owned allow-list used by Central PMS for initial and later human role assignments.';;
COMMENT ON COLUMN "identity"."role_user_type_compatibility"."role_id" IS
  'Canonical human role allowed for the user type.';;
COMMENT ON COLUMN "identity"."role_user_type_compatibility"."user_type" IS
  'Authoritative identity.user_type_enum value compatible with the role.';;
