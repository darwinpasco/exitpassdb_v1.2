-- Create index "ix_service_identities__credential_expires_at" to table: "service_identities"
CREATE INDEX "ix_service_identities__credential_expires_at" ON "identity"."service_identities" ("credential_expires_at");;

