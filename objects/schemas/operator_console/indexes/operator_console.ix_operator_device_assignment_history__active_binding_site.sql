CREATE INDEX IF NOT EXISTS ix_operator_device_assignment_history__active_binding_site
    ON operator_console.operator_device_assignment_history (operator_device_binding_id, site_id, effective_from, effective_to)
    WHERE effective_to IS NULL;;

