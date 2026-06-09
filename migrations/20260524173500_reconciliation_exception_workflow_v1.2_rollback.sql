-- ExitPass v1.2 Reconciliation Exception Workflow Schema Proposal Rollback
-- Proposal only. Do not apply to live databases without approval.

BEGIN;

DROP TABLE IF EXISTS reconciliation.reconciliation_exception_status_history;
DROP TABLE IF EXISTS reconciliation.reconciliation_exception_resolution_approvals;
DROP TABLE IF EXISTS reconciliation.reconciliation_exception_resolution_requests;
DROP TABLE IF EXISTS reconciliation.reconciliation_exception_notes;

DROP TYPE IF EXISTS reconciliation.reconciliation_financial_impact_enum;
DROP TYPE IF EXISTS reconciliation.reconciliation_resolution_approval_decision_enum;
DROP TYPE IF EXISTS reconciliation.reconciliation_resolution_request_status_enum;
DROP TYPE IF EXISTS reconciliation.reconciliation_resolution_action_enum;
DROP TYPE IF EXISTS reconciliation.reconciliation_exception_note_type_enum;

COMMIT;
