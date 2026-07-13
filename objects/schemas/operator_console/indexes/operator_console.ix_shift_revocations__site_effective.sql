CREATE INDEX IF NOT EXISTS ix_shift_revocations__site_effective
    ON operator_console.shift_revocations (site_id, effective_at DESC);;

