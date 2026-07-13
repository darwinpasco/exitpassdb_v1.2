CREATE TABLE IF NOT EXISTS core.fiscal_issuance_readback_reconciliations (
    fiscal_issuance_readback_id uuid DEFAULT gen_random_uuid() NOT NULL,
    fiscal_issuance_reference_id uuid,
    payment_confirmation_id uuid NOT NULL,
    pos_server_fiscal_document_id uuid,
    readback_requested_at timestamptz DEFAULT now() NOT NULL,
    readback_completed_at timestamptz,
    readback_http_status integer,
    readback_result_code varchar(120),
    readback_fiscal_document_number varchar(120),
    readback_evidence_status varchar(80),
    readback_assignment_state varchar(40),
    comparison_result varchar(40) NOT NULL,
    mismatch_reason varchar(160),
    reconciliation_action varchar(120),
    reconciliation_closure_reference varchar(160),
    actor_service_identity_id uuid,
    CONSTRAINT pk_fiscal_issuance_readback_reconciliations PRIMARY KEY (fiscal_issuance_readback_id),
    CONSTRAINT ck_fiscal_issuance_readback_reconciliations__comparison_result CHECK (
        comparison_result IN ('MATCHED', 'MISMATCHED', 'INCONCLUSIVE', 'NOT_FOUND', 'SERVICE_FAILED')
    )
);;

