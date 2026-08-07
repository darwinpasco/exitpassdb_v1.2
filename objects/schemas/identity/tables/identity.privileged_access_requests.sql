CREATE TABLE "identity"."privileged_access_requests" (
  "privileged_access_request_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "request_reference" uuid NOT NULL DEFAULT gen_random_uuid(),
  "target_user_id" uuid NOT NULL,
  "requested_role_id" uuid NOT NULL,
  "requested_scope_type" "identity"."authorization_scope_type_enum" NULL,
  "requested_site_id" uuid NULL,
  "requested_site_group_id" uuid NULL,
  "request_status" "identity"."privileged_access_request_status_enum" NOT NULL DEFAULT 'DRAFT',
  "request_reason_code" character varying(64) NOT NULL,
  "requested_effective_from" timestamptz NOT NULL,
  "requested_effective_to" timestamptz NULL,
  "approval_policy_code" character varying(64) NULL,
  "requested_at" timestamptz NOT NULL,
  "requested_by_user_id" uuid NOT NULL,
  "expires_at" timestamptz NULL,
  "closed_at" timestamptz NULL,
  "activated_user_role_id" uuid NULL,
  "activated_scope_grant_id" uuid NULL,
  "correlation_id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_privileged_access_requests" PRIMARY KEY ("privileged_access_request_id"),
  CONSTRAINT "uq_privileged_access_requests__reference" UNIQUE ("request_reference"),
  CONSTRAINT "fk_privileged_access_requests__target_user" FOREIGN KEY ("target_user_id") REFERENCES "identity"."users" ("user_id"),
  CONSTRAINT "fk_privileged_access_requests__role" FOREIGN KEY ("requested_role_id") REFERENCES "identity"."roles" ("role_id"),
  CONSTRAINT "fk_privileged_access_requests__site" FOREIGN KEY ("requested_site_id") REFERENCES "sites"."sites" ("site_id"),
  CONSTRAINT "fk_privileged_access_requests__site_group" FOREIGN KEY ("requested_site_group_id") REFERENCES "sites"."site_groups" ("site_group_id"),
  CONSTRAINT "fk_privileged_access_requests__requester" FOREIGN KEY ("requested_by_user_id") REFERENCES "identity"."users" ("user_id"),
  CONSTRAINT "fk_privileged_access_requests__activated_role" FOREIGN KEY ("activated_user_role_id") REFERENCES "identity"."user_roles" ("user_role_id"),
  CONSTRAINT "fk_privileged_access_requests__activated_scope" FOREIGN KEY ("activated_scope_grant_id") REFERENCES "identity"."user_role_scope_grants" ("user_role_scope_grant_id"),
  CONSTRAINT "ck_privileged_access_requests__scope_shape" CHECK (("requested_scope_type" IS NULL AND "requested_site_id" IS NULL AND "requested_site_group_id" IS NULL) OR ("requested_scope_type" = 'SITE' AND "requested_site_id" IS NOT NULL AND "requested_site_group_id" IS NULL) OR ("requested_scope_type" = 'SITE_GROUP' AND "requested_site_id" IS NULL AND "requested_site_group_id" IS NOT NULL) OR ("requested_scope_type" = 'GLOBAL' AND "requested_site_id" IS NULL AND "requested_site_group_id" IS NULL)),
  CONSTRAINT "ck_privileged_access_requests__effective_window" CHECK ("requested_effective_to" IS NULL OR "requested_effective_to" > "requested_effective_from"),
  CONSTRAINT "ck_privileged_access_requests__expiry" CHECK ("expires_at" IS NULL OR "expires_at" > "requested_at"),
  CONSTRAINT "ck_privileged_access_requests__closure" CHECK (("request_status" IN ('REJECTED', 'CANCELLED', 'EXPIRED', 'APPLIED')) = ("closed_at" IS NOT NULL)),
  CONSTRAINT "ck_privileged_access_requests__activation" CHECK (("request_status" = 'APPLIED' AND "activated_user_role_id" IS NOT NULL AND (("requested_scope_type" IS NULL AND "activated_scope_grant_id" IS NULL) OR ("requested_scope_type" IS NOT NULL AND "activated_scope_grant_id" IS NOT NULL))) OR ("request_status" <> 'APPLIED' AND "activated_user_role_id" IS NULL AND "activated_scope_grant_id" IS NULL)),
  CONSTRAINT "ck_privileged_access_requests__reason" CHECK (btrim("request_reason_code") <> ''),
  CONSTRAINT "ck_privileged_access_requests__policy" CHECK ("approval_policy_code" IS NULL OR btrim("approval_policy_code") <> ''),
  CONSTRAINT "ck_privileged_access_requests__row_version" CHECK ("row_version" > 0)
);;

CREATE INDEX "ix_privileged_access_requests__queue" ON "identity"."privileged_access_requests" ("request_status", "requested_at", "expires_at");;
CREATE INDEX "ix_privileged_access_requests__target" ON "identity"."privileged_access_requests" ("target_user_id", "request_status", "requested_at" DESC);;
CREATE INDEX "ix_privileged_access_requests__requester" ON "identity"."privileged_access_requests" ("requested_by_user_id", "requested_at" DESC);;
CREATE INDEX "ix_privileged_access_requests__correlation" ON "identity"."privileged_access_requests" ("correlation_id");;

COMMENT ON TABLE "identity"."privileged_access_requests" IS 'Durable privileged role/scope proposal and activation linkage. DRAFT/PENDING are never approval; no approver count, global eligibility, or automatic activation policy is hard-coded by I-019.';;
