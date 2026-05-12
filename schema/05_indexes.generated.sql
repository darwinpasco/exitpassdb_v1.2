-- ============================================================
-- 05. Indexes
-- Generated from ExitPass v1.2 DDL
-- ============================================================
CREATE UNIQUE INDEX IF NOT EXISTS ux_tariff_snapshots__active_by_session
ON core.tariff_snapshots (parking_session_id)
WHERE snapshot_status = 'ACTIVE';

CREATE UNIQUE INDEX IF NOT EXISTS ux_tariff_snapshots__superseded_by
ON core.tariff_snapshots (superseded_by_tariff_snapshot_id)
WHERE superseded_by_tariff_snapshot_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_payment_attempts__active_by_session
ON core.payment_attempts (parking_session_id)
WHERE attempt_status IN ('REQUESTED', 'PENDING_PROVIDER', 'PENDING_FINALIZATION');

CREATE UNIQUE INDEX IF NOT EXISTS ux_payment_confirmations__provider_transaction_ref
ON core.payment_confirmations (payment_rail_id, provider_transaction_ref)
WHERE provider_transaction_ref IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_payment_confirmations__provider_outcome
ON core.payment_confirmations (provider_outcome_id)
WHERE provider_outcome_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_exit_authorizations__active_by_session
ON core.exit_authorizations (parking_session_id)
WHERE authorization_status = 'ISSUED';

CREATE UNIQUE INDEX IF NOT EXISTS ux_provider_sessions__provider_ref
ON payments.provider_sessions (payment_rail_id, provider_session_ref)
WHERE provider_session_ref IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_provider_sessions__active_by_attempt_rail
ON payments.provider_sessions (payment_attempt_id, payment_rail_id)
WHERE session_status IN ('CREATED', 'ACTIVE', 'PENDING');

CREATE UNIQUE INDEX IF NOT EXISTS ux_provider_callbacks__provider_event
ON payments.provider_callbacks (payment_rail_id, provider_event_ref)
WHERE provider_event_ref IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_provider_outcomes__provider_transaction_ref
ON payments.provider_outcomes (payment_rail_id, provider_transaction_ref)
WHERE provider_transaction_ref IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_provider_outcomes__provider_callback
ON payments.provider_outcomes (provider_callback_id)
WHERE provider_callback_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_provider_outcomes__provider_status_query
ON payments.provider_outcomes (provider_status_query_id)
WHERE provider_status_query_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_session_resolution_requests__idempotency_key
ON sessions.session_resolution_requests (idempotency_key)
WHERE idempotency_key IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_session_lookup_cache__active_scope_without_site
ON sessions.session_lookup_cache (site_group_id, lookup_type, lookup_identifier_hash)
WHERE cache_status = 'ACTIVE' AND site_id IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_session_lookup_cache__active_scope_with_site
ON sessions.session_lookup_cache (site_group_id, site_id, lookup_type, lookup_identifier_hash)
WHERE cache_status = 'ACTIVE' AND site_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_session_identifier_indexes__active_scope_without_site
ON sessions.session_identifier_indexes (site_group_id, identifier_type, identifier_hash)
WHERE identifier_status = 'ACTIVE' AND site_id IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_session_identifier_indexes__active_scope_with_site
ON sessions.session_identifier_indexes (site_group_id, site_id, identifier_type, identifier_hash)
WHERE identifier_status = 'ACTIVE' AND site_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_coupon_applications__active_merchant_session
ON coupons.coupon_applications (merchant_id, parking_session_id)
WHERE application_status IN ('REQUESTED', 'RESERVED', 'APPLIED');

CREATE UNIQUE INDEX IF NOT EXISTS ux_coupon_applications__reservation_ref
ON coupons.coupon_applications (reservation_ref)
WHERE reservation_ref IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_discount_policy_references__active_local_policy
ON discounts.discount_policy_references (entitlement_type, lgu_code, site_group_id, site_id, policy_level, policy_version)
WHERE policy_status = 'ACTIVE' AND lgu_code IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_statutory_discount_validations__active_session_entitlement
ON discounts.statutory_discount_validations (parking_session_id, entitlement_type)
WHERE validation_status IN ('REQUESTED', 'PENDING_OPERATOR_REVIEW', 'APPROVED');

CREATE UNIQUE INDEX IF NOT EXISTS ux_discount_evidence_references__evidence_hash
ON discounts.discount_evidence_references (evidence_hash)
WHERE evidence_hash IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_gate_devices__service_identity
ON gates.gate_devices (service_identity_id)
WHERE service_identity_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_gate_devices__serial_number
ON gates.gate_devices (serial_number)
WHERE serial_number IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_gate_devices__vendor_device_ref
ON gates.gate_devices (site_id, vendor_device_ref)
WHERE vendor_device_ref IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_gate_auth_consumptions__successful_exit_auth
ON gates.gate_authorization_consumptions (exit_authorization_id)
WHERE consume_status = 'CONSUMED';

