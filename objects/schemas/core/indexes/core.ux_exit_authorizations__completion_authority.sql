CREATE UNIQUE INDEX "ux_exit_authorizations__completion_authority"
  ON "core"."exit_authorizations" ("completion_basis", "completion_authority_reference_id");;
