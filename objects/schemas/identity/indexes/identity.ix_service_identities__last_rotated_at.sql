-- Create index "ix_service_identities__last_rotated_at" to table: "service_identities"
CREATE INDEX "ix_service_identities__last_rotated_at" ON "identity"."service_identities" ("last_rotated_at");;

