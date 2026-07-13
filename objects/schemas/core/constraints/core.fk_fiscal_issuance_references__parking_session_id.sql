ALTER TABLE core.fiscal_issuance_references
    ADD CONSTRAINT fk_fiscal_issuance_references__parking_session_id
    FOREIGN KEY (parking_session_id)
    REFERENCES core.parking_sessions(parking_session_id)
    DEFERRABLE INITIALLY IMMEDIATE;;

