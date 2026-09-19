-- ExitPass v1.3 transaction-completion authority for ExitAuthorization.
-- PAYMENT_FINALITY retains its payment chain. ZERO_PAYABLE_STATUTORY_FINALITY
-- is anchored to the applied statutory payable basis and never fabricates payment rows.

DO $preflight$
BEGIN
    IF to_regclass('core.exit_authorizations') IS NULL OR
       to_regclass('core.fiscal_issuance_references') IS NULL OR
       to_regclass('discounts.statutory_discount_payable_basis_application_commands') IS NULL THEN
        RAISE EXCEPTION 'ExitAuthorization completion-authority migration prerequisites are missing';
    END IF;
END
$preflight$;

ALTER TYPE core.exit_authorization_status_enum ADD VALUE IF NOT EXISTS 'CONSUMED';

BEGIN;

ALTER TABLE core.fiscal_issuance_references
    ADD COLUMN IF NOT EXISTS completion_basis varchar(64),
    ADD COLUMN IF NOT EXISTS completion_authority_reference_id uuid,
    ADD COLUMN IF NOT EXISTS statutory_discount_decision_command_id uuid,
    ADD COLUMN IF NOT EXISTS statutory_discount_payable_basis_application_command_id uuid,
    ADD COLUMN IF NOT EXISTS statutory_discount_validation_id uuid,
    ADD COLUMN IF NOT EXISTS applied_policy_reference_id uuid,
    ADD COLUMN IF NOT EXISTS statutory_discount_policy_version_id uuid,
    ADD COLUMN IF NOT EXISTS electronic_journal_event_reference varchar(192);

UPDATE core.fiscal_issuance_references
SET completion_basis = 'PAYMENT_FINALITY',
    completion_authority_reference_id = payment_confirmation_id
WHERE completion_basis IS NULL
  AND payment_attempt_id IS NOT NULL
  AND payment_confirmation_id IS NOT NULL;

DO $fiscal_backfill$
BEGIN
    IF EXISTS (
        SELECT 1 FROM core.fiscal_issuance_references
        WHERE completion_basis IS NULL OR completion_authority_reference_id IS NULL
    ) THEN
        RAISE EXCEPTION 'Fiscal issuance completion-authority backfill is incomplete';
    END IF;
END
$fiscal_backfill$;

ALTER TABLE core.fiscal_issuance_references
    ALTER COLUMN payment_attempt_id DROP NOT NULL,
    ALTER COLUMN payment_confirmation_id DROP NOT NULL,
    ALTER COLUMN completion_basis SET NOT NULL,
    ALTER COLUMN completion_authority_reference_id SET NOT NULL;

ALTER TABLE core.exit_authorizations
    ADD COLUMN IF NOT EXISTS tariff_snapshot_id uuid,
    ADD COLUMN IF NOT EXISTS completion_basis varchar(64),
    ADD COLUMN IF NOT EXISTS completion_authority_reference_id uuid,
    ADD COLUMN IF NOT EXISTS statutory_discount_decision_command_id uuid,
    ADD COLUMN IF NOT EXISTS statutory_discount_payable_basis_application_command_id uuid,
    ADD COLUMN IF NOT EXISTS statutory_discount_validation_id uuid,
    ADD COLUMN IF NOT EXISTS applied_policy_reference_id uuid,
    ADD COLUMN IF NOT EXISTS statutory_discount_policy_version_id uuid,
    ADD COLUMN IF NOT EXISTS consumed_at timestamptz;

UPDATE core.exit_authorizations AS ea
SET tariff_snapshot_id = pa.tariff_snapshot_id,
    completion_basis = 'PAYMENT_FINALITY',
    completion_authority_reference_id = ea.payment_confirmation_id
FROM core.payment_attempts AS pa
WHERE ea.payment_attempt_id = pa.payment_attempt_id
  AND (ea.tariff_snapshot_id IS NULL OR ea.completion_basis IS NULL OR
       ea.completion_authority_reference_id IS NULL);

DO $authorization_backfill$
BEGIN
    IF EXISTS (
        SELECT 1 FROM core.exit_authorizations
        WHERE tariff_snapshot_id IS NULL OR completion_basis IS NULL OR
              completion_authority_reference_id IS NULL
    ) THEN
        RAISE EXCEPTION 'Historical paid ExitAuthorization backfill is incomplete';
    END IF;
