\set ON_ERROR_STOP on

DO $validation$
DECLARE
    missing text[] := ARRAY[]::text[];
    required_column text;
    required_constraint text;
    required_index text;
    projection_relation regclass := to_regclass('sessions.vendor_session_projections');
    sync_target_relation regclass := to_regclass('sessions.vendor_session_projection_sync_targets');
    projection_columns text[] := ARRAY[
        'vendor_session_projection_id', 'vendor_system_id', 'site_id', 'site_group_id',
        'source_adapter_identity_id', 'parking_lot_index_code', 'parking_lot_name',
        'passageway_index_code', 'passageway_name', 'lane_index_code', 'lane_name',
        'lane_direction', 'vendor_record_guid', 'card_num', 'plate_license', 'enter_time',
        'exit_time', 'allow_type', 'allow_result', 'image_url', 'source_api',
        'source_payload_hash', 'source_payload_reference', 'source_event_at',
        'stable_identity_type', 'stable_identity_key', 'first_seen_at', 'last_seen_at',
        'last_refreshed_at', 'projection_status', 'correlation_id', 'created_at',
        'created_by_service_identity_id', 'updated_at', 'updated_by_service_identity_id',
        'row_version'
    ];
    sync_target_columns text[] := ARRAY[
        'projection_sync_target_id', 'site_id', 'site_group_id', 'vendor_system_id',
        'parking_lot_index_code', 'parking_lot_name', 'enabled_flag',
        'poll_interval_seconds', 'lookback_window_minutes', 'page_size', 'last_success_at',
        'last_failure_at', 'last_attempt_at', 'health_status', 'failure_count',
        'last_error_code', 'last_error_message', 'last_lock_contention_at',
        'lock_contention_count', 'correlation_id', 'created_at', 'updated_at', 'row_version'
    ];
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_enum e
        JOIN pg_type t ON t.oid = e.enumtypid
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname = 'identity'
          AND t.typname = 'human_session_audience_enum'
          AND e.enumlabel = 'NATIVE_PARKING_APP'
    ) THEN
        missing := array_append(missing, 'identity.human_session_audience_enum.NATIVE_PARKING_APP');
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_attribute a
        WHERE a.attrelid = 'identity.local_credentials'::regclass
          AND a.attname = 'temporary_password_expires_at'
          AND NOT a.attisdropped
          AND format_type(a.atttypid, a.atttypmod) = 'timestamp with time zone'
    ) THEN
        missing := array_append(missing, 'identity.local_credentials.temporary_password_expires_at timestamptz');
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conrelid = 'identity.local_credentials'::regclass
          AND conname = 'ck_local_credentials_temporary_password_expiry'
          AND contype = 'c'
          AND pg_get_constraintdef(oid) ILIKE '%credential_status%CHANGE_REQUIRED%temporary_password_expires_at IS NOT NULL%credential_status%<>%CHANGE_REQUIRED%temporary_password_expires_at IS NULL%'
    ) THEN
        missing := array_append(missing, 'ck_local_credentials_temporary_password_expiry definition');
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_indexes
        WHERE schemaname = 'identity'
          AND tablename = 'local_credentials'
          AND indexname = 'ix_local_credentials_temporary_password_expiry'
          AND indexdef ILIKE '%(temporary_password_expires_at)%'
          AND indexdef ILIKE '%WHERE (credential_status = ''CHANGE_REQUIRED''%'
    ) THEN
        missing := array_append(missing, 'ix_local_credentials_temporary_password_expiry definition');
    END IF;

    IF EXISTS (
        SELECT 1
        FROM identity.local_credentials
        WHERE (credential_status = 'CHANGE_REQUIRED' AND temporary_password_expires_at IS NULL)
           OR (credential_status <> 'CHANGE_REQUIRED' AND temporary_password_expires_at IS NOT NULL)
    ) THEN
        missing := array_append(missing, 'local credential temporary-password expiry invariant');
    END IF;

    IF projection_relation IS NULL THEN
        missing := array_append(missing, 'sessions.vendor_session_projections');
    ELSE
        FOREACH required_column IN ARRAY projection_columns LOOP
            IF NOT EXISTS (
                SELECT 1
                FROM information_schema.columns
                WHERE table_schema = 'sessions'
                  AND table_name = 'vendor_session_projections'
                  AND column_name = required_column
            ) THEN
                missing := array_append(missing, 'sessions.vendor_session_projections.' || required_column);
            END IF;
        END LOOP;
    END IF;

    IF sync_target_relation IS NULL THEN
        missing := array_append(missing, 'sessions.vendor_session_projection_sync_targets');
    ELSE
        FOREACH required_column IN ARRAY sync_target_columns LOOP
            IF NOT EXISTS (
                SELECT 1
                FROM information_schema.columns
                WHERE table_schema = 'sessions'
                  AND table_name = 'vendor_session_projection_sync_targets'
                  AND column_name = required_column
            ) THEN
                missing := array_append(missing, 'sessions.vendor_session_projection_sync_targets.' || required_column);
            END IF;
        END LOOP;
    END IF;

    IF projection_relation IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM pg_attribute
            WHERE attrelid = projection_relation
              AND attname = 'source_payload_hash'
              AND format_type(atttypid, atttypmod) = 'character(64)'
              AND NOT attisdropped
        ) THEN missing := array_append(missing, 'vendor_session_projections.source_payload_hash char(64)'); END IF;
        IF NOT EXISTS (
            SELECT 1 FROM pg_attribute
            WHERE attrelid = projection_relation
              AND attname = 'row_version'
              AND format_type(atttypid, atttypmod) = 'bigint'
              AND NOT attisdropped
        ) THEN missing := array_append(missing, 'vendor_session_projections.row_version bigint'); END IF;
    END IF;

    IF sync_target_relation IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_schema = 'sessions'
              AND table_name = 'vendor_session_projection_sync_targets'
              AND column_name = 'enabled_flag'
              AND column_default = 'false'
        ) THEN missing := array_append(missing, 'sync target enabled_flag default false'); END IF;
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_schema = 'sessions'
              AND table_name = 'vendor_session_projection_sync_targets'
              AND column_name = 'poll_interval_seconds'
              AND column_default = '60'
        ) THEN missing := array_append(missing, 'sync target poll_interval_seconds default 60'); END IF;
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_schema = 'sessions'
              AND table_name = 'vendor_session_projection_sync_targets'
              AND column_name = 'health_status'
              AND column_default = '''DISABLED''::text'
        ) THEN missing := array_append(missing, 'sync target health_status default DISABLED'); END IF;
    END IF;

    FOREACH required_constraint IN ARRAY ARRAY[
        'pk_vendor_session_projections',
        'fk_vendor_session_projections__vendor_system_id',
        'fk_vendor_session_projections__site_id',
        'fk_vendor_session_projections__site_group_id',
        'fk_vendor_session_projections__source_adapter_identity_id',
        'fk_vendor_session_projections__created_by_service_identity_id',
        'fk_vendor_session_projections__updated_by_service_identity_id',
        'uq_vendor_session_projections__target_stable_identity',
        'ck_vendor_session_projections__row_version_positive',
        'ck_vendor_session_projections__projection_status',
        'ck_vendor_session_projections__source_payload_hash_sha256',
        'ck_vendor_session_projections__stable_identity_required',
        'ck_vendor_session_projections__seen_window',
        'pk_vendor_session_projection_sync_targets',
        'fk_vendor_session_projection_sync_targets__site_id',
        'fk_vendor_session_projection_sync_targets__site_group_id',
        'fk_vendor_session_projection_sync_targets__vendor_system_id',
        'ck_vendor_session_projection_sync_targets__row_version_positive',
        'ck_vendor_session_projection_sync_targets__health_status',
        'ck_vendor_session_projection_sync_targets__parking_lot_required',
        'ck_vendor_session_projection_sync_targets__lookback_positive',
        'ck_vendor_session_projection_sync_targets__page_size_bounds',
        'ck_vendor_projection_targets__lock_contention_non_negative',
        'fk_parking_sessions__source_adapter_identity_id',
        'fk_tariff_snapshots__source_adapter_identity_id'
    ] LOOP
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = required_constraint) THEN
            missing := array_append(missing, required_constraint);
        END IF;
    END LOOP;

    IF projection_relation IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = projection_relation
          AND conname = 'uq_vendor_session_projections__target_stable_identity'
          AND pg_get_constraintdef(oid) ILIKE '%vendor_system_id, site_group_id, site_id, parking_lot_index_code, stable_identity_key%'
    ) THEN missing := array_append(missing, 'target-scoped stable identity definition'); END IF;

    IF sync_target_relation IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = sync_target_relation
          AND conname = 'ck_vendor_session_projection_sync_targets__health_status'
          AND pg_get_constraintdef(oid) LIKE '%DEFERRED%'
    ) THEN missing := array_append(missing, 'sync target DEFERRED health status'); END IF;

    IF sync_target_relation IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = sync_target_relation
          AND contype = 'c'
          AND pg_get_constraintdef(oid) ILIKE '%poll_interval_seconds > 0%'
    ) THEN missing := array_append(missing, 'sync target positive poll interval constraint'); END IF;

    IF sync_target_relation IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = sync_target_relation
          AND contype = 'c'
          AND pg_get_constraintdef(oid) ILIKE '%failure_count >= 0%'
    ) THEN missing := array_append(missing, 'sync target nonnegative failure count constraint'); END IF;

    FOREACH required_index IN ARRAY ARRAY[
        'ux_vendor_session_projections__target_vendor_record_guid',
        'ix_vendor_session_projections__card_num',
        'ix_vendor_session_projections__plate_license',
        'ix_vendor_session_projections__parking_lot_card',
        'ix_vendor_session_projections__site_card',
        'ix_vendor_session_projections__status_refreshed',
        'ix_vendor_session_projections__active_open',
        'ix_vendor_session_projections__last_refreshed_at',
        'ix_vendor_session_projections__correlation_id',
        'ix_vendor_session_projections__source_adapter_identity_id',
        'ux_vendor_session_projection_sync_targets__scope',
        'ix_vendor_session_projection_sync_targets__enabled_due',
        'ix_vendor_session_projection_sync_targets__site',
        'ix_vendor_session_projection_sync_targets__parking_lot',
        'ix_vendor_session_projection_sync_targets__vendor_system',
        'ix_vendor_session_projection_sync_targets__health',
        'ix_vendor_session_projection_sync_targets__correlation_id',
        'ix_parking_sessions__source_adapter_identity_id',
        'ix_tariff_snapshots__source_adapter_identity_id'
    ] LOOP
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = required_index) THEN
            missing := array_append(missing, required_index);
        END IF;
    END LOOP;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'core' AND table_name = 'parking_sessions'
          AND column_name = 'source_adapter_identity_id' AND data_type = 'uuid'
    ) THEN missing := array_append(missing, 'core.parking_sessions.source_adapter_identity_id'); END IF;
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'core' AND table_name = 'tariff_snapshots'
          AND column_name = 'source_adapter_identity_id' AND data_type = 'uuid'
    ) THEN missing := array_append(missing, 'core.tariff_snapshots.source_adapter_identity_id'); END IF;

    IF array_length(missing, 1) IS NOT NULL THEN
        RAISE EXCEPTION 'Central PMS runtime schema contract validation failed. Missing or incompatible: %', array_to_string(missing, ', ');
    END IF;
END
$validation$;

SELECT 'Central PMS Human Authentication and vendor projection runtime schema contract validation passed.' AS validation_result;
