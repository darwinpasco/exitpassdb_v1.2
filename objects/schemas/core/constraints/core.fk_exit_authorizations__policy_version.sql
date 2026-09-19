ALTER TABLE "core"."exit_authorizations"
  ADD CONSTRAINT "fk_exit_authorizations__policy_version"
  FOREIGN KEY ("statutory_discount_policy_version_id")
  REFERENCES "discounts"."statutory_discount_policy_versions" ("statutory_discount_policy_version_id") DEFERRABLE;;
