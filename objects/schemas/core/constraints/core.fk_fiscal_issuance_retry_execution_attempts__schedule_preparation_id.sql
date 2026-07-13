ALTER TABLE core.fiscal_issuance_retry_execution_attempts
    ADD CONSTRAINT fk_fiscal_issuance_retry_execution_attempts__schedule_preparation_id
    FOREIGN KEY (retry_schedule_preparation_attempt_id)
    REFERENCES core.fiscal_issuance_retry_schedule_preparations(retry_schedule_preparation_attempt_id)
    DEFERRABLE INITIALLY IMMEDIATE;;

