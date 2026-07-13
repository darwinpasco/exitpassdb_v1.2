CREATE INDEX IF NOT EXISTS ix_shift_takeovers__shift_status
    ON operator_console.shift_takeovers (operator_shift_id, takeover_status, requested_at DESC);;

