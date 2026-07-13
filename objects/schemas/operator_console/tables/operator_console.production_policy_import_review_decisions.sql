CREATE TABLE IF NOT EXISTS operator_console.production_policy_import_review_decisions (
    review_decision_id uuid DEFAULT gen_random_uuid() NOT NULL,
    review_id uuid NOT NULL,
    reviewer_role varchar(32) NOT NULL,
    decision_action varchar(64) NOT NULL,
    reviewer_operator_id uuid NOT NULL,
    reason text,
    decided_at timestamptz DEFAULT now() NOT NULL,
    correlation_id uuid NOT NULL,
    created_at timestamptz DEFAULT now() NOT NULL,
    CONSTRAINT pk_policy_import_review_decisions PRIMARY KEY (review_decision_id),
    CONSTRAINT fk_policy_import_review_decisions__review
        FOREIGN KEY (review_id)
        REFERENCES operator_console.production_policy_import_review_submissions(review_id)
        ON DELETE CASCADE,
    CONSTRAINT uq_policy_import_review_decisions__review_role
        UNIQUE (review_id, reviewer_role),
    CONSTRAINT ck_policy_import_review_decisions__role
        CHECK (reviewer_role IN ('LEGAL', 'OPS', 'QA', 'DB')),
    CONSTRAINT ck_policy_import_review_decisions__action
        CHECK (decision_action IN ('APPROVE_LEGAL', 'APPROVE_OPS', 'APPROVE_QA', 'APPROVE_DB')),
    CONSTRAINT ck_policy_import_review_decisions__reason
        CHECK (reason IS NULL OR btrim(reason) <> '')
);;

