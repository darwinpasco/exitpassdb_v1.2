CREATE INDEX IF NOT EXISTS ix_sd_pba__parking_session
    ON discounts.statutory_discount_payable_basis_applications (parking_session_id);;

