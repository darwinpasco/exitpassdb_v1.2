-- Create index "ix_integration_credential_references__next_rotation_due_at" to table: "integration_credential_references"
CREATE INDEX "ix_integration_credential_references__next_rotation_due_at" ON "integration"."integration_credential_references" ("next_rotation_due_at");;