END
$authorization_backfill$;

ALTER TABLE core.exit_authorizations
    ALTER COLUMN payment_attempt_id DROP NOT NULL,
    ALTER COLUMN payment_confirmation_id DROP NOT NULL,
    ALTER COLUMN tariff_snapshot_id SET NOT NULL,
    ALTER COLUMN completion_basis SET NOT NULL,
    ALTER COLUMN completion_authority_reference_id SET NOT NULL;

DO $constraints$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ck_fiscal_issuance_references__completion_ancestry') THEN
        ALTER TABLE core.fiscal_issuance_references ADD CONSTRAINT ck_fiscal_issuance_references__completion_ancestry CHECK (
            (completion_basis = 'PAYMENT_FINALITY' AND payment_attempt_id IS NOT NULL AND
             payment_confirmation_id IS NOT NULL AND completion_authority_reference_id = payment_confirmation_id AND
             statutory_discount_decision_command_id IS NULL AND statutory_discount_payable_basis_application_command_id IS NULL AND
             statutory_discount_validation_id IS NULL AND applied_policy_reference_id IS NULL AND
             statutory_discount_policy_version_id IS NULL)
            OR
            (completion_basis = 'ZERO_PAYABLE_STATUTORY_FINALITY' AND payment_attempt_id IS NULL AND
             payment_confirmation_id IS NULL AND completion_authority_reference_id = statutory_discount_payable_basis_application_command_id AND
             statutory_discount_decision_command_id IS NOT NULL AND statutory_discount_payable_basis_application_command_id IS NOT NULL AND
             statutory_discount_validation_id IS NOT NULL AND
             ((applied_policy_reference_id IS NOT NULL AND statutory_discount_policy_version_id IS NULL) OR
              (applied_policy_reference_id IS NULL AND statutory_discount_policy_version_id IS NOT NULL)))
        );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ck_exit_authorizations__completion_basis') THEN
        ALTER TABLE core.exit_authorizations ADD CONSTRAINT ck_exit_authorizations__completion_basis
            CHECK (completion_basis IN ('PAYMENT_FINALITY', 'ZERO_PAYABLE_STATUTORY_FINALITY'));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ck_exit_authorizations__consumed_state') THEN
        ALTER TABLE core.exit_authorizations ADD CONSTRAINT ck_exit_authorizations__consumed_state CHECK (
            (authorization_status = 'CONSUMED' AND consumed_at IS NOT NULL) OR
            (authorization_status <> 'CONSUMED' AND consumed_at IS NULL));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ck_exit_authorizations__completion_ancestry') THEN
        ALTER TABLE core.exit_authorizations ADD CONSTRAINT ck_exit_authorizations__completion_ancestry CHECK (
            (completion_basis = 'PAYMENT_FINALITY' AND payment_attempt_id IS NOT NULL AND
             payment_confirmation_id IS NOT NULL AND completion_authority_reference_id = payment_confirmation_id AND
             statutory_discount_decision_command_id IS NULL AND statutory_discount_payable_basis_application_command_id IS NULL AND
             statutory_discount_validation_id IS NULL AND applied_policy_reference_id IS NULL AND
             statutory_discount_policy_version_id IS NULL)
            OR
            (completion_basis = 'ZERO_PAYABLE_STATUTORY_FINALITY' AND payment_attempt_id IS NULL AND
             payment_confirmation_id IS NULL AND completion_authority_reference_id = statutory_discount_payable_basis_application_command_id AND
             statutory_discount_decision_command_id IS NOT NULL AND statutory_discount_payable_basis_application_command_id IS NOT NULL AND
             statutory_discount_validation_id IS NOT NULL AND
             ((applied_policy_reference_id IS NOT NULL AND statutory_discount_policy_version_id IS NULL) OR
              (applied_policy_reference_id IS NULL AND statutory_discount_policy_version_id IS NOT NULL)))
        );
    END IF;
END
$constraints$;

DO $foreign_keys$
DECLARE
    item record;
