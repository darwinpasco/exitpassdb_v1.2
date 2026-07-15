-- ExitPass v1.3 Central PMS DB alignment validation.
-- Run after applying migrations and, for RBAC/UAT checks, after applying the v1.3 UAT seed script.

DO $$
DECLARE
    missing text[] := ARRAY[]::text[];
    gate_processing_missing_columns text[];
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

    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'discounts' AND indexname = 'ux_sd_pba__validation_active') THEN missing := array_append(missing, 'ux_sd_pba__validation_active'); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'core' AND indexname = 'ux_tariff_snapshots__statutory_discount_validation_applied') THEN missing := array_append(missing, 'ux_tariff_snapshots__statutory_discount_validation_applied'); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'core' AND indexname = 'ux_fiscal_issuance_references__active_idempotency_scope') THEN missing := array_append(missing, 'ux_fiscal_issuance_references__active_idempotency_scope'); END IF;

    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'pos') THEN
        SELECT count(*) INTO unexpected_pos_objects FROM information_schema.tables WHERE table_schema = 'pos';
        missing := array_append(missing, 'unexpected POS Server-owned pos.* objects: ' || unexpected_pos_objects::text);
    END IF;

    IF array_length(missing, 1) IS NOT NULL THEN
        RAISE EXCEPTION 'ExitPass v1.3 Central PMS DB alignment validation failed. Missing/unexpected: %', array_to_string(missing, ', ');
    END IF;
END $$;

SELECT 'ExitPass v1.3 Central PMS DB alignment schema validation passed.' AS validation_result;

