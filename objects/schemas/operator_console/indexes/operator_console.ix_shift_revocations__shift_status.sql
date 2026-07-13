CREATE INDEX IF NOT EXISTS ix_shift_revocations__shift_status
    ON operator_console.shift_revocations (operator_shift_id, revocation_status, requested_at DESC);;

