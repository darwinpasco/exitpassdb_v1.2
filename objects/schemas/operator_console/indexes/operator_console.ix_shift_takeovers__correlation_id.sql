CREATE INDEX IF NOT EXISTS ix_shift_takeovers__correlation_id
    ON operator_console.shift_takeovers (correlation_id)
    WHERE correlation_id IS NOT NULL;;

