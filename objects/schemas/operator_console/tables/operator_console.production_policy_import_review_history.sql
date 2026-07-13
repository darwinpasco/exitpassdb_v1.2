CREATE TABLE IF NOT EXISTS operator_console.production_policy_import_review_history (
    review_history_id uuid DEFAULT gen_random_uuid() NOT NULL,
    review_id uuid NOT NULL,
    history_fingerprint varchar(64) NOT NULL,
    decision_action varchar(64) NOT NULL,
    review_status varchar(64) NOT NULL,
    actor_operator_id uuid NOT NULL,
    reviewer_role varchar(32),
    reason text,
    occurred_at timestamptz DEFAULT now() NOT NULL,
    correlation_id uuid NOT NULL,
    created_at timestamptz DEFAULT now() NOT NULL,
    CONSTRAINT pk_policy_import_review_history PRIMARY KEY (review_history_id),
    CONSTRAINT fk_policy_import_review_history__review
        FOREIGN KEY (review_id)
        REFERENCES operator_console.production_policy_import_review_submissions(review_id)
        ON DELETE CASCADE,
    CONSTRAINT uq_policy_import_review_history__fingerprint
        UNIQUE (review_id, history_fingerprint),
    CONSTRAINT ck_policy_import_review_history__fingerprint
        CHECK (history_fingerprint ~ '^[0-9a-f]{64}$'),
    CONSTRAINT ck_policy_import_review_history__status
        CHECK (review_status IN (
            'DRAFT_DRY_RUN',
            'SUBMITTED_FOR_REVIEW',
            'LEGAL_REVIEW_PENDING',
            'OPS_REVIEW_PENDING',
            'QA_REVIEW_PENDING',
            'DB_REVIEW_PENDING',
            'APPROVED_FOR_DB_REPO_ALIGNMENT',
            'REJECTED',
            'CANCELLED',
            'SUPERSEDED'
        )),
    CONSTRAINT ck_policy_import_review_history__action
        CHECK (decision_action IN (
            'SUBMIT_FOR_REVIEW',
            'REQUEST_CHANGES',
            'APPROVE_LEGAL',
            'APPROVE_OPS',
            'APPROVE_QA',
            'APPROVE_DB',
            'REJECT',
            'ESCALATE',
            'CANCEL',
            'MARK_SUPERSEDED'
        )),
    CONSTRAINT ck_policy_import_review_history__role
        CHECK (reviewer_role IS NULL OR reviewer_role IN ('LEGAL', 'OPS', 'QA', 'DB')),
    CONSTRAINT ck_policy_import_review_history__reason
        CHECK (reason IS NULL OR btrim(reason) <> '')
);;

