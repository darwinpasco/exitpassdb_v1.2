CREATE UNIQUE INDEX IF NOT EXISTS ux_sd_pba__idempotency_key
    ON discounts.statutory_discount_payable_basis_applications (idempotency_key)
    WHERE idempotency_key IS NOT NULL;;

