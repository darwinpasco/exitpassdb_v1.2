-- ExitPass v1.3 Central PMS typed payment-chain routine alignment.
-- Additive migration generated from object-source routine files.
-- Promotes typed Central PMS routines while preserving table/data state.

-- ============================================================================
-- Source object: objects/schemas/core/functions/core.create_or_reuse_payment_attempt.sql
-- ============================================================================
/*
 * ExitPass v1.2 durable SQL patch.
 *
 * BRD:
 * - 9.9 Payment Initiation
 * - 9.13 Timeout, Retry, and Duplicate Handling
 * - 10.7.4 One Active Payment Attempt Per Session
 * - 18.11 Payment Attempt Integrity
 *
 * SDD:
 * - 6.3 Initiate Payment Attempt
 * - 8.3 PaymentAttempt State Machine
 * - 9.6 Integrity Constraints and Concurrency Rules
 *
 * System Invariants:
 * - PaymentAttempt creation must be anchored to an existing ParkingSession and TariffSnapshot.
 * - Idempotency-key replay must return the existing PaymentAttempt deterministically.
 * - Concurrent callers must not create duplicate active PaymentAttempts for one ParkingSession.
 * - TariffSnapshot consumption and PaymentAttempt creation are serialized by database row locks.
 * - All writes use ExitPass v1.2 table names, v1.2 enums, and service-identity audit attribution.
 */

CREATE OR REPLACE FUNCTION core.create_or_reuse_payment_attempt(
    p_parking_session_id uuid,
    p_tariff_snapshot_id uuid,
    p_payment_provider_code text,
    p_idempotency_key text,
    p_requested_by text,
    p_correlation_id uuid,
    p_now timestamptz
)
RETURNS TABLE (
    payment_attempt_id uuid,
    parking_session_id uuid,
    tariff_snapshot_id uuid,
    attempt_status text,
    payment_provider_code text,
    was_reused boolean,
    outcome_code text,
    failure_code text,
    gross_amount_snapshot numeric,
    statutory_discount_snapshot numeric,
    coupon_discount_snapshot numeric,
    net_amount_due_snapshot numeric,
    currency_code text,
    tariff_version_reference text
)
LANGUAGE plpgsql
AS $function$
DECLARE
    v_session core.parking_sessions%ROWTYPE;
    v_tariff core.tariff_snapshots%ROWTYPE;
    v_existing core.payment_attempts%ROWTYPE;
    v_created core.payment_attempts%ROWTYPE;

    v_requested_by_service_identity_id uuid;
    v_payment_rail_id uuid;
    v_resolved_payment_provider_code text;