CREATE UNIQUE INDEX IF NOT EXISTS ux_mops_transaction_records__source_transaction_ref
ON reconciliation.mops_transaction_records (source_system_code, source_transaction_ref)
WHERE source_transaction_ref IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_mops_transaction_records__source_batch_collection
ON reconciliation.mops_transaction_records (source_system_code, source_batch_ref, collection_reference)
WHERE source_batch_ref IS NOT NULL AND collection_reference IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_device_assignments__active_gate_device
ON sites.device_assignments (gate_device_id)
WHERE assignment_status = 'ACTIVE' AND gate_device_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_device_assignments__active_service_identity
ON sites.device_assignments (service_identity_id)
WHERE assignment_status = 'ACTIVE' AND service_identity_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_device_assignments__active_lane_assignment_type
ON sites.device_assignments (site_id, lane_id, assignment_type)
WHERE assignment_status = 'ACTIVE' AND lane_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_merchant_site_scopes__active_site_group_scope
ON merchants.merchant_site_scopes (merchant_id, site_group_id, scope_type)
WHERE scope_status = 'ACTIVE' AND site_group_id IS NOT NULL AND site_id IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_merchant_site_scopes__active_site_scope
ON merchants.merchant_site_scopes (merchant_id, site_id, scope_type)
WHERE scope_status = 'ACTIVE' AND site_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_merchant_wallets__active_currency_type
ON merchants.merchant_wallets (merchant_id, currency_code, wallet_type)
WHERE wallet_status = 'ACTIVE';

CREATE UNIQUE INDEX IF NOT EXISTS ux_merchant_users__active_user_merchant
ON merchants.merchant_users (merchant_id, user_id)
WHERE merchant_user_status = 'ACTIVE';

CREATE UNIQUE INDEX IF NOT EXISTS ux_user_roles__active_user_role
ON identity.user_roles (user_id, role_id)
WHERE assignment_status = 'ACTIVE';

CREATE UNIQUE INDEX IF NOT EXISTS ux_role_permissions__active_role_permission
ON identity.role_permissions (role_id, permission_id)
WHERE binding_status = 'ACTIVE';

CREATE UNIQUE INDEX IF NOT EXISTS ux_adapter_mappings__vendor_object_active
ON integration.adapter_mappings (vendor_system_id, mapping_type, vendor_object_type, vendor_object_ref)
WHERE mapping_status = 'ACTIVE';

