COMMENT ON COLUMN "identity"."users"."username_normalized" IS 'Database-derived normalized username used as the unique v1.3 local human login identifier. Username reuse is prohibited across all lifecycle states.';;
COMMENT ON COLUMN "identity"."users"."lockout_expires_at" IS 'Optional end of a bounded local-authentication lockout. Runtime authorization still evaluates user status and security policy.';;
COMMENT ON COLUMN "identity"."users"."lockout_reason_code" IS 'Controlled privacy-safe reason for the current lockout posture.';;
COMMENT ON COLUMN "identity"."users"."credential_version" IS 'Monotonic version copied into human sessions and advanced when credential validity changes.';;
COMMENT ON COLUMN "identity"."users"."authorization_epoch" IS 'Monotonic authorization version copied into human sessions and advanced when role or scope authority changes.';;
