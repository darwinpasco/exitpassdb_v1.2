/*
 * ExitPass v1.2 durable SQL patch.
 *
 * BRD:
 * - 9.12 Exit Authorization
 * - 9.13 Timeout, Retry, and Duplicate Handling
 * - 10.7.2 Payment Finality Invariant
 * - 10.7.7 Exit Token Integrity Invariant
 *
 * SDD:
 * - 6.5 Issue Exit Authorization
 * - 8.5 ExitAuthorization State Machine
 * - 9.6 Integrity Constraints and Concurrency Rules
 *
 * System Invariants:
 * - ExitAuthorization must be anchored to an existing finalized/confirmed PaymentAttempt.
 * - ExitAuthorization must be tied back to the canonical ParkingSession and PaymentConfirmation chain.
 * - Replayed issuance for the same confirmed PaymentAttempt returns the existing authorization deterministically.
 * - All writes use ExitPass v1.2 table names, v1.2 enums, hashed token storage, and service-identity audit attribution.
 */

CREATE OR REPLACE FUNCTION core.issue_exit_authorization(
    p_parking_session_id uuid,
    p_payment_attempt_id uuid,
    p_requested_by uuid,
    p_correlation_id uuid,
    p_now timestamptz
)
RETURNS TABLE (
    exit_authorization_id uuid,
    parking_session_id uuid,
    payment_attempt_id uuid,
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
    v_authorization core.exit_authorizations%ROWTYPE;
    v_requested_by_service_identity_id uuid;
    v_authorization_token text;
BEGIN
    SELECT pa.*
    INTO v_attempt
    FROM core.payment_attempts AS pa
    WHERE pa.payment_attempt_id = p_payment_attempt_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'payment attempt % was not found', p_payment_attempt_id
            USING ERRCODE = 'P0002';
    END IF;

    IF v_attempt.parking_session_id <> p_parking_session_id THEN
        RAISE EXCEPTION 'payment attempt % does not belong to parking session %', p_payment_attempt_id, p_parking_session_id
            USING ERRCODE = 'P0001';
    END IF;

    SELECT ea.*
    INTO v_authorization
    FROM core.exit_authorizations AS ea
    WHERE ea.payment_attempt_id = p_payment_attempt_id
    FOR UPDATE;

    IF FOUND THEN
        RETURN QUERY
        SELECT
            v_authorization.exit_authorization_id::uuid,
            v_authorization.parking_session_id::uuid,
            v_authorization.payment_attempt_id::uuid,
            v_authorization.exit_authorization_id::text,
            v_authorization.authorization_status::text,
            v_authorization.issued_at::timestamptz,
            v_authorization.expires_at::timestamptz;
        RETURN;
    END IF;

    IF v_attempt.attempt_status <> 'CONFIRMED' THEN
        RAISE EXCEPTION 'payment attempt % is not confirmed', p_payment_attempt_id
            USING ERRCODE = 'P0001';
    END IF;

    SELECT pc.*
    INTO v_confirmation
    FROM core.payment_confirmations AS pc
    WHERE pc.payment_attempt_id = p_payment_attempt_id
      AND pc.confirmation_status = 'RECORDED'
    ORDER BY pc.confirmed_at DESC, pc.created_at DESC
    LIMIT 1;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'payment attempt % has no recorded payment confirmation', p_payment_attempt_id
            USING ERRCODE = 'P0001';
    END IF;

    IF v_confirmation.payment_attempt_id <> v_attempt.payment_attempt_id THEN
        RAISE EXCEPTION 'payment confirmation % is not anchored to payment attempt %', v_confirmation.payment_confirmation_id, p_payment_attempt_id
            USING ERRCODE = 'P0001';
    END IF;

    SELECT si.service_identity_id
    INTO v_requested_by_service_identity_id
    FROM identity.service_identities AS si
    WHERE si.service_identity_id = p_requested_by
    LIMIT 1;

    IF v_requested_by_service_identity_id IS NULL THEN
        v_requested_by_service_identity_id := v_attempt.updated_by_service_identity_id;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        v_requested_by_service_identity_id := v_confirmation.created_by_service_identity_id;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        v_requested_by_service_identity_id := v_attempt.created_by_service_identity_id;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        RAISE EXCEPTION 'requested_by service identity could not be resolved'
            USING ERRCODE = 'P0002';
    END IF;

    v_authorization_token := 'EXIT-' || replace(gen_random_uuid()::text, '-', '');

    INSERT INTO core.exit_authorizations (
        exit_authorization_id,
        parking_session_id,
        tariff_snapshot_id,
        completion_basis,
        completion_authority_reference_id,
        payment_attempt_id,
        payment_confirmation_id,
        authorization_token_hash,
        authorization_status,
        issued_at,
        expires_at,
        correlation_id,
        created_at,
        created_by_service_identity_id,
        updated_at,
        updated_by_service_identity_id
    )
    VALUES (
        gen_random_uuid(),
        v_attempt.parking_session_id,
        v_attempt.tariff_snapshot_id,
        'PAYMENT_FINALITY',
        v_confirmation.payment_confirmation_id,
        v_attempt.payment_attempt_id,
        v_confirmation.payment_confirmation_id,
        encode(digest(v_authorization_token, 'sha256'), 'hex'),
        'ISSUED',
        p_now,
        p_now + interval '15 minutes',
        p_correlation_id,
        p_now,
        v_requested_by_service_identity_id,
        p_now,
        v_requested_by_service_identity_id
    )
    RETURNING *
    INTO v_authorization;

    RETURN QUERY
    SELECT
        v_authorization.exit_authorization_id::uuid,
        v_authorization.parking_session_id::uuid,
        v_authorization.payment_attempt_id::uuid,
        v_authorization_token::text,
        v_authorization.authorization_status::text,
        v_authorization.issued_at::timestamptz,
        v_authorization.expires_at::timestamptz;
END;
$function$;

/*
 * v1.3 completion-authority overload. The v1.2 five-argument signature above
 * remains available for PAYMENT_FINALITY callers during rolling upgrades.
 */
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

        SELECT pa.* INTO v_attempt
        FROM core.payment_attempts AS pa
        WHERE pa.payment_attempt_id = p_payment_attempt_id
        FOR UPDATE;

        IF NOT FOUND OR v_attempt.parking_session_id <> p_parking_session_id OR
           v_attempt.attempt_status <> 'CONFIRMED' OR v_attempt.finalized_at IS NULL THEN
            RAISE EXCEPTION 'PAYMENT_FINALITY payment attempt is not eligible' USING ERRCODE = 'P0001';
        END IF;

        SELECT pc.* INTO v_confirmation
        FROM core.payment_confirmations AS pc
        WHERE pc.payment_attempt_id = v_attempt.payment_attempt_id
          AND pc.confirmation_status = 'RECORDED'
          AND (p_payment_confirmation_id IS NULL OR pc.payment_confirmation_id = p_payment_confirmation_id)
        ORDER BY pc.confirmed_at DESC, pc.created_at DESC
        LIMIT 1;

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
                  p_statutory_discount_payable_basis_application_command_id
        FOR UPDATE;

        IF NOT FOUND OR v_application.command_status <> 'APPLIED' OR
           v_application.parking_session_id <> p_parking_session_id OR
           v_application.applied_tariff_snapshot_id <> p_tariff_snapshot_id OR
           v_application.statutory_discount_decision_command_id <>
               p_statutory_discount_decision_command_id OR
           v_application.statutory_discount_validation_id <> p_statutory_discount_validation_id OR
           v_application.approved_final_payable_amount_minor_units <> 0 OR
           p_completion_authority_reference_id <>
               p_statutory_discount_payable_basis_application_command_id OR
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

        SELECT decision.* INTO v_decision
        FROM discounts.statutory_discount_decision_commands AS decision
        WHERE decision.statutory_discount_decision_command_id =
                  p_statutory_discount_decision_command_id;

        IF NOT FOUND OR v_decision.parking_session_id <> p_parking_session_id OR
           v_decision.command_status <> 'COMPLETED' OR
           v_decision.decision_result_status <> 'APPROVED' OR
           v_decision.statutory_discount_validation_id <> p_statutory_discount_validation_id OR
           v_decision.applied_tariff_snapshot_id <> p_tariff_snapshot_id OR
           v_decision.net_payable_amount_minor_units <> 0 THEN
            RAISE EXCEPTION 'ZERO_PAYABLE_STATUTORY_FINALITY decision authority is invalid'
                USING ERRCODE = 'P0001';
        END IF;

        SELECT validation.* INTO v_validation
        FROM discounts.statutory_discount_validations AS validation
        WHERE validation.statutory_discount_validation_id = p_statutory_discount_validation_id;

        IF NOT FOUND OR v_validation.parking_session_id <> p_parking_session_id OR
           v_validation.validation_status <> 'APPROVED' OR
           v_validation.net_amount_after_discount <> 0 THEN
            RAISE EXCEPTION 'ZERO_PAYABLE_STATUTORY_FINALITY validation authority is invalid'
                USING ERRCODE = 'P0001';
        END IF;
    ELSE
        RAISE EXCEPTION 'unsupported ExitAuthorization completion basis: %', p_completion_basis
            USING ERRCODE = 'P0001';
    END IF;

    SELECT ea.* INTO v_authorization
    FROM core.exit_authorizations AS ea
    WHERE ea.completion_basis = p_completion_basis
      AND ea.completion_authority_reference_id = v_authority_reference_id
    FOR UPDATE;

    IF FOUND THEN
        RETURN QUERY SELECT
            v_authorization.exit_authorization_id, v_authorization.parking_session_id,
            v_authorization.tariff_snapshot_id, v_authorization.completion_basis::text,
            v_authorization.completion_authority_reference_id,
            v_authorization.payment_attempt_id, v_authorization.payment_confirmation_id,
            v_authorization.exit_authorization_id::text,
            v_authorization.authorization_status::text,
            v_authorization.issued_at, v_authorization.expires_at;
        RETURN;
    END IF;

    SELECT fir.* INTO v_fiscal
    FROM core.fiscal_issuance_references AS fir
    WHERE fir.is_active AND NOT fir.is_superseded
      AND fir.parking_session_id = p_parking_session_id
      AND fir.tariff_snapshot_id = v_tariff_snapshot_id
      AND fir.completion_basis = p_completion_basis
      AND fir.completion_authority_reference_id = v_authority_reference_id
      AND fir.fiscal_issuance_state IN (
          'FISCAL_ISSUANCE_RECORDED', 'FISCAL_ISSUANCE_REPLAYED', 'FISCAL_ISSUANCE_RECONCILED')
      AND fir.pos_server_fiscal_document_id IS NOT NULL
      AND fir.fiscal_document_number IS NOT NULL
    ORDER BY fir.last_updated_at DESC
    LIMIT 1;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'required fiscal completion is not recorded for ExitAuthorization'
            USING ERRCODE = 'P0001';
    END IF;

    SELECT si.service_identity_id INTO v_requested_by_service_identity_id
    FROM identity.service_identities AS si
    WHERE si.service_identity_id = p_requested_by
    LIMIT 1;

    v_requested_by_service_identity_id := COALESCE(
        v_requested_by_service_identity_id,
        v_fiscal.updated_by_service_identity_id,
        v_fiscal.recorded_by_service_identity_id,
        v_attempt.updated_by_service_identity_id,
        v_attempt.created_by_service_identity_id);

    IF v_requested_by_service_identity_id IS NULL THEN
        RAISE EXCEPTION 'requested_by service identity could not be resolved' USING ERRCODE = 'P0002';
    END IF;

    v_authorization_token := 'EXIT-' || replace(gen_random_uuid()::text, '-', '');
    INSERT INTO core.exit_authorizations (
        exit_authorization_id, parking_session_id, tariff_snapshot_id,
        completion_basis, completion_authority_reference_id,
        payment_attempt_id, payment_confirmation_id,
        statutory_discount_decision_command_id,
        statutory_discount_payable_basis_application_command_id,
        statutory_discount_validation_id, applied_policy_reference_id,
        statutory_discount_policy_version_id, authorization_token_hash,
        authorization_status, issued_at, expires_at, correlation_id,
        created_at, created_by_service_identity_id, updated_at,
        updated_by_service_identity_id)
    VALUES (
        gen_random_uuid(), p_parking_session_id, v_tariff_snapshot_id,
        p_completion_basis, v_authority_reference_id,
        p_payment_attempt_id, v_payment_confirmation_id,
        p_statutory_discount_decision_command_id,
        p_statutory_discount_payable_basis_application_command_id,
        p_statutory_discount_validation_id, p_applied_policy_reference_id,
        p_statutory_discount_policy_version_id,
        encode(digest(v_authorization_token, 'sha256'), 'hex'),
        'ISSUED', p_now, p_now + interval '15 minutes', p_correlation_id,
        p_now, v_requested_by_service_identity_id, p_now,
        v_requested_by_service_identity_id)
    RETURNING * INTO v_authorization;

    RETURN QUERY SELECT
        v_authorization.exit_authorization_id, v_authorization.parking_session_id,
        v_authorization.tariff_snapshot_id, v_authorization.completion_basis::text,
        v_authorization.completion_authority_reference_id,
        v_authorization.payment_attempt_id, v_authorization.payment_confirmation_id,
        v_authorization_token, v_authorization.authorization_status::text,
        v_authorization.issued_at, v_authorization.expires_at;
END;
$function$;