BEGIN
    FOR item IN SELECT * FROM (VALUES
        ('fk_exit_authorizations__tariff_snapshot_id', 'core.exit_authorizations', 'tariff_snapshot_id', 'core.tariff_snapshots', 'tariff_snapshot_id'),
        ('fk_exit_authorizations__statutory_decision', 'core.exit_authorizations', 'statutory_discount_decision_command_id', 'discounts.statutory_discount_decision_commands', 'statutory_discount_decision_command_id'),
        ('fk_exit_authorizations__statutory_application', 'core.exit_authorizations', 'statutory_discount_payable_basis_application_command_id', 'discounts.statutory_discount_payable_basis_application_commands', 'statutory_discount_payable_basis_application_command_id'),
        ('fk_exit_authorizations__statutory_validation', 'core.exit_authorizations', 'statutory_discount_validation_id', 'discounts.statutory_discount_validations', 'statutory_discount_validation_id'),
        ('fk_exit_authorizations__applied_policy', 'core.exit_authorizations', 'applied_policy_reference_id', 'discounts.discount_policy_references', 'discount_policy_reference_id'),
        ('fk_exit_authorizations__policy_version', 'core.exit_authorizations', 'statutory_discount_policy_version_id', 'discounts.statutory_discount_policy_versions', 'statutory_discount_policy_version_id'),
        ('fk_fiscal_issuance_references__statutory_decision', 'core.fiscal_issuance_references', 'statutory_discount_decision_command_id', 'discounts.statutory_discount_decision_commands', 'statutory_discount_decision_command_id'),
        ('fk_fiscal_issuance_references__statutory_application', 'core.fiscal_issuance_references', 'statutory_discount_payable_basis_application_command_id', 'discounts.statutory_discount_payable_basis_application_commands', 'statutory_discount_payable_basis_application_command_id'),
        ('fk_fiscal_issuance_references__statutory_validation', 'core.fiscal_issuance_references', 'statutory_discount_validation_id', 'discounts.statutory_discount_validations', 'statutory_discount_validation_id'),
        ('fk_fiscal_issuance_references__applied_policy', 'core.fiscal_issuance_references', 'applied_policy_reference_id', 'discounts.discount_policy_references', 'discount_policy_reference_id'),
        ('fk_fiscal_issuance_references__policy_version', 'core.fiscal_issuance_references', 'statutory_discount_policy_version_id', 'discounts.statutory_discount_policy_versions', 'statutory_discount_policy_version_id')
    ) AS v(constraint_name, source_table, source_column, target_table, target_column)
    LOOP
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = item.constraint_name) THEN
            EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %I FOREIGN KEY (%I) REFERENCES %s (%I) DEFERRABLE',
                item.source_table, item.constraint_name, item.source_column, item.target_table, item.target_column);
        END IF;
    END LOOP;
END
$foreign_keys$;

CREATE INDEX IF NOT EXISTS ix_exit_authorizations__tariff_snapshot_id
    ON core.exit_authorizations (tariff_snapshot_id);
CREATE INDEX IF NOT EXISTS ix_exit_authorizations__completion_basis
    ON core.exit_authorizations (completion_basis);
CREATE UNIQUE INDEX IF NOT EXISTS ux_exit_authorizations__completion_authority
    ON core.exit_authorizations (completion_basis, completion_authority_reference_id);
CREATE INDEX IF NOT EXISTS ix_fiscal_issuance_references__completion_basis
    ON core.fiscal_issuance_references (completion_basis);
CREATE UNIQUE INDEX IF NOT EXISTS ux_fiscal_issuance_references__active_statutory_application
    ON core.fiscal_issuance_references (statutory_discount_payable_basis_application_command_id)
    WHERE is_active AND NOT is_superseded AND statutory_discount_payable_basis_application_command_id IS NOT NULL;

COMMIT;