BEGIN
    /*
     * ExitPass v1.2 BRD 9.9 and SDD 6.3 require PaymentAttempt creation to carry service audit attribution.
     * The routine accepts UUID text, service_identity_code, seeded row attribution, or latest active service identity.
     */
    IF p_requested_by IS NOT NULL AND btrim(p_requested_by) <> '' THEN
        BEGIN
            v_requested_by_service_identity_id := p_requested_by::uuid;
        EXCEPTION
            WHEN invalid_text_representation THEN
                SELECT si.service_identity_id
                INTO v_requested_by_service_identity_id
                FROM identity.service_identities AS si
                WHERE si.service_identity_code = p_requested_by
                LIMIT 1;
        END;
    END IF;

    SELECT ps.*
    INTO v_session
    FROM core.parking_sessions AS ps
    WHERE ps.parking_session_id = p_parking_session_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            NULL::uuid,
            p_parking_session_id::uuid,
            p_tariff_snapshot_id::uuid,
            NULL::text,
            COALESCE(p_payment_provider_code, '')::text,
            FALSE::boolean,
            'PARKING_SESSION_NOT_FOUND'::text,
            'PARKING_SESSION_NOT_FOUND'::text,
            0::numeric,
            0::numeric,
            0::numeric,
            0::numeric,
            ''::text,
            NULL::text;
        RETURN;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        v_requested_by_service_identity_id := v_session.created_by_service_identity_id;
    END IF;

    SELECT ts.*
    INTO v_tariff
    FROM core.tariff_snapshots AS ts
    WHERE ts.tariff_snapshot_id = p_tariff_snapshot_id
      AND ts.parking_session_id = p_parking_session_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            NULL::uuid,
            p_parking_session_id::uuid,
            p_tariff_snapshot_id::uuid,
            NULL::text,
            COALESCE(p_payment_provider_code, '')::text,
            FALSE::boolean,
            'TARIFF_SNAPSHOT_NOT_FOUND'::text,
            'TARIFF_SNAPSHOT_NOT_FOUND'::text,
            0::numeric,
            0::numeric,
            0::numeric,
            0::numeric,
            ''::text,
            NULL::text;
        RETURN;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        v_requested_by_service_identity_id := v_tariff.created_by_service_identity_id;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        SELECT si.service_identity_id
        INTO v_requested_by_service_identity_id
        FROM identity.service_identities AS si
        WHERE si.identity_status = 'ACTIVE'
        ORDER BY si.created_at DESC
        LIMIT 1;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        RETURN QUERY
        SELECT
            NULL::uuid,
            p_parking_session_id::uuid,
            p_tariff_snapshot_id::uuid,
            NULL::text,
            COALESCE(p_payment_provider_code, '')::text,
            FALSE::boolean,
            'REQUESTED_BY_SERVICE_IDENTITY_NOT_FOUND'::text,
            'REQUESTED_BY_SERVICE_IDENTITY_NOT_FOUND'::text,
            COALESCE(v_tariff.gross_amount, 0)::numeric,
            COALESCE(v_tariff.statutory_discount_amount, 0)::numeric,
            COALESCE(v_tariff.coupon_discount_amount, 0)::numeric,
            COALESCE(v_tariff.net_amount, 0)::numeric,
            COALESCE(v_tariff.currency_code::text, '')::text,
            v_tariff.tariff_version_reference::text;
        RETURN;
    END IF;

    /*
     * ExitPass v1.2 BRD 9.13 and SDD 9.6 require retry-safe idempotency-key replay.
     */
    SELECT pa.*
    INTO v_existing
    FROM core.payment_attempts AS pa
    WHERE pa.idempotency_key = p_idempotency_key
    LIMIT 1;

    IF FOUND THEN
        RETURN QUERY
        SELECT
            v_existing.payment_attempt_id::uuid,
            v_existing.parking_session_id::uuid,
            v_existing.tariff_snapshot_id::uuid,
            v_existing.attempt_status::text,
            COALESCE(p_payment_provider_code, v_resolved_payment_provider_code, '')::text,
            TRUE::boolean,
            'REUSED_BY_IDEMPOTENCY_KEY'::text,
            NULL::text,
            COALESCE(v_tariff.gross_amount, v_existing.amount)::numeric,
            COALESCE(v_tariff.statutory_discount_amount, 0)::numeric,
            COALESCE(v_tariff.coupon_discount_amount, 0)::numeric,
            v_existing.amount::numeric,
            v_existing.currency_code::text,
            v_tariff.tariff_version_reference::text;
        RETURN;
    END IF;

    /*
     * ExitPass v1.2 BRD 10.7.4 and SDD 9.6 require one active PaymentAttempt per ParkingSession.
     */
    SELECT pa.*
    INTO v_existing
    FROM core.payment_attempts AS pa
    WHERE pa.parking_session_id = p_parking_session_id
      AND pa.attempt_status IN (
          'REQUESTED',
          'PENDING_PROVIDER',
          'PENDING_FINALIZATION'
      )
    ORDER BY pa.created_at DESC
    LIMIT 1;

    IF FOUND THEN
        RETURN QUERY
        SELECT
            v_existing.payment_attempt_id::uuid,
            v_existing.parking_session_id::uuid,
            v_existing.tariff_snapshot_id::uuid,
            v_existing.attempt_status::text,
            COALESCE(p_payment_provider_code, v_resolved_payment_provider_code, '')::text,
            TRUE::boolean,
            'ACTIVE_ATTEMPT_EXISTS'::text,
            NULL::text,
            COALESCE(v_tariff.gross_amount, v_existing.amount)::numeric,
            COALESCE(v_tariff.statutory_discount_amount, 0)::numeric,
            COALESCE(v_tariff.coupon_discount_amount, 0)::numeric,
            v_existing.amount::numeric,
            v_existing.currency_code::text,
            v_tariff.tariff_version_reference::text;
        RETURN;
    END IF;

    /*
     * ExitPass v1.2 SDD 6.3 requires the immutable TariffSnapshot to be eligible before it can be consumed.
     */
    IF v_tariff.snapshot_status <> 'ACTIVE'
       OR v_tariff.consumed_at IS NOT NULL
       OR v_tariff.expires_at <= p_now
       OR v_tariff.superseded_by_tariff_snapshot_id IS NOT NULL THEN
        RETURN QUERY
        SELECT
            NULL::uuid,
            p_parking_session_id::uuid,
            p_tariff_snapshot_id::uuid,
            NULL::text,
            COALESCE(p_payment_provider_code, '')::text,
            FALSE::boolean,
            'TARIFF_SNAPSHOT_NOT_ELIGIBLE'::text,
            'TARIFF_SNAPSHOT_NOT_ELIGIBLE'::text,
            v_tariff.gross_amount::numeric,
            v_tariff.statutory_discount_amount::numeric,
            v_tariff.coupon_discount_amount::numeric,
            v_tariff.net_amount::numeric,
            v_tariff.currency_code::text,
            v_tariff.tariff_version_reference::text;
        RETURN;
    END IF;

    /*
     * payment_rail_id is stored for internal settlement/routing.
     * The returned payment_provider_code preserves p_payment_provider_code because the public API/test
     * expects the requested method/rail code, for example GCASH, not the backend provider, for example PAYMONGO.
     */
    SELECT pr.payment_rail_id, pr.provider_code
    INTO v_payment_rail_id, v_resolved_payment_provider_code
    FROM payments.payment_rails AS pr
    WHERE pr.rail_status = 'ACTIVE'
      AND pr.supported_currency_code = v_tariff.currency_code
      AND (
             pr.provider_code = p_payment_provider_code
          OR pr.rail_code = p_payment_provider_code
      )
      AND pr.effective_from <= p_now
      AND (pr.effective_to IS NULL OR pr.effective_to > p_now)
    ORDER BY pr.is_primary DESC, pr.created_at ASC
    LIMIT 1;

    IF v_payment_rail_id IS NULL THEN
        SELECT pr.payment_rail_id, pr.provider_code
        INTO v_payment_rail_id, v_resolved_payment_provider_code
        FROM payments.payment_rails AS pr
        WHERE pr.rail_status = 'ACTIVE'
          AND pr.supported_currency_code = v_tariff.currency_code
          AND pr.effective_from <= p_now
          AND (pr.effective_to IS NULL OR pr.effective_to > p_now)
        ORDER BY pr.is_primary DESC, pr.created_at ASC
        LIMIT 1;
    END IF;

    IF v_payment_rail_id IS NULL THEN
        RETURN QUERY
        SELECT
            NULL::uuid,
            p_parking_session_id::uuid,
            p_tariff_snapshot_id::uuid,
            NULL::text,
            COALESCE(p_payment_provider_code, '')::text,
            FALSE::boolean,
            'PAYMENT_RAIL_NOT_FOUND'::text,
            'PAYMENT_RAIL_NOT_FOUND'::text,
            v_tariff.gross_amount::numeric,
            v_tariff.statutory_discount_amount::numeric,
            v_tariff.coupon_discount_amount::numeric,
            v_tariff.net_amount::numeric,
            v_tariff.currency_code::text,
            v_tariff.tariff_version_reference::text;
        RETURN;
    END IF;

    INSERT INTO core.payment_attempts (
        payment_attempt_id,
        parking_session_id,
        tariff_snapshot_id,
        idempotency_key,
        payment_rail_id,
        currency_code,
        amount,
        attempt_status,
        requested_at,
        expires_at,
        finalized_at,
        failure_reason_code,
        correlation_id,
        created_at,
        created_by_service_identity_id,
        updated_at,
        updated_by_service_identity_id,
        row_version
    )
    VALUES (
        gen_random_uuid(),
        p_parking_session_id,
        p_tariff_snapshot_id,
        p_idempotency_key,
        v_payment_rail_id,
        v_tariff.currency_code,
        v_tariff.net_amount,
        'REQUESTED',
        p_now,
        p_now + INTERVAL '15 minutes',
        NULL,
        NULL,
        p_correlation_id,
        p_now,
        v_requested_by_service_identity_id,
        p_now,
        v_requested_by_service_identity_id,
        1
    )
    RETURNING *
    INTO v_created;

    UPDATE core.tariff_snapshots AS ts
    SET
        consumed_at = p_now,
        snapshot_status = 'CONSUMED',
        updated_at = p_now,
        updated_by_service_identity_id = v_requested_by_service_identity_id,
        row_version = ts.row_version + 1
    WHERE ts.tariff_snapshot_id = p_tariff_snapshot_id;

    RETURN QUERY
    SELECT
        v_created.payment_attempt_id::uuid,
        v_created.parking_session_id::uuid,
        v_created.tariff_snapshot_id::uuid,
        v_created.attempt_status::text,
        COALESCE(p_payment_provider_code, v_resolved_payment_provider_code, '')::text,
        FALSE::boolean,
        'CREATED'::text,
        NULL::text,
        v_tariff.gross_amount::numeric,
        v_tariff.statutory_discount_amount::numeric,
        v_tariff.coupon_discount_amount::numeric,
        v_tariff.net_amount::numeric,
        v_tariff.currency_code::text,
        v_tariff.tariff_version_reference::text;
