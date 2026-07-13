CREATE TABLE IF NOT EXISTS operator_console.production_policy_import_review_findings (
    review_finding_id uuid DEFAULT gen_random_uuid() NOT NULL,
    review_id uuid NOT NULL,
    finding_fingerprint varchar(64) NOT NULL,
    severity varchar(16) NOT NULL,
    message text NOT NULL,
    field_name varchar(128),
    created_at timestamptz DEFAULT now() NOT NULL,
    CONSTRAINT pk_policy_import_review_findings PRIMARY KEY (review_finding_id),
    CONSTRAINT fk_policy_import_review_findings__review
        FOREIGN KEY (review_id)
        REFERENCES operator_console.production_policy_import_review_submissions(review_id)
        ON DELETE CASCADE,
    CONSTRAINT uq_policy_import_review_findings__fingerprint
        UNIQUE (review_id, finding_fingerprint),
    CONSTRAINT ck_policy_import_review_findings__fingerprint
        CHECK (finding_fingerprint ~ '^[0-9a-f]{64}$'),
    CONSTRAINT ck_policy_import_review_findings__severity
        CHECK (severity IN ('PASS', 'WARN', 'FAIL')),
    CONSTRAINT ck_policy_import_review_findings__message
        CHECK (btrim(message) <> '')
);;

