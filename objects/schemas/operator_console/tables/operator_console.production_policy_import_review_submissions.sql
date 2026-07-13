CREATE TABLE IF NOT EXISTS operator_console.production_policy_import_review_submissions (
    review_id uuid DEFAULT gen_random_uuid() NOT NULL,
    maker_operator_id uuid NOT NULL,
    file_name varchar(512),
    submission_fingerprint varchar(64) NOT NULL,
    review_status varchar(64) NOT NULL,
    dry_run_result_json jsonb NOT NULL,
    correlation_id uuid NOT NULL,
    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT pk_policy_import_review_submissions PRIMARY KEY (review_id),
    CONSTRAINT ck_policy_import_review_submissions__status
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
    CONSTRAINT ck_policy_import_review_submissions__fingerprint
        CHECK (submission_fingerprint ~ '^[0-9a-f]{64}$'),
    CONSTRAINT ck_policy_import_review_submissions__dry_run_only
        CHECK (
            COALESCE((dry_run_result_json ->> 'isDryRun')::boolean, false) = true
            AND COALESCE((dry_run_result_json ->> 'policiesImported')::boolean, true) = false
        ),
    CONSTRAINT ck_policy_import_review_submissions__row_version_positive
        CHECK (row_version > 0)
);;

