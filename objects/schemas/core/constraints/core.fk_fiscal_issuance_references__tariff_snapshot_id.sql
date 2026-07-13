ALTER TABLE core.fiscal_issuance_references
    ADD CONSTRAINT fk_fiscal_issuance_references__tariff_snapshot_id
    FOREIGN KEY (tariff_snapshot_id)
    REFERENCES core.tariff_snapshots(tariff_snapshot_id)
    DEFERRABLE INITIALLY IMMEDIATE;;

