CREATE TABLE IF NOT EXISTS operator_console.operator_access_evaluations (
    operator_access_evaluation_id uuid DEFAULT gen_random_uuid() NOT NULL,
    correlation_id uuid,
    requested_action varchar(96) NOT NULL,
    evaluation_status operator_console.access_evaluation_status_enum NOT NULL,
    operator_user_id uuid NOT NULL,
    hr_identity_mapping_id uuid,
    operator_device_binding_id uuid,
    operator_shift_id uuid,
    shift_takeover_id uuid,
    site_group_id uuid,
    site_id uuid,
    target_entity_type varchar(64),
    target_entity_id uuid,
    evaluated_at timestamptz NOT NULL,
    decision_snapshot_json jsonb,
    audit_event_id uuid,
    created_at timestamptz DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    CONSTRAINT pk_operator_access_evaluations PRIMARY KEY (operator_access_evaluation_id),
    CONSTRAINT fk_operator_access_evaluations__operator_user_id FOREIGN KEY (operator_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_access_evaluations__hr_identity_mapping_id FOREIGN KEY (hr_identity_mapping_id)
        REFERENCES operator_console.hr_identity_mappings(hr_identity_mapping_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_access_evaluations__operator_device_binding_id FOREIGN KEY (operator_device_binding_id)
        REFERENCES operator_console.operator_device_bindings(operator_device_binding_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_access_evaluations__operator_shift_id FOREIGN KEY (operator_shift_id)
        REFERENCES operator_console.operator_shifts(operator_shift_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_access_evaluations__shift_takeover_id FOREIGN KEY (shift_takeover_id)
        REFERENCES operator_console.shift_takeovers(shift_takeover_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_access_evaluations__site_group_id FOREIGN KEY (site_group_id)
        REFERENCES sites.site_groups(site_group_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_access_evaluations__site_id FOREIGN KEY (site_id)
        REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_access_evaluations__audit_event_id FOREIGN KEY (audit_event_id)
        REFERENCES audit.audit_events(audit_event_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_access_evaluations__created_by_user_id FOREIGN KEY (created_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_access_evaluations__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE
);;

