ALTER TABLE core.fiscal_issuance_retry_schedule_preparations
    ADD CONSTRAINT fk_fiscal_issuance_retry_schedule_preparations__command_preparation_id
    FOREIGN KEY (retry_command_preparation_attempt_id)
    REFERENCES core.fiscal_issuance_retry_command_preparations(retry_command_preparation_attempt_id)
    DEFERRABLE INITIALLY IMMEDIATE;;

