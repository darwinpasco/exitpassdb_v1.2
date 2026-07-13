CREATE TABLE IF NOT EXISTS operator_console.operator_device_assignment_history (
    operator_device_assignment_history_id uuid DEFAULT gen_random_uuid() NOT NULL,
    operator_device_binding_id uuid NOT NULL,
    site_group_id uuid NOT NULL,
    site_id uuid NOT NULL,
    assignment_status_code varchar(64) NOT NULL,
    assignment_source_code varchar(64) NOT NULL,
    assignment_reason_code varchar(64),
    assigned_at timestamptz NOT NULL,
    assigned_by_user_id uuid,
    assigned_by_service_identity_id uuid,
    effective_from timestamptz NOT NULL,
    effective_to timestamptz,
    ended_at timestamptz,
    ended_by_user_id uuid,
    ended_by_service_identity_id uuid,
    end_reason_code varchar(64),
    correlation_id uuid,
    created_at timestamptz DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    CONSTRAINT pk_operator_device_assignment_history PRIMARY KEY (operator_device_assignment_history_id),
    CONSTRAINT fk_operator_device_assignment_history__binding_id FOREIGN KEY (operator_device_binding_id)
        REFERENCES operator_console.operator_device_bindings(operator_device_binding_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_device_assignment_history__site_group_id FOREIGN KEY (site_group_id)
        REFERENCES sites.site_groups(site_group_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_device_assignment_history__site_id FOREIGN KEY (site_id)
        REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_device_assignment_history__assigned_by_user_id FOREIGN KEY (assigned_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_op_dev_assign_hist__assigned_svc_identity FOREIGN KEY (assigned_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_device_assignment_history__ended_by_user_id FOREIGN KEY (ended_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_op_dev_assign_hist__ended_svc_identity FOREIGN KEY (ended_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_device_assignment_history__created_by_user_id FOREIGN KEY (created_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_op_dev_assign_hist__created_svc_identity FOREIGN KEY (created_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT ck_operator_device_assignment_history__effective_window CHECK (effective_to IS NULL OR effective_to > effective_from)
);;