END;
$function$;

-- ============================================================================
-- Source object: objects/schemas/core/functions/core.finalize_payment_attempt.sql
-- ============================================================================
/*
 * ExitPass v1.2 durable SQL patch.
 *
 * BRD:
 * - 9.10 Payment Processing and Confirmation
 * - 9.13 Timeout, Retry, and Duplicate Handling
 * - 10.7.2 Payment Finality Invariant
 * - 10.7.9 Provider Outcome Traceability Invariant
 *
 * SDD:
 * - 6.4 Finalize Payment
 * - 10.5.3 Report Verified Payment Outcome
 * - 9.6 Integrity Constraints and Concurrency Rules
 *
 * System Invariants:
 * - PaymentAttempt finalization must be anchored to an existing v1.2 PaymentAttempt.
 * - Terminal PaymentAttempt state transitions must be deterministic and replay-safe.
 * - A conflicting terminal replay must not overwrite prior finality.
 * - All writes use ExitPass v1.2 table names, v1.2 enums, and service-identity audit attribution.
 */

CREATE OR REPLACE FUNCTION core.finalize_payment_attempt(
    p_payment_attempt_id uuid,
    p_final_attempt_status text,
    p_requested_by text,
    p_correlation_id uuid,
    p_now timestamptz
)
RETURNS TABLE (
    payment_attempt_id uuid,
    attempt_status text
)
LANGUAGE plpgsql
AS $function$
DECLARE
    v_attempt core.payment_attempts%ROWTYPE;
    v_requested_by_service_identity_id uuid;
    v_final_attempt_status text;
