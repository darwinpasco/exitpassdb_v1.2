-- Read-only validation for ExitPass v1.3 completion-authority ExitAuthorization.
DO $validation$
DECLARE
    missing_count integer;
BEGIN
    SELECT count(*) INTO missing_count
    FROM (VALUES
        ('tariff_snapshot_id'), ('completion_basis'), ('completion_authority_reference_id'),
        ('payment_attempt_id'), ('payment_confirmation_id'),
        ('statutory_discount_decision_command_id'),
        ('statutory_discount_payable_basis_application_command_id'),
        ('statutory_discount_validation_id'), ('consumed_at')
    ) AS required(column_name)
    WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.columns AS c
        WHERE c.table_schema = 'core' AND c.table_name = 'exit_authorizations'
          AND c.column_name = required.column_name);
    IF missing_count <> 0 THEN
        RAISE EXCEPTION 'core.exit_authorizations is missing % completion-authority columns', missing_count;
    END IF;

    IF EXISTS (
        SELECT 1 FROM core.exit_authorizations
        WHERE completion_basis = 'PAYMENT_FINALITY'
          AND (payment_attempt_id IS NULL OR payment_confirmation_id IS NULL OR
               completion_authority_reference_id IS DISTINCT FROM payment_confirmation_id)
    ) THEN
        RAISE EXCEPTION 'Invalid PAYMENT_FINALITY ExitAuthorization ancestry exists';
    END IF;

    IF EXISTS (
        SELECT 1 FROM core.exit_authorizations
        WHERE completion_basis = 'ZERO_PAYABLE_STATUTORY_FINALITY'
          AND (payment_attempt_id IS NOT NULL OR payment_confirmation_id IS NOT NULL OR
               completion_authority_reference_id IS DISTINCT FROM
                   statutory_discount_payable_basis_application_command_id)
    ) THEN
        RAISE EXCEPTION 'Invalid ZERO_PAYABLE_STATUTORY_FINALITY ExitAuthorization ancestry exists';
    END IF;

    IF EXISTS (
        SELECT 1 FROM core.exit_authorizations
        WHERE authorization_status = 'CONSUMED' AND consumed_at IS NULL
    ) THEN
        RAISE EXCEPTION 'Consumed ExitAuthorization is missing consumed_at';
    END IF;

    IF to_regprocedure('core.issue_exit_authorization(uuid,uuid,text,uuid,uuid,uuid,uuid,uuid,uuid,uuid,uuid,uuid,uuid,timestamp with time zone)') IS NULL THEN
        RAISE EXCEPTION 'Completion-authority issue_exit_authorization overload is missing';
    END IF;
    IF to_regprocedure('core.consume_exit_authorization(uuid,uuid,uuid,timestamp with time zone,text)') IS NULL THEN
        RAISE EXCEPTION 'Completion-aware consume_exit_authorization overload is missing';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ck_exit_authorizations__completion_ancestry') OR
       NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ck_fiscal_issuance_references__completion_ancestry') OR
       to_regclass('core.ux_exit_authorizations__completion_authority') IS NULL THEN
        RAISE EXCEPTION 'Completion-authority constraints or unique index are missing';
    END IF;

    RAISE NOTICE 'ExitAuthorization completion-authority validation passed.';
END
$validation$;
