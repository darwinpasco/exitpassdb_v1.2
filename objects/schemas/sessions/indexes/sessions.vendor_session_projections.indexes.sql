CREATE UNIQUE INDEX ux_vendor_session_projections__target_vendor_record_guid
ON sessions.vendor_session_projections (
    vendor_system_id,
    site_group_id,
    site_id,
    parking_lot_index_code,
    vendor_record_guid
)
WHERE vendor_system_id IS NOT NULL
  AND site_group_id IS NOT NULL
  AND site_id IS NOT NULL
  AND parking_lot_index_code IS NOT NULL
  AND vendor_record_guid IS NOT NULL;

CREATE INDEX ix_vendor_session_projections__card_num
ON sessions.vendor_session_projections (card_num)
WHERE card_num IS NOT NULL;

CREATE INDEX ix_vendor_session_projections__plate_license
ON sessions.vendor_session_projections (plate_license)
WHERE plate_license IS NOT NULL;

CREATE INDEX ix_vendor_session_projections__parking_lot_card
ON sessions.vendor_session_projections (parking_lot_index_code, card_num)
WHERE card_num IS NOT NULL;

CREATE INDEX ix_vendor_session_projections__site_card
ON sessions.vendor_session_projections (site_id, card_num)
WHERE site_id IS NOT NULL AND card_num IS NOT NULL;

CREATE INDEX ix_vendor_session_projections__status_refreshed
ON sessions.vendor_session_projections (projection_status, last_refreshed_at DESC);

CREATE INDEX ix_vendor_session_projections__active_open
ON sessions.vendor_session_projections (parking_lot_index_code, last_refreshed_at DESC)
WHERE projection_status = 'ACTIVE';

CREATE INDEX ix_vendor_session_projections__last_refreshed_at
ON sessions.vendor_session_projections (last_refreshed_at);

CREATE INDEX ix_vendor_session_projections__correlation_id
ON sessions.vendor_session_projections (correlation_id)
WHERE correlation_id IS NOT NULL;

CREATE INDEX ix_vendor_session_projections__source_adapter_identity_id
ON sessions.vendor_session_projections (source_adapter_identity_id);
