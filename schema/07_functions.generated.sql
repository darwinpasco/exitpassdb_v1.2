-- ============================================================
-- 07A. Functions
-- Generated from ExitPass v1.2 DDL
-- ============================================================
CREATE OR REPLACE FUNCTION core.create_or_reuse_payment_attempt() RETURNS void LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'core.create_or_reuse_payment_attempt is a v1.2 routine placeholder and must be implemented before production use'; END; $$;

CREATE OR REPLACE FUNCTION core.record_payment_confirmation() RETURNS void LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'core.record_payment_confirmation is a v1.2 routine placeholder and must be implemented before production use'; END; $$;

CREATE OR REPLACE FUNCTION core.issue_exit_authorization() RETURNS void LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'core.issue_exit_authorization is a v1.2 routine placeholder and must be implemented before production use'; END; $$;

CREATE OR REPLACE FUNCTION gates.consume_exit_authorization() RETURNS void LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'gates.consume_exit_authorization is a v1.2 routine placeholder and must be implemented before production use'; END; $$;

CREATE OR REPLACE FUNCTION coupons.reserve_coupon_application() RETURNS void LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'coupons.reserve_coupon_application is a v1.2 routine placeholder and must be implemented before production use'; END; $$;

CREATE OR REPLACE FUNCTION coupons.commit_coupon_application() RETURNS void LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'coupons.commit_coupon_application is a v1.2 routine placeholder and must be implemented before production use'; END; $$;

CREATE OR REPLACE FUNCTION coupons.release_coupon_application() RETURNS void LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'coupons.release_coupon_application is a v1.2 routine placeholder and must be implemented before production use'; END; $$;

CREATE OR REPLACE FUNCTION discounts.record_statutory_discount_validation() RETURNS void LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'discounts.record_statutory_discount_validation is a v1.2 routine placeholder and must be implemented before production use'; END; $$;

CREATE OR REPLACE FUNCTION operations.record_manual_gate_log() RETURNS void LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'operations.record_manual_gate_log is a v1.2 routine placeholder and must be implemented before production use'; END; $$;

CREATE OR REPLACE FUNCTION reconciliation.import_mops_transaction_record() RETURNS void LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'reconciliation.import_mops_transaction_record is a v1.2 routine placeholder and must be implemented before production use'; END; $$;

CREATE OR REPLACE FUNCTION reconciliation.resolve_reconciliation_item() RETURNS void LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'reconciliation.resolve_reconciliation_item is a v1.2 routine placeholder and must be implemented before production use'; END; $$;

CREATE OR REPLACE FUNCTION events.enqueue_outbox_event() RETURNS void LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'events.enqueue_outbox_event is a v1.2 routine placeholder and must be implemented before production use'; END; $$;

