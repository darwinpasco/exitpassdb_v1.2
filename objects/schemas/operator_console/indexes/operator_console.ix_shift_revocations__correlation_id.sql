CREATE INDEX IF NOT EXISTS ix_shift_revocations__correlation_id
    ON operator_console.shift_revocations (correlation_id)
    WHERE correlation_id IS NOT NULL;;

