CREATE INDEX IF NOT EXISTS ix_sd_pba__original_tariff_snapshot
    ON discounts.statutory_discount_payable_basis_applications (original_tariff_snapshot_id);;

