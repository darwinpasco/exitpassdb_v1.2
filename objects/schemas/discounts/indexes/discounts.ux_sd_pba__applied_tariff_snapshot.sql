CREATE UNIQUE INDEX IF NOT EXISTS ux_sd_pba__applied_tariff_snapshot
    ON discounts.statutory_discount_payable_basis_applications (applied_tariff_snapshot_id)
    WHERE applied_tariff_snapshot_id IS NOT NULL;;

