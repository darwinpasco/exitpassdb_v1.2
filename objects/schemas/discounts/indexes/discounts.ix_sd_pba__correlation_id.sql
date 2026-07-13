CREATE INDEX IF NOT EXISTS ix_sd_pba__correlation_id
    ON discounts.statutory_discount_payable_basis_applications (correlation_id);;

