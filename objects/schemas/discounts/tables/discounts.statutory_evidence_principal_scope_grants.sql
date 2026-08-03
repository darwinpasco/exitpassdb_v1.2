CREATE TABLE "discounts"."statutory_evidence_principal_scope_grants" (
  "statutory_evidence_principal_scope_grant_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "actor_user_id" uuid NULL,
  "actor_service_identity_id" uuid NULL,
  "source_channel" character varying(64) NOT NULL,
  "site_id" uuid NULL,
  "site_group_id" uuid NULL,
  "capture_allowed" boolean NOT NULL DEFAULT false,
  "view_allowed" boolean NOT NULL DEFAULT false,
  "review_lock_allowed" boolean NOT NULL DEFAULT false,
  "hold_allowed" boolean NOT NULL DEFAULT false,
  "deletion_request_allowed" boolean NOT NULL DEFAULT false,
  "grant_status" character varying(32) NOT NULL DEFAULT 'ACTIVE',
  "effective_from" timestamptz NOT NULL DEFAULT now(),
  "effective_to" timestamptz NULL,
  "reason_code" character varying(64) NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_statutory_evidence_principal_scope_grants" PRIMARY KEY ("statutory_evidence_principal_scope_grant_id"),
  CONSTRAINT "fk_stat_ev_scope_grants__actor_user" FOREIGN KEY ("actor_user_id") REFERENCES "identity"."users" ("user_id"),
  CONSTRAINT "fk_stat_ev_scope_grants__service_identity" FOREIGN KEY ("actor_service_identity_id") REFERENCES "identity"."service_identities" ("service_identity_id"),
  CONSTRAINT "fk_stat_ev_scope_grants__site" FOREIGN KEY ("site_id") REFERENCES "sites"."sites" ("site_id"),
  CONSTRAINT "fk_stat_ev_scope_grants__site_group" FOREIGN KEY ("site_group_id") REFERENCES "sites"."site_groups" ("site_group_id"),
  CONSTRAINT "ck_stat_ev_scope_grants__one_actor" CHECK ((actor_user_id IS NOT NULL AND actor_service_identity_id IS NULL) OR (actor_user_id IS NULL AND actor_service_identity_id IS NOT NULL)),
  CONSTRAINT "ck_stat_ev_scope_grants__scope" CHECK (site_id IS NOT NULL OR site_group_id IS NOT NULL),
  CONSTRAINT "ck_stat_ev_scope_grants__source_channel" CHECK (source_channel IN ('WEBPAY', 'ASSISTED_PAYMENT_TERMINAL', 'OPERATOR_CONSOLE', 'CENTRAL_PMS')),
  CONSTRAINT "ck_stat_ev_scope_grants__status" CHECK (grant_status IN ('ACTIVE', 'SUSPENDED', 'REVOKED', 'EXPIRED')),
  CONSTRAINT "ck_stat_ev_scope_grants__permission" CHECK (capture_allowed OR view_allowed OR review_lock_allowed OR hold_allowed OR deletion_request_allowed),
  CONSTRAINT "ck_stat_ev_scope_grants__effective_window" CHECK (effective_to IS NULL OR effective_to > effective_from),
  CONSTRAINT "ck_stat_ev_scope_grants__row_version" CHECK (row_version > 0)
);;

CREATE INDEX "ix_stat_ev_scope_grants__actor_user" ON "discounts"."statutory_evidence_principal_scope_grants" ("actor_user_id", "source_channel", "grant_status");;
CREATE INDEX "ix_stat_ev_scope_grants__service_identity" ON "discounts"."statutory_evidence_principal_scope_grants" ("actor_service_identity_id", "source_channel", "grant_status");;
CREATE INDEX "ix_stat_ev_scope_grants__site_scope" ON "discounts"."statutory_evidence_principal_scope_grants" ("site_id", "site_group_id", "source_channel");;
CREATE UNIQUE INDEX "ux_stat_ev_scope_grants__active_user_scope" ON "discounts"."statutory_evidence_principal_scope_grants" ("actor_user_id", "source_channel", COALESCE("site_id", '00000000-0000-0000-0000-000000000000'::uuid), COALESCE("site_group_id", '00000000-0000-0000-0000-000000000000'::uuid)) WHERE actor_user_id IS NOT NULL AND grant_status = 'ACTIVE' AND effective_to IS NULL;;
CREATE UNIQUE INDEX "ux_stat_ev_scope_grants__active_service_scope" ON "discounts"."statutory_evidence_principal_scope_grants" ("actor_service_identity_id", "source_channel", COALESCE("site_id", '00000000-0000-0000-0000-000000000000'::uuid), COALESCE("site_group_id", '00000000-0000-0000-0000-000000000000'::uuid)) WHERE actor_service_identity_id IS NOT NULL AND grant_status = 'ACTIVE' AND effective_to IS NULL;;
COMMENT ON TABLE "discounts"."statutory_evidence_principal_scope_grants" IS 'Server-owned statutory evidence metadata scope grants for capture, view, review lock, hold, and deletion-request authority. Possession of an opaque evidence reference is not authorization.';;
