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
        authorization_status = 'CONSUMED',
        consumed_at = p_now,
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

/*
 * v1.3 completion-aware overload. PAYMENT_FINALITY delegates to the proven
 * four-argument routine. Zero-payable statutory completion is consumed on
 * core.exit_authorizations and never requests an ExitPass physical gate command.
 */
CREATE OR REPLACE FUNCTION core.consume_exit_authorization(
    p_exit_authorization_id uuid,
    p_requested_by uuid,
    p_correlation_id uuid,
    p_now timestamptz,
    p_completion_basis text
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
    v_requested_by_service_identity_id uuid;
    v_valid boolean;
BEGIN
    IF p_completion_basis = 'PAYMENT_FINALITY' THEN
        RETURN QUERY
        SELECT consumed.exit_authorization_id, consumed.authorization_status, consumed.consumed_at
        FROM core.consume_exit_authorization(
            p_exit_authorization_id,
            p_requested_by,
            p_correlation_id,
            p_now) AS consumed;
        UPDATE core.exit_authorizations AS ea
        SET authorization_status = 'CONSUMED',
            consumed_at = p_now,
            correlation_id = COALESCE(p_correlation_id, ea.correlation_id),
            updated_at = p_now,
            updated_by_service_identity_id = COALESCE(
                ea.updated_by_service_identity_id,
                ea.created_by_service_identity_id),
            row_version = ea.row_version + 1
        WHERE ea.exit_authorization_id = p_exit_authorization_id
          AND ea.authorization_status <> 'CONSUMED';
        RETURN;
    END IF;

    IF p_completion_basis <> 'ZERO_PAYABLE_STATUTORY_FINALITY' THEN
        RAISE EXCEPTION 'unsupported ExitAuthorization completion basis: %', p_completion_basis
            USING ERRCODE = 'P0001';
    END IF;

    SELECT ea.* INTO v_authorization
    FROM core.exit_authorizations AS ea
    WHERE ea.exit_authorization_id = p_exit_authorization_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'exit authorization % was not found', p_exit_authorization_id
            USING ERRCODE = 'P0002';
    END IF;

    IF v_authorization.completion_basis <> p_completion_basis THEN
        RAISE EXCEPTION 'ExitAuthorization completion basis mismatch'
            USING ERRCODE = 'P0001';
    END IF;

    IF v_authorization.authorization_status = 'CONSUMED' THEN
        RAISE EXCEPTION 'exit authorization % has already been consumed', p_exit_authorization_id
            USING ERRCODE = 'P0001';
    END IF;

    IF v_authorization.authorization_status <> 'ISSUED' OR
       v_authorization.expires_at <= p_now THEN
        RAISE EXCEPTION 'exit authorization % is not currently valid', p_exit_authorization_id
            USING ERRCODE = 'P0001';
    END IF;

    SELECT ps.* INTO v_session
    FROM core.parking_sessions AS ps
    WHERE ps.parking_session_id = v_authorization.parking_session_id;

    IF NOT FOUND OR v_session.session_status <> 'ACTIVE' THEN
        RAISE EXCEPTION 'parking session is not eligible for ExitAuthorization consume'
            USING ERRCODE = 'P0001';
    END IF;

    SELECT EXISTS (
        SELECT 1
        FROM discounts.statutory_discount_payable_basis_application_commands AS app
        JOIN discounts.statutory_discount_decision_commands AS decision
          ON decision.statutory_discount_decision_command_id =
             app.statutory_discount_decision_command_id
        JOIN discounts.statutory_discount_validations AS validation
          ON validation.statutory_discount_validation_id =
             app.statutory_discount_validation_id
        JOIN core.fiscal_issuance_references AS fir
          ON fir.parking_session_id = v_authorization.parking_session_id
         AND fir.tariff_snapshot_id = v_authorization.tariff_snapshot_id
         AND fir.completion_basis = v_authorization.completion_basis
         AND fir.completion_authority_reference_id =
             v_authorization.completion_authority_reference_id
         AND fir.is_active
         AND NOT fir.is_superseded
         AND fir.fiscal_issuance_state IN (
             'FISCAL_ISSUANCE_RECORDED',
             'FISCAL_ISSUANCE_REPLAYED',
             'FISCAL_ISSUANCE_RECONCILED')
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
          AND decision.decision_result_status = 'APPROVED'
          AND decision.command_status = 'COMPLETED'
          AND validation.validation_status = 'APPROVED'
          AND validation.net_amount_after_discount = 0
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
          AND v_authorization.payment_attempt_id IS NULL
          AND v_authorization.payment_confirmation_id IS NULL)
    INTO v_valid;

    IF NOT v_valid THEN
        RAISE EXCEPTION 'zero-payable ExitAuthorization completion authority is no longer valid'
            USING ERRCODE = 'P0001';
    END IF;

    SELECT si.service_identity_id INTO v_requested_by_service_identity_id
    FROM identity.service_identities AS si
    WHERE si.service_identity_id = p_requested_by
    LIMIT 1;

    v_requested_by_service_identity_id := COALESCE(
        v_requested_by_service_identity_id,
        v_authorization.updated_by_service_identity_id,
        v_authorization.created_by_service_identity_id);

    IF v_requested_by_service_identity_id IS NULL THEN
        RAISE EXCEPTION 'requested_by service identity could not be resolved'
            USING ERRCODE = 'P0002';
    END IF;

    UPDATE core.exit_authorizations AS ea
    SET authorization_status = 'CONSUMED',
        consumed_at = p_now,
        correlation_id = COALESCE(p_correlation_id, ea.correlation_id),
        updated_at = p_now,
        updated_by_service_identity_id = v_requested_by_service_identity_id,
        row_version = ea.row_version + 1
    WHERE ea.exit_authorization_id = p_exit_authorization_id;

    RETURN QUERY SELECT
        v_authorization.exit_authorization_id,
        'CONSUMED'::text,
        p_now;
END;
$function$;