CREATE OR REPLACE FUNCTION core.issue_exit_authorization(
    p_parking_session_id uuid,
    p_tariff_snapshot_id uuid,
    p_completion_basis text,
    p_completion_authority_reference_id uuid,
    p_payment_attempt_id uuid,
    p_payment_confirmation_id uuid,
    p_statutory_discount_decision_command_id uuid,
    p_statutory_discount_payable_basis_application_command_id uuid,
    p_statutory_discount_validation_id uuid,
    p_applied_policy_reference_id uuid,
    p_statutory_discount_policy_version_id uuid,
    p_requested_by uuid,
    p_correlation_id uuid,
    p_now timestamptz
)
RETURNS TABLE (
    exit_authorization_id uuid,
    parking_session_id uuid,
    tariff_snapshot_id uuid,
    completion_basis text,
    completion_authority_reference_id uuid,
    payment_attempt_id uuid,
    payment_confirmation_id uuid,
    authorization_token text,
    authorization_status text,
    issued_at timestamptz,
    expiration_timestamp timestamptz
)
LANGUAGE plpgsql
AS $function$
DECLARE
    v_attempt core.payment_attempts%ROWTYPE;
    v_confirmation core.payment_confirmations%ROWTYPE;
    v_application discounts.statutory_discount_payable_basis_application_commands%ROWTYPE;
    v_decision discounts.statutory_discount_decision_commands%ROWTYPE;
    v_validation discounts.statutory_discount_validations%ROWTYPE;
    v_fiscal core.fiscal_issuance_references%ROWTYPE;
    v_authorization core.exit_authorizations%ROWTYPE;
    v_requested_by_service_identity_id uuid;
    v_authorization_token text;
    v_tariff_snapshot_id uuid := p_tariff_snapshot_id;
    v_authority_reference_id uuid := p_completion_authority_reference_id;
    v_payment_confirmation_id uuid := p_payment_confirmation_id;
