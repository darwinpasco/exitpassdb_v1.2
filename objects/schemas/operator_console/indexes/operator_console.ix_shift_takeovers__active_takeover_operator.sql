CREATE INDEX IF NOT EXISTS ix_shift_takeovers__active_takeover_operator
    ON operator_console.shift_takeovers (takeover_operator_user_id, site_id, active_from, active_to)
    WHERE takeover_status = 'ACTIVE';;