BEGIN
    v_final_attempt_status := NULLIF(upper(btrim(p_final_attempt_status)), '');

    IF v_final_attempt_status IS NULL THEN
        RAISE EXCEPTION 'final attempt status is required'
            USING ERRCODE = '22023';
    END IF;

    IF v_final_attempt_status NOT IN ('CONFIRMED', 'FAILED', 'EXPIRED', 'CANCELLED') THEN
        RAISE EXCEPTION 'final attempt status % is not supported for finalization', v_final_attempt_status
            USING ERRCODE = '22023';
    END IF;

    IF p_requested_by IS NOT NULL AND btrim(p_requested_by) <> '' THEN
        BEGIN
            v_requested_by_service_identity_id := p_requested_by::uuid;
        EXCEPTION
            WHEN invalid_text_representation THEN
                SELECT si.service_identity_id
                INTO v_requested_by_service_identity_id
                FROM identity.service_identities AS si
                WHERE si.service_identity_code = p_requested_by
                LIMIT 1;
        END;
    END IF;

    SELECT pa.*
    INTO v_attempt
    FROM core.payment_attempts AS pa
    WHERE pa.payment_attempt_id = p_payment_attempt_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'payment attempt % was not found', p_payment_attempt_id
            USING ERRCODE = 'P0002';
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        v_requested_by_service_identity_id := v_attempt.updated_by_service_identity_id;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        v_requested_by_service_identity_id := v_attempt.created_by_service_identity_id;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        SELECT si.service_identity_id
        INTO v_requested_by_service_identity_id
        FROM identity.service_identities AS si
        WHERE si.identity_status = 'ACTIVE'
        ORDER BY si.created_at DESC
        LIMIT 1;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        RAISE EXCEPTION 'requested_by service identity could not be resolved'
            USING ERRCODE = 'P0002';
    END IF;

    IF v_attempt.attempt_status IN ('CONFIRMED', 'FAILED', 'EXPIRED', 'CANCELLED') THEN
        IF v_attempt.attempt_status::text = v_final_attempt_status THEN
            RETURN QUERY
            SELECT
                v_attempt.payment_attempt_id::uuid,
                v_attempt.attempt_status::text;
            RETURN;
        END IF;

        RAISE EXCEPTION 'payment attempt % is already final with status %', p_payment_attempt_id, v_attempt.attempt_status
            USING ERRCODE = 'P0001';
    END IF;

    UPDATE core.payment_attempts AS pa
    SET
        attempt_status = v_final_attempt_status::core.payment_attempt_status_enum,
        finalized_at = p_now,
        failure_reason_code = CASE
            WHEN v_final_attempt_status = 'FAILED' THEN 'PROVIDER_REPORTED_FAILURE'
            WHEN v_final_attempt_status IN ('EXPIRED', 'CANCELLED') THEN v_final_attempt_status
            ELSE NULL
        END,
        correlation_id = COALESCE(p_correlation_id, pa.correlation_id),
        updated_at = p_now,
        updated_by_service_identity_id = v_requested_by_service_identity_id,
        row_version = pa.row_version + 1
    WHERE pa.payment_attempt_id = p_payment_attempt_id
    RETURNING pa.*
    INTO v_attempt;

    RETURN QUERY
    SELECT
        v_attempt.payment_attempt_id::uuid,
        v_attempt.attempt_status::text;
