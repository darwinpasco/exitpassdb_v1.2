CREATE OR REPLACE FUNCTION discounts.enforce_statutory_discount_payable_basis_application()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
DECLARE
    v_validation discounts.statutory_discount_validations%ROWTYPE;
    v_original_tariff core.tariff_snapshots%ROWTYPE;
    v_applied_tariff core.tariff_snapshots%ROWTYPE;
    v_payment_attempt_exists boolean;
BEGIN
    SELECT *
    INTO v_validation
    FROM discounts.statutory_discount_validations
    WHERE statutory_discount_validation_id = NEW.statutory_discount_validation_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'statutory discount validation % was not found', NEW.statutory_discount_validation_id
            USING ERRCODE = '23503';
    END IF;

    IF v_validation.parking_session_id <> NEW.parking_session_id THEN
        RAISE EXCEPTION 'statutory discount validation % belongs to parking session %, not %',
            NEW.statutory_discount_validation_id,
            v_validation.parking_session_id,
            NEW.parking_session_id
            USING ERRCODE = '23514';
    END IF;

    SELECT *
    INTO v_original_tariff
    FROM core.tariff_snapshots
    WHERE tariff_snapshot_id = NEW.original_tariff_snapshot_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'original tariff snapshot % was not found', NEW.original_tariff_snapshot_id
            USING ERRCODE = '23503';
    END IF;

    IF v_original_tariff.parking_session_id <> NEW.parking_session_id THEN
        RAISE EXCEPTION 'original tariff snapshot % belongs to parking session %, not %',
            NEW.original_tariff_snapshot_id,
            v_original_tariff.parking_session_id,
            NEW.parking_session_id
            USING ERRCODE = '23514';
    END IF;

    IF NEW.application_status = 'APPLIED' THEN
        IF v_validation.validation_status <> 'APPROVED' THEN
            RAISE EXCEPTION 'statutory discount validation % must be APPROVED before payable-basis application',
                NEW.statutory_discount_validation_id
                USING ERRCODE = '23514';
        END IF;

        IF v_validation.evidence_required AND NOT v_validation.evidence_captured THEN
            RAISE EXCEPTION 'statutory discount validation % requires captured evidence before payable-basis application',
                NEW.statutory_discount_validation_id
                USING ERRCODE = '23514';
        END IF;

        SELECT *
        INTO v_applied_tariff
        FROM core.tariff_snapshots
        WHERE tariff_snapshot_id = NEW.applied_tariff_snapshot_id;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'applied tariff snapshot % was not found', NEW.applied_tariff_snapshot_id
                USING ERRCODE = '23503';
        END IF;

        IF v_applied_tariff.parking_session_id <> NEW.parking_session_id THEN
            RAISE EXCEPTION 'applied tariff snapshot % belongs to parking session %, not %',
                NEW.applied_tariff_snapshot_id,
                v_applied_tariff.parking_session_id,
                NEW.parking_session_id
                USING ERRCODE = '23514';
        END IF;

        IF v_applied_tariff.statutory_discount_validation_id IS DISTINCT FROM NEW.statutory_discount_validation_id THEN
            RAISE EXCEPTION 'applied tariff snapshot % must reference statutory discount validation %',
                NEW.applied_tariff_snapshot_id,
                NEW.statutory_discount_validation_id
                USING ERRCODE = '23514';
        END IF;

        IF v_applied_tariff.snapshot_status <> 'ACTIVE' THEN
            RAISE EXCEPTION 'applied tariff snapshot % must be ACTIVE, not %',
                NEW.applied_tariff_snapshot_id,
                v_applied_tariff.snapshot_status
                USING ERRCODE = '23514';
        END IF;

        IF v_applied_tariff.statutory_discount_amount <= 0 THEN
            RAISE EXCEPTION 'applied tariff snapshot % must contain a positive statutory discount amount',
                NEW.applied_tariff_snapshot_id
                USING ERRCODE = '23514';
        END IF;

        SELECT EXISTS (
            SELECT 1
            FROM core.payment_attempts
            WHERE parking_session_id = NEW.parking_session_id
        )
        INTO v_payment_attempt_exists;

        IF v_payment_attempt_exists THEN
            RAISE EXCEPTION 'parking session % already has a payment attempt and cannot receive statutory payable-basis application',
                NEW.parking_session_id
                USING ERRCODE = '23514';
        END IF;
    END IF;

    RETURN NEW;
END;
$function$;;

