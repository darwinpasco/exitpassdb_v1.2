CREATE UNIQUE INDEX IF NOT EXISTS ux_sd_pba__validation_active
    ON discounts.statutory_discount_payable_basis_applications (statutory_discount_validation_id)
    WHERE application_status IN (
        'REQUESTED'::discounts.statutory_discount_payable_application_status_enum,
        'APPLIED'::discounts.statutory_discount_payable_application_status_enum
    );;