END;
$function$;

-- ============================================================================
-- Source object: objects/schemas/core/functions/core.record_payment_confirmation.sql
-- ============================================================================
/*
 * ExitPass v1.2 durable SQL patch.
 *
 * BRD:
 * - 9.10 Payment Processing and Confirmation
 * - 10.7.9 Provider Outcome Traceability Invariant
 * - 10.7.10 Idempotent Payment Confirmation Invariant
 *
 * SDD:
 * - 6.4 Finalize Payment
 * - 7.3 Provider Callback / Confirmation Handling
 * - 9.6 Integrity Constraints and Concurrency Rules
 *
 * System Invariants:
 * - PaymentConfirmation must be anchored to an existing PaymentAttempt.
 * - Same-attempt same-provider-reference webhook replay returns the existing PaymentConfirmation.
 * - Provider transaction references must not create ambiguous cross-attempt confirmation evidence.
 * - Confirmed provider evidence moves the canonical PaymentAttempt to terminal CONFIRMED state.
 * - All writes use ExitPass v1.2 table names and service-identity audit attribution.
 */

CREATE OR REPLACE FUNCTION core.record_payment_confirmation(
    p_payment_attempt_id uuid,
    p_provider_reference text,
    p_provider_status text,
    p_requested_by text,
    p_correlation_id uuid,
    p_now timestamptz
)
RETURNS TABLE (
    payment_confirmation_id uuid,
    payment_attempt_id uuid,
    provider_reference text,
    provider_status text,
    verified_timestamp timestamptz
)
LANGUAGE plpgsql
AS $function$
DECLARE
    v_attempt core.payment_attempts%ROWTYPE;
    v_confirmation core.payment_confirmations%ROWTYPE;
    v_requested_by_service_identity_id uuid;
    v_normalized_provider_reference text;
    v_normalized_provider_status text;
