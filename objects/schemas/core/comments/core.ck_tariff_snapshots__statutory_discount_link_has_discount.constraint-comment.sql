COMMENT ON CONSTRAINT ck_tariff_snapshots__statutory_discount_link_has_discount
    ON core.tariff_snapshots IS
    'A tariff snapshot linked to a statutory discount validation must carry a positive statutory discount amount.';;

