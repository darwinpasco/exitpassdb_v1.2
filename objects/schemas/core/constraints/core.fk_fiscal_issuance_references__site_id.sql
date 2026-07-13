ALTER TABLE core.fiscal_issuance_references
    ADD CONSTRAINT fk_fiscal_issuance_references__site_id
    FOREIGN KEY (site_id)
    REFERENCES sites.sites(site_id)
    DEFERRABLE INITIALLY IMMEDIATE;;