BEGIN
    v_normalized_provider_reference := NULLIF(btrim(p_provider_reference), '');
    v_normalized_provider_status := NULLIF(upper(btrim(p_provider_status)), '');

    IF v_normalized_provider_reference IS NULL THEN
        RAISE EXCEPTION 'provider reference is required'
            USING ERRCODE = '22023';
    END IF;

    IF v_normalized_provider_status IS NULL THEN
        RAISE EXCEPTION 'provider status is required'
            USING ERRCODE = '22023';
    END IF;

    IF p_requested_by IS NOT NULL AND btrim(p_requested_by) <> '' THEN
        BEGIN
            v_requested_by_service_identity_id := p_requested_by::uuid;
        EXCEPTION
            WHEN invalid_text_representation THEN
                SELECT si.service_identity_id
                INTO v_requested_by_service_identity_id
                FROM identity.service_identities AS si
                WHERE si.service_identity_code = p_requested_by
                LIMIT 1;
        END;
    END IF;

    SELECT pa.*
    INTO v_attempt
    FROM core.payment_attempts AS pa
    WHERE pa.payment_attempt_id = p_payment_attempt_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'payment attempt % was not found', p_payment_attempt_id
            USING ERRCODE = 'P0002';
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        v_requested_by_service_identity_id := v_attempt.updated_by_service_identity_id;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        v_requested_by_service_identity_id := v_attempt.created_by_service_identity_id;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        SELECT si.service_identity_id
        INTO v_requested_by_service_identity_id
        FROM identity.service_identities AS si
        WHERE si.identity_status = 'ACTIVE'
        ORDER BY si.created_at DESC
        LIMIT 1;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        RAISE EXCEPTION 'requested_by service identity could not be resolved'
            USING ERRCODE = 'P0002';
    END IF;

    SELECT pc.*
    INTO v_confirmation
    FROM core.payment_confirmations AS pc
    WHERE pc.payment_attempt_id = p_payment_attempt_id
    FOR UPDATE;

    IF FOUND THEN
        IF v_confirmation.provider_transaction_ref = v_normalized_provider_reference THEN
            /*
             * ExitPass v1.2 BRD 10.7.10 and SDD 7.3 require retry-safe provider webhook handling.
             * The canonical invariant is same PaymentAttempt + same provider reference => same evidence row.
             */
            RETURN QUERY
            SELECT
                v_confirmation.payment_confirmation_id::uuid,
                v_confirmation.payment_attempt_id::uuid,
                v_confirmation.provider_transaction_ref::text,
                v_normalized_provider_status::text,
                v_confirmation.verified_at::timestamptz;
            RETURN;
        END IF;

        RAISE EXCEPTION 'payment confirmation already exists for payment attempt %', p_payment_attempt_id
            USING
                ERRCODE = '23505',
                CONSTRAINT = 'uq_payment_confirmations__payment_attempt';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM core.payment_confirmations AS pc
        WHERE pc.payment_rail_id IS NOT DISTINCT FROM v_attempt.payment_rail_id
          AND pc.provider_transaction_ref = v_normalized_provider_reference
    ) THEN
        RAISE EXCEPTION 'provider reference % has already been recorded', v_normalized_provider_reference
            USING
                ERRCODE = '23505',
                CONSTRAINT = 'ux_payment_confirmations__provider_transaction_ref';
    END IF;

    INSERT INTO core.payment_confirmations (
        payment_confirmation_id,
        payment_attempt_id,
        provider_outcome_id,
        payment_rail_id,
        provider_transaction_ref,
        currency_code,
        confirmed_amount,
        confirmation_status,
        verified_at,
        confirmed_at,
        correlation_id,
        created_at,
        created_by_service_identity_id
    )
    VALUES (
        gen_random_uuid(),
        p_payment_attempt_id,
        NULL,
        v_attempt.payment_rail_id,
        v_normalized_provider_reference,
        v_attempt.currency_code,
        v_attempt.amount,
        'RECORDED',
        p_now,
        p_now,
        p_correlation_id,
        p_now,
        v_requested_by_service_identity_id
    )
    RETURNING *
    INTO v_confirmation;

    IF v_normalized_provider_status IN ('SUCCESS', 'SUCCEEDED', 'PAID', 'CONFIRMED') THEN
        UPDATE core.payment_attempts AS pa
        SET
            attempt_status = 'CONFIRMED',
            finalized_at = COALESCE(pa.finalized_at, p_now),
            failure_reason_code = NULL,
            updated_at = p_now,
            updated_by_service_identity_id = v_requested_by_service_identity_id,
            row_version = pa.row_version + 1
        WHERE pa.payment_attempt_id = p_payment_attempt_id;
    ELSIF v_normalized_provider_status IN ('FAILED', 'DECLINED', 'CANCELLED', 'EXPIRED') THEN
        UPDATE core.payment_attempts AS pa
        SET
            attempt_status = 'FAILED',
            finalized_at = COALESCE(pa.finalized_at, p_now),
            failure_reason_code = v_normalized_provider_status,
            updated_at = p_now,
            updated_by_service_identity_id = v_requested_by_service_identity_id,
            row_version = pa.row_version + 1
        WHERE pa.payment_attempt_id = p_payment_attempt_id;
    END IF;

    RETURN QUERY
    SELECT
        v_confirmation.payment_confirmation_id::uuid,
        v_confirmation.payment_attempt_id::uuid,
        v_confirmation.provider_transaction_ref::text,
        v_normalized_provider_status::text,
        v_confirmation.verified_at::timestamptz;
