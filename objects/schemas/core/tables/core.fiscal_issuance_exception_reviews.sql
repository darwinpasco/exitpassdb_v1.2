CREATE TABLE IF NOT EXISTS core.fiscal_issuance_exception_reviews (
    fiscal_issuance_exception_review_id uuid DEFAULT gen_random_uuid() NOT NULL,
    fiscal_issuance_reference_id uuid,
    payment_confirmation_id uuid NOT NULL,
    current_exception_state varchar(80) NOT NULL,
    exception_reason_code varchar(120) NOT NULL,
    exception_category varchar(80) NOT NULL,
    review_status varchar(60) NOT NULL,
    assigned_reviewer_ref varchar(160),
    supervisor_escalation_required boolean DEFAULT false NOT NULL,
    manual_release_requested boolean DEFAULT false NOT NULL,
    manual_release_reference_id uuid,
    incident_reference varchar(160),
    reconciliation_status varchar(60),
    reconciliation_closed_at timestamptz,
    reconciliation_closed_by_ref varchar(160),
    latest_readback_status varchar(80),
    latest_mismatch_reason varchar(160),
    customer_impacting boolean DEFAULT false NOT NULL,
    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL,
    CONSTRAINT pk_fiscal_issuance_exception_reviews PRIMARY KEY (fiscal_issuance_exception_review_id)
);;

