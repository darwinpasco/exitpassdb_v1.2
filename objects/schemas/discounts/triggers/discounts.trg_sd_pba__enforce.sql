CREATE TRIGGER trg_sd_pba__enforce
BEFORE INSERT OR UPDATE OF
    statutory_discount_validation_id,
    parking_session_id,
    original_tariff_snapshot_id,
    applied_tariff_snapshot_id,
    application_status
ON discounts.statutory_discount_payable_basis_applications
FOR EACH ROW
EXECUTE FUNCTION discounts.enforce_statutory_discount_payable_basis_application();;