END;
$function$;

-- ============================================================================
-- Source object: objects/schemas/core/functions/core.issue_exit_authorization.sql
-- ============================================================================
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

-- ============================================================================
-- Source object: objects/schemas/core/functions/core.consume_exit_authorization.sql
-- ============================================================================
/*
 * ExitPass v1.2 durable SQL patch.
 *
 * BRD:
 * - 9.12 Exit Authorization
 * - 9.13 Timeout, Retry, and Duplicate Handling
 * - 10.7.7 Exit Token Integrity Invariant
 * - 10.7.8 Single-Use Consume Invariant
 *
 * SDD:
 * - 6.6 Consume Exit Authorization
 * - 8.5 ExitAuthorization State Machine
 * - 9.6 Integrity Constraints and Concurrency Rules
 *
 * System Invariants:
 * - AuthorizationConsumption must be anchored to an existing issued ExitAuthorization.
 * - Consumption must be single-use, auditable, and deterministic.
 * - Expired, invalidated, and already-consumed authorizations fail closed.
 * - All writes use ExitPass v1.2 core and gates table names, v1.2 enums, and service-identity audit attribution.
 */

CREATE OR REPLACE FUNCTION core.consume_exit_authorization(
    p_exit_authorization_id uuid,
    p_requested_by uuid,
    p_correlation_id uuid,
    p_now timestamptz
)
RETURNS TABLE (
    exit_authorization_id uuid,
    authorization_status text,
    consumed_at timestamptz
)
LANGUAGE plpgsql
AS $function$
DECLARE
    v_authorization core.exit_authorizations%ROWTYPE;
    v_session core.parking_sessions%ROWTYPE;
    v_existing_consumed_at timestamptz;
    v_requested_by_service_identity_id uuid;
    v_consumption gates.gate_authorization_consumptions%ROWTYPE;