BEGIN
    IF p_parking_session_id IS NULL OR p_completion_basis IS NULL THEN
        RAISE EXCEPTION 'parking session and completion basis are required' USING ERRCODE = 'P0001';
    END IF;

    IF p_completion_basis = 'PAYMENT_FINALITY' THEN
        IF p_payment_attempt_id IS NULL OR
           p_statutory_discount_decision_command_id IS NOT NULL OR
           p_statutory_discount_payable_basis_application_command_id IS NOT NULL OR
           p_statutory_discount_validation_id IS NOT NULL OR
           p_applied_policy_reference_id IS NOT NULL OR
           p_statutory_discount_policy_version_id IS NOT NULL THEN
            RAISE EXCEPTION 'PAYMENT_FINALITY requires payment ancestry only' USING ERRCODE = 'P0001';
        END IF;

        SELECT pa.* INTO v_attempt FROM core.payment_attempts AS pa
        WHERE pa.payment_attempt_id = p_payment_attempt_id FOR UPDATE;
        IF NOT FOUND OR v_attempt.parking_session_id <> p_parking_session_id OR
           v_attempt.attempt_status <> 'CONFIRMED' OR v_attempt.finalized_at IS NULL THEN
            RAISE EXCEPTION 'PAYMENT_FINALITY payment attempt is not eligible' USING ERRCODE = 'P0001';
        END IF;

        SELECT pc.* INTO v_confirmation FROM core.payment_confirmations AS pc
        WHERE pc.payment_attempt_id = v_attempt.payment_attempt_id
          AND pc.confirmation_status = 'RECORDED'
          AND (p_payment_confirmation_id IS NULL OR pc.payment_confirmation_id = p_payment_confirmation_id)
        ORDER BY pc.confirmed_at DESC, pc.created_at DESC LIMIT 1;
        IF NOT FOUND OR v_confirmation.confirmed_amount <> v_attempt.amount OR
           v_confirmation.currency_code <> v_attempt.currency_code THEN
            RAISE EXCEPTION 'PAYMENT_FINALITY confirmation is not eligible' USING ERRCODE = 'P0001';
        END IF;

        v_tariff_snapshot_id := v_attempt.tariff_snapshot_id;
        v_authority_reference_id := v_confirmation.payment_confirmation_id;
        v_payment_confirmation_id := v_confirmation.payment_confirmation_id;
        IF p_tariff_snapshot_id IS NOT NULL AND p_tariff_snapshot_id <> v_tariff_snapshot_id THEN
            RAISE EXCEPTION 'PAYMENT_FINALITY tariff snapshot mismatch' USING ERRCODE = 'P0001';
        END IF;
        IF p_completion_authority_reference_id IS NOT NULL AND
           p_completion_authority_reference_id <> v_authority_reference_id THEN
            RAISE EXCEPTION 'PAYMENT_FINALITY completion authority mismatch' USING ERRCODE = 'P0001';
        END IF;
    ELSIF p_completion_basis = 'ZERO_PAYABLE_STATUTORY_FINALITY' THEN
        IF p_tariff_snapshot_id IS NULL OR p_completion_authority_reference_id IS NULL OR
           p_payment_attempt_id IS NOT NULL OR p_payment_confirmation_id IS NOT NULL OR
           p_statutory_discount_decision_command_id IS NULL OR
           p_statutory_discount_payable_basis_application_command_id IS NULL OR
           p_statutory_discount_validation_id IS NULL OR
           ((p_applied_policy_reference_id IS NULL) = (p_statutory_discount_policy_version_id IS NULL)) THEN
            RAISE EXCEPTION 'ZERO_PAYABLE_STATUTORY_FINALITY ancestry is incomplete or mixed with payment ancestry'
                USING ERRCODE = 'P0001';
        END IF;

        SELECT app.* INTO v_application
        FROM discounts.statutory_discount_payable_basis_application_commands AS app
        WHERE app.statutory_discount_payable_basis_application_command_id =
              p_statutory_discount_payable_basis_application_command_id FOR UPDATE;
        IF NOT FOUND OR v_application.command_status <> 'APPLIED' OR
           v_application.parking_session_id <> p_parking_session_id OR
           v_application.applied_tariff_snapshot_id <> p_tariff_snapshot_id OR
           v_application.statutory_discount_decision_command_id <> p_statutory_discount_decision_command_id OR
           v_application.statutory_discount_validation_id <> p_statutory_discount_validation_id OR
           v_application.approved_final_payable_amount_minor_units <> 0 OR
           p_completion_authority_reference_id <> p_statutory_discount_payable_basis_application_command_id OR
           COALESCE(
               v_application.statutory_discount_policy_version_id,
               v_application.applied_policy_reference_id) IS DISTINCT FROM
               COALESCE(p_statutory_discount_policy_version_id, p_applied_policy_reference_id) OR
           (v_application.applied_policy_reference_id IS NOT NULL AND
            v_application.statutory_discount_policy_version_id IS NOT NULL AND
            v_application.applied_policy_reference_id <>
                v_application.statutory_discount_policy_version_id) THEN
            RAISE EXCEPTION 'ZERO_PAYABLE_STATUTORY_FINALITY payable-basis authority is invalid'
                USING ERRCODE = 'P0001';
        END IF;

        SELECT decision.* INTO v_decision FROM discounts.statutory_discount_decision_commands AS decision
        WHERE decision.statutory_discount_decision_command_id = p_statutory_discount_decision_command_id;
        IF NOT FOUND OR v_decision.parking_session_id <> p_parking_session_id OR
           v_decision.command_status <> 'COMPLETED' OR v_decision.decision_result_status <> 'APPROVED' OR
           v_decision.statutory_discount_validation_id <> p_statutory_discount_validation_id OR
           v_decision.applied_tariff_snapshot_id <> p_tariff_snapshot_id OR
           v_decision.net_payable_amount_minor_units <> 0 THEN
            RAISE EXCEPTION 'ZERO_PAYABLE_STATUTORY_FINALITY decision authority is invalid'
                USING ERRCODE = 'P0001';
        END IF;

        SELECT validation.* INTO v_validation FROM discounts.statutory_discount_validations AS validation
        WHERE validation.statutory_discount_validation_id = p_statutory_discount_validation_id;
        IF NOT FOUND OR v_validation.parking_session_id <> p_parking_session_id OR
           v_validation.validation_status <> 'APPROVED' OR v_validation.net_amount_after_discount <> 0 THEN
            RAISE EXCEPTION 'ZERO_PAYABLE_STATUTORY_FINALITY validation authority is invalid'
                USING ERRCODE = 'P0001';
        END IF;
    ELSE
        RAISE EXCEPTION 'unsupported ExitAuthorization completion basis: %', p_completion_basis USING ERRCODE = 'P0001';
    END IF;

    SELECT ea.* INTO v_authorization FROM core.exit_authorizations AS ea
    WHERE ea.completion_basis = p_completion_basis
      AND ea.completion_authority_reference_id = v_authority_reference_id FOR UPDATE;
    IF FOUND THEN
        RETURN QUERY SELECT v_authorization.exit_authorization_id, v_authorization.parking_session_id,
            v_authorization.tariff_snapshot_id, v_authorization.completion_basis::text,
            v_authorization.completion_authority_reference_id, v_authorization.payment_attempt_id,
            v_authorization.payment_confirmation_id, v_authorization.exit_authorization_id::text,
            v_authorization.authorization_status::text, v_authorization.issued_at, v_authorization.expires_at;
        RETURN;
    END IF;

    SELECT fir.* INTO v_fiscal FROM core.fiscal_issuance_references AS fir
    WHERE fir.is_active AND NOT fir.is_superseded
      AND fir.parking_session_id = p_parking_session_id
      AND fir.tariff_snapshot_id = v_tariff_snapshot_id
      AND fir.completion_basis = p_completion_basis
      AND fir.completion_authority_reference_id = v_authority_reference_id
      AND fir.fiscal_issuance_state IN ('FISCAL_ISSUANCE_RECORDED', 'FISCAL_ISSUANCE_REPLAYED', 'FISCAL_ISSUANCE_RECONCILED')
      AND fir.pos_server_fiscal_document_id IS NOT NULL AND fir.fiscal_document_number IS NOT NULL
    ORDER BY fir.last_updated_at DESC LIMIT 1;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'required fiscal completion is not recorded for ExitAuthorization' USING ERRCODE = 'P0001';
    END IF;

    SELECT si.service_identity_id INTO v_requested_by_service_identity_id
    FROM identity.service_identities AS si WHERE si.service_identity_id = p_requested_by LIMIT 1;
    v_requested_by_service_identity_id := COALESCE(
        v_requested_by_service_identity_id, v_fiscal.updated_by_service_identity_id,
        v_fiscal.recorded_by_service_identity_id, v_attempt.updated_by_service_identity_id,
        v_attempt.created_by_service_identity_id);
    IF v_requested_by_service_identity_id IS NULL THEN
        RAISE EXCEPTION 'requested_by service identity could not be resolved' USING ERRCODE = 'P0002';
    END IF;

    v_authorization_token := 'EXIT-' || replace(gen_random_uuid()::text, '-', '');
    INSERT INTO core.exit_authorizations (
        exit_authorization_id, parking_session_id, tariff_snapshot_id, completion_basis,
        completion_authority_reference_id, payment_attempt_id, payment_confirmation_id,
        statutory_discount_decision_command_id, statutory_discount_payable_basis_application_command_id,
        statutory_discount_validation_id, applied_policy_reference_id, statutory_discount_policy_version_id,
        authorization_token_hash, authorization_status, issued_at, expires_at, correlation_id,
        created_at, created_by_service_identity_id, updated_at, updated_by_service_identity_id)
    VALUES (
        gen_random_uuid(), p_parking_session_id, v_tariff_snapshot_id, p_completion_basis,
        v_authority_reference_id, p_payment_attempt_id, v_payment_confirmation_id,
        p_statutory_discount_decision_command_id, p_statutory_discount_payable_basis_application_command_id,
        p_statutory_discount_validation_id, p_applied_policy_reference_id, p_statutory_discount_policy_version_id,
        encode(digest(v_authorization_token, 'sha256'), 'hex'), 'ISSUED', p_now,
        p_now + interval '15 minutes', p_correlation_id, p_now, v_requested_by_service_identity_id,
        p_now, v_requested_by_service_identity_id)
    RETURNING * INTO v_authorization;

    RETURN QUERY SELECT v_authorization.exit_authorization_id, v_authorization.parking_session_id,
        v_authorization.tariff_snapshot_id, v_authorization.completion_basis::text,
        v_authorization.completion_authority_reference_id, v_authorization.payment_attempt_id,
        v_authorization.payment_confirmation_id, v_authorization_token,
        v_authorization.authorization_status::text, v_authorization.issued_at, v_authorization.expires_at;
