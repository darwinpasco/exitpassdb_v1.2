-- Set comment to column: "authorization_token_hash" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."authorization_token_hash" IS 'Hash of opaque token used for secure lookup and replay-safe validation.';;

