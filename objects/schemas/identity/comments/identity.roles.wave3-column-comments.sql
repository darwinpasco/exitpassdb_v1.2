COMMENT ON COLUMN "identity"."roles"."role_provenance" IS
  'Authoritative classification: canonical, historical legacy, isolated UAT test, or service-only.';;
COMMENT ON COLUMN "identity"."roles"."direct_add_user_eligible" IS
  'True only when Central PMS may offer the role for atomic direct Add User assignment.';;
COMMENT ON COLUMN "identity"."roles"."human_assignable" IS
  'False for service roles, isolated test roles, and retired historical roles.';;
