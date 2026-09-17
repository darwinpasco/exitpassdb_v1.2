CREATE TABLE sessions.vendor_session_projection_sync_targets (
    projection_sync_target_id uuid DEFAULT gen_random_uuid() NOT NULL,
    site_id uuid NOT NULL,
    site_group_id uuid NOT NULL,
    vendor_system_id uuid NOT NULL,
    parking_lot_index_code text NOT NULL,
    parking_lot_name text,
    enabled_flag boolean DEFAULT false NOT NULL,
    poll_interval_seconds integer DEFAULT 60 NOT NULL,
    lookback_window_minutes integer DEFAULT 180 NOT NULL,
    page_size integer DEFAULT 100 NOT NULL,
    last_success_at timestamptz,
    last_failure_at timestamptz,
    last_attempt_at timestamptz,
    health_status text DEFAULT 'DISABLED' NOT NULL,
    failure_count integer DEFAULT 0 NOT NULL,
    last_error_code text,
    last_error_message text,
    last_lock_contention_at timestamptz,
    lock_contention_count integer DEFAULT 0 NOT NULL,
    correlation_id uuid,
    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL,
    row_version integer DEFAULT 1 NOT NULL,
    CONSTRAINT pk_vendor_session_projection_sync_targets PRIMARY KEY (projection_sync_target_id),
    CONSTRAINT fk_vendor_session_projection_sync_targets__site_id
        FOREIGN KEY (site_id) REFERENCES sites.sites(site_id)
        DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_vendor_session_projection_sync_targets__site_group_id
        FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id)
        DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_vendor_session_projection_sync_targets__vendor_system_id
        FOREIGN KEY (vendor_system_id) REFERENCES integration.vendor_systems(vendor_system_id)
        DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT ck_vendor_session_projection_sync_targets__row_version_positive CHECK (row_version > 0),
    CONSTRAINT ck_vendor_session_projection_sync_targets__health_status
        CHECK (health_status IN ('HEALTHY', 'DEGRADED', 'FAILING', 'DISABLED', 'DEFERRED', 'UNKNOWN')),
    CONSTRAINT ck_vendor_session_projection_sync_targets__parking_lot_required
        CHECK (length(btrim(parking_lot_index_code)) > 0),
    CONSTRAINT ck_vendor_session_projection_sync_targets__poll_interval_positive
        CHECK (poll_interval_seconds > 0),
    CONSTRAINT ck_vendor_session_projection_sync_targets__lookback_positive
        CHECK (lookback_window_minutes > 0),
    CONSTRAINT ck_vendor_session_projection_sync_targets__page_size_bounds
        CHECK (page_size BETWEEN 1 AND 500),
    CONSTRAINT ck_vendor_session_projection_sync_targets__failure_count_non_negative
        CHECK (failure_count >= 0),
    CONSTRAINT ck_vendor_projection_targets__lock_contention_non_negative
        CHECK (lock_contention_count >= 0)
);
