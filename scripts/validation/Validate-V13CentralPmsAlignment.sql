-- ExitPass v1.3 Central PMS DB alignment validation.
-- Run after applying migrations and, for RBAC/UAT checks, after applying the v1.3 UAT seed script.

DO $$
DECLARE
    missing text[] := ARRAY[]::text[];
    gate_processing_missing_columns text[];
    gate_commands_missing_columns text[];
    hikcentral_audit_missing_columns text[];
    hikcentral_audit_forbidden_columns text[];
    unexpected_pos_objects integer;
BEGIN
    IF to_regclass('core.fiscal_issuance_references') IS NULL THEN missing := array_append(missing, 'core.fiscal_issuance_references'); END IF;
    IF to_regclass('core.fiscal_issuance_attempt_history') IS NULL THEN missing := array_append(missing, 'core.fiscal_issuance_attempt_history'); END IF;
    IF to_regclass('core.fiscal_issuance_exception_reviews') IS NULL THEN missing := array_append(missing, 'core.fiscal_issuance_exception_reviews'); END IF;
    IF to_regclass('core.fiscal_issuance_readback_reconciliations') IS NULL THEN missing := array_append(missing, 'core.fiscal_issuance_readback_reconciliations'); END IF;
    IF to_regclass('core.fiscal_issuance_retry_command_preparations') IS NULL THEN missing := array_append(missing, 'core.fiscal_issuance_retry_command_preparations'); END IF;
    IF to_regclass('core.fiscal_issuance_retry_schedule_preparations') IS NULL THEN missing := array_append(missing, 'core.fiscal_issuance_retry_schedule_preparations'); END IF;
    IF to_regclass('core.fiscal_issuance_retry_execution_attempts') IS NULL THEN missing := array_append(missing, 'core.fiscal_issuance_retry_execution_attempts'); END IF;
    IF to_regclass('core.fiscal_issuance_semantic_hash_recalculation_previews') IS NULL THEN missing := array_append(missing, 'core.fiscal_issuance_semantic_hash_recalculation_previews'); END IF;
    IF to_regclass('core.fiscal_issuance_semantic_hash_backfill_mutation_preparations') IS NULL THEN missing := array_append(missing, 'core.fiscal_issuance_semantic_hash_backfill_mutation_preparations'); END IF;
    IF to_regclass('core.fiscal_issuance_semantic_hash_backfill_workflow_requests') IS NULL THEN missing := array_append(missing, 'core.fiscal_issuance_semantic_hash_backfill_workflow_requests'); END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'operator_console') THEN missing := array_append(missing, 'operator_console schema'); END IF;
    IF to_regclass('operator_console.hr_identity_mappings') IS NULL THEN missing := array_append(missing, 'operator_console.hr_identity_mappings'); END IF;
    IF to_regclass('operator_console.operator_device_bindings') IS NULL THEN missing := array_append(missing, 'operator_console.operator_device_bindings'); END IF;
    IF to_regclass('operator_console.operator_device_assignment_history') IS NULL THEN missing := array_append(missing, 'operator_console.operator_device_assignment_history'); END IF;
    IF to_regclass('operator_console.operator_shifts') IS NULL THEN missing := array_append(missing, 'operator_console.operator_shifts'); END IF;
    IF to_regclass('operator_console.operator_access_evaluations') IS NULL THEN missing := array_append(missing, 'operator_console.operator_access_evaluations'); END IF;
    IF to_regclass('operator_console.operator_access_evaluation_reasons') IS NULL THEN missing := array_append(missing, 'operator_console.operator_access_evaluation_reasons'); END IF;
    IF to_regclass('operator_console.production_policy_import_review_submissions') IS NULL THEN missing := array_append(missing, 'operator_console.production_policy_import_review_submissions'); END IF;
    IF to_regclass('operator_console.production_policy_import_review_decisions') IS NULL THEN missing := array_append(missing, 'operator_console.production_policy_import_review_decisions'); END IF;
    IF to_regclass('operator_console.production_policy_import_review_history') IS NULL THEN missing := array_append(missing, 'operator_console.production_policy_import_review_history'); END IF;
    IF to_regclass('operator_console.production_policy_import_review_findings') IS NULL THEN missing := array_append(missing, 'operator_console.production_policy_import_review_findings'); END IF;

    IF to_regclass('discounts.statutory_entitlement_fingerprints') IS NULL THEN missing := array_append(missing, 'discounts.statutory_entitlement_fingerprints'); END IF;
    IF to_regclass('discounts.statutory_discount_payable_basis_applications') IS NULL THEN missing := array_append(missing, 'discounts.statutory_discount_payable_basis_applications'); END IF;
    IF to_regprocedure('discounts.apply_statutory_discount_payable_basis(uuid,uuid,uuid)') IS NULL THEN missing := array_append(missing, 'discounts.apply_statutory_discount_payable_basis(uuid,uuid,uuid)'); END IF;

    IF to_regprocedure('core.create_or_reuse_payment_attempt(uuid,uuid,text,text,text,uuid,timestamp with time zone)') IS NULL THEN missing := array_append(missing, 'core.create_or_reuse_payment_attempt(uuid,uuid,text,text,text,uuid,timestamptz)'); END IF;
    IF to_regprocedure('core.finalize_payment_attempt(uuid,text,text,uuid,timestamp with time zone)') IS NULL THEN missing := array_append(missing, 'core.finalize_payment_attempt(uuid,text,text,uuid,timestamptz)'); END IF;
    IF to_regprocedure('core.record_payment_confirmation(uuid,text,text,text,uuid,timestamp with time zone)') IS NULL THEN missing := array_append(missing, 'core.record_payment_confirmation(uuid,text,text,text,uuid,timestamptz)'); END IF;
    IF to_regprocedure('core.issue_exit_authorization(uuid,uuid,uuid,uuid,timestamp with time zone)') IS NULL THEN missing := array_append(missing, 'core.issue_exit_authorization(uuid,uuid,uuid,uuid,timestamptz)'); END IF;
    IF to_regprocedure('core.consume_exit_authorization(uuid,uuid,uuid,timestamp with time zone)') IS NULL THEN missing := array_append(missing, 'core.consume_exit_authorization(uuid,uuid,uuid,timestamptz)'); END IF;

    IF to_regclass('gates.gate_authorization_consumed_processing') IS NULL THEN
        missing := array_append(missing, 'gates.gate_authorization_consumed_processing');
    ELSE
        SELECT array_agg(required.column_name)
        INTO gate_processing_missing_columns
        FROM (
            VALUES
                ('processing_id'),
                ('processing_key'),
                ('event_id'),
                ('event_type'),
                ('event_ref'),
                ('gate_authorization_consumption_id'),
                ('exit_authorization_id'),
                ('parking_session_id'),
                ('payment_attempt_id'),
                ('tariff_snapshot_id'),
                ('gate_device_id'),
                ('service_identity_id'),
                ('lane_id'),
                ('site_id'),
                ('vendor_system_id'),
                ('consumed_at'),
                ('correlation_id'),
                ('processing_status'),
                ('processing_result'),
                ('attempt_count'),
                ('first_attempted_at'),
                ('last_attempted_at'),
                ('processed_at'),
                ('failure_code'),
                ('failure_reason'),
                ('created_at'),
                ('updated_at')
        ) AS required(column_name)
        WHERE NOT EXISTS (
            SELECT 1
            FROM information_schema.columns actual
            WHERE actual.table_schema = 'gates'
              AND actual.table_name = 'gate_authorization_consumed_processing'
              AND actual.column_name = required.column_name
        );

        IF array_length(gate_processing_missing_columns, 1) IS NOT NULL THEN
            missing := array_append(missing, 'gates.gate_authorization_consumed_processing missing columns: ' || array_to_string(gate_processing_missing_columns, ', '));
        END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM pg_constraint con
            JOIN pg_class cls ON cls.oid = con.conrelid
            JOIN pg_namespace n ON n.oid = cls.relnamespace
            WHERE n.nspname = 'gates'
              AND cls.relname = 'gate_authorization_consumed_processing'
              AND con.conname = 'fk_gate_auth_consumed_processing__consumption'
              AND con.contype = 'f'
        ) THEN missing := array_append(missing, 'fk_gate_auth_consumed_processing__consumption'); END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM pg_constraint con
            JOIN pg_class cls ON cls.oid = con.conrelid
            JOIN pg_namespace n ON n.oid = cls.relnamespace
            WHERE n.nspname = 'gates'
              AND cls.relname = 'gate_authorization_consumed_processing'
              AND con.conname = 'ck_gate_auth_consumed_processing__attempt_count'
              AND con.contype = 'c'
        ) THEN missing := array_append(missing, 'ck_gate_auth_consumed_processing__attempt_count'); END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM pg_constraint con
            JOIN pg_class cls ON cls.oid = con.conrelid
            JOIN pg_namespace n ON n.oid = cls.relnamespace
            WHERE n.nspname = 'gates'
              AND cls.relname = 'gate_authorization_consumed_processing'
              AND con.conname = 'ck_gate_auth_consumed_processing__processed_at'
              AND con.contype = 'c'
        ) THEN missing := array_append(missing, 'ck_gate_auth_consumed_processing__processed_at'); END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM pg_index idx
            JOIN pg_class ix ON ix.oid = idx.indexrelid
            JOIN pg_class tbl ON tbl.oid = idx.indrelid
            JOIN pg_namespace n ON n.oid = tbl.relnamespace
            WHERE n.nspname = 'gates'
              AND tbl.relname = 'gate_authorization_consumed_processing'
              AND ix.relname = 'ux_gate_auth_consumed_processing__key_event_type'
              AND idx.indisunique
        ) THEN missing := array_append(missing, 'ux_gate_auth_consumed_processing__key_event_type'); END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM pg_index idx
            JOIN pg_class ix ON ix.oid = idx.indexrelid
            JOIN pg_class tbl ON tbl.oid = idx.indrelid
            JOIN pg_namespace n ON n.oid = tbl.relnamespace
            WHERE n.nspname = 'gates'
              AND tbl.relname = 'gate_authorization_consumed_processing'
              AND ix.relname = 'ux_gate_auth_consumed_processing__event_id'
              AND idx.indisunique
              AND pg_get_expr(idx.indpred, idx.indrelid) ILIKE '%event_id%IS NOT NULL%'
        ) THEN missing := array_append(missing, 'ux_gate_auth_consumed_processing__event_id'); END IF;

        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'gates' AND indexname = 'ix_gate_auth_consumed_processing__consumption') THEN missing := array_append(missing, 'ix_gate_auth_consumed_processing__consumption'); END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'gates' AND indexname = 'ix_gate_auth_consumed_processing__status') THEN missing := array_append(missing, 'ix_gate_auth_consumed_processing__status'); END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'gates' AND indexname = 'ix_gate_auth_consumed_processing__correlation_id') THEN missing := array_append(missing, 'ix_gate_auth_consumed_processing__correlation_id'); END IF;
    END IF;

    IF to_regclass('gates.gate_commands') IS NULL THEN
        missing := array_append(missing, 'gates.gate_commands');
    ELSE
        SELECT array_agg(required.column_name)
        INTO gate_commands_missing_columns
        FROM (
            VALUES
                ('command_id'),
                ('command_type'),
                ('source_processing_id'),
                ('source_event_id'),
                ('source_event_ref'),
                ('gate_authorization_consumption_id'),
                ('exit_authorization_id'),
                ('parking_session_id'),
                ('payment_attempt_id'),
                ('tariff_snapshot_id'),
                ('gate_device_id'),
                ('service_identity_id'),
                ('lane_id'),
                ('site_id'),
                ('vendor_system_id'),
                ('command_status'),
                ('attempt_count'),
                ('max_attempts'),
                ('retry_policy_code'),
                ('requested_at'),
                ('started_at'),
                ('last_attempted_at'),
                ('next_attempt_at'),
                ('completed_at'),
                ('terminal_failure_at'),
                ('failure_code'),
                ('failure_reason'),
                ('last_failure_code'),
                ('last_failure_reason'),
                ('correlation_id'),
                ('created_at'),
                ('updated_at')
        ) AS required(column_name)
        WHERE NOT EXISTS (
            SELECT 1
            FROM information_schema.columns actual
            WHERE actual.table_schema = 'gates'
              AND actual.table_name = 'gate_commands'
              AND actual.column_name = required.column_name
        );

        IF array_length(gate_commands_missing_columns, 1) IS NOT NULL THEN
            missing := array_append(missing, 'gates.gate_commands missing columns: ' || array_to_string(gate_commands_missing_columns, ', '));
        END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM pg_constraint con
            JOIN pg_class cls ON cls.oid = con.conrelid
            JOIN pg_namespace n ON n.oid = cls.relnamespace
            WHERE n.nspname = 'gates'
              AND cls.relname = 'gate_commands'
              AND con.conname = 'fk_gate_commands__source_processing_id'
              AND con.contype = 'f'
        ) THEN missing := array_append(missing, 'fk_gate_commands__source_processing_id'); END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM pg_constraint con
            JOIN pg_class cls ON cls.oid = con.conrelid
            JOIN pg_namespace n ON n.oid = cls.relnamespace
            WHERE n.nspname = 'gates'
              AND cls.relname = 'gate_commands'
              AND con.conname = 'fk_gate_commands__consumption'
              AND con.contype = 'f'
        ) THEN missing := array_append(missing, 'fk_gate_commands__consumption'); END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM pg_index idx
            JOIN pg_class ix ON ix.oid = idx.indexrelid
            JOIN pg_class tbl ON tbl.oid = idx.indrelid
            JOIN pg_namespace n ON n.oid = tbl.relnamespace
            WHERE n.nspname = 'gates'
              AND tbl.relname = 'gate_commands'
              AND ix.relname = 'ux_gate_commands__source_processing_command_type'
              AND idx.indisunique
        ) THEN missing := array_append(missing, 'ux_gate_commands__source_processing_command_type'); END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM pg_constraint con
            JOIN pg_class cls ON cls.oid = con.conrelid
            JOIN pg_namespace n ON n.oid = cls.relnamespace
            WHERE n.nspname = 'gates'
              AND cls.relname = 'gate_commands'
              AND con.conname = 'ck_gate_commands__status'
              AND con.contype = 'c'
        ) THEN missing := array_append(missing, 'ck_gate_commands__status'); END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM pg_constraint con
            JOIN pg_class cls ON cls.oid = con.conrelid
            JOIN pg_namespace n ON n.oid = cls.relnamespace
            WHERE n.nspname = 'gates'
              AND cls.relname = 'gate_commands'
              AND con.conname = 'ck_gate_commands__attempt_count'
              AND con.contype = 'c'
        ) THEN missing := array_append(missing, 'ck_gate_commands__attempt_count'); END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM pg_constraint con
            JOIN pg_class cls ON cls.oid = con.conrelid
            JOIN pg_namespace n ON n.oid = cls.relnamespace
            WHERE n.nspname = 'gates'
              AND cls.relname = 'gate_commands'
              AND con.conname = 'ck_gate_commands__max_attempts'
              AND con.contype = 'c'
        ) THEN missing := array_append(missing, 'ck_gate_commands__max_attempts'); END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM pg_constraint con
            JOIN pg_class cls ON cls.oid = con.conrelid
            JOIN pg_namespace n ON n.oid = cls.relnamespace
            WHERE n.nspname = 'gates'
              AND cls.relname = 'gate_commands'
              AND con.conname = 'ck_gate_commands__attempt_policy'
              AND con.contype = 'c'
        ) THEN missing := array_append(missing, 'ck_gate_commands__attempt_policy'); END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM pg_constraint con
            JOIN pg_class cls ON cls.oid = con.conrelid
            JOIN pg_namespace n ON n.oid = cls.relnamespace
            WHERE n.nspname = 'gates'
              AND cls.relname = 'gate_commands'
              AND con.conname = 'ck_gate_commands__retryable_next_attempt'
              AND con.contype = 'c'
        ) THEN missing := array_append(missing, 'ck_gate_commands__retryable_next_attempt'); END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM pg_constraint con
            JOIN pg_class cls ON cls.oid = con.conrelid
            JOIN pg_namespace n ON n.oid = cls.relnamespace
            WHERE n.nspname = 'gates'
              AND cls.relname = 'gate_commands'
              AND con.conname = 'ck_gate_commands__terminal_failure_at'
              AND con.contype = 'c'
        ) THEN missing := array_append(missing, 'ck_gate_commands__terminal_failure_at'); END IF;

        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'gates' AND indexname = 'ix_gate_commands__consumption') THEN missing := array_append(missing, 'ix_gate_commands__consumption'); END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'gates' AND indexname = 'ix_gate_commands__status') THEN missing := array_append(missing, 'ix_gate_commands__status'); END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'gates' AND indexname = 'ix_gate_commands__correlation_id') THEN missing := array_append(missing, 'ix_gate_commands__correlation_id'); END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'gates' AND indexname = 'ix_gate_commands__next_attempt_at') THEN missing := array_append(missing, 'ix_gate_commands__next_attempt_at'); END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'gates' AND indexname = 'ix_gate_commands__terminal_failure_at') THEN missing := array_append(missing, 'ix_gate_commands__terminal_failure_at'); END IF;
    END IF;

    IF to_regclass('gates.hikcentral_gate_action_audits') IS NULL THEN
        missing := array_append(missing, 'gates.hikcentral_gate_action_audits');
    ELSE
        SELECT array_agg(required.column_name)
        INTO hikcentral_audit_missing_columns
        FROM (
            VALUES
                ('hikcentral_gate_action_audit_id'),
                ('gate_command_id'),
                ('source_processing_id'),
                ('gate_authorization_consumption_id'),
                ('exit_authorization_id'),
                ('parking_session_id'),
                ('payment_attempt_id'),
                ('tariff_snapshot_id'),
                ('gate_device_id'),
                ('service_identity_id'),
                ('lane_id'),
                ('site_id'),
                ('vendor_system_id'),
                ('vendor_code'),
                ('vendor_operation'),
                ('door_index_code'),
                ('request_method'),
                ('request_path'),
                ('request_hash'),
                ('signed_header_names'),
                ('request_correlation_id'),
                ('vendor_correlation_id'),
                ('http_status_code'),
                ('vendor_result_code'),
                ('vendor_result_message'),
                ('action_outcome'),
                ('retryable'),
                ('failure_recorded'),
                ('duration_ms'),
                ('timed_out'),
                ('vendor_unavailable'),
                ('transport_failure'),
                ('requested_at'),
                ('responded_at'),
                ('created_at')
        ) AS required(column_name)
        WHERE NOT EXISTS (
            SELECT 1
            FROM information_schema.columns actual
            WHERE actual.table_schema = 'gates'
              AND actual.table_name = 'hikcentral_gate_action_audits'
              AND actual.column_name = required.column_name
        );

        IF array_length(hikcentral_audit_missing_columns, 1) IS NOT NULL THEN
            missing := array_append(missing, 'gates.hikcentral_gate_action_audits missing columns: ' || array_to_string(hikcentral_audit_missing_columns, ', '));
        END IF;

        SELECT array_agg(column_name)
        INTO hikcentral_audit_forbidden_columns
        FROM information_schema.columns
        WHERE table_schema = 'gates'
          AND table_name = 'hikcentral_gate_action_audits'
          AND (
              lower(column_name) IN ('app_key', 'app_secret', 'credential', 'signature', 'request_body', 'response_body', 'request_headers', 'response_headers', 'payload_json')
              OR lower(column_name) LIKE '%credential%'
              OR lower(column_name) LIKE '%signature%'
              OR lower(column_name) LIKE '%request_body%'
              OR lower(column_name) LIKE '%response_body%'
              OR lower(column_name) LIKE '%request_headers%'
              OR lower(column_name) LIKE '%response_headers%'
              OR lower(column_name) LIKE '%payload_json%'
          );

        IF array_length(hikcentral_audit_forbidden_columns, 1) IS NOT NULL THEN
            missing := array_append(missing, 'gates.hikcentral_gate_action_audits forbidden secret/raw-payload columns: ' || array_to_string(hikcentral_audit_forbidden_columns, ', '));
        END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM pg_constraint con
            JOIN pg_class cls ON cls.oid = con.conrelid
            JOIN pg_namespace n ON n.oid = cls.relnamespace
            WHERE n.nspname = 'gates'
              AND cls.relname = 'hikcentral_gate_action_audits'
              AND con.conname = 'fk_hikcentral_gate_action_audits__gate_command_id'
              AND con.contype = 'f'
        ) THEN missing := array_append(missing, 'fk_hikcentral_gate_action_audits__gate_command_id'); END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM pg_constraint con
            JOIN pg_class cls ON cls.oid = con.conrelid
            JOIN pg_namespace n ON n.oid = cls.relnamespace
            WHERE n.nspname = 'gates'
              AND cls.relname = 'hikcentral_gate_action_audits'
              AND con.conname = 'ck_hikcentral_gate_action_audits__vendor'
              AND con.contype = 'c'
        ) THEN missing := array_append(missing, 'ck_hikcentral_gate_action_audits__vendor'); END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM pg_constraint con
            JOIN pg_class cls ON cls.oid = con.conrelid
            JOIN pg_namespace n ON n.oid = cls.relnamespace
            WHERE n.nspname = 'gates'
              AND cls.relname = 'hikcentral_gate_action_audits'
              AND con.conname = 'ck_hikcentral_gate_action_audits__method'
              AND con.contype = 'c'
        ) THEN missing := array_append(missing, 'ck_hikcentral_gate_action_audits__method'); END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM pg_constraint con
            JOIN pg_class cls ON cls.oid = con.conrelid
            JOIN pg_namespace n ON n.oid = cls.relnamespace
            WHERE n.nspname = 'gates'
              AND cls.relname = 'hikcentral_gate_action_audits'
              AND con.conname = 'ck_hikcentral_gate_action_audits__duration'
              AND con.contype = 'c'
        ) THEN missing := array_append(missing, 'ck_hikcentral_gate_action_audits__duration'); END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM pg_constraint con
            JOIN pg_class cls ON cls.oid = con.conrelid
            JOIN pg_namespace n ON n.oid = cls.relnamespace
            WHERE n.nspname = 'gates'
              AND cls.relname = 'hikcentral_gate_action_audits'
              AND con.conname = 'ck_hikcentral_gate_action_audits__timestamps'
              AND con.contype = 'c'
        ) THEN missing := array_append(missing, 'ck_hikcentral_gate_action_audits__timestamps'); END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM pg_constraint con
            JOIN pg_class cls ON cls.oid = con.conrelid
            JOIN pg_namespace n ON n.oid = cls.relnamespace
            WHERE n.nspname = 'gates'
              AND cls.relname = 'hikcentral_gate_action_audits'
              AND con.conname = 'ck_hikcentral_gate_action_audits__http_status'
              AND con.contype = 'c'
        ) THEN missing := array_append(missing, 'ck_hikcentral_gate_action_audits__http_status'); END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM pg_constraint con
            JOIN pg_class cls ON cls.oid = con.conrelid
            JOIN pg_namespace n ON n.oid = cls.relnamespace
            WHERE n.nspname = 'gates'
              AND cls.relname = 'hikcentral_gate_action_audits'
              AND con.conname = 'ck_hikcentral_gate_action_audits__outcome'
              AND con.contype = 'c'
        ) THEN missing := array_append(missing, 'ck_hikcentral_gate_action_audits__outcome'); END IF;

        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'gates' AND indexname = 'ix_hikcentral_gate_action_audits__gate_command') THEN missing := array_append(missing, 'ix_hikcentral_gate_action_audits__gate_command'); END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'gates' AND indexname = 'ix_hikcentral_gate_action_audits__source_processing') THEN missing := array_append(missing, 'ix_hikcentral_gate_action_audits__source_processing'); END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'gates' AND indexname = 'ix_hikcentral_gate_action_audits__consumption') THEN missing := array_append(missing, 'ix_hikcentral_gate_action_audits__consumption'); END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'gates' AND indexname = 'ix_hikcentral_gate_action_audits__exit_authorization') THEN missing := array_append(missing, 'ix_hikcentral_gate_action_audits__exit_authorization'); END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'gates' AND indexname = 'ix_hikcentral_gate_action_audits__vendor_system') THEN missing := array_append(missing, 'ix_hikcentral_gate_action_audits__vendor_system'); END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'gates' AND indexname = 'ix_hikcentral_gate_action_audits__outcome') THEN missing := array_append(missing, 'ix_hikcentral_gate_action_audits__outcome'); END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'gates' AND indexname = 'ix_hikcentral_gate_action_audits__requested_at') THEN missing := array_append(missing, 'ix_hikcentral_gate_action_audits__requested_at'); END IF;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'discounts' AND indexname = 'ux_sd_pba__validation_active') THEN missing := array_append(missing, 'ux_sd_pba__validation_active'); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'core' AND indexname = 'ux_tariff_snapshots__statutory_discount_validation_applied') THEN missing := array_append(missing, 'ux_tariff_snapshots__statutory_discount_validation_applied'); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'core' AND indexname = 'ux_fiscal_issuance_references__active_idempotency_scope') THEN missing := array_append(missing, 'ux_fiscal_issuance_references__active_idempotency_scope'); END IF;

    IF to_regclass('discounts.statutory_discount_decision_commands') IS NULL THEN missing := array_append(missing, 'discounts.statutory_discount_decision_commands'); END IF;
    IF to_regclass('discounts.statutory_discount_payable_basis_application_commands') IS NULL THEN missing := array_append(missing, 'discounts.statutory_discount_payable_basis_application_commands'); END IF;
    IF to_regclass('operator_console.statutory_discount_service_channel_reviews') IS NULL THEN missing := array_append(missing, 'operator_console.statutory_discount_service_channel_reviews'); END IF;

    IF to_regclass('discounts.statutory_discount_decision_commands') IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'discounts' AND table_name = 'statutory_discount_decision_commands' AND column_name = 'business_identity') THEN missing := array_append(missing, 'decision command business_identity'); END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'discounts' AND table_name = 'statutory_discount_decision_commands' AND column_name = 'decision_result_status') THEN missing := array_append(missing, 'decision command decision_result_status'); END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_constraint con JOIN pg_class cls ON cls.oid = con.conrelid JOIN pg_namespace n ON n.oid = cls.relnamespace WHERE n.nspname = 'discounts' AND cls.relname = 'statutory_discount_decision_commands' AND con.conname = 'ck_statutory_discount_decision_commands__command_status' AND pg_get_constraintdef(con.oid) LIKE '%AWAITING_REVIEW%') THEN missing := array_append(missing, 'decision command AWAITING_REVIEW constraint'); END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_constraint con JOIN pg_class cls ON cls.oid = con.conrelid JOIN pg_namespace n ON n.oid = cls.relnamespace WHERE n.nspname = 'discounts' AND cls.relname = 'statutory_discount_decision_commands' AND con.conname = 'ck_statutory_discount_decision_commands__decision_result_status' AND pg_get_constraintdef(con.oid) LIKE '%NOT_DECIDED%') THEN missing := array_append(missing, 'decision command NOT_DECIDED constraint'); END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_constraint con JOIN pg_class cls ON cls.oid = con.conrelid JOIN pg_namespace n ON n.oid = cls.relnamespace WHERE n.nspname = 'discounts' AND cls.relname = 'statutory_discount_decision_commands' AND con.conname = 'ck_statutory_discount_decision_commands__semantic_version' AND pg_get_constraintdef(con.oid) LIKE '%statutory-discount-decision:sha256:v1%' AND pg_get_constraintdef(con.oid) LIKE '%statutory-discount-decision:sha256:v2%') THEN missing := array_append(missing, 'decision command v1/v2 semantic source constraint'); END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'discounts' AND indexname = 'ux_statutory_discount_decision_commands__business_identity_text') THEN missing := array_append(missing, 'ux_statutory_discount_decision_commands__business_identity_text'); END IF;
    END IF;

    IF to_regclass('discounts.statutory_discount_payable_basis_application_commands') IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint con JOIN pg_class cls ON cls.oid = con.conrelid JOIN pg_namespace n ON n.oid = cls.relnamespace WHERE n.nspname = 'discounts' AND cls.relname = 'statutory_discount_payable_basis_application_commands' AND con.conname = 'ck_stat_discount_pba_commands__semantic_version' AND pg_get_constraintdef(con.oid) LIKE '%statutory-discount-payable-basis-application:sha256:v1%') THEN missing := array_append(missing, 'application command v1 semantic source constraint'); END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'discounts' AND indexname = 'ux_stat_discount_pba_commands__decision_command') THEN missing := array_append(missing, 'ux_stat_discount_pba_commands__decision_command'); END IF;
    END IF;

    IF to_regclass('operator_console.statutory_discount_service_channel_reviews') IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'operator_console' AND table_name = 'statutory_discount_service_channel_reviews' AND column_name = 'statutory_discount_validation_id') THEN missing := array_append(missing, 'service-channel review statutory_discount_validation_id'); END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_constraint con JOIN pg_class cls ON cls.oid = con.conrelid JOIN pg_namespace n ON n.oid = cls.relnamespace WHERE n.nspname = 'operator_console' AND cls.relname = 'statutory_discount_service_channel_reviews' AND con.conname = 'fk_stat_disc_svc_reviews__validation' AND con.contype = 'f') THEN missing := array_append(missing, 'fk_stat_disc_svc_reviews__validation'); END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'operator_console' AND indexname = 'ux_stat_disc_svc_reviews__validation') THEN missing := array_append(missing, 'ux_stat_disc_svc_reviews__validation'); END IF;
    END IF;

    IF to_regclass('sites.jurisdictions') IS NULL THEN missing := array_append(missing, 'sites.jurisdictions'); END IF;
    IF to_regclass('sites.site_jurisdiction_assignments') IS NULL THEN missing := array_append(missing, 'sites.site_jurisdiction_assignments'); END IF;
    IF to_regclass('discounts.statutory_discount_policy_versions') IS NULL THEN missing := array_append(missing, 'discounts.statutory_discount_policy_versions'); END IF;
    IF to_regclass('discounts.statutory_discount_policy_version_evidence_requirements') IS NULL THEN missing := array_append(missing, 'discounts.statutory_discount_policy_version_evidence_requirements'); END IF;
    IF to_regclass('discounts.statutory_discount_policy_version_relationships') IS NULL THEN missing := array_append(missing, 'discounts.statutory_discount_policy_version_relationships'); END IF;
    IF to_regclass('discounts.statutory_discount_decision_policy_authorities') IS NULL THEN missing := array_append(missing, 'discounts.statutory_discount_decision_policy_authorities'); END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_enum e JOIN pg_type t ON t.oid = e.enumtypid JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'discounts' AND t.typname = 'policy_verification_status_enum' AND e.enumlabel = 'VERIFIED_ACTIVE_OPERATIONAL') THEN missing := array_append(missing, 'policy_verification_status_enum VERIFIED_ACTIVE_OPERATIONAL'); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_enum e JOIN pg_type t ON t.oid = e.enumtypid JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'discounts' AND t.typname = 'statutory_policy_publication_status_enum' AND e.enumlabel = 'ACTIVE_FOR_TRANSACTION_USE') THEN missing := array_append(missing, 'statutory_policy_publication_status_enum ACTIVE_FOR_TRANSACTION_USE'); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_enum e JOIN pg_type t ON t.oid = e.enumtypid JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'discounts' AND t.typname = 'parking_service_applicability_status_enum' AND e.enumlabel = 'COVERED') THEN missing := array_append(missing, 'parking_service_applicability_status_enum COVERED'); END IF;

    IF to_regclass('sites.jurisdictions') IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint con JOIN pg_class cls ON cls.oid = con.conrelid JOIN pg_namespace n ON n.oid = cls.relnamespace WHERE n.nspname = 'sites' AND cls.relname = 'jurisdictions' AND con.conname = 'uq_jurisdictions__code' AND con.contype = 'u') THEN missing := array_append(missing, 'uq_jurisdictions__code'); END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_constraint con JOIN pg_class cls ON cls.oid = con.conrelid JOIN pg_namespace n ON n.oid = cls.relnamespace WHERE n.nspname = 'sites' AND cls.relname = 'jurisdictions' AND con.conname = 'ck_jurisdictions__no_self_replacement' AND con.contype = 'c') THEN missing := array_append(missing, 'ck_jurisdictions__no_self_replacement'); END IF;
    END IF;

    IF to_regclass('sites.site_jurisdiction_assignments') IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'sites' AND indexname = 'ux_site_jurisdiction_assignments__one_open_active') THEN missing := array_append(missing, 'ux_site_jurisdiction_assignments__one_open_active'); END IF;
        IF EXISTS (
            SELECT 1
            FROM sites.site_jurisdiction_assignments a
            JOIN sites.site_jurisdiction_assignments b
              ON a.site_id = b.site_id
             AND a.site_jurisdiction_assignment_id <> b.site_jurisdiction_assignment_id
             AND a.assignment_status = 'ACTIVE'::sites.site_jurisdiction_assignment_status_enum
             AND b.assignment_status = 'ACTIVE'::sites.site_jurisdiction_assignment_status_enum
             AND tstzrange(a.effective_from, COALESCE(a.effective_to, 'infinity'::timestamptz), '[)') &&
                 tstzrange(b.effective_from, COALESCE(b.effective_to, 'infinity'::timestamptz), '[)')
        ) THEN missing := array_append(missing, 'overlapping active site jurisdiction assignments'); END IF;
    END IF;

    IF to_regclass('discounts.statutory_discount_policy_versions') IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint con JOIN pg_class cls ON cls.oid = con.conrelid JOIN pg_namespace n ON n.oid = cls.relnamespace WHERE n.nspname = 'discounts' AND cls.relname = 'statutory_discount_policy_versions' AND con.conname = 'ck_sd_policy_versions__transaction_active_verification' AND con.contype = 'c') THEN missing := array_append(missing, 'ck_sd_policy_versions__transaction_active_verification'); END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_constraint con JOIN pg_class cls ON cls.oid = con.conrelid JOIN pg_namespace n ON n.oid = cls.relnamespace WHERE n.nspname = 'discounts' AND cls.relname = 'statutory_discount_policy_versions' AND con.conname = 'ck_sd_policy_versions__proposed_unverified_not_active' AND con.contype = 'c') THEN missing := array_append(missing, 'ck_sd_policy_versions__proposed_unverified_not_active'); END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_constraint con JOIN pg_class cls ON cls.oid = con.conrelid JOIN pg_namespace n ON n.oid = cls.relnamespace WHERE n.nspname = 'discounts' AND cls.relname = 'statutory_discount_policy_versions' AND con.conname = 'ck_sd_policy_versions__active_parking_covered' AND con.contype = 'c') THEN missing := array_append(missing, 'ck_sd_policy_versions__active_parking_covered'); END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'discounts' AND indexname = 'ix_sd_policy_versions__active_lookup') THEN missing := array_append(missing, 'ix_sd_policy_versions__active_lookup'); END IF;
        IF EXISTS (SELECT 1 FROM discounts.statutory_discount_policy_versions WHERE transaction_publication_status = 'ACTIVE_FOR_TRANSACTION_USE'::discounts.statutory_policy_publication_status_enum AND source_verification_status IN ('LEAD_UNVERIFIED'::discounts.policy_verification_status_enum, 'VERIFIED_SECONDARY'::discounts.policy_verification_status_enum, 'PROPOSED_ONLY'::discounts.policy_verification_status_enum, 'PROPOSED'::discounts.policy_verification_status_enum, 'NO_LOCAL_RULE_FOUND'::discounts.policy_verification_status_enum, 'STATUS_UNRESOLVED'::discounts.policy_verification_status_enum, 'REJECTED'::discounts.policy_verification_status_enum)) THEN missing := array_append(missing, 'unverified/proposed/no-local policy is transaction active'); END IF;
        IF EXISTS (SELECT 1 FROM discounts.statutory_discount_policy_versions WHERE transaction_publication_status = 'ACTIVE_FOR_TRANSACTION_USE'::discounts.statutory_policy_publication_status_enum AND parking_service_applicability <> 'COVERED'::discounts.parking_service_applicability_status_enum) THEN missing := array_append(missing, 'transaction-active policy without covered parking applicability'); END IF;
        IF EXISTS (
            SELECT 1
            FROM discounts.statutory_discount_policy_versions a
            JOIN discounts.statutory_discount_policy_versions b
              ON a.statutory_discount_policy_version_id <> b.statutory_discount_policy_version_id
             AND a.entitlement_type = b.entitlement_type
             AND a.jurisdiction_id = b.jurisdiction_id
             AND a.policy_scope_type = b.policy_scope_type
             AND COALESCE(a.site_group_id, '00000000-0000-0000-0000-000000000000'::uuid) = COALESCE(b.site_group_id, '00000000-0000-0000-0000-000000000000'::uuid)
             AND COALESCE(a.site_id, '00000000-0000-0000-0000-000000000000'::uuid) = COALESCE(b.site_id, '00000000-0000-0000-0000-000000000000'::uuid)
             AND a.transaction_publication_status = 'ACTIVE_FOR_TRANSACTION_USE'::discounts.statutory_policy_publication_status_enum
             AND b.transaction_publication_status = 'ACTIVE_FOR_TRANSACTION_USE'::discounts.statutory_policy_publication_status_enum
             AND a.parking_service_applicability = 'COVERED'::discounts.parking_service_applicability_status_enum
             AND b.parking_service_applicability = 'COVERED'::discounts.parking_service_applicability_status_enum
             AND a.precedence_rank = b.precedence_rank
             AND tstzrange(COALESCE(a.transaction_use_effective_from, '-infinity'::timestamptz), COALESCE(a.transaction_use_effective_to, 'infinity'::timestamptz), '[)') &&
                 tstzrange(COALESCE(b.transaction_use_effective_from, '-infinity'::timestamptz), COALESCE(b.transaction_use_effective_to, 'infinity'::timestamptz), '[)')
        ) THEN missing := array_append(missing, 'overlapping active statutory policy versions without deterministic precedence'); END IF;
    END IF;

    IF to_regclass('discounts.statutory_discount_decision_policy_authorities') IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint con JOIN pg_class cls ON cls.oid = con.conrelid JOIN pg_namespace n ON n.oid = cls.relnamespace WHERE n.nspname = 'discounts' AND cls.relname = 'statutory_discount_decision_policy_authorities' AND con.conname = 'ck_sd_decision_policy_authorities__active_authority' AND con.contype = 'c') THEN missing := array_append(missing, 'ck_sd_decision_policy_authorities__active_authority'); END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'discounts' AND indexname = 'ix_sd_decision_policy_authorities__policy_version') THEN missing := array_append(missing, 'ix_sd_decision_policy_authorities__policy_version'); END IF;
    END IF;

    IF to_regclass('discounts.statutory_discount_validations') IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'discounts' AND table_name = 'statutory_discount_validations' AND column_name = 'statutory_discount_policy_version_id') THEN missing := array_append(missing, 'validation statutory_discount_policy_version_id'); END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_constraint con JOIN pg_class cls ON cls.oid = con.conrelid JOIN pg_namespace n ON n.oid = cls.relnamespace WHERE n.nspname = 'discounts' AND cls.relname = 'statutory_discount_validations' AND con.conname = 'fk_statutory_discount_validations__policy_version' AND con.contype = 'f') THEN missing := array_append(missing, 'fk_statutory_discount_validations__policy_version'); END IF;
    END IF;

    IF to_regclass('discounts.statutory_discount_payable_basis_application_commands') IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'discounts' AND table_name = 'statutory_discount_payable_basis_application_commands' AND column_name = 'statutory_discount_decision_policy_authority_id') THEN missing := array_append(missing, 'application command statutory_discount_decision_policy_authority_id'); END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_constraint con JOIN pg_class cls ON cls.oid = con.conrelid JOIN pg_namespace n ON n.oid = cls.relnamespace WHERE n.nspname = 'discounts' AND cls.relname = 'statutory_discount_payable_basis_application_commands' AND con.conname = 'ck_stat_discount_pba_commands__policy_authority_matches_decision' AND con.contype = 'c') THEN missing := array_append(missing, 'ck_stat_discount_pba_commands__policy_authority_matches_decision'); END IF;
    END IF;

    IF to_regclass('operator_console.statutory_discount_service_channel_reviews') IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'operator_console' AND table_name = 'statutory_discount_service_channel_reviews' AND column_name = 'statutory_discount_decision_policy_authority_id') THEN missing := array_append(missing, 'service-channel review statutory_discount_decision_policy_authority_id'); END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_constraint con JOIN pg_class cls ON cls.oid = con.conrelid JOIN pg_namespace n ON n.oid = cls.relnamespace WHERE n.nspname = 'operator_console' AND cls.relname = 'statutory_discount_service_channel_reviews' AND con.conname = 'ck_stat_disc_svc_reviews__policy_authority_matches_decision' AND con.contype = 'c') THEN missing := array_append(missing, 'ck_stat_disc_svc_reviews__policy_authority_matches_decision'); END IF;
    END IF;

    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE (table_schema, table_name) IN (('discounts','statutory_discount_validations'), ('operator_console','statutory_discount_service_channel_reviews'))
          AND (lower(column_name) LIKE '%base64%' OR lower(column_name) LIKE '%full_id%' OR lower(column_name) LIKE '%image_bytes%' OR lower(column_name) LIKE '%raw_evidence%')
    ) THEN missing := array_append(missing, 'statutory discount unsafe raw evidence/full-ID style column'); END IF;
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'pos') THEN
        SELECT count(*) INTO unexpected_pos_objects FROM information_schema.tables WHERE table_schema = 'pos';
        missing := array_append(missing, 'unexpected POS Server-owned pos.* objects: ' || unexpected_pos_objects::text);
    END IF;

    IF array_length(missing, 1) IS NOT NULL THEN
        RAISE EXCEPTION 'ExitPass v1.3 Central PMS DB alignment validation failed. Missing/unexpected: %', array_to_string(missing, ', ');
    END IF;
END $$;

SELECT 'ExitPass v1.3 Central PMS DB alignment schema validation passed.' AS validation_result;