BEGIN
    SELECT ea.*
    INTO v_authorization
    FROM core.exit_authorizations AS ea
    WHERE ea.exit_authorization_id = p_exit_authorization_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'exit authorization % was not found', p_exit_authorization_id
            USING ERRCODE = 'P0002';
    END IF;

    SELECT ps.*
    INTO v_session
    FROM core.parking_sessions AS ps
    WHERE ps.parking_session_id = v_authorization.parking_session_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'parking session % was not found for exit authorization %',
            v_authorization.parking_session_id,
            p_exit_authorization_id
            USING ERRCODE = 'P0002';
    END IF;

    SELECT gac.consumed_at
    INTO v_existing_consumed_at
    FROM gates.gate_authorization_consumptions AS gac
    WHERE gac.exit_authorization_id = p_exit_authorization_id
      AND gac.consume_status = 'CONSUMED'
    ORDER BY gac.consumed_at DESC
    LIMIT 1;

    IF FOUND THEN
        RAISE EXCEPTION 'exit authorization % has already been consumed', p_exit_authorization_id
            USING ERRCODE = 'P0001';
    END IF;

    IF v_authorization.authorization_status <> 'ISSUED' THEN
        RAISE EXCEPTION 'exit authorization % is not issued', p_exit_authorization_id
            USING ERRCODE = 'P0001';
    END IF;

    IF v_authorization.expires_at <= p_now THEN
        INSERT INTO gates.gate_authorization_consumptions (
            gate_authorization_consumption_id,
            exit_authorization_id,
            authorization_token_hash,
            site_id,
            consume_status,
            consume_reason_code,
            requested_at,
            validated_at,
            command_requested,
            command_result_status,
            failure_detail,
            correlation_id,
            created_at,
            created_by_service_identity_id,
            updated_at,
            updated_by_service_identity_id
        )
        VALUES (
            gen_random_uuid(),
            v_authorization.exit_authorization_id,
            v_authorization.authorization_token_hash,
            v_session.site_id,
            'EXPIRED',
            'EXIT_AUTHORIZATION_EXPIRED',
            p_now,
            p_now,
            false,
            'NOT_REQUESTED',
            'Exit authorization expired before consume.',
            p_correlation_id,
            p_now,
            COALESCE(v_authorization.updated_by_service_identity_id, v_authorization.created_by_service_identity_id),
            p_now,
            COALESCE(v_authorization.updated_by_service_identity_id, v_authorization.created_by_service_identity_id)
        );

        RAISE EXCEPTION 'exit authorization % is expired', p_exit_authorization_id
            USING ERRCODE = 'P0001';
    END IF;

    SELECT si.service_identity_id
    INTO v_requested_by_service_identity_id
    FROM identity.service_identities AS si
    WHERE si.service_identity_id = p_requested_by
    LIMIT 1;

    IF v_requested_by_service_identity_id IS NULL THEN
        v_requested_by_service_identity_id := v_authorization.updated_by_service_identity_id;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        v_requested_by_service_identity_id := v_authorization.created_by_service_identity_id;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        RAISE EXCEPTION 'requested_by service identity could not be resolved'
            USING ERRCODE = 'P0002';
    END IF;

    INSERT INTO gates.gate_authorization_consumptions (
        gate_authorization_consumption_id,
        exit_authorization_id,
        authorization_token_hash,
        site_id,
        consume_status,
        consume_reason_code,
        requested_at,
        validated_at,
        consumed_at,
        command_requested,
        command_result_status,
        command_result_at,
        correlation_id,
        created_at,
        created_by_service_identity_id,
        updated_at,
        updated_by_service_identity_id
    )
    VALUES (
        gen_random_uuid(),
        v_authorization.exit_authorization_id,
        v_authorization.authorization_token_hash,
        v_session.site_id,
        'CONSUMED',
        'EXIT_AUTHORIZATION_CONSUMED',
        p_now,
        p_now,
        p_now,
        true,
        'REQUESTED',
        p_now,
        p_correlation_id,
        p_now,
        v_requested_by_service_identity_id,
        p_now,
        v_requested_by_service_identity_id
    )
    RETURNING *
    INTO v_consumption;

    UPDATE core.exit_authorizations AS ea
    SET
        updated_at = p_now,
        updated_by_service_identity_id = v_requested_by_service_identity_id,
        row_version = ea.row_version + 1
    WHERE ea.exit_authorization_id = p_exit_authorization_id;

    RETURN QUERY
    SELECT
        v_authorization.exit_authorization_id::uuid,
        'CONSUMED'::text,
        v_consumption.consumed_at::timestamptz;
END;
$function$;

