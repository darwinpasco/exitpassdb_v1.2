CREATE TABLE sessions.vendor_session_projections (
    vendor_session_projection_id uuid DEFAULT gen_random_uuid() NOT NULL,
    vendor_system_id uuid,
    site_id uuid,
    site_group_id uuid,
    source_adapter_identity_id uuid,
    parking_lot_index_code text,
    parking_lot_name text,
    passageway_index_code text,
    passageway_name text,
    lane_index_code text,
    lane_name text,
    lane_direction text,
    vendor_record_guid text,
    card_num text,
    plate_license text,
    enter_time timestamptz,
    exit_time timestamptz,
    allow_type text,
    allow_result text,
    image_url text,
    source_api text NOT NULL,
    source_payload_hash char(64) NOT NULL,
    source_payload_reference text,
    source_event_at timestamptz,
    stable_identity_type text NOT NULL,
    stable_identity_key text NOT NULL,
    first_seen_at timestamptz NOT NULL,
    last_seen_at timestamptz NOT NULL,
    last_refreshed_at timestamptz NOT NULL,
    projection_status text NOT NULL,
    correlation_id uuid,
    created_at timestamptz DEFAULT now() NOT NULL,
    created_by_service_identity_id uuid NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT pk_vendor_session_projections PRIMARY KEY (vendor_session_projection_id),
    CONSTRAINT fk_vendor_session_projections__vendor_system_id
        FOREIGN KEY (vendor_system_id) REFERENCES integration.vendor_systems(vendor_system_id)
        DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_vendor_session_projections__site_id
        FOREIGN KEY (site_id) REFERENCES sites.sites(site_id)
        DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_vendor_session_projections__site_group_id
        FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id)
        DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_vendor_session_projections__source_adapter_identity_id
        FOREIGN KEY (source_adapter_identity_id) REFERENCES identity.service_identities(service_identity_id),
    CONSTRAINT fk_vendor_session_projections__created_by_service_identity_id
        FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id)
        DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_vendor_session_projections__updated_by_service_identity_id
        FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id)
        DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT uq_vendor_session_projections__target_stable_identity
        UNIQUE (vendor_system_id, site_group_id, site_id, parking_lot_index_code, stable_identity_key),
    CONSTRAINT ck_vendor_session_projections__row_version_positive CHECK (row_version > 0),
    CONSTRAINT ck_vendor_session_projections__projection_status
        CHECK (projection_status IN ('ACTIVE', 'EXITED', 'STALE', 'INVALIDATED', 'UNKNOWN')),
    CONSTRAINT ck_vendor_session_projections__source_payload_hash_sha256
        CHECK (source_payload_hash ~ '^[0-9a-f]{64}$'),
    CONSTRAINT ck_vendor_session_projections__stable_identity_required
        CHECK (length(btrim(stable_identity_type)) > 0 AND length(btrim(stable_identity_key)) > 0),
    CONSTRAINT ck_vendor_session_projections__seen_window
        CHECK (last_seen_at >= first_seen_at AND last_refreshed_at >= first_seen_at)
);
