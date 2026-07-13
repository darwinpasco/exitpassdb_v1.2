CREATE INDEX IF NOT EXISTS ix_operator_shifts__operator_site_status
    ON operator_console.operator_shifts (operator_user_id, site_id, operational_status);;

