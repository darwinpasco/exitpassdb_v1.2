CREATE TABLE IF NOT EXISTS operator_console.operator_access_evaluation_reasons (
    operator_access_evaluation_reason_id uuid DEFAULT gen_random_uuid() NOT NULL,
    operator_access_evaluation_id uuid NOT NULL,
    reason_code varchar(96) NOT NULL,
    reason_message text,
    reason_source varchar(96),
    source_entity_type varchar(64),
    source_entity_id uuid,
    evaluated_fact_path varchar(256),
    display_order integer DEFAULT 0 NOT NULL,
    created_at timestamptz DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    CONSTRAINT pk_operator_access_evaluation_reasons PRIMARY KEY (operator_access_evaluation_reason_id),
    CONSTRAINT fk_operator_access_evaluation_reasons__evaluation_id FOREIGN KEY (operator_access_evaluation_id)
        REFERENCES operator_console.operator_access_evaluations(operator_access_evaluation_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_access_evaluation_reasons__created_by_user_id FOREIGN KEY (created_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_op_access_eval_reasons__created_svc_identity FOREIGN KEY (created_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT ck_op_access_eval_reasons__display_order_nonneg CHECK (display_order >= 0)
);;

