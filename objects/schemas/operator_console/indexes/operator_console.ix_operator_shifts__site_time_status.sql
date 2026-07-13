CREATE INDEX IF NOT EXISTS ix_operator_shifts__site_time_status
    ON operator_console.operator_shifts (site_id, scheduled_start_at, scheduled_end_at, operational_status);;