CREATE UNIQUE INDEX IF NOT EXISTS ux_feature_flags__scoped_flag
ON config.feature_flags (
    flag_code,
    environment_code,
    COALESCE(site_group_id, '00000000-0000-0000-0000-000000000000'::uuid),
    COALESCE(site_id, '00000000-0000-0000-0000-000000000000'::uuid),
    COALESCE(merchant_id, '00000000-0000-0000-0000-000000000000'::uuid),
    COALESCE(payment_rail_id, '00000000-0000-0000-0000-000000000000'::uuid),
    COALESCE(service_identity_id, '00000000-0000-0000-0000-000000000000'::uuid)
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_outbox_events__domain_event
ON events.outbox_events (domain_event_id)
WHERE domain_event_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_consumer_checkpoints__consumer_scope
ON events.consumer_checkpoints (
    consumer_name,
    COALESCE(consumer_group, ''),
    COALESCE(subscription_name, ''),
    COALESCE(event_type, ''),
    COALESCE(aggregate_type, '')
);

CREATE INDEX IF NOT EXISTS ix_parking_sessions__site_group_id ON core.parking_sessions (site_group_id);

CREATE INDEX IF NOT EXISTS ix_parking_sessions__site_id ON core.parking_sessions (site_id);

CREATE INDEX IF NOT EXISTS ix_parking_sessions__vendor_system_id ON core.parking_sessions (vendor_system_id);

CREATE INDEX IF NOT EXISTS ix_parking_sessions__vendor_session_status ON core.parking_sessions (vendor_session_status);

CREATE INDEX IF NOT EXISTS ix_parking_sessions__correlation_id ON core.parking_sessions (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_tariff_snapshots__parking_session_id ON core.tariff_snapshots (parking_session_id);

CREATE INDEX IF NOT EXISTS ix_tariff_snapshots__superseded_by_tariff_snapshot_id ON core.tariff_snapshots (superseded_by_tariff_snapshot_id);

CREATE INDEX IF NOT EXISTS ix_tariff_snapshots__vendor_system_id ON core.tariff_snapshots (vendor_system_id);

CREATE INDEX IF NOT EXISTS ix_tariff_snapshots__statutory_discount_validation_id ON core.tariff_snapshots (statutory_discount_validation_id);

CREATE INDEX IF NOT EXISTS ix_tariff_snapshots__correlation_id ON core.tariff_snapshots (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_payment_attempts__parking_session_id ON core.payment_attempts (parking_session_id);

CREATE INDEX IF NOT EXISTS ix_payment_attempts__tariff_snapshot_id ON core.payment_attempts (tariff_snapshot_id);

CREATE INDEX IF NOT EXISTS ix_payment_attempts__payment_rail_id ON core.payment_attempts (payment_rail_id);

CREATE INDEX IF NOT EXISTS ix_payment_attempts__attempt_status ON core.payment_attempts (attempt_status);

CREATE INDEX IF NOT EXISTS ix_payment_attempts__correlation_id ON core.payment_attempts (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_payment_confirmations__payment_attempt_id ON core.payment_confirmations (payment_attempt_id);

CREATE INDEX IF NOT EXISTS ix_payment_confirmations__provider_outcome_id ON core.payment_confirmations (provider_outcome_id);

CREATE INDEX IF NOT EXISTS ix_payment_confirmations__payment_rail_id ON core.payment_confirmations (payment_rail_id);

CREATE INDEX IF NOT EXISTS ix_payment_confirmations__confirmation_status ON core.payment_confirmations (confirmation_status);

CREATE INDEX IF NOT EXISTS ix_payment_confirmations__correlation_id ON core.payment_confirmations (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_exit_authorizations__parking_session_id ON core.exit_authorizations (parking_session_id);

CREATE INDEX IF NOT EXISTS ix_exit_authorizations__payment_attempt_id ON core.exit_authorizations (payment_attempt_id);

CREATE INDEX IF NOT EXISTS ix_exit_authorizations__payment_confirmation_id ON core.exit_authorizations (payment_confirmation_id);

CREATE INDEX IF NOT EXISTS ix_exit_authorizations__authorization_status ON core.exit_authorizations (authorization_status);

CREATE INDEX IF NOT EXISTS ix_exit_authorizations__correlation_id ON core.exit_authorizations (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_payment_rails__rail_status ON payments.payment_rails (rail_status);

CREATE INDEX IF NOT EXISTS ix_provider_sessions__payment_attempt_id ON payments.provider_sessions (payment_attempt_id);

CREATE INDEX IF NOT EXISTS ix_provider_sessions__payment_rail_id ON payments.provider_sessions (payment_rail_id);

CREATE INDEX IF NOT EXISTS ix_provider_sessions__session_status ON payments.provider_sessions (session_status);

CREATE INDEX IF NOT EXISTS ix_provider_sessions__expires_at ON payments.provider_sessions (expires_at);

CREATE INDEX IF NOT EXISTS ix_provider_sessions__correlation_id ON payments.provider_sessions (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_provider_callbacks__payment_rail_id ON payments.provider_callbacks (payment_rail_id);

CREATE INDEX IF NOT EXISTS ix_provider_callbacks__provider_session_id ON payments.provider_callbacks (provider_session_id);

CREATE INDEX IF NOT EXISTS ix_provider_callbacks__payment_attempt_id ON payments.provider_callbacks (payment_attempt_id);

CREATE INDEX IF NOT EXISTS ix_provider_callbacks__verification_status ON payments.provider_callbacks (verification_status);

CREATE INDEX IF NOT EXISTS ix_provider_callbacks__processing_status ON payments.provider_callbacks (processing_status);

CREATE INDEX IF NOT EXISTS ix_provider_callbacks__received_at ON payments.provider_callbacks (received_at);

CREATE INDEX IF NOT EXISTS ix_provider_callbacks__correlation_id ON payments.provider_callbacks (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_provider_status_queries__payment_attempt_id ON payments.provider_status_queries (payment_attempt_id);

CREATE INDEX IF NOT EXISTS ix_provider_status_queries__provider_session_id ON payments.provider_status_queries (provider_session_id);

CREATE INDEX IF NOT EXISTS ix_provider_status_queries__payment_rail_id ON payments.provider_status_queries (payment_rail_id);

CREATE INDEX IF NOT EXISTS ix_provider_status_queries__query_status ON payments.provider_status_queries (query_status);

CREATE INDEX IF NOT EXISTS ix_provider_status_queries__correlation_id ON payments.provider_status_queries (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_provider_outcomes__payment_attempt_id ON payments.provider_outcomes (payment_attempt_id);

CREATE INDEX IF NOT EXISTS ix_provider_outcomes__provider_session_id ON payments.provider_outcomes (provider_session_id);

CREATE INDEX IF NOT EXISTS ix_provider_outcomes__provider_callback_id ON payments.provider_outcomes (provider_callback_id);

CREATE INDEX IF NOT EXISTS ix_provider_outcomes__payment_rail_id ON payments.provider_outcomes (payment_rail_id);

CREATE INDEX IF NOT EXISTS ix_provider_outcomes__correlation_id ON payments.provider_outcomes (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_session_resolution_requests__site_group_id ON sessions.session_resolution_requests (site_group_id);

CREATE INDEX IF NOT EXISTS ix_session_resolution_requests__site_id ON sessions.session_resolution_requests (site_id);

CREATE INDEX IF NOT EXISTS ix_session_resolution_requests__request_status ON sessions.session_resolution_requests (request_status);

CREATE INDEX IF NOT EXISTS ix_session_resolution_requests__requested_at ON sessions.session_resolution_requests (requested_at);

CREATE INDEX IF NOT EXISTS ix_session_resolution_requests__correlation_id ON sessions.session_resolution_requests (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_session_resolution_results__session_resolution_request_id ON sessions.session_resolution_results (session_resolution_request_id);

CREATE INDEX IF NOT EXISTS ix_session_resolution_results__parking_session_id ON sessions.session_resolution_results (parking_session_id);

CREATE INDEX IF NOT EXISTS ix_session_resolution_results__site_group_id ON sessions.session_resolution_results (site_group_id);

CREATE INDEX IF NOT EXISTS ix_session_resolution_results__site_id ON sessions.session_resolution_results (site_id);

CREATE INDEX IF NOT EXISTS ix_session_resolution_results__correlation_id ON sessions.session_resolution_results (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_session_lookup_cache__site_group_id ON sessions.session_lookup_cache (site_group_id);

CREATE INDEX IF NOT EXISTS ix_session_lookup_cache__site_id ON sessions.session_lookup_cache (site_id);

CREATE INDEX IF NOT EXISTS ix_session_lookup_cache__parking_session_id ON sessions.session_lookup_cache (parking_session_id);

CREATE INDEX IF NOT EXISTS ix_session_lookup_cache__vendor_system_id ON sessions.session_lookup_cache (vendor_system_id);

CREATE INDEX IF NOT EXISTS ix_session_lookup_cache__correlation_id ON sessions.session_lookup_cache (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_session_identifier_indexes__parking_session_id ON sessions.session_identifier_indexes (parking_session_id);

CREATE INDEX IF NOT EXISTS ix_session_identifier_indexes__site_group_id ON sessions.session_identifier_indexes (site_group_id);

CREATE INDEX IF NOT EXISTS ix_session_identifier_indexes__site_id ON sessions.session_identifier_indexes (site_id);

CREATE INDEX IF NOT EXISTS ix_session_identifier_indexes__vendor_system_id ON sessions.session_identifier_indexes (vendor_system_id);

CREATE INDEX IF NOT EXISTS ix_session_identifier_indexes__correlation_id ON sessions.session_identifier_indexes (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_coupons__merchant_id ON coupons.coupons (merchant_id);

CREATE INDEX IF NOT EXISTS ix_coupons__coupon_status ON coupons.coupons (coupon_status);

CREATE INDEX IF NOT EXISTS ix_coupon_rule_groups__coupon_id ON coupons.coupon_rule_groups (coupon_id);

CREATE INDEX IF NOT EXISTS ix_coupon_rule_groups__rule_group_status ON coupons.coupon_rule_groups (rule_group_status);

CREATE INDEX IF NOT EXISTS ix_coupon_rules__coupon_rule_group_id ON coupons.coupon_rules (coupon_rule_group_id);

CREATE INDEX IF NOT EXISTS ix_coupon_rules__site_group_id ON coupons.coupon_rules (site_group_id);

CREATE INDEX IF NOT EXISTS ix_coupon_rules__site_id ON coupons.coupon_rules (site_id);

CREATE INDEX IF NOT EXISTS ix_coupon_applications__coupon_id ON coupons.coupon_applications (coupon_id);

CREATE INDEX IF NOT EXISTS ix_coupon_applications__merchant_id ON coupons.coupon_applications (merchant_id);

CREATE INDEX IF NOT EXISTS ix_coupon_applications__merchant_wallet_id ON coupons.coupon_applications (merchant_wallet_id);

CREATE INDEX IF NOT EXISTS ix_coupon_applications__parking_session_id ON coupons.coupon_applications (parking_session_id);

CREATE INDEX IF NOT EXISTS ix_coupon_applications__correlation_id ON coupons.coupon_applications (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_discount_policy_references__site_group_id ON discounts.discount_policy_references (site_group_id);

CREATE INDEX IF NOT EXISTS ix_discount_policy_references__site_id ON discounts.discount_policy_references (site_id);

CREATE INDEX IF NOT EXISTS ix_discount_policy_references__parent_policy_reference_id ON discounts.discount_policy_references (parent_policy_reference_id);

CREATE INDEX IF NOT EXISTS ix_statutory_discount_validations__parking_session_id ON discounts.statutory_discount_validations (parking_session_id);

CREATE INDEX IF NOT EXISTS ix_statutory_discount_validations__tariff_snapshot_id ON discounts.statutory_discount_validations (tariff_snapshot_id);

CREATE INDEX IF NOT EXISTS ix_statutory_discount_validations__applied_policy_reference_ ON discounts.statutory_discount_validations (applied_policy_reference_id);

CREATE INDEX IF NOT EXISTS ix_statutory_discount_validations__fallback_policy_reference ON discounts.statutory_discount_validations (fallback_policy_reference_id);

CREATE INDEX IF NOT EXISTS ix_statutory_discount_validations__correlation_id ON discounts.statutory_discount_validations (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_discount_evidence_references__statutory_discount_validati ON discounts.discount_evidence_references (statutory_discount_validation_id);

CREATE INDEX IF NOT EXISTS ix_discount_evidence_references__evidence_capture_status ON discounts.discount_evidence_references (evidence_capture_status);

CREATE INDEX IF NOT EXISTS ix_discount_evidence_references__redaction_status ON discounts.discount_evidence_references (redaction_status);

CREATE INDEX IF NOT EXISTS ix_discount_evidence_references__retention_expires_at ON discounts.discount_evidence_references (retention_expires_at);

CREATE INDEX IF NOT EXISTS ix_discount_evidence_references__correlation_id ON discounts.discount_evidence_references (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_gate_devices__site_id ON gates.gate_devices (site_id);

CREATE INDEX IF NOT EXISTS ix_gate_devices__lane_id ON gates.gate_devices (lane_id);

CREATE INDEX IF NOT EXISTS ix_gate_devices__service_identity_id ON gates.gate_devices (service_identity_id);

CREATE INDEX IF NOT EXISTS ix_gate_authorization_consumptions__exit_authorization_id ON gates.gate_authorization_consumptions (exit_authorization_id);

CREATE INDEX IF NOT EXISTS ix_gate_authorization_consumptions__gate_device_id ON gates.gate_authorization_consumptions (gate_device_id);

CREATE INDEX IF NOT EXISTS ix_gate_authorization_consumptions__site_id ON gates.gate_authorization_consumptions (site_id);

CREATE INDEX IF NOT EXISTS ix_gate_authorization_consumptions__lane_id ON gates.gate_authorization_consumptions (lane_id);

CREATE INDEX IF NOT EXISTS ix_gate_authorization_consumptions__consume_status ON gates.gate_authorization_consumptions (consume_status);

CREATE INDEX IF NOT EXISTS ix_gate_authorization_consumptions__command_result_status ON gates.gate_authorization_consumptions (command_result_status);

CREATE INDEX IF NOT EXISTS ix_gate_authorization_consumptions__correlation_id ON gates.gate_authorization_consumptions (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_gate_events__gate_device_id ON gates.gate_events (gate_device_id);

CREATE INDEX IF NOT EXISTS ix_gate_events__exit_authorization_id ON gates.gate_events (exit_authorization_id);

CREATE INDEX IF NOT EXISTS ix_gate_events__site_id ON gates.gate_events (site_id);

CREATE INDEX IF NOT EXISTS ix_gate_events__lane_id ON gates.gate_events (lane_id);

CREATE INDEX IF NOT EXISTS ix_gate_events__event_status ON gates.gate_events (event_status);

CREATE INDEX IF NOT EXISTS ix_gate_events__occurred_at ON gates.gate_events (occurred_at);

CREATE INDEX IF NOT EXISTS ix_gate_events__correlation_id ON gates.gate_events (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_gate_heartbeats__gate_device_id ON gates.gate_heartbeats (gate_device_id);

CREATE INDEX IF NOT EXISTS ix_gate_heartbeats__site_id ON gates.gate_heartbeats (site_id);

CREATE INDEX IF NOT EXISTS ix_gate_heartbeats__lane_id ON gates.gate_heartbeats (lane_id);

CREATE INDEX IF NOT EXISTS ix_gate_heartbeats__heartbeat_status ON gates.gate_heartbeats (heartbeat_status);

CREATE INDEX IF NOT EXISTS ix_gate_heartbeats__device_reported_status ON gates.gate_heartbeats (device_reported_status);

CREATE INDEX IF NOT EXISTS ix_gate_heartbeats__observed_at ON gates.gate_heartbeats (observed_at);

CREATE INDEX IF NOT EXISTS ix_gate_heartbeats__correlation_id ON gates.gate_heartbeats (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_manual_gate_logs__parking_session_id ON operations.manual_gate_logs (parking_session_id);

CREATE INDEX IF NOT EXISTS ix_manual_gate_logs__exit_authorization_id ON operations.manual_gate_logs (exit_authorization_id);

CREATE INDEX IF NOT EXISTS ix_manual_gate_logs__incident_record_id ON operations.manual_gate_logs (incident_record_id);

CREATE INDEX IF NOT EXISTS ix_manual_gate_logs__override_approval_id ON operations.manual_gate_logs (override_approval_id);

CREATE INDEX IF NOT EXISTS ix_manual_gate_logs__site_id ON operations.manual_gate_logs (site_id);

CREATE INDEX IF NOT EXISTS ix_manual_gate_logs__lane_id ON operations.manual_gate_logs (lane_id);

CREATE INDEX IF NOT EXISTS ix_manual_gate_logs__correlation_id ON operations.manual_gate_logs (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_override_requests__incident_record_id ON operations.override_requests (incident_record_id);

CREATE INDEX IF NOT EXISTS ix_override_requests__site_id ON operations.override_requests (site_id);

CREATE INDEX IF NOT EXISTS ix_override_requests__lane_id ON operations.override_requests (lane_id);

CREATE INDEX IF NOT EXISTS ix_override_requests__requested_by_user_id ON operations.override_requests (requested_by_user_id);

CREATE INDEX IF NOT EXISTS ix_override_requests__correlation_id ON operations.override_requests (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_override_approvals__override_request_id ON operations.override_approvals (override_request_id);

CREATE INDEX IF NOT EXISTS ix_override_approvals__decided_by_user_id ON operations.override_approvals (decided_by_user_id);

CREATE INDEX IF NOT EXISTS ix_override_approvals__correlation_id ON operations.override_approvals (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_incident_records__site_group_id ON operations.incident_records (site_group_id);

CREATE INDEX IF NOT EXISTS ix_incident_records__site_id ON operations.incident_records (site_id);

CREATE INDEX IF NOT EXISTS ix_incident_records__lane_id ON operations.incident_records (lane_id);

CREATE INDEX IF NOT EXISTS ix_incident_records__gate_device_id ON operations.incident_records (gate_device_id);

CREATE INDEX IF NOT EXISTS ix_incident_records__correlation_id ON operations.incident_records (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_operator_action_logs__operator_user_id ON operations.operator_action_logs (operator_user_id);

CREATE INDEX IF NOT EXISTS ix_operator_action_logs__site_id ON operations.operator_action_logs (site_id);

CREATE INDEX IF NOT EXISTS ix_operator_action_logs__correlation_id ON operations.operator_action_logs (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_mops_transaction_records__parking_session_id ON reconciliation.mops_transaction_records (parking_session_id);

CREATE INDEX IF NOT EXISTS ix_mops_transaction_records__manual_gate_log_id ON reconciliation.mops_transaction_records (manual_gate_log_id);

CREATE INDEX IF NOT EXISTS ix_mops_transaction_records__incident_record_id ON reconciliation.mops_transaction_records (incident_record_id);

CREATE INDEX IF NOT EXISTS ix_mops_transaction_records__site_id ON reconciliation.mops_transaction_records (site_id);

CREATE INDEX IF NOT EXISTS ix_mops_transaction_records__lane_id ON reconciliation.mops_transaction_records (lane_id);

CREATE INDEX IF NOT EXISTS ix_mops_transaction_records__imported_by_service_identity_id ON reconciliation.mops_transaction_records (imported_by_service_identity_id);

CREATE INDEX IF NOT EXISTS ix_mops_transaction_records__correlation_id ON reconciliation.mops_transaction_records (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_reconciliation_runs__site_group_id ON reconciliation.reconciliation_runs (site_group_id);

CREATE INDEX IF NOT EXISTS ix_reconciliation_runs__site_id ON reconciliation.reconciliation_runs (site_id);

CREATE INDEX IF NOT EXISTS ix_reconciliation_runs__incident_record_id ON reconciliation.reconciliation_runs (incident_record_id);

CREATE INDEX IF NOT EXISTS ix_reconciliation_runs__payment_rail_id ON reconciliation.reconciliation_runs (payment_rail_id);

CREATE INDEX IF NOT EXISTS ix_reconciliation_runs__correlation_id ON reconciliation.reconciliation_runs (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_reconciliation_items__reconciliation_run_id ON reconciliation.reconciliation_items (reconciliation_run_id);

CREATE INDEX IF NOT EXISTS ix_reconciliation_items__mops_transaction_record_id ON reconciliation.reconciliation_items (mops_transaction_record_id);

CREATE INDEX IF NOT EXISTS ix_reconciliation_items__manual_gate_log_id ON reconciliation.reconciliation_items (manual_gate_log_id);

CREATE INDEX IF NOT EXISTS ix_reconciliation_items__payment_attempt_id ON reconciliation.reconciliation_items (payment_attempt_id);

CREATE INDEX IF NOT EXISTS ix_reconciliation_items__payment_confirmation_id ON reconciliation.reconciliation_items (payment_confirmation_id);

CREATE INDEX IF NOT EXISTS ix_reconciliation_items__provider_outcome_id ON reconciliation.reconciliation_items (provider_outcome_id);

CREATE INDEX IF NOT EXISTS ix_reconciliation_items__correlation_id ON reconciliation.reconciliation_items (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_reconciliation_exceptions__reconciliation_run_id ON reconciliation.reconciliation_exceptions (reconciliation_run_id);

CREATE INDEX IF NOT EXISTS ix_reconciliation_exceptions__reconciliation_item_id ON reconciliation.reconciliation_exceptions (reconciliation_item_id);

CREATE INDEX IF NOT EXISTS ix_reconciliation_exceptions__incident_record_id ON reconciliation.reconciliation_exceptions (incident_record_id);

CREATE INDEX IF NOT EXISTS ix_reconciliation_exceptions__assigned_to_user_id ON reconciliation.reconciliation_exceptions (assigned_to_user_id);

CREATE INDEX IF NOT EXISTS ix_reconciliation_exceptions__correlation_id ON reconciliation.reconciliation_exceptions (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_settlement_comparison_records__reconciliation_item_id ON reconciliation.settlement_comparison_records (reconciliation_item_id);

CREATE INDEX IF NOT EXISTS ix_settlement_comparison_records__mops_transaction_record_id ON reconciliation.settlement_comparison_records (mops_transaction_record_id);

CREATE INDEX IF NOT EXISTS ix_settlement_comparison_records__reconciliation_exception_i ON reconciliation.settlement_comparison_records (reconciliation_exception_id);

CREATE INDEX IF NOT EXISTS ix_settlement_comparison_records__payment_confirmation_id ON reconciliation.settlement_comparison_records (payment_confirmation_id);

CREATE INDEX IF NOT EXISTS ix_settlement_comparison_records__correlation_id ON reconciliation.settlement_comparison_records (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_site_groups__site_group_status ON sites.site_groups (site_group_status);

CREATE INDEX IF NOT EXISTS ix_sites__site_group_id ON sites.sites (site_group_id);

CREATE INDEX IF NOT EXISTS ix_sites__site_status ON sites.sites (site_status);

CREATE INDEX IF NOT EXISTS ix_lanes__site_id ON sites.lanes (site_id);

CREATE INDEX IF NOT EXISTS ix_lanes__lane_status ON sites.lanes (lane_status);

CREATE INDEX IF NOT EXISTS ix_device_assignments__site_id ON sites.device_assignments (site_id);

CREATE INDEX IF NOT EXISTS ix_device_assignments__lane_id ON sites.device_assignments (lane_id);

CREATE INDEX IF NOT EXISTS ix_device_assignments__gate_device_id ON sites.device_assignments (gate_device_id);

CREATE INDEX IF NOT EXISTS ix_merchants__merchant_status ON merchants.merchants (merchant_status);

CREATE INDEX IF NOT EXISTS ix_merchant_site_scopes__merchant_id ON merchants.merchant_site_scopes (merchant_id);

CREATE INDEX IF NOT EXISTS ix_merchant_site_scopes__site_group_id ON merchants.merchant_site_scopes (site_group_id);

CREATE INDEX IF NOT EXISTS ix_merchant_site_scopes__site_id ON merchants.merchant_site_scopes (site_id);

CREATE INDEX IF NOT EXISTS ix_merchant_wallets__merchant_id ON merchants.merchant_wallets (merchant_id);

CREATE INDEX IF NOT EXISTS ix_merchant_wallets__wallet_status ON merchants.merchant_wallets (wallet_status);

CREATE INDEX IF NOT EXISTS ix_merchant_users__merchant_id ON merchants.merchant_users (merchant_id);

CREATE INDEX IF NOT EXISTS ix_merchant_users__user_id ON merchants.merchant_users (user_id);

CREATE INDEX IF NOT EXISTS ix_merchant_users__merchant_user_status ON merchants.merchant_users (merchant_user_status);

CREATE INDEX IF NOT EXISTS ix_users__user_status ON identity.users (user_status);

CREATE INDEX IF NOT EXISTS ix_users__last_login_at ON identity.users (last_login_at);

CREATE INDEX IF NOT EXISTS ix_users__locked_at ON identity.users (locked_at);

CREATE INDEX IF NOT EXISTS ix_roles__role_status ON identity.roles (role_status);

CREATE INDEX IF NOT EXISTS ix_permissions__permission_status ON identity.permissions (permission_status);

CREATE INDEX IF NOT EXISTS ix_user_roles__user_id ON identity.user_roles (user_id);

CREATE INDEX IF NOT EXISTS ix_user_roles__role_id ON identity.user_roles (role_id);

CREATE INDEX IF NOT EXISTS ix_user_roles__assigned_by_user_id ON identity.user_roles (assigned_by_user_id);

CREATE INDEX IF NOT EXISTS ix_role_permissions__role_id ON identity.role_permissions (role_id);

CREATE INDEX IF NOT EXISTS ix_role_permissions__permission_id ON identity.role_permissions (permission_id);

CREATE INDEX IF NOT EXISTS ix_role_permissions__assigned_by_user_id ON identity.role_permissions (assigned_by_user_id);

CREATE INDEX IF NOT EXISTS ix_service_identities__identity_status ON identity.service_identities (identity_status);

CREATE INDEX IF NOT EXISTS ix_service_identities__credential_expires_at ON identity.service_identities (credential_expires_at);

CREATE INDEX IF NOT EXISTS ix_service_identities__last_rotated_at ON identity.service_identities (last_rotated_at);

CREATE INDEX IF NOT EXISTS ix_audit_events__actor_user_id ON audit.audit_events (actor_user_id);

CREATE INDEX IF NOT EXISTS ix_audit_events__actor_service_identity_id ON audit.audit_events (actor_service_identity_id);

CREATE INDEX IF NOT EXISTS ix_audit_events__created_by_service_identity_id ON audit.audit_events (created_by_service_identity_id);

CREATE INDEX IF NOT EXISTS ix_audit_events__occurred_at ON audit.audit_events (occurred_at);

CREATE INDEX IF NOT EXISTS ix_audit_events__recorded_at ON audit.audit_events (recorded_at);

CREATE INDEX IF NOT EXISTS ix_audit_events__correlation_id ON audit.audit_events (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_audit_events__causation_id ON audit.audit_events (causation_id) WHERE causation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_audit_trail_entries__audit_event_id ON audit.audit_trail_entries (audit_event_id);

CREATE INDEX IF NOT EXISTS ix_audit_trail_entries__changed_by_user_id ON audit.audit_trail_entries (changed_by_user_id);

CREATE INDEX IF NOT EXISTS ix_audit_trail_entries__changed_by_service_identity_id ON audit.audit_trail_entries (changed_by_service_identity_id);

CREATE INDEX IF NOT EXISTS ix_audit_trail_entries__created_by_service_identity_id ON audit.audit_trail_entries (created_by_service_identity_id);

CREATE INDEX IF NOT EXISTS ix_audit_trail_entries__changed_at ON audit.audit_trail_entries (changed_at);

CREATE INDEX IF NOT EXISTS ix_audit_trail_entries__correlation_id ON audit.audit_trail_entries (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_security_events__audit_event_id ON audit.security_events (audit_event_id);

CREATE INDEX IF NOT EXISTS ix_security_events__actor_user_id ON audit.security_events (actor_user_id);

CREATE INDEX IF NOT EXISTS ix_security_events__actor_service_identity_id ON audit.security_events (actor_service_identity_id);

CREATE INDEX IF NOT EXISTS ix_security_events__incident_record_id ON audit.security_events (incident_record_id);

CREATE INDEX IF NOT EXISTS ix_security_events__resolved_by_user_id ON audit.security_events (resolved_by_user_id);

CREATE INDEX IF NOT EXISTS ix_security_events__created_by_service_identity_id ON audit.security_events (created_by_service_identity_id);

CREATE INDEX IF NOT EXISTS ix_security_events__correlation_id ON audit.security_events (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_evidence_links__audit_event_id ON audit.evidence_links (audit_event_id);

CREATE INDEX IF NOT EXISTS ix_evidence_links__security_event_id ON audit.evidence_links (security_event_id);

CREATE INDEX IF NOT EXISTS ix_evidence_links__linked_by_user_id ON audit.evidence_links (linked_by_user_id);

CREATE INDEX IF NOT EXISTS ix_evidence_links__linked_by_service_identity_id ON audit.evidence_links (linked_by_service_identity_id);

CREATE INDEX IF NOT EXISTS ix_evidence_links__purged_by_user_id ON audit.evidence_links (purged_by_user_id);

CREATE INDEX IF NOT EXISTS ix_evidence_links__retention_expires_at ON audit.evidence_links (retention_expires_at);

CREATE INDEX IF NOT EXISTS ix_evidence_links__correlation_id ON audit.evidence_links (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_vendor_systems__vendor_system_status ON integration.vendor_systems (vendor_system_status);

CREATE INDEX IF NOT EXISTS ix_vendor_endpoints__vendor_system_id ON integration.vendor_endpoints (vendor_system_id);

CREATE INDEX IF NOT EXISTS ix_vendor_endpoints__credential_reference_id ON integration.vendor_endpoints (credential_reference_id);

CREATE INDEX IF NOT EXISTS ix_vendor_endpoints__endpoint_status ON integration.vendor_endpoints (endpoint_status);

CREATE INDEX IF NOT EXISTS ix_adapter_mappings__vendor_system_id ON integration.adapter_mappings (vendor_system_id);

CREATE INDEX IF NOT EXISTS ix_adapter_mappings__site_group_id ON integration.adapter_mappings (site_group_id);

CREATE INDEX IF NOT EXISTS ix_adapter_mappings__site_id ON integration.adapter_mappings (site_id);

CREATE INDEX IF NOT EXISTS ix_adapter_mappings__lane_id ON integration.adapter_mappings (lane_id);

CREATE INDEX IF NOT EXISTS ix_adapter_mappings__gate_device_id ON integration.adapter_mappings (gate_device_id);

CREATE INDEX IF NOT EXISTS ix_integration_credential_references__vendor_system_id ON integration.integration_credential_references (vendor_system_id);

CREATE INDEX IF NOT EXISTS ix_integration_credential_references__service_identity_id ON integration.integration_credential_references (service_identity_id);

CREATE INDEX IF NOT EXISTS ix_integration_credential_references__credential_status ON integration.integration_credential_references (credential_status);

CREATE INDEX IF NOT EXISTS ix_integration_credential_references__last_rotated_at ON integration.integration_credential_references (last_rotated_at);

CREATE INDEX IF NOT EXISTS ix_integration_credential_references__next_rotation_due_at ON integration.integration_credential_references (next_rotation_due_at);

CREATE INDEX IF NOT EXISTS ix_integration_health_records__vendor_system_id ON integration.integration_health_records (vendor_system_id);

CREATE INDEX IF NOT EXISTS ix_integration_health_records__vendor_endpoint_id ON integration.integration_health_records (vendor_endpoint_id);

CREATE INDEX IF NOT EXISTS ix_integration_health_records__site_group_id ON integration.integration_health_records (site_group_id);

CREATE INDEX IF NOT EXISTS ix_integration_health_records__site_id ON integration.integration_health_records (site_id);

CREATE INDEX IF NOT EXISTS ix_integration_health_records__correlation_id ON integration.integration_health_records (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_system_parameters__parameter_status ON config.system_parameters (parameter_status);

CREATE INDEX IF NOT EXISTS ix_system_parameters__approved_at ON config.system_parameters (approved_at);

CREATE INDEX IF NOT EXISTS ix_feature_flags__site_group_id ON config.feature_flags (site_group_id);

CREATE INDEX IF NOT EXISTS ix_feature_flags__site_id ON config.feature_flags (site_id);

CREATE INDEX IF NOT EXISTS ix_feature_flags__merchant_id ON config.feature_flags (merchant_id);

CREATE INDEX IF NOT EXISTS ix_rate_limit_policies__policy_status ON config.rate_limit_policies (policy_status);

CREATE INDEX IF NOT EXISTS ix_ttl_policies__policy_status ON config.ttl_policies (policy_status);

CREATE INDEX IF NOT EXISTS ix_controlled_code_sets__code_status ON config.controlled_code_sets (code_status);

CREATE INDEX IF NOT EXISTS ix_domain_events__actor_user_id ON events.domain_events (actor_user_id);

CREATE INDEX IF NOT EXISTS ix_domain_events__actor_service_identity_id ON events.domain_events (actor_service_identity_id);

CREATE INDEX IF NOT EXISTS ix_domain_events__event_status ON events.domain_events (event_status);

CREATE INDEX IF NOT EXISTS ix_domain_events__correlation_id ON events.domain_events (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_domain_events__causation_id ON events.domain_events (causation_id) WHERE causation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_outbox_events__domain_event_id ON events.outbox_events (domain_event_id);

CREATE INDEX IF NOT EXISTS ix_outbox_events__publication_status ON events.outbox_events (publication_status);

CREATE INDEX IF NOT EXISTS ix_outbox_events__available_at ON events.outbox_events (available_at);

CREATE INDEX IF NOT EXISTS ix_outbox_events__published_at ON events.outbox_events (published_at);

CREATE INDEX IF NOT EXISTS ix_outbox_events__next_retry_at ON events.outbox_events (next_retry_at);

CREATE INDEX IF NOT EXISTS ix_outbox_events__correlation_id ON events.outbox_events (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_outbox_events__causation_id ON events.outbox_events (causation_id) WHERE causation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_event_publications__outbox_event_id ON events.event_publications (outbox_event_id);

CREATE INDEX IF NOT EXISTS ix_event_publications__publication_status ON events.event_publications (publication_status);

CREATE INDEX IF NOT EXISTS ix_event_publications__started_at ON events.event_publications (started_at);

CREATE INDEX IF NOT EXISTS ix_event_publications__completed_at ON events.event_publications (completed_at);

CREATE INDEX IF NOT EXISTS ix_event_publications__correlation_id ON events.event_publications (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_dead_letter_records__outbox_event_id ON events.dead_letter_records (outbox_event_id);

CREATE INDEX IF NOT EXISTS ix_dead_letter_records__event_publication_id ON events.dead_letter_records (event_publication_id);

CREATE INDEX IF NOT EXISTS ix_dead_letter_records__dead_letter_status ON events.dead_letter_records (dead_letter_status);

CREATE INDEX IF NOT EXISTS ix_dead_letter_records__dead_lettered_at ON events.dead_letter_records (dead_lettered_at);

CREATE INDEX IF NOT EXISTS ix_dead_letter_records__resolved_at ON events.dead_letter_records (resolved_at);

CREATE INDEX IF NOT EXISTS ix_dead_letter_records__replay_requested_at ON events.dead_letter_records (replay_requested_at);

CREATE INDEX IF NOT EXISTS ix_dead_letter_records__correlation_id ON events.dead_letter_records (correlation_id) WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_consumer_checkpoints__last_outbox_event_id ON events.consumer_checkpoints (last_outbox_event_id);

CREATE INDEX IF NOT EXISTS ix_consumer_checkpoints__last_domain_event_id ON events.consumer_checkpoints (last_domain_event_id);

CREATE INDEX IF NOT EXISTS ix_consumer_checkpoints__checkpoint_status ON events.consumer_checkpoints (checkpoint_status);

CREATE INDEX IF NOT EXISTS ix_consumer_checkpoints__last_processed_at ON events.consumer_checkpoints (last_processed_at);

CREATE INDEX IF NOT EXISTS ix_consumer_checkpoints__correlation_id ON events.consumer_checkpoints (correlation_id) WHERE correlation_id IS NOT NULL;

