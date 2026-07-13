-- ExitPass v1.3 Central PMS DB alignment validation.
-- Run after applying migrations and, for RBAC/UAT checks, after applying the v1.3 UAT seed script.

DO $$
DECLARE
    missing text[] := ARRAY[]::text[];
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

