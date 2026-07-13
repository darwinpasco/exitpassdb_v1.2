INSERT INTO config.controlled_code_sets (
    code_set_name,
    code_value,
    code_label,
    code_description,
    code_domain,
    code_status,
    sort_order,
    requires_comment,
    requires_approval,
    is_sensitive,
    effective_from
)
VALUES
    ('OPERATOR_CONSOLE_DUPLICATE_DETECTION_SCOPE', 'SAME_SESSION_ONLY', 'Same Session Only', 'Duplicate detection is scoped to the same parking session.', 'OPERATOR_CONSOLE', 'ACTIVE', 10, false, false, false, '2026-01-01T00:00:00Z'),
    ('OPERATOR_CONSOLE_DUPLICATE_DETECTION_SCOPE', 'SAME_SITE_ACTIVE_DAY', 'Same Site Active Day', 'Duplicate detection is scoped to the same site and active business day.', 'OPERATOR_CONSOLE', 'ACTIVE', 20, false, false, false, '2026-01-01T00:00:00Z'),
    ('OPERATOR_CONSOLE_DUPLICATE_DETECTION_SCOPE', 'SAME_SITE_GROUP_ACTIVE_DAY', 'Same Site Group Active Day', 'Duplicate detection is scoped to the same site group and active business day.', 'OPERATOR_CONSOLE', 'ACTIVE', 30, false, false, false, '2026-01-01T00:00:00Z'),
    ('OPERATOR_CONSOLE_DUPLICATE_DETECTION_SCOPE', 'GLOBAL_ACTIVE_DAY', 'Global Active Day', 'Duplicate detection is scoped globally for the active business day.', 'OPERATOR_CONSOLE', 'ACTIVE', 40, false, false, false, '2026-01-01T00:00:00Z'),
    ('OPERATOR_CONSOLE_DUPLICATE_DETECTION_SCOPE', 'CONFIGURED_POLICY_WINDOW', 'Configured Policy Window', 'Duplicate detection is scoped by configured statutory discount policy window.', 'OPERATOR_CONSOLE', 'ACTIVE', 50, false, false, false, '2026-01-01T00:00:00Z')
ON CONFLICT ON CONSTRAINT uq_controlled_code_sets__set_value_domain
DO UPDATE SET
    code_label = EXCLUDED.code_label,
    code_description = EXCLUDED.code_description,
    code_status = EXCLUDED.code_status,
    sort_order = EXCLUDED.sort_order,
    requires_comment = EXCLUDED.requires_comment,
    requires_approval = EXCLUDED.requires_approval,
    is_sensitive = EXCLUDED.is_sensitive,
    updated_at = now(),
    row_version = config.controlled_code_sets.row_version + 1;;

