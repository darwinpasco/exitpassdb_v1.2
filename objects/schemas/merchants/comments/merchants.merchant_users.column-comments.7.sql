-- Set comment to column: "can_view_wallet" on table: "merchant_users"
COMMENT ON COLUMN "merchants"."merchant_users"."can_view_wallet" IS 'Indicates whether the user may view merchant wallet context, subject to RBAC.';;