END;
$function$;

CREATE OR REPLACE FUNCTION core.issue_exit_authorization(
    p_parking_session_id uuid,
    p_payment_attempt_id uuid,
    p_requested_by uuid,
    p_correlation_id uuid,
    p_now timestamptz
)
RETURNS TABLE (
    exit_authorization_id uuid, parking_session_id uuid, payment_attempt_id uuid,
    authorization_token text, authorization_status text, issued_at timestamptz,
    expiration_timestamp timestamptz
)
LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT issued.exit_authorization_id, issued.parking_session_id, issued.payment_attempt_id,
           issued.authorization_token, issued.authorization_status, issued.issued_at,
           issued.expiration_timestamp
    FROM core.issue_exit_authorization(
        p_parking_session_id, NULL, 'PAYMENT_FINALITY', NULL, p_payment_attempt_id,
        NULL, NULL, NULL, NULL, NULL, NULL, p_requested_by, p_correlation_id, p_now) AS issued;
END;
$function$;

CREATE OR REPLACE FUNCTION core.consume_exit_authorization(
    p_exit_authorization_id uuid,
    p_requested_by uuid,
    p_correlation_id uuid,
    p_now timestamptz,
    p_completion_basis text
)
RETURNS TABLE (exit_authorization_id uuid, authorization_status text, consumed_at timestamptz)
LANGUAGE plpgsql
AS $function$
DECLARE
    v_authorization core.exit_authorizations%ROWTYPE;
    v_session core.parking_sessions%ROWTYPE;
    v_requested_by_service_identity_id uuid;
    v_valid boolean;
