-- Set comment to column: "credential_reference" on table: "service_identities"
COMMENT ON COLUMN "identity"."service_identities"."credential_reference" IS 'Reference to secret, certificate, key vault entry, or credential profile.';;

