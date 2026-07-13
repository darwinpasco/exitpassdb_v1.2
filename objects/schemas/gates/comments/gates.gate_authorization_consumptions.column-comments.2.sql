-- Set comment to column: "authorization_token_hash" on table: "gate_authorization_consumptions"
COMMENT ON COLUMN "gates"."gate_authorization_consumptions"."authorization_token_hash" IS 'Hash of presented token where authorization ID is not yet known or for replay analysis.';;

