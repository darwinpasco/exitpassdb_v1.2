CREATE INDEX IF NOT EXISTS ix_sd_pba__status
    ON discounts.statutory_discount_payable_basis_applications (application_status);;