BEGIN
    IF p_completion_basis = 'PAYMENT_FINALITY' THEN
        RETURN QUERY SELECT consumed.exit_authorization_id, consumed.authorization_status, consumed.consumed_at
        FROM core.consume_exit_authorization(p_exit_authorization_id, p_requested_by, p_correlation_id, p_now) AS consumed;
        UPDATE core.exit_authorizations AS ea
        SET authorization_status = 'CONSUMED', consumed_at = p_now,
            correlation_id = COALESCE(p_correlation_id, ea.correlation_id), updated_at = p_now,
            updated_by_service_identity_id = COALESCE(
                ea.updated_by_service_identity_id, ea.created_by_service_identity_id),
            row_version = ea.row_version + 1
        WHERE ea.exit_authorization_id = p_exit_authorization_id
          AND ea.authorization_status <> 'CONSUMED';
        RETURN;
    END IF;
    IF p_completion_basis <> 'ZERO_PAYABLE_STATUTORY_FINALITY' THEN
        RAISE EXCEPTION 'unsupported ExitAuthorization completion basis: %', p_completion_basis USING ERRCODE = 'P0001';
    END IF;

    SELECT ea.* INTO v_authorization FROM core.exit_authorizations AS ea
    WHERE ea.exit_authorization_id = p_exit_authorization_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'exit authorization % was not found', p_exit_authorization_id USING ERRCODE = 'P0002';
    END IF;
    IF v_authorization.completion_basis <> p_completion_basis THEN
        RAISE EXCEPTION 'ExitAuthorization completion basis mismatch' USING ERRCODE = 'P0001';
    END IF;
    IF v_authorization.authorization_status = 'CONSUMED' THEN
        RAISE EXCEPTION 'exit authorization % has already been consumed', p_exit_authorization_id USING ERRCODE = 'P0001';
    END IF;
    IF v_authorization.authorization_status <> 'ISSUED' OR v_authorization.expires_at <= p_now THEN
        RAISE EXCEPTION 'exit authorization % is not currently valid', p_exit_authorization_id USING ERRCODE = 'P0001';
    END IF;

    SELECT ps.* INTO v_session FROM core.parking_sessions AS ps
    WHERE ps.parking_session_id = v_authorization.parking_session_id;
    IF NOT FOUND OR v_session.session_status <> 'ACTIVE' THEN
        RAISE EXCEPTION 'parking session is not eligible for ExitAuthorization consume' USING ERRCODE = 'P0001';
    END IF;

    SELECT EXISTS (
        SELECT 1
        FROM discounts.statutory_discount_payable_basis_application_commands AS app
        JOIN discounts.statutory_discount_decision_commands AS decision
          ON decision.statutory_discount_decision_command_id = app.statutory_discount_decision_command_id
        JOIN discounts.statutory_discount_validations AS validation
          ON validation.statutory_discount_validation_id = app.statutory_discount_validation_id
        JOIN core.fiscal_issuance_references AS fir
          ON fir.parking_session_id = v_authorization.parking_session_id
         AND fir.tariff_snapshot_id = v_authorization.tariff_snapshot_id
         AND fir.completion_basis = v_authorization.completion_basis
         AND fir.completion_authority_reference_id = v_authorization.completion_authority_reference_id
         AND fir.is_active AND NOT fir.is_superseded
         AND fir.fiscal_issuance_state IN ('FISCAL_ISSUANCE_RECORDED', 'FISCAL_ISSUANCE_REPLAYED', 'FISCAL_ISSUANCE_RECONCILED')
         AND fir.pos_server_fiscal_document_id IS NOT NULL
        WHERE app.statutory_discount_payable_basis_application_command_id =
              v_authorization.statutory_discount_payable_basis_application_command_id
          AND app.command_status = 'APPLIED'
          AND app.parking_session_id = v_authorization.parking_session_id
          AND app.applied_tariff_snapshot_id = v_authorization.tariff_snapshot_id
          AND app.approved_final_payable_amount_minor_units = 0
          AND app.statutory_discount_decision_command_id =
              v_authorization.statutory_discount_decision_command_id
          AND app.statutory_discount_validation_id =
              v_authorization.statutory_discount_validation_id
          AND COALESCE(
                  app.statutory_discount_policy_version_id,
                  app.applied_policy_reference_id) =
              COALESCE(
                  v_authorization.statutory_discount_policy_version_id,
                  v_authorization.applied_policy_reference_id)
          AND (app.applied_policy_reference_id IS NULL OR
               app.statutory_discount_policy_version_id IS NULL OR
               app.applied_policy_reference_id = app.statutory_discount_policy_version_id)
          AND decision.decision_result_status = 'APPROVED' AND decision.command_status = 'COMPLETED'
          AND validation.validation_status = 'APPROVED' AND validation.net_amount_after_discount = 0
          AND fir.statutory_discount_decision_command_id =
              v_authorization.statutory_discount_decision_command_id
          AND fir.statutory_discount_payable_basis_application_command_id =
              v_authorization.statutory_discount_payable_basis_application_command_id
          AND fir.statutory_discount_validation_id =
              v_authorization.statutory_discount_validation_id
          AND COALESCE(
                  fir.statutory_discount_policy_version_id,
                  fir.applied_policy_reference_id) =
              COALESCE(
                  v_authorization.statutory_discount_policy_version_id,
                  v_authorization.applied_policy_reference_id)
          AND v_authorization.payment_attempt_id IS NULL AND v_authorization.payment_confirmation_id IS NULL)
    INTO v_valid;
    IF NOT v_valid THEN
        RAISE EXCEPTION 'zero-payable ExitAuthorization completion authority is no longer valid' USING ERRCODE = 'P0001';
    END IF;

    SELECT si.service_identity_id INTO v_requested_by_service_identity_id
    FROM identity.service_identities AS si WHERE si.service_identity_id = p_requested_by LIMIT 1;
    v_requested_by_service_identity_id := COALESCE(
        v_requested_by_service_identity_id, v_authorization.updated_by_service_identity_id,
        v_authorization.created_by_service_identity_id);
    IF v_requested_by_service_identity_id IS NULL THEN
        RAISE EXCEPTION 'requested_by service identity could not be resolved' USING ERRCODE = 'P0002';
    END IF;

    UPDATE core.exit_authorizations AS ea
    SET authorization_status = 'CONSUMED', consumed_at = p_now,
        correlation_id = COALESCE(p_correlation_id, ea.correlation_id), updated_at = p_now,
        updated_by_service_identity_id = v_requested_by_service_identity_id,
        row_version = ea.row_version + 1
    WHERE ea.exit_authorization_id = p_exit_authorization_id;

    RETURN QUERY SELECT v_authorization.exit_authorization_id, 'CONSUMED'::text, p_now;
END;
$function$;
