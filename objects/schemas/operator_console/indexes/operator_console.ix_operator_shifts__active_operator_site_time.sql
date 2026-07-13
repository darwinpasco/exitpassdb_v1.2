CREATE INDEX IF NOT EXISTS ix_operator_shifts__active_operator_site_time
    ON operator_console.operator_shifts (operator_user_id, site_id, active_from, active_to)
    WHERE operational_status = 'ACTIVE';;

