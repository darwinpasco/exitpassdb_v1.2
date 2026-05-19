--
-- PostgreSQL database dump
--

\restrict FL1J3mh1xeSyeDAnYlS7TGPHZ4ul3cB7ogWfJZijWbxcphDF4zDuh7GrdftF6Tq

-- Dumped from database version 16.13
-- Dumped by pg_dump version 16.13

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: audit; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA audit;


--
-- Name: config; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA config;


--
-- Name: core; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA core;


--
-- Name: coupons; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA coupons;


--
-- Name: discounts; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA discounts;


--
-- Name: events; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA events;


--
-- Name: gates; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA gates;


--
-- Name: identity; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA identity;


--
-- Name: integration; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA integration;


--
-- Name: merchants; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA merchants;


--
-- Name: operations; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA operations;


--
-- Name: payments; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA payments;


--
-- Name: reconciliation; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA reconciliation;


--
-- Name: sessions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA sessions;


--
-- Name: sites; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA sites;


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: audit_change_type_enum; Type: TYPE; Schema: audit; Owner: -
--

CREATE TYPE audit.audit_change_type_enum AS ENUM (
    'CREATE',
    'UPDATE',
    'DELETE',
    'ACTIVATE',
    'SUSPEND',
    'REVOKE',
    'RETIRE',
    'APPROVE',
    'REJECT',
    'CONFIGURE',
    'ROTATE_CREDENTIAL_REFERENCE',
    'CORRECT',
    'MIGRATE'
);


--
-- Name: audit_event_category_enum; Type: TYPE; Schema: audit; Owner: -
--

CREATE TYPE audit.audit_event_category_enum AS ENUM (
    'DOMAIN_STATE_CHANGE',
    'ACCESS',
    'CONFIGURATION_CHANGE',
    'POLICY_CHANGE',
    'SECURITY_RELEVANT',
    'INTEGRATION',
    'RECONCILIATION',
    'MANUAL_OPERATION',
    'EVIDENCE_ACCESS',
    'EVENTING',
    'SYSTEM'
);


--
-- Name: audit_event_result_enum; Type: TYPE; Schema: audit; Owner: -
--

CREATE TYPE audit.audit_event_result_enum AS ENUM (
    'SUCCESS',
    'FAILED',
    'DENIED',
    'REJECTED',
    'EXPIRED',
    'CANCELLED',
    'DUPLICATE',
    'NO_OP',
    'UNKNOWN'
);


--
-- Name: evidence_access_classification_enum; Type: TYPE; Schema: audit; Owner: -
--

CREATE TYPE audit.evidence_access_classification_enum AS ENUM (
    'INTERNAL',
    'RESTRICTED',
    'HIGHLY_RESTRICTED'
);


--
-- Name: evidence_link_status_enum; Type: TYPE; Schema: audit; Owner: -
--

CREATE TYPE audit.evidence_link_status_enum AS ENUM (
    'ACTIVE',
    'REDACTED',
    'PURGED',
    'HASH_ONLY',
    'REVOKED'
);


--
-- Name: evidence_redaction_status_enum; Type: TYPE; Schema: audit; Owner: -
--

CREATE TYPE audit.evidence_redaction_status_enum AS ENUM (
    'NOT_REDACTED',
    'PARTIALLY_REDACTED',
    'FULLY_REDACTED',
    'HASH_ONLY'
);


--
-- Name: evidence_storage_type_enum; Type: TYPE; Schema: audit; Owner: -
--

CREATE TYPE audit.evidence_storage_type_enum AS ENUM (
    'OBJECT_STORAGE',
    'EVIDENCE_VAULT',
    'HASH_ONLY',
    'EXTERNAL_REFERENCE',
    'REDACTED_REFERENCE'
);


--
-- Name: evidence_type_enum; Type: TYPE; Schema: audit; Owner: -
--

CREATE TYPE audit.evidence_type_enum AS ENUM (
    'PROVIDER_PAYLOAD',
    'PROVIDER_RESPONSE',
    'STATUTORY_DISCOUNT_EVIDENCE',
    'MANUAL_GATE_EVIDENCE',
    'INCIDENT_EVIDENCE',
    'RECONCILIATION_EVIDENCE',
    'SETTLEMENT_EVIDENCE',
    'CONFIGURATION_CHANGE_EVIDENCE',
    'SECURITY_EVIDENCE',
    'SCREENSHOT',
    'DOCUMENT',
    'HASH_ONLY_REFERENCE',
    'OTHER'
);


--
-- Name: security_event_category_enum; Type: TYPE; Schema: audit; Owner: -
--

CREATE TYPE audit.security_event_category_enum AS ENUM (
    'AUTHENTICATION',
    'AUTHORIZATION',
    'REPLAY',
    'RATE_LIMIT',
    'WEBHOOK_TRUST',
    'TOKEN_VALIDATION',
    'EVIDENCE_ACCESS',
    'PRIVILEGED_ACCESS',
    'CREDENTIAL_REFERENCE',
    'SERVICE_IDENTITY',
    'SUSPICIOUS_ACTIVITY',
    'DATA_ACCESS',
    'CONFIGURATION_SECURITY'
);


--
-- Name: security_event_result_enum; Type: TYPE; Schema: audit; Owner: -
--

CREATE TYPE audit.security_event_result_enum AS ENUM (
    'ALLOWED',
    'DENIED',
    'FAILED',
    'BLOCKED',
    'REJECTED',
    'DETECTED',
    'ESCALATED',
    'UNKNOWN'
);


--
-- Name: security_event_status_enum; Type: TYPE; Schema: audit; Owner: -
--

CREATE TYPE audit.security_event_status_enum AS ENUM (
    'OPEN',
    'ACKNOWLEDGED',
    'UNDER_REVIEW',
    'RESOLVED',
    'FALSE_POSITIVE',
    'ESCALATED',
    'CLOSED'
);


--
-- Name: security_severity_enum; Type: TYPE; Schema: audit; Owner: -
--

CREATE TYPE audit.security_severity_enum AS ENUM (
    'LOW',
    'MEDIUM',
    'HIGH',
    'CRITICAL'
);


--
-- Name: controlled_code_status_enum; Type: TYPE; Schema: config; Owner: -
--

CREATE TYPE config.controlled_code_status_enum AS ENUM (
    'DRAFT',
    'ACTIVE',
    'SUSPENDED',
    'DEPRECATED',
    'RETIRED'
);


--
-- Name: feature_flag_status_enum; Type: TYPE; Schema: config; Owner: -
--

CREATE TYPE config.feature_flag_status_enum AS ENUM (
    'DRAFT',
    'ACTIVE',
    'SUSPENDED',
    'EXPIRED',
    'RETIRED'
);


--
-- Name: rate_limit_enforcement_mode_enum; Type: TYPE; Schema: config; Owner: -
--

CREATE TYPE config.rate_limit_enforcement_mode_enum AS ENUM (
    'MONITOR_ONLY',
    'ENFORCE',
    'BLOCK',
    'CHALLENGE',
    'DISABLED'
);


--
-- Name: rate_limit_policy_status_enum; Type: TYPE; Schema: config; Owner: -
--

CREATE TYPE config.rate_limit_policy_status_enum AS ENUM (
    'DRAFT',
    'ACTIVE',
    'SUSPENDED',
    'RETIRED'
);


--
-- Name: rate_limit_scope_type_enum; Type: TYPE; Schema: config; Owner: -
--

CREATE TYPE config.rate_limit_scope_type_enum AS ENUM (
    'PUBLIC_LOOKUP',
    'PAYMENT_CREATE',
    'PROVIDER_CALLBACK',
    'GATE_CONSUME',
    'ADMIN_API',
    'SUPPORT_TOOL',
    'EVIDENCE_ACCESS',
    'SERVICE_TO_SERVICE',
    'MERCHANT_USER',
    'DEVICE',
    'CUSTOM'
);


--
-- Name: system_parameter_status_enum; Type: TYPE; Schema: config; Owner: -
--

CREATE TYPE config.system_parameter_status_enum AS ENUM (
    'DRAFT',
    'ACTIVE',
    'SUSPENDED',
    'SUPERSEDED',
    'RETIRED'
);


--
-- Name: system_parameter_type_enum; Type: TYPE; Schema: config; Owner: -
--

CREATE TYPE config.system_parameter_type_enum AS ENUM (
    'TEXT',
    'NUMERIC',
    'BOOLEAN',
    'JSON_REFERENCE'
);


--
-- Name: ttl_expiry_action_enum; Type: TYPE; Schema: config; Owner: -
--

CREATE TYPE config.ttl_expiry_action_enum AS ENUM (
    'EXPIRE_RECORD',
    'INVALIDATE_RECORD',
    'RELEASE_RESERVATION',
    'REQUIRE_RECHECK',
    'BLOCK_USE',
    'PURGE_OR_ARCHIVE',
    'NOTIFY_ONLY',
    'CUSTOM_WORKFLOW'
);


--
-- Name: ttl_policy_status_enum; Type: TYPE; Schema: config; Owner: -
--

CREATE TYPE config.ttl_policy_status_enum AS ENUM (
    'DRAFT',
    'ACTIVE',
    'SUSPENDED',
    'RETIRED'
);


--
-- Name: ttl_scope_type_enum; Type: TYPE; Schema: config; Owner: -
--

CREATE TYPE config.ttl_scope_type_enum AS ENUM (
    'TARIFF_SNAPSHOT',
    'PAYMENT_ATTEMPT',
    'PROVIDER_SESSION',
    'COUPON_RESERVATION',
    'STATUTORY_DISCOUNT_VALIDATION',
    'SESSION_LOOKUP_CACHE',
    'EXIT_AUTHORIZATION',
    'PROVIDER_CALLBACK_REPLAY_WINDOW',
    'EVIDENCE_RETENTION',
    'OUTBOX_RETRY',
    'CUSTOM'
);


--
-- Name: exit_authorization_status_enum; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.exit_authorization_status_enum AS ENUM (
    'ISSUED',
    'EXPIRED',
    'INVALIDATED'
);


--
-- Name: parking_session_status_enum; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.parking_session_status_enum AS ENUM (
    'ACTIVE',
    'CLOSED',
    'EXPIRED',
    'INVALIDATED'
);


--
-- Name: payment_attempt_status_enum; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.payment_attempt_status_enum AS ENUM (
    'REQUESTED',
    'PENDING_PROVIDER',
    'PENDING_FINALIZATION',
    'CONFIRMED',
    'FAILED',
    'EXPIRED',
    'CANCELLED'
);


--
-- Name: payment_confirmation_status_enum; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.payment_confirmation_status_enum AS ENUM (
    'RECORDED',
    'VOIDED'
);


--
-- Name: tariff_snapshot_status_enum; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.tariff_snapshot_status_enum AS ENUM (
    'ACTIVE',
    'CONSUMED',
    'EXPIRED',
    'SUPERSEDED',
    'INVALIDATED'
);


--
-- Name: coupon_application_status_enum; Type: TYPE; Schema: coupons; Owner: -
--

CREATE TYPE coupons.coupon_application_status_enum AS ENUM (
    'REQUESTED',
    'RESERVED',
    'APPLIED',
    'COMMITTED',
    'RELEASED',
    'EXPIRED',
    'REJECTED',
    'CANCELLED',
    'REVERSED'
);


--
-- Name: coupon_denomination_type_enum; Type: TYPE; Schema: coupons; Owner: -
--

CREATE TYPE coupons.coupon_denomination_type_enum AS ENUM (
    'FIXED_AMOUNT',
    'PERCENTAGE',
    'FULL_WAIVER'
);


--
-- Name: coupon_rule_evaluation_strategy_enum; Type: TYPE; Schema: coupons; Owner: -
--

CREATE TYPE coupons.coupon_rule_evaluation_strategy_enum AS ENUM (
    'ALL_RULES_MUST_PASS',
    'ANY_RULE_MAY_PASS',
    'FIRST_MATCH',
    'PRIORITY_ORDERED'
);


--
-- Name: coupon_rule_group_status_enum; Type: TYPE; Schema: coupons; Owner: -
--

CREATE TYPE coupons.coupon_rule_group_status_enum AS ENUM (
    'DRAFT',
    'ACTIVE',
    'SUSPENDED',
    'RETIRED'
);


--
-- Name: coupon_rule_operator_enum; Type: TYPE; Schema: coupons; Owner: -
--

CREATE TYPE coupons.coupon_rule_operator_enum AS ENUM (
    'EQUALS',
    'NOT_EQUALS',
    'IN',
    'NOT_IN',
    'GREATER_THAN',
    'GREATER_THAN_OR_EQUAL',
    'LESS_THAN',
    'LESS_THAN_OR_EQUAL',
    'BETWEEN',
    'EXISTS',
    'NOT_EXISTS'
);


--
-- Name: coupon_rule_status_enum; Type: TYPE; Schema: coupons; Owner: -
--

CREATE TYPE coupons.coupon_rule_status_enum AS ENUM (
    'DRAFT',
    'ACTIVE',
    'SUSPENDED',
    'RETIRED'
);


--
-- Name: coupon_rule_type_enum; Type: TYPE; Schema: coupons; Owner: -
--

CREATE TYPE coupons.coupon_rule_type_enum AS ENUM (
    'SITE_GROUP_SCOPE',
    'SITE_SCOPE',
    'MERCHANT_SCOPE',
    'VALIDITY_WINDOW',
    'MINIMUM_GROSS_AMOUNT',
    'MAXIMUM_DISCOUNT_AMOUNT',
    'STACKING_POLICY',
    'FULL_WAIVER_ALLOWED',
    'WALLET_SUFFICIENCY',
    'BASELINE_HOURS_ONLY',
    'PAYMENT_RAIL_SCOPE',
    'CUSTOM_CONTROLLED'
);


--
-- Name: coupon_stacking_policy_enum; Type: TYPE; Schema: coupons; Owner: -
--

CREATE TYPE coupons.coupon_stacking_policy_enum AS ENUM (
    'NO_STACKING',
    'STACK_WITH_STATUTORY_DISCOUNT',
    'STACK_WITH_COUPON',
    'STACK_WITH_BOTH',
    'HIGHEST_BENEFIT_ONLY'
);


--
-- Name: coupon_status_enum; Type: TYPE; Schema: coupons; Owner: -
--

CREATE TYPE coupons.coupon_status_enum AS ENUM (
    'DRAFT',
    'ACTIVE',
    'SUSPENDED',
    'EXPIRED',
    'RETIRED'
);


--
-- Name: coupon_type_enum; Type: TYPE; Schema: coupons; Owner: -
--

CREATE TYPE coupons.coupon_type_enum AS ENUM (
    'STANDARD',
    'MERCHANT_SUBSIDY',
    'VALIDATION',
    'FULL_WAIVER',
    'SERVICE_RECOVERY',
    'PROMOTIONAL'
);


--
-- Name: discount_evidence_type_enum; Type: TYPE; Schema: discounts; Owner: -
--

CREATE TYPE discounts.discount_evidence_type_enum AS ENUM (
    'SENIOR_CITIZEN_ID',
    'PWD_ID',
    'AUTHORIZATION_LETTER',
    'SUPPORTING_DOCUMENT',
    'VALIDATION_SCREENSHOT',
    'HASH_ONLY_REFERENCE',
    'OTHER'
);


--
-- Name: discount_policy_level_enum; Type: TYPE; Schema: discounts; Owner: -
--

CREATE TYPE discounts.discount_policy_level_enum AS ENUM (
    'NATIONAL_LAW',
    'LOCAL_ORDINANCE',
    'SITE_POLICY',
    'OPERATIONAL_POLICY'
);


--
-- Name: discount_policy_status_enum; Type: TYPE; Schema: discounts; Owner: -
--

CREATE TYPE discounts.discount_policy_status_enum AS ENUM (
    'DRAFT',
    'ACTIVE',
    'SUSPENDED',
    'SUPERSEDED',
    'RETIRED'
);


--
-- Name: discount_policy_type_enum; Type: TYPE; Schema: discounts; Owner: -
--

CREATE TYPE discounts.discount_policy_type_enum AS ENUM (
    'LEGAL_REFERENCE',
    'LOCAL_ORDINANCE',
    'SITE_POLICY',
    'OPERATIONAL_POLICY',
    'IMPLEMENTATION_POLICY'
);


--
-- Name: evidence_access_classification_enum; Type: TYPE; Schema: discounts; Owner: -
--

CREATE TYPE discounts.evidence_access_classification_enum AS ENUM (
    'INTERNAL',
    'RESTRICTED',
    'HIGHLY_RESTRICTED'
);


--
-- Name: evidence_capture_status_enum; Type: TYPE; Schema: discounts; Owner: -
--

CREATE TYPE discounts.evidence_capture_status_enum AS ENUM (
    'CAPTURED',
    'REFERENCED',
    'REDACTED',
    'PURGED',
    'HASH_ONLY',
    'REJECTED'
);


--
-- Name: evidence_redaction_status_enum; Type: TYPE; Schema: discounts; Owner: -
--

CREATE TYPE discounts.evidence_redaction_status_enum AS ENUM (
    'NOT_REDACTED',
    'PARTIALLY_REDACTED',
    'FULLY_REDACTED',
    'HASH_ONLY'
);


--
-- Name: evidence_storage_type_enum; Type: TYPE; Schema: discounts; Owner: -
--

CREATE TYPE discounts.evidence_storage_type_enum AS ENUM (
    'OBJECT_STORAGE',
    'EVIDENCE_VAULT',
    'HASH_ONLY',
    'EXTERNAL_REFERENCE',
    'REDACTED_REFERENCE'
);


--
-- Name: policy_resolution_basis_enum; Type: TYPE; Schema: discounts; Owner: -
--

CREATE TYPE discounts.policy_resolution_basis_enum AS ENUM (
    'LOCAL_ORDINANCE_APPLIED',
    'NATIONAL_LAW_FALLBACK',
    'SITE_POLICY_OPERATIONAL_ONLY',
    'MANUAL_POLICY_SELECTION',
    'SYSTEM_DEFAULT'
);


--
-- Name: statutory_discount_validations_channel_enum; Type: TYPE; Schema: discounts; Owner: -
--

CREATE TYPE discounts.statutory_discount_validations_channel_enum AS ENUM (
    'WEB_PAY',
    'OPERATOR_ASSISTED',
    'SYSTEM_VALIDATED',
    'SUPPORT_REVIEW',
    'RECONCILIATION_REVIEW'
);


--
-- Name: statutory_discount_validations_status_enum; Type: TYPE; Schema: discounts; Owner: -
--

CREATE TYPE discounts.statutory_discount_validations_status_enum AS ENUM (
    'REQUESTED',
    'PENDING_OPERATOR_REVIEW',
    'APPROVED',
    'REJECTED',
    'FAILED',
    'EXPIRED',
    'CANCELLED'
);


--
-- Name: statutory_entitlement_type_enum; Type: TYPE; Schema: discounts; Owner: -
--

CREATE TYPE discounts.statutory_entitlement_type_enum AS ENUM (
    'SENIOR_CITIZEN',
    'PWD',
    'OTHER_STATUTORY'
);


--
-- Name: consumer_checkpoint_status_enum; Type: TYPE; Schema: events; Owner: -
--

CREATE TYPE events.consumer_checkpoint_status_enum AS ENUM (
    'ACTIVE',
    'LOCKED',
    'FAILED',
    'PAUSED',
    'REPLAYING',
    'RESET',
    'RETIRED'
);


--
-- Name: dead_letter_status_enum; Type: TYPE; Schema: events; Owner: -
--

CREATE TYPE events.dead_letter_status_enum AS ENUM (
    'OPEN',
    'UNDER_REVIEW',
    'REPLAY_REQUESTED',
    'REPLAYED',
    'RESOLVED',
    'REJECTED',
    'CLOSED',
    'CANCELLED'
);


--
-- Name: dead_letter_type_enum; Type: TYPE; Schema: events; Owner: -
--

CREATE TYPE events.dead_letter_type_enum AS ENUM (
    'PUBLICATION_FAILURE',
    'BROKER_REJECTION',
    'PAYLOAD_VALIDATION_FAILURE',
    'ROUTING_FAILURE',
    'CONSUMER_FAILURE',
    'CONSUMER_REJECTION',
    'RETRY_EXHAUSTED',
    'UNKNOWN'
);


--
-- Name: domain_event_status_enum; Type: TYPE; Schema: events; Owner: -
--

CREATE TYPE events.domain_event_status_enum AS ENUM (
    'RECORDED',
    'SUPERSEDED',
    'CANCELLED',
    'IGNORED'
);


--
-- Name: event_broker_type_enum; Type: TYPE; Schema: events; Owner: -
--

CREATE TYPE events.event_broker_type_enum AS ENUM (
    'RABBITMQ',
    'KAFKA',
    'AZURE_SERVICE_BUS',
    'AWS_SNS_SQS',
    'WEBHOOK',
    'IN_PROCESS',
    'OTHER'
);


--
-- Name: event_publication_status_enum; Type: TYPE; Schema: events; Owner: -
--

CREATE TYPE events.event_publication_status_enum AS ENUM (
    'STARTED',
    'PUBLISHED',
    'FAILED',
    'TIMEOUT',
    'REJECTED',
    'CANCELLED'
);


--
-- Name: outbox_publication_status_enum; Type: TYPE; Schema: events; Owner: -
--

CREATE TYPE events.outbox_publication_status_enum AS ENUM (
    'PENDING',
    'LOCKED',
    'PUBLISHED',
    'FAILED',
    'RETRY_PENDING',
    'DEAD_LETTERED',
    'CANCELLED'
);


--
-- Name: gate_authorization_consumption_status_enum; Type: TYPE; Schema: gates; Owner: -
--

CREATE TYPE gates.gate_authorization_consumption_status_enum AS ENUM (
    'REQUESTED',
    'VALIDATED',
    'CONSUMED',
    'DENIED',
    'EXPIRED',
    'INVALID',
    'REPLAYED',
    'MISMATCHED',
    'FAILED'
);


--
-- Name: gate_command_result_status_enum; Type: TYPE; Schema: gates; Owner: -
--

CREATE TYPE gates.gate_command_result_status_enum AS ENUM (
    'NOT_REQUESTED',
    'REQUESTED',
    'ACKNOWLEDGED',
    'OPENED',
    'FAILED',
    'TIMEOUT',
    'UNKNOWN'
);


--
-- Name: gate_device_status_enum; Type: TYPE; Schema: gates; Owner: -
--

CREATE TYPE gates.gate_device_status_enum AS ENUM (
    'DRAFT',
    'ACTIVE',
    'MAINTENANCE',
    'OFFLINE',
    'SUSPENDED',
    'RETIRED'
);


--
-- Name: gate_device_type_enum; Type: TYPE; Schema: gates; Owner: -
--

CREATE TYPE gates.gate_device_type_enum AS ENUM (
    'BARRIER_CONTROLLER',
    'LANE_CONTROLLER',
    'EXIT_TERMINAL',
    'LPR_DEVICE',
    'GATEWAY',
    'INTEGRATION_ENDPOINT',
    'OTHER'
);


--
-- Name: gate_event_status_enum; Type: TYPE; Schema: gates; Owner: -
--

CREATE TYPE gates.gate_event_status_enum AS ENUM (
    'RECORDED',
    'SUCCESS',
    'FAILED',
    'ERROR',
    'ABNORMAL',
    'IGNORED',
    'DUPLICATE'
);


--
-- Name: gate_event_type_enum; Type: TYPE; Schema: gates; Owner: -
--

CREATE TYPE gates.gate_event_type_enum AS ENUM (
    'AUTHORIZATION_PRESENTED',
    'AUTHORIZATION_VALIDATED',
    'AUTHORIZATION_DENIED',
    'AUTHORIZATION_CONSUMED',
    'GATE_OPEN_COMMAND_REQUESTED',
    'GATE_OPEN_ACKNOWLEDGED',
    'GATE_OPEN_FAILED',
    'BARRIER_RAISED',
    'BARRIER_LOWERED',
    'VEHICLE_DETECTED',
    'VEHICLE_EXITED',
    'DEVICE_ONLINE',
    'DEVICE_OFFLINE',
    'DEVICE_ERROR',
    'MANUAL_INTERVENTION',
    'TAMPER_ALERT',
    'ABNORMAL_EVENT'
);


--
-- Name: gate_heartbeat_status_enum; Type: TYPE; Schema: gates; Owner: -
--

CREATE TYPE gates.gate_heartbeat_status_enum AS ENUM (
    'ONLINE',
    'DEGRADED',
    'OFFLINE',
    'ERROR',
    'UNKNOWN'
);


--
-- Name: permission_status_enum; Type: TYPE; Schema: identity; Owner: -
--

CREATE TYPE identity.permission_status_enum AS ENUM (
    'DRAFT',
    'ACTIVE',
    'DEPRECATED',
    'RETIRED'
);


--
-- Name: role_permission_binding_status_enum; Type: TYPE; Schema: identity; Owner: -
--

CREATE TYPE identity.role_permission_binding_status_enum AS ENUM (
    'ACTIVE',
    'SUSPENDED',
    'REVOKED',
    'EXPIRED',
    'RETIRED'
);


--
-- Name: role_status_enum; Type: TYPE; Schema: identity; Owner: -
--

CREATE TYPE identity.role_status_enum AS ENUM (
    'DRAFT',
    'ACTIVE',
    'SUSPENDED',
    'RETIRED'
);


--
-- Name: role_type_enum; Type: TYPE; Schema: identity; Owner: -
--

CREATE TYPE identity.role_type_enum AS ENUM (
    'SYSTEM',
    'OPERATIONS',
    'MERCHANT',
    'FINANCE',
    'COMPLIANCE',
    'SUPPORT',
    'SECURITY',
    'SERVICE',
    'OTHER'
);


--
-- Name: service_credential_type_enum; Type: TYPE; Schema: identity; Owner: -
--

CREATE TYPE identity.service_credential_type_enum AS ENUM (
    'CLIENT_SECRET_REFERENCE',
    'CERTIFICATE_REFERENCE',
    'MTLS_CERTIFICATE_REFERENCE',
    'API_KEY_REFERENCE',
    'JWT_SIGNING_KEY_REFERENCE',
    'KEY_VAULT_REFERENCE',
    'WEBHOOK_SECRET_REFERENCE',
    'NONE'
);


--
-- Name: service_identity_status_enum; Type: TYPE; Schema: identity; Owner: -
--

CREATE TYPE identity.service_identity_status_enum AS ENUM (
    'DRAFT',
    'ACTIVE',
    'SUSPENDED',
    'REVOKED',
    'EXPIRED',
    'RETIRED'
);


--
-- Name: service_identity_type_enum; Type: TYPE; Schema: identity; Owner: -
--

CREATE TYPE identity.service_identity_type_enum AS ENUM (
    'INTERNAL_SERVICE',
    'EXTERNAL_CLIENT',
    'ADAPTER',
    'BACKGROUND_WORKER',
    'SCHEDULED_JOB',
    'WEBHOOK_RECEIVER',
    'DEVICE',
    'GATEWAY',
    'OTHER'
);


--
-- Name: user_role_assignment_status_enum; Type: TYPE; Schema: identity; Owner: -
--

CREATE TYPE identity.user_role_assignment_status_enum AS ENUM (
    'ACTIVE',
    'SUSPENDED',
    'REVOKED',
    'EXPIRED',
    'RETIRED'
);


--
-- Name: user_status_enum; Type: TYPE; Schema: identity; Owner: -
--

CREATE TYPE identity.user_status_enum AS ENUM (
    'INVITED',
    'ACTIVE',
    'LOCKED',
    'SUSPENDED',
    'INACTIVE',
    'RETIRED'
);


--
-- Name: user_type_enum; Type: TYPE; Schema: identity; Owner: -
--

CREATE TYPE identity.user_type_enum AS ENUM (
    'INTERNAL_ADMIN',
    'OPERATIONS_USER',
    'SITE_OPERATOR',
    'SUPPORT_USER',
    'FINANCE_USER',
    'COMPLIANCE_USER',
    'MERCHANT_USER',
    'SECURITY_USER',
    'OTHER'
);


--
-- Name: adapter_mapping_confidence_enum; Type: TYPE; Schema: integration; Owner: -
--

CREATE TYPE integration.adapter_mapping_confidence_enum AS ENUM (
    'MANUAL_APPROVED',
    'IMPORTED_APPROVED',
    'SYSTEM_DISCOVERED',
    'LOW_CONFIDENCE',
    'UNKNOWN'
);


--
-- Name: adapter_mapping_status_enum; Type: TYPE; Schema: integration; Owner: -
--

CREATE TYPE integration.adapter_mapping_status_enum AS ENUM (
    'DRAFT',
    'ACTIVE',
    'SUSPENDED',
    'SUPERSEDED',
    'RETIRED'
);


--
-- Name: adapter_mapping_type_enum; Type: TYPE; Schema: integration; Owner: -
--

CREATE TYPE integration.adapter_mapping_type_enum AS ENUM (
    'SITE_GROUP',
    'SITE',
    'LANE',
    'GATE_DEVICE',
    'PAYMENT_RAIL',
    'TARIFF_GROUP',
    'VENDOR_LOCATION',
    'OTHER'
);


--
-- Name: http_method_enum; Type: TYPE; Schema: integration; Owner: -
--

CREATE TYPE integration.http_method_enum AS ENUM (
    'GET',
    'POST',
    'PUT',
    'PATCH',
    'DELETE'
);


--
-- Name: integration_credential_status_enum; Type: TYPE; Schema: integration; Owner: -
--

CREATE TYPE integration.integration_credential_status_enum AS ENUM (
    'DRAFT',
    'ACTIVE',
    'ROTATION_DUE',
    'EXPIRED',
    'REVOKED',
    'RETIRED'
);


--
-- Name: integration_credential_type_enum; Type: TYPE; Schema: integration; Owner: -
--

CREATE TYPE integration.integration_credential_type_enum AS ENUM (
    'API_KEY_REFERENCE',
    'CLIENT_SECRET_REFERENCE',
    'OAUTH_CLIENT_REFERENCE',
    'MTLS_CERTIFICATE_REFERENCE',
    'SIGNING_KEY_REFERENCE',
    'WEBHOOK_SECRET_REFERENCE',
    'BASIC_AUTH_REFERENCE',
    'OTHER'
);


--
-- Name: integration_health_check_type_enum; Type: TYPE; Schema: integration; Owner: -
--

CREATE TYPE integration.integration_health_check_type_enum AS ENUM (
    'SCHEDULED_HEALTH_CHECK',
    'ON_DEMAND_CHECK',
    'REQUEST_FAILURE',
    'CALLBACK_FAILURE',
    'LATENCY_OBSERVATION',
    'RECOVERY_OBSERVATION',
    'MANUAL_OBSERVATION'
);


--
-- Name: integration_health_status_enum; Type: TYPE; Schema: integration; Owner: -
--

CREATE TYPE integration.integration_health_status_enum AS ENUM (
    'AVAILABLE',
    'DEGRADED',
    'UNAVAILABLE',
    'ERROR',
    'UNKNOWN'
);


--
-- Name: secret_store_type_enum; Type: TYPE; Schema: integration; Owner: -
--

CREATE TYPE integration.secret_store_type_enum AS ENUM (
    'KEY_VAULT',
    'SECRETS_MANAGER',
    'CERTIFICATE_STORE',
    'HSM',
    'ENVIRONMENT_REFERENCE',
    'OTHER'
);


--
-- Name: vendor_endpoint_status_enum; Type: TYPE; Schema: integration; Owner: -
--

CREATE TYPE integration.vendor_endpoint_status_enum AS ENUM (
    'DRAFT',
    'ACTIVE',
    'MAINTENANCE',
    'SUSPENDED',
    'DEPRECATED',
    'RETIRED'
);


--
-- Name: vendor_endpoint_type_enum; Type: TYPE; Schema: integration; Owner: -
--

CREATE TYPE integration.vendor_endpoint_type_enum AS ENUM (
    'SESSION_LOOKUP',
    'TARIFF_QUERY',
    'PAYMENT_CREATE',
    'PAYMENT_STATUS',
    'WEBHOOK_RECEIVE',
    'GATE_COMMAND',
    'HEALTH_CHECK',
    'TOKEN_REQUEST',
    'EVIDENCE_UPLOAD',
    'OTHER'
);


--
-- Name: vendor_system_status_enum; Type: TYPE; Schema: integration; Owner: -
--

CREATE TYPE integration.vendor_system_status_enum AS ENUM (
    'DRAFT',
    'ACTIVE',
    'MAINTENANCE',
    'SUSPENDED',
    'DEPRECATED',
    'RETIRED'
);


--
-- Name: vendor_system_type_enum; Type: TYPE; Schema: integration; Owner: -
--

CREATE TYPE integration.vendor_system_type_enum AS ENUM (
    'VENDOR_PMS',
    'PAYMENT_PROVIDER',
    'GATE_CONTROLLER',
    'LPR_PROVIDER',
    'MOPS_PROVIDER',
    'EVIDENCE_STORAGE',
    'NOTIFICATION_PROVIDER',
    'OTHER'
);


--
-- Name: merchant_scope_type_enum; Type: TYPE; Schema: merchants; Owner: -
--

CREATE TYPE merchants.merchant_scope_type_enum AS ENUM (
    'SITE_GROUP',
    'SITE'
);


--
-- Name: merchant_site_scope_status_enum; Type: TYPE; Schema: merchants; Owner: -
--

CREATE TYPE merchants.merchant_site_scope_status_enum AS ENUM (
    'DRAFT',
    'ACTIVE',
    'SUSPENDED',
    'EXPIRED',
    'REVOKED',
    'RETIRED'
);


--
-- Name: merchant_status_enum; Type: TYPE; Schema: merchants; Owner: -
--

CREATE TYPE merchants.merchant_status_enum AS ENUM (
    'DRAFT',
    'ACTIVE',
    'SUSPENDED',
    'INACTIVE',
    'RETIRED'
);


--
-- Name: merchant_type_enum; Type: TYPE; Schema: merchants; Owner: -
--

CREATE TYPE merchants.merchant_type_enum AS ENUM (
    'TENANT',
    'ANCHOR_TENANT',
    'PROPERTY_OPERATOR',
    'INSTITUTION',
    'SERVICE_PROVIDER',
    'PROMOTIONAL_PARTNER',
    'OTHER'
);


--
-- Name: merchant_user_status_enum; Type: TYPE; Schema: merchants; Owner: -
--

CREATE TYPE merchants.merchant_user_status_enum AS ENUM (
    'INVITED',
    'ACTIVE',
    'SUSPENDED',
    'REVOKED',
    'EXPIRED',
    'RETIRED'
);


--
-- Name: merchant_user_type_enum; Type: TYPE; Schema: merchants; Owner: -
--

CREATE TYPE merchants.merchant_user_type_enum AS ENUM (
    'MERCHANT_ADMIN',
    'MERCHANT_MANAGER',
    'MERCHANT_STAFF',
    'REPORT_VIEWER',
    'COUPON_OPERATOR',
    'OTHER'
);


--
-- Name: merchant_wallet_status_enum; Type: TYPE; Schema: merchants; Owner: -
--

CREATE TYPE merchants.merchant_wallet_status_enum AS ENUM (
    'DRAFT',
    'ACTIVE',
    'SUSPENDED',
    'FROZEN',
    'CLOSED',
    'RETIRED'
);


--
-- Name: merchant_wallet_type_enum; Type: TYPE; Schema: merchants; Owner: -
--

CREATE TYPE merchants.merchant_wallet_type_enum AS ENUM (
    'PRE_FUNDED',
    'POSTPAID_SPONSORSHIP',
    'CREDIT_LIMIT',
    'EXTERNAL_LEDGER',
    'PROMOTIONAL_BUDGET',
    'OTHER'
);


--
-- Name: incident_severity_enum; Type: TYPE; Schema: operations; Owner: -
--

CREATE TYPE operations.incident_severity_enum AS ENUM (
    'LOW',
    'MEDIUM',
    'HIGH',
    'CRITICAL'
);


--
-- Name: incident_status_enum; Type: TYPE; Schema: operations; Owner: -
--

CREATE TYPE operations.incident_status_enum AS ENUM (
    'OPEN',
    'ACKNOWLEDGED',
    'INVESTIGATING',
    'MITIGATED',
    'RESOLVED',
    'CLOSED',
    'CANCELLED'
);


--
-- Name: manual_gate_action_status_enum; Type: TYPE; Schema: operations; Owner: -
--

CREATE TYPE operations.manual_gate_action_status_enum AS ENUM (
    'RECORDED',
    'COMPLETED',
    'FAILED',
    'CANCELLED',
    'UNDER_REVIEW',
    'RECONCILED'
);


--
-- Name: manual_gate_action_type_enum; Type: TYPE; Schema: operations; Owner: -
--

CREATE TYPE operations.manual_gate_action_type_enum AS ENUM (
    'MANUAL_OPEN',
    'MANUAL_RELEASE',
    'EMERGENCY_OPEN',
    'MOPS_RELEASE',
    'SUPERVISOR_RELEASE',
    'DEVICE_FAILURE_RELEASE',
    'INCIDENT_RELEASE'
);


--
-- Name: operator_action_status_enum; Type: TYPE; Schema: operations; Owner: -
--

CREATE TYPE operations.operator_action_status_enum AS ENUM (
    'RECORDED',
    'SUCCESS',
    'FAILED',
    'DENIED',
    'CANCELLED'
);


--
-- Name: operator_action_type_enum; Type: TYPE; Schema: operations; Owner: -
--

CREATE TYPE operations.operator_action_type_enum AS ENUM (
    'SENSITIVE_EVIDENCE_VIEW',
    'INCIDENT_ASSIGN',
    'INCIDENT_UPDATE',
    'RECONCILIATION_REVIEW',
    'CONTROLLED_RECHECK',
    'PROVIDER_STATUS_QUERY_TRIGGERED',
    'SUPPORT_NOTE_ADDED',
    'REPORT_EXPORTED',
    'CONFIGURATION_VIEW',
    'SECURITY_REVIEW'
);


--
-- Name: override_approval_decision_enum; Type: TYPE; Schema: operations; Owner: -
--

CREATE TYPE operations.override_approval_decision_enum AS ENUM (
    'APPROVED',
    'REJECTED',
    'ESCALATED',
    'CANCELLED',
    'EXPIRED'
);


--
-- Name: override_request_status_enum; Type: TYPE; Schema: operations; Owner: -
--

CREATE TYPE operations.override_request_status_enum AS ENUM (
    'REQUESTED',
    'PENDING_APPROVAL',
    'APPROVED',
    'REJECTED',
    'CANCELLED',
    'EXPIRED',
    'EXECUTED',
    'CLOSED'
);


--
-- Name: override_type_enum; Type: TYPE; Schema: operations; Owner: -
--

CREATE TYPE operations.override_type_enum AS ENUM (
    'MANUAL_GATE_OPEN',
    'EXIT_AUTHORIZATION_REISSUE',
    'COUPON_EXCEPTION',
    'STATUTORY_DISCOUNT_REVIEW_EXCEPTION',
    'INCIDENT_RELEASE',
    'CONTINUITY_ACTION',
    'RECONCILIATION_CORRECTION',
    'SUPPORT_ACTION'
);


--
-- Name: central_pms_report_status_enum; Type: TYPE; Schema: payments; Owner: -
--

CREATE TYPE payments.central_pms_report_status_enum AS ENUM (
    'NOT_REPORTED',
    'REPORTED',
    'ACCEPTED',
    'REJECTED',
    'FAILED',
    'RETRY_PENDING'
);


--
-- Name: payment_rail_status_enum; Type: TYPE; Schema: payments; Owner: -
--

CREATE TYPE payments.payment_rail_status_enum AS ENUM (
    'DRAFT',
    'ACTIVE',
    'SUSPENDED',
    'MAINTENANCE',
    'DEPRECATED',
    'RETIRED'
);


--
-- Name: payment_rail_type_enum; Type: TYPE; Schema: payments; Owner: -
--

CREATE TYPE payments.payment_rail_type_enum AS ENUM (
    'QRPH',
    'CARD',
    'EWALLET',
    'HOSTED_CHECKOUT',
    'BANK_TRANSFER',
    'OTHER'
);


--
-- Name: provider_callback_processing_status_enum; Type: TYPE; Schema: payments; Owner: -
--

CREATE TYPE payments.provider_callback_processing_status_enum AS ENUM (
    'RECEIVED',
    'PROCESSING',
    'PROCESSED',
    'DUPLICATE',
    'REJECTED',
    'FAILED'
);


--
-- Name: provider_callback_verification_status_enum; Type: TYPE; Schema: payments; Owner: -
--

CREATE TYPE payments.provider_callback_verification_status_enum AS ENUM (
    'UNVERIFIED',
    'VERIFIED',
    'FAILED_SIGNATURE',
    'FAILED_TIMESTAMP',
    'FAILED_SOURCE',
    'FAILED_REPLAY',
    'FAILED_SCHEMA',
    'UNKNOWN'
);


--
-- Name: provider_outcome_status_enum; Type: TYPE; Schema: payments; Owner: -
--

CREATE TYPE payments.provider_outcome_status_enum AS ENUM (
    'CONFIRMED',
    'FAILED',
    'EXPIRED',
    'CANCELLED',
    'REJECTED',
    'UNKNOWN'
);


--
-- Name: provider_session_status_enum; Type: TYPE; Schema: payments; Owner: -
--

CREATE TYPE payments.provider_session_status_enum AS ENUM (
    'CREATED',
    'ACTIVE',
    'PENDING',
    'PAID',
    'FAILED',
    'EXPIRED',
    'CANCELLED',
    'UNKNOWN'
);


--
-- Name: provider_status_query_status_enum; Type: TYPE; Schema: payments; Owner: -
--

CREATE TYPE payments.provider_status_query_status_enum AS ENUM (
    'REQUESTED',
    'COMPLETED',
    'FAILED',
    'TIMEOUT',
    'INCONCLUSIVE'
);


--
-- Name: mops_transaction_record_status_enum; Type: TYPE; Schema: reconciliation; Owner: -
--

CREATE TYPE reconciliation.mops_transaction_record_status_enum AS ENUM (
    'RECORDED',
    'IMPORTED',
    'PENDING_RECONCILIATION',
    'RECONCILED',
    'DISPUTED',
    'REJECTED',
    'CANCELLED'
);


--
-- Name: reconciliation_comparison_basis_enum; Type: TYPE; Schema: reconciliation; Owner: -
--

CREATE TYPE reconciliation.reconciliation_comparison_basis_enum AS ENUM (
    'MOPS_TO_CORE',
    'MOPS_TO_SETTLEMENT',
    'PROVIDER_TO_CORE',
    'MANUAL_GATE_TO_CORE',
    'COUPON_WALLET_TO_APPLICATION',
    'SETTLEMENT_TO_CONFIRMATION',
    'INCIDENT_SCOPE_REVIEW'
);


--
-- Name: reconciliation_exception_severity_enum; Type: TYPE; Schema: reconciliation; Owner: -
--

CREATE TYPE reconciliation.reconciliation_exception_severity_enum AS ENUM (
    'LOW',
    'MEDIUM',
    'HIGH',
    'CRITICAL'
);


--
-- Name: reconciliation_exception_status_enum; Type: TYPE; Schema: reconciliation; Owner: -
--

CREATE TYPE reconciliation.reconciliation_exception_status_enum AS ENUM (
    'OPEN',
    'ASSIGNED',
    'UNDER_REVIEW',
    'RESOLVED',
    'REJECTED',
    'ESCALATED',
    'CLOSED',
    'CANCELLED'
);


--
-- Name: reconciliation_exception_type_enum; Type: TYPE; Schema: reconciliation; Owner: -
--

CREATE TYPE reconciliation.reconciliation_exception_type_enum AS ENUM (
    'AMOUNT_MISMATCH',
    'MISSING_PAYMENT_CONFIRMATION',
    'MISSING_PROVIDER_OUTCOME',
    'MISSING_MOPS_RECORD',
    'DUPLICATE_RECORD',
    'MANUAL_GATE_WITHOUT_PAYMENT',
    'SETTLEMENT_MISMATCH',
    'COUPON_WALLET_MISMATCH',
    'UNRESOLVED_CONTINUITY_RECORD',
    'POLICY_EXCEPTION',
    'UNKNOWN_EXCEPTION'
);


--
-- Name: reconciliation_item_status_enum; Type: TYPE; Schema: reconciliation; Owner: -
--

CREATE TYPE reconciliation.reconciliation_item_status_enum AS ENUM (
    'PENDING',
    'MATCHED',
    'MISMATCHED',
    'EXCEPTION',
    'DISPUTED',
    'REJECTED',
    'RESOLVED',
    'CLOSED'
);


--
-- Name: reconciliation_match_status_enum; Type: TYPE; Schema: reconciliation; Owner: -
--

CREATE TYPE reconciliation.reconciliation_match_status_enum AS ENUM (
    'NOT_EVALUATED',
    'MATCH',
    'AMOUNT_MISMATCH',
    'MISSING_SOURCE',
    'MISSING_TARGET',
    'DUPLICATE',
    'INCONCLUSIVE',
    'REJECTED'
);


--
-- Name: reconciliation_run_status_enum; Type: TYPE; Schema: reconciliation; Owner: -
--

CREATE TYPE reconciliation.reconciliation_run_status_enum AS ENUM (
    'STARTED',
    'PROCESSING',
    'COMPLETED',
    'FAILED',
    'CANCELLED',
    'REPROCESSING'
);


--
-- Name: reconciliation_run_type_enum; Type: TYPE; Schema: reconciliation; Owner: -
--

CREATE TYPE reconciliation.reconciliation_run_type_enum AS ENUM (
    'MOPS_RECONCILIATION',
    'PROVIDER_SETTLEMENT',
    'MANUAL_GATE_REVIEW',
    'INCIDENT_RECONCILIATION',
    'COUPON_WALLET_RECONCILIATION',
    'PAYMENT_PROVIDER_RECONCILIATION',
    'VENDOR_PMS_RECONCILIATION'
);


--
-- Name: reconciliation_scope_type_enum; Type: TYPE; Schema: reconciliation; Owner: -
--

CREATE TYPE reconciliation.reconciliation_scope_type_enum AS ENUM (
    'TIME_WINDOW',
    'SITE',
    'SITE_GROUP',
    'INCIDENT',
    'SOURCE_BATCH',
    'PAYMENT_RAIL',
    'VENDOR_SYSTEM',
    'MIXED'
);


--
-- Name: settlement_comparison_result_enum; Type: TYPE; Schema: reconciliation; Owner: -
--

CREATE TYPE reconciliation.settlement_comparison_result_enum AS ENUM (
    'MATCHED',
    'MISMATCHED',
    'SHORT_SETTLED',
    'OVER_SETTLED',
    'MISSING_SETTLEMENT',
    'DUPLICATE_SETTLEMENT',
    'UNRESOLVED',
    'REJECTED'
);


--
-- Name: settlement_comparison_source_type_enum; Type: TYPE; Schema: reconciliation; Owner: -
--

CREATE TYPE reconciliation.settlement_comparison_source_type_enum AS ENUM (
    'PROVIDER_SETTLEMENT_REPORT',
    'BANK_STATEMENT',
    'PAYMENT_RAIL_REPORT',
    'MERCHANT_WALLET_LEDGER',
    'MOPS_EXPORT',
    'MANUAL_COLLECTION_REPORT',
    'OTHER'
);


--
-- Name: session_identifier_status_enum; Type: TYPE; Schema: sessions; Owner: -
--

CREATE TYPE sessions.session_identifier_status_enum AS ENUM (
    'ACTIVE',
    'EXPIRED',
    'INVALIDATED',
    'SUPERSEDED'
);


--
-- Name: session_lookup_cache_status_enum; Type: TYPE; Schema: sessions; Owner: -
--

CREATE TYPE sessions.session_lookup_cache_status_enum AS ENUM (
    'ACTIVE',
    'EXPIRED',
    'INVALIDATED',
    'SUPERSEDED'
);


--
-- Name: session_lookup_type_enum; Type: TYPE; Schema: sessions; Owner: -
--

CREATE TYPE sessions.session_lookup_type_enum AS ENUM (
    'PLATE_NUMBER',
    'TICKET_NUMBER',
    'VENDOR_SESSION_REF',
    'QR_REFERENCE',
    'COMBINED_PLATE_TICKET'
);


--
-- Name: session_resolution_channel_enum; Type: TYPE; Schema: sessions; Owner: -
--

CREATE TYPE sessions.session_resolution_channel_enum AS ENUM (
    'WEB_PAY',
    'OPERATOR_ASSISTED',
    'INTERNAL_SERVICE',
    'RECONCILIATION_RECHECK',
    'SUPPORT_RECHECK'
);


--
-- Name: session_resolution_request_status_enum; Type: TYPE; Schema: sessions; Owner: -
--

CREATE TYPE sessions.session_resolution_request_status_enum AS ENUM (
    'REQUESTED',
    'PROCESSING',
    'COMPLETED',
    'FAILED',
    'EXPIRED',
    'CANCELLED'
);


--
-- Name: session_resolution_result_status_enum; Type: TYPE; Schema: sessions; Owner: -
--

CREATE TYPE sessions.session_resolution_result_status_enum AS ENUM (
    'RESOLVED_SINGLE',
    'NOT_FOUND',
    'AMBIGUOUS',
    'FAILED',
    'EXPIRED',
    'CANCELLED'
);


--
-- Name: device_assignment_status_enum; Type: TYPE; Schema: sites; Owner: -
--

CREATE TYPE sites.device_assignment_status_enum AS ENUM (
    'ACTIVE',
    'SUSPENDED',
    'SUPERSEDED',
    'EXPIRED',
    'RETIRED'
);


--
-- Name: device_assignment_type_enum; Type: TYPE; Schema: sites; Owner: -
--

CREATE TYPE sites.device_assignment_type_enum AS ENUM (
    'GATE_DEVICE',
    'LPR_DEVICE',
    'LANE_CONTROLLER',
    'PAYMENT_DEVICE',
    'SERVICE_PRINCIPAL',
    'OTHER'
);


--
-- Name: lane_direction_enum; Type: TYPE; Schema: sites; Owner: -
--

CREATE TYPE sites.lane_direction_enum AS ENUM (
    'INBOUND',
    'OUTBOUND',
    'BIDIRECTIONAL',
    'NOT_APPLICABLE'
);


--
-- Name: lane_status_enum; Type: TYPE; Schema: sites; Owner: -
--

CREATE TYPE sites.lane_status_enum AS ENUM (
    'DRAFT',
    'ACTIVE',
    'MAINTENANCE',
    'SUSPENDED',
    'INACTIVE',
    'RETIRED'
);


--
-- Name: lane_type_enum; Type: TYPE; Schema: sites; Owner: -
--

CREATE TYPE sites.lane_type_enum AS ENUM (
    'ENTRY',
    'EXIT',
    'MIXED',
    'VALIDATION',
    'SERVICE',
    'OTHER'
);


--
-- Name: site_group_status_enum; Type: TYPE; Schema: sites; Owner: -
--

CREATE TYPE sites.site_group_status_enum AS ENUM (
    'DRAFT',
    'ACTIVE',
    'SUSPENDED',
    'INACTIVE',
    'RETIRED'
);


--
-- Name: site_status_enum; Type: TYPE; Schema: sites; Owner: -
--

CREATE TYPE sites.site_status_enum AS ENUM (
    'DRAFT',
    'ACTIVE',
    'SUSPENDED',
    'INACTIVE',
    'RETIRED'
);


--
-- Name: site_type_enum; Type: TYPE; Schema: sites; Owner: -
--

CREATE TYPE sites.site_type_enum AS ENUM (
    'OPEN_LOT',
    'STRUCTURED_PARKING',
    'MALL_PARKING',
    'MIXED_USE_PROPERTY',
    'TERMINAL',
    'CAMPUS',
    'OTHER'
);


--
-- Name: consume_exit_authorization(uuid, uuid, uuid, timestamp with time zone); Type: FUNCTION; Schema: core; Owner: -
--

CREATE FUNCTION core.consume_exit_authorization(p_exit_authorization_id uuid, p_requested_by uuid, p_correlation_id uuid, p_now timestamp with time zone) RETURNS TABLE(exit_authorization_id uuid, authorization_status text, consumed_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_authorization core.exit_authorizations%ROWTYPE;
    v_session core.parking_sessions%ROWTYPE;
    v_existing_consumed_at timestamptz;
    v_requested_by_service_identity_id uuid;
    v_consumption gates.gate_authorization_consumptions%ROWTYPE;
BEGIN
    SELECT ea.*
    INTO v_authorization
    FROM core.exit_authorizations AS ea
    WHERE ea.exit_authorization_id = p_exit_authorization_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'exit authorization % was not found', p_exit_authorization_id
            USING ERRCODE = 'P0002';
    END IF;

    SELECT ps.*
    INTO v_session
    FROM core.parking_sessions AS ps
    WHERE ps.parking_session_id = v_authorization.parking_session_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'parking session % was not found for exit authorization %',
            v_authorization.parking_session_id,
            p_exit_authorization_id
            USING ERRCODE = 'P0002';
    END IF;

    SELECT gac.consumed_at
    INTO v_existing_consumed_at
    FROM gates.gate_authorization_consumptions AS gac
    WHERE gac.exit_authorization_id = p_exit_authorization_id
      AND gac.consume_status = 'CONSUMED'
    ORDER BY gac.consumed_at DESC
    LIMIT 1;

    IF FOUND THEN
        RAISE EXCEPTION 'exit authorization % has already been consumed', p_exit_authorization_id
            USING ERRCODE = 'P0001';
    END IF;

    IF v_authorization.authorization_status <> 'ISSUED' THEN
        RAISE EXCEPTION 'exit authorization % is not issued', p_exit_authorization_id
            USING ERRCODE = 'P0001';
    END IF;

    IF v_authorization.expires_at <= p_now THEN
        INSERT INTO gates.gate_authorization_consumptions (
            gate_authorization_consumption_id,
            exit_authorization_id,
            authorization_token_hash,
            site_id,
            consume_status,
            consume_reason_code,
            requested_at,
            validated_at,
            command_requested,
            command_result_status,
            failure_detail,
            correlation_id,
            created_at,
            created_by_service_identity_id,
            updated_at,
            updated_by_service_identity_id
        )
        VALUES (
            gen_random_uuid(),
            v_authorization.exit_authorization_id,
            v_authorization.authorization_token_hash,
            v_session.site_id,
            'EXPIRED',
            'EXIT_AUTHORIZATION_EXPIRED',
            p_now,
            p_now,
            false,
            'NOT_REQUESTED',
            'Exit authorization expired before consume.',
            p_correlation_id,
            p_now,
            COALESCE(v_authorization.updated_by_service_identity_id, v_authorization.created_by_service_identity_id),
            p_now,
            COALESCE(v_authorization.updated_by_service_identity_id, v_authorization.created_by_service_identity_id)
        );

        RAISE EXCEPTION 'exit authorization % is expired', p_exit_authorization_id
            USING ERRCODE = 'P0001';
    END IF;

    SELECT si.service_identity_id
    INTO v_requested_by_service_identity_id
    FROM identity.service_identities AS si
    WHERE si.service_identity_id = p_requested_by
    LIMIT 1;

    IF v_requested_by_service_identity_id IS NULL THEN
        v_requested_by_service_identity_id := v_authorization.updated_by_service_identity_id;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        v_requested_by_service_identity_id := v_authorization.created_by_service_identity_id;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        RAISE EXCEPTION 'requested_by service identity could not be resolved'
            USING ERRCODE = 'P0002';
    END IF;

    INSERT INTO gates.gate_authorization_consumptions (
        gate_authorization_consumption_id,
        exit_authorization_id,
        authorization_token_hash,
        site_id,
        consume_status,
        consume_reason_code,
        requested_at,
        validated_at,
        consumed_at,
        command_requested,
        command_result_status,
        command_result_at,
        correlation_id,
        created_at,
        created_by_service_identity_id,
        updated_at,
        updated_by_service_identity_id
    )
    VALUES (
        gen_random_uuid(),
        v_authorization.exit_authorization_id,
        v_authorization.authorization_token_hash,
        v_session.site_id,
        'CONSUMED',
        'EXIT_AUTHORIZATION_CONSUMED',
        p_now,
        p_now,
        p_now,
        true,
        'REQUESTED',
        p_now,
        p_correlation_id,
        p_now,
        v_requested_by_service_identity_id,
        p_now,
        v_requested_by_service_identity_id
    )
    RETURNING *
    INTO v_consumption;

    UPDATE core.exit_authorizations AS ea
    SET
        updated_at = p_now,
        updated_by_service_identity_id = v_requested_by_service_identity_id,
        row_version = ea.row_version + 1
    WHERE ea.exit_authorization_id = p_exit_authorization_id;

    RETURN QUERY
    SELECT
        v_authorization.exit_authorization_id::uuid,
        'CONSUMED'::text,
        v_consumption.consumed_at::timestamptz;
END;
$$;


--
-- Name: create_or_reuse_payment_attempt(uuid, uuid, text, text, text, uuid, timestamp with time zone); Type: FUNCTION; Schema: core; Owner: -
--

CREATE FUNCTION core.create_or_reuse_payment_attempt(p_parking_session_id uuid, p_tariff_snapshot_id uuid, p_payment_provider_code text, p_idempotency_key text, p_requested_by text, p_correlation_id uuid, p_now timestamp with time zone) RETURNS TABLE(payment_attempt_id uuid, parking_session_id uuid, tariff_snapshot_id uuid, attempt_status text, payment_provider_code text, was_reused boolean, outcome_code text, failure_code text, gross_amount_snapshot numeric, statutory_discount_snapshot numeric, coupon_discount_snapshot numeric, net_amount_due_snapshot numeric, currency_code text, tariff_version_reference text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_session core.parking_sessions%ROWTYPE;
    v_tariff core.tariff_snapshots%ROWTYPE;
    v_existing core.payment_attempts%ROWTYPE;
    v_created core.payment_attempts%ROWTYPE;

    v_requested_by_service_identity_id uuid;
    v_payment_rail_id uuid;
    v_resolved_payment_provider_code text;
BEGIN
    /*
     * Resolve audit identity.
     *
     * The application currently passes requested_by as text. In v1.2 persistence,
     * audit attribution is by service_identity_id. This compatibility routine accepts:
     * - UUID text
     * - service_identity_code
     * - fallback to the seeded ParkingSession / TariffSnapshot creator
     * - fallback to the latest active service identity
     */

    IF p_requested_by IS NOT NULL AND btrim(p_requested_by) <> '' THEN
        BEGIN
            v_requested_by_service_identity_id := p_requested_by::uuid;
        EXCEPTION
            WHEN invalid_text_representation THEN
                SELECT si.service_identity_id
                INTO v_requested_by_service_identity_id
                FROM identity.service_identities AS si
                WHERE si.service_identity_code = p_requested_by
                LIMIT 1;
        END;
    END IF;

    SELECT ps.*
    INTO v_session
    FROM core.parking_sessions AS ps
    WHERE ps.parking_session_id = p_parking_session_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            NULL::uuid,
            p_parking_session_id::uuid,
            p_tariff_snapshot_id::uuid,
            NULL::text,
            COALESCE(p_payment_provider_code, '')::text,
            FALSE::boolean,
            'PARKING_SESSION_NOT_FOUND'::text,
            'PARKING_SESSION_NOT_FOUND'::text,
            0::numeric,
            0::numeric,
            0::numeric,
            0::numeric,
            ''::text,
            NULL::text;
        RETURN;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        v_requested_by_service_identity_id := v_session.created_by_service_identity_id;
    END IF;

    SELECT ts.*
    INTO v_tariff
    FROM core.tariff_snapshots AS ts
    WHERE ts.tariff_snapshot_id = p_tariff_snapshot_id
      AND ts.parking_session_id = p_parking_session_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            NULL::uuid,
            p_parking_session_id::uuid,
            p_tariff_snapshot_id::uuid,
            NULL::text,
            COALESCE(p_payment_provider_code, '')::text,
            FALSE::boolean,
            'TARIFF_SNAPSHOT_NOT_FOUND'::text,
            'TARIFF_SNAPSHOT_NOT_FOUND'::text,
            0::numeric,
            0::numeric,
            0::numeric,
            0::numeric,
            ''::text,
            NULL::text;
        RETURN;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        v_requested_by_service_identity_id := v_tariff.created_by_service_identity_id;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        SELECT si.service_identity_id
        INTO v_requested_by_service_identity_id
        FROM identity.service_identities AS si
        WHERE si.identity_status = 'ACTIVE'
        ORDER BY si.created_at DESC
        LIMIT 1;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        RETURN QUERY
        SELECT
            NULL::uuid,
            p_parking_session_id::uuid,
            p_tariff_snapshot_id::uuid,
            NULL::text,
            COALESCE(p_payment_provider_code, '')::text,
            FALSE::boolean,
            'REQUESTED_BY_SERVICE_IDENTITY_NOT_FOUND'::text,
            'REQUESTED_BY_SERVICE_IDENTITY_NOT_FOUND'::text,
            COALESCE(v_tariff.gross_amount, 0)::numeric,
            COALESCE(v_tariff.statutory_discount_amount, 0)::numeric,
            COALESCE(v_tariff.coupon_discount_amount, 0)::numeric,
            COALESCE(v_tariff.net_amount, 0)::numeric,
            COALESCE(v_tariff.currency_code::text, '')::text,
            v_tariff.tariff_version_reference::text;
        RETURN;
    END IF;

    /*
     * Idempotency replay.
     */
    SELECT pa.*
    INTO v_existing
    FROM core.payment_attempts AS pa
    WHERE pa.idempotency_key = p_idempotency_key
    LIMIT 1;

    IF FOUND THEN
        RETURN QUERY
        SELECT
            v_existing.payment_attempt_id::uuid,
            v_existing.parking_session_id::uuid,
            v_existing.tariff_snapshot_id::uuid,
            v_existing.attempt_status::text,
            COALESCE(p_payment_provider_code, v_resolved_payment_provider_code, '')::text,
            TRUE::boolean,
            'REUSED_BY_IDEMPOTENCY_KEY'::text,
            NULL::text,
            COALESCE(v_tariff.gross_amount, v_existing.amount)::numeric,
            COALESCE(v_tariff.statutory_discount_amount, 0)::numeric,
            COALESCE(v_tariff.coupon_discount_amount, 0)::numeric,
            v_existing.amount::numeric,
            v_existing.currency_code::text,
            v_tariff.tariff_version_reference::text;
        RETURN;
    END IF;

    /*
     * One active payment attempt per ParkingSession.
     */
    SELECT pa.*
    INTO v_existing
    FROM core.payment_attempts AS pa
    WHERE pa.parking_session_id = p_parking_session_id
      AND pa.attempt_status IN (
          'REQUESTED',
          'PENDING_PROVIDER',
          'PENDING_FINALIZATION'
      )
    ORDER BY pa.created_at DESC
    LIMIT 1;

    IF FOUND THEN
        RETURN QUERY
        SELECT
            v_existing.payment_attempt_id::uuid,
            v_existing.parking_session_id::uuid,
            v_existing.tariff_snapshot_id::uuid,
            v_existing.attempt_status::text,
            COALESCE(p_payment_provider_code, v_resolved_payment_provider_code, '')::text,
            TRUE::boolean,
            'ACTIVE_ATTEMPT_EXISTS'::text,
            NULL::text,
            COALESCE(v_tariff.gross_amount, v_existing.amount)::numeric,
            COALESCE(v_tariff.statutory_discount_amount, 0)::numeric,
            COALESCE(v_tariff.coupon_discount_amount, 0)::numeric,
            v_existing.amount::numeric,
            v_existing.currency_code::text,
            v_tariff.tariff_version_reference::text;
        RETURN;
    END IF;

    /*
     * TariffSnapshot eligibility.
     */
    IF v_tariff.snapshot_status <> 'ACTIVE'
       OR v_tariff.consumed_at IS NOT NULL
       OR v_tariff.expires_at <= p_now
       OR v_tariff.superseded_by_tariff_snapshot_id IS NOT NULL THEN
        RETURN QUERY
        SELECT
            NULL::uuid,
            p_parking_session_id::uuid,
            p_tariff_snapshot_id::uuid,
            NULL::text,
            COALESCE(p_payment_provider_code, '')::text,
            FALSE::boolean,
            'TARIFF_SNAPSHOT_NOT_ELIGIBLE'::text,
            'TARIFF_SNAPSHOT_NOT_ELIGIBLE'::text,
            v_tariff.gross_amount::numeric,
            v_tariff.statutory_discount_amount::numeric,
            v_tariff.coupon_discount_amount::numeric,
            v_tariff.net_amount::numeric,
            v_tariff.currency_code::text,
            v_tariff.tariff_version_reference::text;
        RETURN;
    END IF;

    /*
     * Resolve payment rail.
     *
     * payment_rail_id is stored for internal settlement/routing.
     * The returned payment_provider_code preserves p_payment_provider_code because the public API/test
     * expects the requested method/rail code, for example GCASH, not the backend provider, for example PAYMONGO.
     */
    SELECT pr.payment_rail_id, pr.provider_code
    INTO v_payment_rail_id, v_resolved_payment_provider_code
    FROM payments.payment_rails AS pr
    WHERE pr.rail_status = 'ACTIVE'
      AND pr.supported_currency_code = v_tariff.currency_code
      AND (
             pr.provider_code = p_payment_provider_code
          OR pr.rail_code = p_payment_provider_code
      )
      AND pr.effective_from <= p_now
      AND (pr.effective_to IS NULL OR pr.effective_to > p_now)
    ORDER BY pr.is_primary DESC, pr.created_at ASC
    LIMIT 1;

    IF v_payment_rail_id IS NULL THEN
        SELECT pr.payment_rail_id, pr.provider_code
        INTO v_payment_rail_id, v_resolved_payment_provider_code
        FROM payments.payment_rails AS pr
        WHERE pr.rail_status = 'ACTIVE'
          AND pr.supported_currency_code = v_tariff.currency_code
          AND pr.effective_from <= p_now
          AND (pr.effective_to IS NULL OR pr.effective_to > p_now)
        ORDER BY pr.is_primary DESC, pr.created_at ASC
        LIMIT 1;
    END IF;

    IF v_payment_rail_id IS NULL THEN
        RETURN QUERY
        SELECT
            NULL::uuid,
            p_parking_session_id::uuid,
            p_tariff_snapshot_id::uuid,
            NULL::text,
            COALESCE(p_payment_provider_code, '')::text,
            FALSE::boolean,
            'PAYMENT_RAIL_NOT_FOUND'::text,
            'PAYMENT_RAIL_NOT_FOUND'::text,
            v_tariff.gross_amount::numeric,
            v_tariff.statutory_discount_amount::numeric,
            v_tariff.coupon_discount_amount::numeric,
            v_tariff.net_amount::numeric,
            v_tariff.currency_code::text,
            v_tariff.tariff_version_reference::text;
        RETURN;
    END IF;

    /*
     * Create PaymentAttempt from immutable TariffSnapshot payable basis.
     */
    INSERT INTO core.payment_attempts (
        payment_attempt_id,
        parking_session_id,
        tariff_snapshot_id,
        idempotency_key,
        payment_rail_id,
        currency_code,
        amount,
        attempt_status,
        requested_at,
        expires_at,
        finalized_at,
        failure_reason_code,
        correlation_id,
        created_at,
        created_by_service_identity_id,
        updated_at,
        updated_by_service_identity_id,
        row_version
    )
    VALUES (
        gen_random_uuid(),
        p_parking_session_id,
        p_tariff_snapshot_id,
        p_idempotency_key,
        v_payment_rail_id,
        v_tariff.currency_code,
        v_tariff.net_amount,
        'REQUESTED',
        p_now,
        p_now + INTERVAL '15 minutes',
        NULL,
        NULL,
        p_correlation_id,
        p_now,
        v_requested_by_service_identity_id,
        p_now,
        v_requested_by_service_identity_id,
        1
    )
    RETURNING *
    INTO v_created;

    UPDATE core.tariff_snapshots AS ts
    SET
        consumed_at = p_now,
        snapshot_status = 'CONSUMED',
        updated_at = p_now,
        updated_by_service_identity_id = v_requested_by_service_identity_id,
        row_version = ts.row_version + 1
    WHERE ts.tariff_snapshot_id = p_tariff_snapshot_id;

    RETURN QUERY
    SELECT
        v_created.payment_attempt_id::uuid,
        v_created.parking_session_id::uuid,
        v_created.tariff_snapshot_id::uuid,
        v_created.attempt_status::text,
        COALESCE(p_payment_provider_code, v_resolved_payment_provider_code, '')::text,
        FALSE::boolean,
        'CREATED'::text,
        NULL::text,
        v_tariff.gross_amount::numeric,
        v_tariff.statutory_discount_amount::numeric,
        v_tariff.coupon_discount_amount::numeric,
        v_tariff.net_amount::numeric,
        v_tariff.currency_code::text,
        v_tariff.tariff_version_reference::text;
END;
$$;


--
-- Name: finalize_payment_attempt(uuid, text, text, uuid, timestamp with time zone); Type: FUNCTION; Schema: core; Owner: -
--

CREATE FUNCTION core.finalize_payment_attempt(p_payment_attempt_id uuid, p_final_attempt_status text, p_requested_by text, p_correlation_id uuid, p_now timestamp with time zone) RETURNS TABLE(payment_attempt_id uuid, attempt_status text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_attempt core.payment_attempts%ROWTYPE;
    v_requested_by_service_identity_id uuid;
    v_final_attempt_status text;
BEGIN
    v_final_attempt_status := NULLIF(upper(btrim(p_final_attempt_status)), '');

    IF v_final_attempt_status IS NULL THEN
        RAISE EXCEPTION 'final attempt status is required'
            USING ERRCODE = '22023';
    END IF;

    IF v_final_attempt_status NOT IN ('CONFIRMED', 'FAILED', 'EXPIRED', 'CANCELLED') THEN
        RAISE EXCEPTION 'final attempt status % is not supported for finalization', v_final_attempt_status
            USING ERRCODE = '22023';
    END IF;

    IF p_requested_by IS NOT NULL AND btrim(p_requested_by) <> '' THEN
        BEGIN
            v_requested_by_service_identity_id := p_requested_by::uuid;
        EXCEPTION
            WHEN invalid_text_representation THEN
                SELECT si.service_identity_id
                INTO v_requested_by_service_identity_id
                FROM identity.service_identities AS si
                WHERE si.service_identity_code = p_requested_by
                LIMIT 1;
        END;
    END IF;

    SELECT pa.*
    INTO v_attempt
    FROM core.payment_attempts AS pa
    WHERE pa.payment_attempt_id = p_payment_attempt_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'payment attempt % was not found', p_payment_attempt_id
            USING ERRCODE = 'P0002';
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        v_requested_by_service_identity_id := v_attempt.updated_by_service_identity_id;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        v_requested_by_service_identity_id := v_attempt.created_by_service_identity_id;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        SELECT si.service_identity_id
        INTO v_requested_by_service_identity_id
        FROM identity.service_identities AS si
        WHERE si.identity_status = 'ACTIVE'
        ORDER BY si.created_at DESC
        LIMIT 1;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        RAISE EXCEPTION 'requested_by service identity could not be resolved'
            USING ERRCODE = 'P0002';
    END IF;

    IF v_attempt.attempt_status IN ('CONFIRMED', 'FAILED', 'EXPIRED', 'CANCELLED') THEN
        IF v_attempt.attempt_status::text = v_final_attempt_status THEN
            RETURN QUERY
            SELECT
                v_attempt.payment_attempt_id::uuid,
                v_attempt.attempt_status::text;
            RETURN;
        END IF;

        RAISE EXCEPTION 'payment attempt % is already final with status %', p_payment_attempt_id, v_attempt.attempt_status
            USING ERRCODE = 'P0001';
    END IF;

    UPDATE core.payment_attempts AS pa
    SET
        attempt_status = v_final_attempt_status::core.payment_attempt_status_enum,
        finalized_at = p_now,
        failure_reason_code = CASE
            WHEN v_final_attempt_status = 'FAILED' THEN 'PROVIDER_REPORTED_FAILURE'
            WHEN v_final_attempt_status IN ('EXPIRED', 'CANCELLED') THEN v_final_attempt_status
            ELSE NULL
        END,
        correlation_id = COALESCE(p_correlation_id, pa.correlation_id),
        updated_at = p_now,
        updated_by_service_identity_id = v_requested_by_service_identity_id,
        row_version = pa.row_version + 1
    WHERE pa.payment_attempt_id = p_payment_attempt_id
    RETURNING pa.*
    INTO v_attempt;

    RETURN QUERY
    SELECT
        v_attempt.payment_attempt_id::uuid,
        v_attempt.attempt_status::text;
END;
$$;


--
-- Name: issue_exit_authorization(); Type: FUNCTION; Schema: core; Owner: -
--

CREATE FUNCTION core.issue_exit_authorization() RETURNS void
    LANGUAGE plpgsql
    AS $$ BEGIN RAISE EXCEPTION 'core.issue_exit_authorization is a v1.2 routine placeholder and must be implemented before production use'; END; $$;


--
-- Name: issue_exit_authorization(uuid, uuid, uuid, uuid, timestamp with time zone); Type: FUNCTION; Schema: core; Owner: -
--

CREATE FUNCTION core.issue_exit_authorization(p_parking_session_id uuid, p_payment_attempt_id uuid, p_requested_by uuid, p_correlation_id uuid, p_now timestamp with time zone) RETURNS TABLE(exit_authorization_id uuid, parking_session_id uuid, payment_attempt_id uuid, authorization_token text, authorization_status text, issued_at timestamp with time zone, expiration_timestamp timestamp with time zone)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_attempt core.payment_attempts%ROWTYPE;
    v_confirmation core.payment_confirmations%ROWTYPE;
    v_authorization core.exit_authorizations%ROWTYPE;
    v_requested_by_service_identity_id uuid;
    v_authorization_token text;
BEGIN
    SELECT pa.*
    INTO v_attempt
    FROM core.payment_attempts AS pa
    WHERE pa.payment_attempt_id = p_payment_attempt_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'payment attempt % was not found', p_payment_attempt_id
            USING ERRCODE = 'P0002';
    END IF;

    IF v_attempt.parking_session_id <> p_parking_session_id THEN
        RAISE EXCEPTION 'payment attempt % does not belong to parking session %', p_payment_attempt_id, p_parking_session_id
            USING ERRCODE = 'P0001';
    END IF;

    SELECT ea.*
    INTO v_authorization
    FROM core.exit_authorizations AS ea
    WHERE ea.payment_attempt_id = p_payment_attempt_id
    FOR UPDATE;

    IF FOUND THEN
        RETURN QUERY
        SELECT
            v_authorization.exit_authorization_id::uuid,
            v_authorization.parking_session_id::uuid,
            v_authorization.payment_attempt_id::uuid,
            v_authorization.exit_authorization_id::text,
            v_authorization.authorization_status::text,
            v_authorization.issued_at::timestamptz,
            v_authorization.expires_at::timestamptz;
        RETURN;
    END IF;

    IF v_attempt.attempt_status <> 'CONFIRMED' THEN
        RAISE EXCEPTION 'payment attempt % is not confirmed', p_payment_attempt_id
            USING ERRCODE = 'P0001';
    END IF;

    SELECT pc.*
    INTO v_confirmation
    FROM core.payment_confirmations AS pc
    WHERE pc.payment_attempt_id = p_payment_attempt_id
      AND pc.confirmation_status = 'RECORDED'
    ORDER BY pc.confirmed_at DESC, pc.created_at DESC
    LIMIT 1;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'payment attempt % has no recorded payment confirmation', p_payment_attempt_id
            USING ERRCODE = 'P0001';
    END IF;

    IF v_confirmation.payment_attempt_id <> v_attempt.payment_attempt_id THEN
        RAISE EXCEPTION 'payment confirmation % is not anchored to payment attempt %', v_confirmation.payment_confirmation_id, p_payment_attempt_id
            USING ERRCODE = 'P0001';
    END IF;

    SELECT si.service_identity_id
    INTO v_requested_by_service_identity_id
    FROM identity.service_identities AS si
    WHERE si.service_identity_id = p_requested_by
    LIMIT 1;

    IF v_requested_by_service_identity_id IS NULL THEN
        v_requested_by_service_identity_id := v_attempt.updated_by_service_identity_id;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        v_requested_by_service_identity_id := v_confirmation.created_by_service_identity_id;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        v_requested_by_service_identity_id := v_attempt.created_by_service_identity_id;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        RAISE EXCEPTION 'requested_by service identity could not be resolved'
            USING ERRCODE = 'P0002';
    END IF;

    v_authorization_token := 'EXIT-' || replace(gen_random_uuid()::text, '-', '');

    INSERT INTO core.exit_authorizations (
        exit_authorization_id,
        parking_session_id,
        payment_attempt_id,
        payment_confirmation_id,
        authorization_token_hash,
        authorization_status,
        issued_at,
        expires_at,
        correlation_id,
        created_at,
        created_by_service_identity_id,
        updated_at,
        updated_by_service_identity_id
    )
    VALUES (
        gen_random_uuid(),
        v_attempt.parking_session_id,
        v_attempt.payment_attempt_id,
        v_confirmation.payment_confirmation_id,
        encode(digest(v_authorization_token, 'sha256'), 'hex'),
        'ISSUED',
        p_now,
        p_now + interval '15 minutes',
        p_correlation_id,
        p_now,
        v_requested_by_service_identity_id,
        p_now,
        v_requested_by_service_identity_id
    )
    RETURNING *
    INTO v_authorization;

    RETURN QUERY
    SELECT
        v_authorization.exit_authorization_id::uuid,
        v_authorization.parking_session_id::uuid,
        v_authorization.payment_attempt_id::uuid,
        v_authorization_token::text,
        v_authorization.authorization_status::text,
        v_authorization.issued_at::timestamptz,
        v_authorization.expires_at::timestamptz;
END;
$$;


--
-- Name: record_payment_confirmation(); Type: FUNCTION; Schema: core; Owner: -
--

CREATE FUNCTION core.record_payment_confirmation() RETURNS void
    LANGUAGE plpgsql
    AS $$ BEGIN RAISE EXCEPTION 'core.record_payment_confirmation is a v1.2 routine placeholder and must be implemented before production use'; END; $$;


--
-- Name: record_payment_confirmation(uuid, text, text, text, uuid, timestamp with time zone); Type: FUNCTION; Schema: core; Owner: -
--

CREATE FUNCTION core.record_payment_confirmation(p_payment_attempt_id uuid, p_provider_reference text, p_provider_status text, p_requested_by text, p_correlation_id uuid, p_now timestamp with time zone) RETURNS TABLE(payment_confirmation_id uuid, payment_attempt_id uuid, provider_reference text, provider_status text, verified_timestamp timestamp with time zone)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_attempt core.payment_attempts%ROWTYPE;
    v_confirmation core.payment_confirmations%ROWTYPE;
    v_requested_by_service_identity_id uuid;
    v_normalized_provider_reference text;
    v_normalized_provider_status text;
BEGIN
    v_normalized_provider_reference := NULLIF(btrim(p_provider_reference), '');
    v_normalized_provider_status := NULLIF(upper(btrim(p_provider_status)), '');

    IF v_normalized_provider_reference IS NULL THEN
        RAISE EXCEPTION 'provider reference is required'
            USING ERRCODE = '22023';
    END IF;

    IF v_normalized_provider_status IS NULL THEN
        RAISE EXCEPTION 'provider status is required'
            USING ERRCODE = '22023';
    END IF;

    IF p_requested_by IS NOT NULL AND btrim(p_requested_by) <> '' THEN
        BEGIN
            v_requested_by_service_identity_id := p_requested_by::uuid;
        EXCEPTION
            WHEN invalid_text_representation THEN
                SELECT si.service_identity_id
                INTO v_requested_by_service_identity_id
                FROM identity.service_identities AS si
                WHERE si.service_identity_code = p_requested_by
                LIMIT 1;
        END;
    END IF;

    SELECT pa.*
    INTO v_attempt
    FROM core.payment_attempts AS pa
    WHERE pa.payment_attempt_id = p_payment_attempt_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'payment attempt % was not found', p_payment_attempt_id
            USING ERRCODE = 'P0002';
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        v_requested_by_service_identity_id := v_attempt.updated_by_service_identity_id;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        v_requested_by_service_identity_id := v_attempt.created_by_service_identity_id;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        SELECT si.service_identity_id
        INTO v_requested_by_service_identity_id
        FROM identity.service_identities AS si
        WHERE si.identity_status = 'ACTIVE'
        ORDER BY si.created_at DESC
        LIMIT 1;
    END IF;

    IF v_requested_by_service_identity_id IS NULL THEN
        RAISE EXCEPTION 'requested_by service identity could not be resolved'
            USING ERRCODE = 'P0002';
    END IF;

    SELECT pc.*
    INTO v_confirmation
    FROM core.payment_confirmations AS pc
    WHERE pc.payment_attempt_id = p_payment_attempt_id
    FOR UPDATE;

    IF FOUND THEN
        IF v_confirmation.provider_transaction_ref = v_normalized_provider_reference THEN
            /*
             * ExitPass v1.2 BRD 10.7.10 and SDD 7.3 require retry-safe provider webhook handling.
             * The canonical invariant is same PaymentAttempt + same provider reference => same evidence row.
             */
            RETURN QUERY
            SELECT
                v_confirmation.payment_confirmation_id::uuid,
                v_confirmation.payment_attempt_id::uuid,
                v_confirmation.provider_transaction_ref::text,
                v_normalized_provider_status::text,
                v_confirmation.verified_at::timestamptz;
            RETURN;
        END IF;

        RAISE EXCEPTION 'payment confirmation already exists for payment attempt %', p_payment_attempt_id
            USING
                ERRCODE = '23505',
                CONSTRAINT = 'uq_payment_confirmations__payment_attempt';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM core.payment_confirmations AS pc
        WHERE pc.payment_rail_id IS NOT DISTINCT FROM v_attempt.payment_rail_id
          AND pc.provider_transaction_ref = v_normalized_provider_reference
    ) THEN
        RAISE EXCEPTION 'provider reference % has already been recorded', v_normalized_provider_reference
            USING
                ERRCODE = '23505',
                CONSTRAINT = 'ux_payment_confirmations__provider_transaction_ref';
    END IF;

    INSERT INTO core.payment_confirmations (
        payment_confirmation_id,
        payment_attempt_id,
        provider_outcome_id,
        payment_rail_id,
        provider_transaction_ref,
        currency_code,
        confirmed_amount,
        confirmation_status,
        verified_at,
        confirmed_at,
        correlation_id,
        created_at,
        created_by_service_identity_id
    )
    VALUES (
        gen_random_uuid(),
        p_payment_attempt_id,
        NULL,
        v_attempt.payment_rail_id,
        v_normalized_provider_reference,
        v_attempt.currency_code,
        v_attempt.amount,
        'RECORDED',
        p_now,
        p_now,
        p_correlation_id,
        p_now,
        v_requested_by_service_identity_id
    )
    RETURNING *
    INTO v_confirmation;

    IF v_normalized_provider_status IN ('SUCCESS', 'SUCCEEDED', 'PAID', 'CONFIRMED') THEN
        UPDATE core.payment_attempts AS pa
        SET
            attempt_status = 'CONFIRMED',
            finalized_at = COALESCE(pa.finalized_at, p_now),
            failure_reason_code = NULL,
            updated_at = p_now,
            updated_by_service_identity_id = v_requested_by_service_identity_id,
            row_version = pa.row_version + 1
        WHERE pa.payment_attempt_id = p_payment_attempt_id;
    ELSIF v_normalized_provider_status IN ('FAILED', 'DECLINED', 'CANCELLED', 'EXPIRED') THEN
        UPDATE core.payment_attempts AS pa
        SET
            attempt_status = 'FAILED',
            finalized_at = COALESCE(pa.finalized_at, p_now),
            failure_reason_code = v_normalized_provider_status,
            updated_at = p_now,
            updated_by_service_identity_id = v_requested_by_service_identity_id,
            row_version = pa.row_version + 1
        WHERE pa.payment_attempt_id = p_payment_attempt_id;
    END IF;

    RETURN QUERY
    SELECT
        v_confirmation.payment_confirmation_id::uuid,
        v_confirmation.payment_attempt_id::uuid,
        v_confirmation.provider_transaction_ref::text,
        v_normalized_provider_status::text,
        v_confirmation.verified_at::timestamptz;
END;
$$;


--
-- Name: commit_coupon_application(); Type: FUNCTION; Schema: coupons; Owner: -
--

CREATE FUNCTION coupons.commit_coupon_application() RETURNS void
    LANGUAGE plpgsql
    AS $$ BEGIN RAISE EXCEPTION 'coupons.commit_coupon_application is a v1.2 routine placeholder and must be implemented before production use'; END; $$;


--
-- Name: release_coupon_application(); Type: FUNCTION; Schema: coupons; Owner: -
--

CREATE FUNCTION coupons.release_coupon_application() RETURNS void
    LANGUAGE plpgsql
    AS $$ BEGIN RAISE EXCEPTION 'coupons.release_coupon_application is a v1.2 routine placeholder and must be implemented before production use'; END; $$;


--
-- Name: reserve_coupon_application(); Type: FUNCTION; Schema: coupons; Owner: -
--

CREATE FUNCTION coupons.reserve_coupon_application() RETURNS void
    LANGUAGE plpgsql
    AS $$ BEGIN RAISE EXCEPTION 'coupons.reserve_coupon_application is a v1.2 routine placeholder and must be implemented before production use'; END; $$;


--
-- Name: record_statutory_discount_validation(); Type: FUNCTION; Schema: discounts; Owner: -
--

CREATE FUNCTION discounts.record_statutory_discount_validation() RETURNS void
    LANGUAGE plpgsql
    AS $$ BEGIN RAISE EXCEPTION 'discounts.record_statutory_discount_validation is a v1.2 routine placeholder and must be implemented before production use'; END; $$;


--
-- Name: enqueue_outbox_event(); Type: FUNCTION; Schema: events; Owner: -
--

CREATE FUNCTION events.enqueue_outbox_event() RETURNS void
    LANGUAGE plpgsql
    AS $$ BEGIN RAISE EXCEPTION 'events.enqueue_outbox_event is a v1.2 routine placeholder and must be implemented before production use'; END; $$;


--
-- Name: consume_exit_authorization(); Type: FUNCTION; Schema: gates; Owner: -
--

CREATE FUNCTION gates.consume_exit_authorization() RETURNS void
    LANGUAGE plpgsql
    AS $$ BEGIN RAISE EXCEPTION 'gates.consume_exit_authorization is a v1.2 routine placeholder and must be implemented before production use'; END; $$;


--
-- Name: record_manual_gate_log(); Type: FUNCTION; Schema: operations; Owner: -
--

CREATE FUNCTION operations.record_manual_gate_log() RETURNS void
    LANGUAGE plpgsql
    AS $$ BEGIN RAISE EXCEPTION 'operations.record_manual_gate_log is a v1.2 routine placeholder and must be implemented before production use'; END; $$;


--
-- Name: import_mops_transaction_record(); Type: FUNCTION; Schema: reconciliation; Owner: -
--

CREATE FUNCTION reconciliation.import_mops_transaction_record() RETURNS void
    LANGUAGE plpgsql
    AS $$ BEGIN RAISE EXCEPTION 'reconciliation.import_mops_transaction_record is a v1.2 routine placeholder and must be implemented before production use'; END; $$;


--
-- Name: resolve_reconciliation_item(); Type: FUNCTION; Schema: reconciliation; Owner: -
--

CREATE FUNCTION reconciliation.resolve_reconciliation_item() RETURNS void
    LANGUAGE plpgsql
    AS $$ BEGIN RAISE EXCEPTION 'reconciliation.resolve_reconciliation_item is a v1.2 routine placeholder and must be implemented before production use'; END; $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_events; Type: TABLE; Schema: audit; Owner: -
--

CREATE TABLE audit.audit_events (
    audit_event_id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_type character varying(96) NOT NULL,
    event_category audit.audit_event_category_enum NOT NULL,
    event_result audit.audit_event_result_enum NOT NULL,
    event_reason_code character varying(64),
    target_entity_type character varying(64),
    target_entity_id uuid,
    related_entity_type character varying(64),
    related_entity_id uuid,
    source_schema character varying(64),
    source_service_name character varying(128),
    source_channel character varying(64),
    actor_user_id uuid,
    actor_service_identity_id uuid,
    actor_ip_hash character(64),
    actor_user_agent_hash character(64),
    summary character varying(256),
    details_ref character varying(256),
    details_hash character(64),
    occurred_at timestamp with time zone NOT NULL,
    recorded_at timestamp with time zone DEFAULT now() NOT NULL,
    correlation_id uuid,
    causation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_service_identity_id uuid
);


--
-- Name: TABLE audit_events; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON TABLE audit.audit_events IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN audit_events.audit_event_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_events.audit_event_id IS 'Canonical identifier of the audit event.';


--
-- Name: COLUMN audit_events.event_type; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_events.event_type IS 'Controlled audit event type.';


--
-- Name: COLUMN audit_events.event_category; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_events.event_category IS 'Audit event category.';


--
-- Name: COLUMN audit_events.event_result; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_events.event_result IS 'Event result classification.';


--
-- Name: COLUMN audit_events.event_reason_code; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_events.event_reason_code IS 'Controlled reason code explaining result.';


--
-- Name: COLUMN audit_events.target_entity_type; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_events.target_entity_type IS 'Type of affected domain entity.';


--
-- Name: COLUMN audit_events.target_entity_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_events.target_entity_id IS 'Identifier of affected domain entity.';


--
-- Name: COLUMN audit_events.related_entity_type; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_events.related_entity_type IS 'Type of related domain entity, where applicable.';


--
-- Name: COLUMN audit_events.related_entity_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_events.related_entity_id IS 'Identifier of related domain entity.';


--
-- Name: COLUMN audit_events.source_schema; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_events.source_schema IS 'Source schema or domain that produced the audit event.';


--
-- Name: COLUMN audit_events.source_service_name; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_events.source_service_name IS 'Source service that produced the event.';


--
-- Name: COLUMN audit_events.source_channel; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_events.source_channel IS 'Source channel, such as Web Pay, API, worker, gate, or admin UI.';


--
-- Name: COLUMN audit_events.actor_user_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_events.actor_user_id IS 'Human actor, where applicable.';


--
-- Name: COLUMN audit_events.actor_service_identity_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_events.actor_service_identity_id IS 'Service, adapter, job, or device actor, where applicable.';


--
-- Name: COLUMN audit_events.actor_ip_hash; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_events.actor_ip_hash IS 'Hash of actor IP where retained.';


--
-- Name: COLUMN audit_events.actor_user_agent_hash; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_events.actor_user_agent_hash IS 'Hash of user agent where retained.';


--
-- Name: COLUMN audit_events.summary; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_events.summary IS 'Short audit summary.';


--
-- Name: COLUMN audit_events.details_ref; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_events.details_ref IS 'Reference to structured audit details if stored separately.';


--
-- Name: COLUMN audit_events.details_hash; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_events.details_hash IS 'Hash of details payload where retained.';


--
-- Name: COLUMN audit_events.occurred_at; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_events.occurred_at IS 'Timestamp when audited event occurred.';


--
-- Name: COLUMN audit_events.recorded_at; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_events.recorded_at IS 'Timestamp when audit event was recorded.';


--
-- Name: COLUMN audit_events.correlation_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_events.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN audit_events.causation_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_events.causation_id IS 'Causation identifier where applicable.';


--
-- Name: COLUMN audit_events.created_at; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_events.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN audit_events.created_by_service_identity_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_events.created_by_service_identity_id IS 'Service identity that wrote the audit event.';


--
-- Name: audit_trail_entries; Type: TABLE; Schema: audit; Owner: -
--

CREATE TABLE audit.audit_trail_entries (
    audit_trail_entry_id uuid DEFAULT gen_random_uuid() NOT NULL,
    audit_event_id uuid,
    change_type audit.audit_change_type_enum NOT NULL,
    target_entity_type character varying(64) NOT NULL,
    target_entity_id uuid NOT NULL,
    field_name character varying(128),
    before_value_hash character(64),
    after_value_hash character(64),
    before_value_redacted text,
    after_value_redacted text,
    change_summary character varying(256),
    change_reason_code character varying(64),
    changed_at timestamp with time zone NOT NULL,
    changed_by_user_id uuid,
    changed_by_service_identity_id uuid,
    approval_reference_type character varying(64),
    approval_reference_id uuid,
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_service_identity_id uuid
);


--
-- Name: TABLE audit_trail_entries; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON TABLE audit.audit_trail_entries IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN audit_trail_entries.audit_trail_entry_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_trail_entries.audit_trail_entry_id IS 'Canonical identifier of the audit trail entry.';


--
-- Name: COLUMN audit_trail_entries.audit_event_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_trail_entries.audit_event_id IS 'Parent audit event, where applicable.';


--
-- Name: COLUMN audit_trail_entries.change_type; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_trail_entries.change_type IS 'Type of change recorded.';


--
-- Name: COLUMN audit_trail_entries.target_entity_type; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_trail_entries.target_entity_type IS 'Type of changed entity.';


--
-- Name: COLUMN audit_trail_entries.target_entity_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_trail_entries.target_entity_id IS 'Identifier of changed entity.';


--
-- Name: COLUMN audit_trail_entries.field_name; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_trail_entries.field_name IS 'Field that changed, if field-level trail is used.';


--
-- Name: COLUMN audit_trail_entries.before_value_hash; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_trail_entries.before_value_hash IS 'Hash of previous value where value is sensitive or large.';


--
-- Name: COLUMN audit_trail_entries.after_value_hash; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_trail_entries.after_value_hash IS 'Hash of new value where value is sensitive or large.';


--
-- Name: COLUMN audit_trail_entries.before_value_redacted; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_trail_entries.before_value_redacted IS 'Redacted before value, where allowed.';


--
-- Name: COLUMN audit_trail_entries.after_value_redacted; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_trail_entries.after_value_redacted IS 'Redacted after value, where allowed.';


--
-- Name: COLUMN audit_trail_entries.change_summary; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_trail_entries.change_summary IS 'Short summary of change.';


--
-- Name: COLUMN audit_trail_entries.change_reason_code; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_trail_entries.change_reason_code IS 'Controlled reason for change.';


--
-- Name: COLUMN audit_trail_entries.changed_at; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_trail_entries.changed_at IS 'Timestamp when change occurred.';


--
-- Name: COLUMN audit_trail_entries.changed_by_user_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_trail_entries.changed_by_user_id IS 'Human actor responsible for change.';


--
-- Name: COLUMN audit_trail_entries.changed_by_service_identity_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_trail_entries.changed_by_service_identity_id IS 'Service actor responsible for change.';


--
-- Name: COLUMN audit_trail_entries.approval_reference_type; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_trail_entries.approval_reference_type IS 'Approval entity type, where change was approved.';


--
-- Name: COLUMN audit_trail_entries.approval_reference_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_trail_entries.approval_reference_id IS 'Approval entity ID, where change was approved.';


--
-- Name: COLUMN audit_trail_entries.correlation_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_trail_entries.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN audit_trail_entries.created_at; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_trail_entries.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN audit_trail_entries.created_by_service_identity_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.audit_trail_entries.created_by_service_identity_id IS 'Service identity that wrote the audit trail entry.';


--
-- Name: evidence_links; Type: TABLE; Schema: audit; Owner: -
--

CREATE TABLE audit.evidence_links (
    evidence_link_id uuid DEFAULT gen_random_uuid() NOT NULL,
    audit_event_id uuid,
    security_event_id uuid,
    target_entity_type character varying(64),
    target_entity_id uuid,
    evidence_type audit.evidence_type_enum NOT NULL,
    evidence_storage_type audit.evidence_storage_type_enum NOT NULL,
    evidence_storage_ref character varying(256),
    evidence_hash character(64),
    access_classification audit.evidence_access_classification_enum NOT NULL,
    retention_policy_code character varying(64) NOT NULL,
    retention_expires_at timestamp with time zone,
    redaction_status audit.evidence_redaction_status_enum NOT NULL,
    link_status audit.evidence_link_status_enum NOT NULL,
    linked_at timestamp with time zone DEFAULT now() NOT NULL,
    linked_by_user_id uuid,
    linked_by_service_identity_id uuid,
    purged_at timestamp with time zone,
    purged_by_user_id uuid,
    purged_by_service_identity_id uuid,
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_evidence_links__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE evidence_links; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON TABLE audit.evidence_links IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN evidence_links.evidence_link_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.evidence_links.evidence_link_id IS 'Canonical identifier of the evidence link.';


--
-- Name: COLUMN evidence_links.audit_event_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.evidence_links.audit_event_id IS 'Audit event supported by the evidence.';


--
-- Name: COLUMN evidence_links.security_event_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.evidence_links.security_event_id IS 'Security event supported by the evidence.';


--
-- Name: COLUMN evidence_links.target_entity_type; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.evidence_links.target_entity_type IS 'Domain entity type supported by the evidence.';


--
-- Name: COLUMN evidence_links.target_entity_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.evidence_links.target_entity_id IS 'Domain entity identifier supported by the evidence.';


--
-- Name: COLUMN evidence_links.evidence_type; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.evidence_links.evidence_type IS 'Type of evidence.';


--
-- Name: COLUMN evidence_links.evidence_storage_type; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.evidence_links.evidence_storage_type IS 'Storage mechanism or reference type.';


--
-- Name: COLUMN evidence_links.evidence_storage_ref; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.evidence_links.evidence_storage_ref IS 'Object key, evidence vault reference, URI reference, or controlled storage reference.';


--
-- Name: COLUMN evidence_links.evidence_hash; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.evidence_links.evidence_hash IS 'Hash of evidence content where retained.';


--
-- Name: COLUMN evidence_links.access_classification; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.evidence_links.access_classification IS 'Access classification.';


--
-- Name: COLUMN evidence_links.retention_policy_code; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.evidence_links.retention_policy_code IS 'Retention policy applied to evidence.';


--
-- Name: COLUMN evidence_links.retention_expires_at; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.evidence_links.retention_expires_at IS 'Timestamp when evidence becomes eligible for purge or redaction.';


--
-- Name: COLUMN evidence_links.redaction_status; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.evidence_links.redaction_status IS 'Redaction or minimization state.';


--
-- Name: COLUMN evidence_links.link_status; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.evidence_links.link_status IS 'Evidence link lifecycle state.';


--
-- Name: COLUMN evidence_links.linked_at; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.evidence_links.linked_at IS 'Timestamp when evidence was linked.';


--
-- Name: COLUMN evidence_links.linked_by_user_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.evidence_links.linked_by_user_id IS 'User who linked the evidence.';


--
-- Name: COLUMN evidence_links.linked_by_service_identity_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.evidence_links.linked_by_service_identity_id IS 'Service identity that linked the evidence.';


--
-- Name: COLUMN evidence_links.purged_at; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.evidence_links.purged_at IS 'Timestamp when evidence payload was purged, if applicable.';


--
-- Name: COLUMN evidence_links.purged_by_user_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.evidence_links.purged_by_user_id IS 'User who purged the evidence.';


--
-- Name: COLUMN evidence_links.purged_by_service_identity_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.evidence_links.purged_by_service_identity_id IS 'Service identity that purged the evidence.';


--
-- Name: COLUMN evidence_links.correlation_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.evidence_links.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN evidence_links.created_at; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.evidence_links.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN evidence_links.created_by_user_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.evidence_links.created_by_user_id IS 'User who created the evidence link.';


--
-- Name: COLUMN evidence_links.created_by_service_identity_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.evidence_links.created_by_service_identity_id IS 'Service identity that created the evidence link.';


--
-- Name: COLUMN evidence_links.updated_at; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.evidence_links.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN evidence_links.updated_by_user_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.evidence_links.updated_by_user_id IS 'User who last updated the evidence link.';


--
-- Name: COLUMN evidence_links.updated_by_service_identity_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.evidence_links.updated_by_service_identity_id IS 'Service identity that last updated the evidence link.';


--
-- Name: COLUMN evidence_links.row_version; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.evidence_links.row_version IS 'Optimistic concurrency version.';


--
-- Name: security_events; Type: TABLE; Schema: audit; Owner: -
--

CREATE TABLE audit.security_events (
    security_event_id uuid DEFAULT gen_random_uuid() NOT NULL,
    audit_event_id uuid,
    security_event_type character varying(96) NOT NULL,
    security_event_category audit.security_event_category_enum NOT NULL,
    security_severity audit.security_severity_enum NOT NULL,
    security_event_status audit.security_event_status_enum NOT NULL,
    result audit.security_event_result_enum NOT NULL,
    reason_code character varying(64),
    target_entity_type character varying(64),
    target_entity_id uuid,
    actor_user_id uuid,
    actor_service_identity_id uuid,
    source_ip_hash character(64),
    user_agent_hash character(64),
    request_fingerprint_hash character(64),
    incident_record_id uuid,
    detected_at timestamp with time zone NOT NULL,
    recorded_at timestamp with time zone DEFAULT now() NOT NULL,
    resolved_at timestamp with time zone,
    resolved_by_user_id uuid,
    resolution_reason_code character varying(64),
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_security_events__resolved_after_detected CHECK (((resolved_at IS NULL) OR (resolved_at >= detected_at))),
    CONSTRAINT ck_security_events__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE security_events; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON TABLE audit.security_events IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN security_events.security_event_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.security_events.security_event_id IS 'Canonical identifier of the security event.';


--
-- Name: COLUMN security_events.audit_event_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.security_events.audit_event_id IS 'Related audit event, where applicable.';


--
-- Name: COLUMN security_events.security_event_type; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.security_events.security_event_type IS 'Controlled security event type.';


--
-- Name: COLUMN security_events.security_event_category; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.security_events.security_event_category IS 'Security event category.';


--
-- Name: COLUMN security_events.security_severity; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.security_events.security_severity IS 'Severity of security event.';


--
-- Name: COLUMN security_events.security_event_status; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.security_events.security_event_status IS 'Security event lifecycle or handling state.';


--
-- Name: COLUMN security_events.result; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.security_events.result IS 'Result classification.';


--
-- Name: COLUMN security_events.reason_code; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.security_events.reason_code IS 'Controlled security reason.';


--
-- Name: COLUMN security_events.target_entity_type; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.security_events.target_entity_type IS 'Target entity type.';


--
-- Name: COLUMN security_events.target_entity_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.security_events.target_entity_id IS 'Target entity ID.';


--
-- Name: COLUMN security_events.actor_user_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.security_events.actor_user_id IS 'Human actor involved.';


--
-- Name: COLUMN security_events.actor_service_identity_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.security_events.actor_service_identity_id IS 'Service or device actor involved.';


--
-- Name: COLUMN security_events.source_ip_hash; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.security_events.source_ip_hash IS 'Hash of source IP where retained.';


--
-- Name: COLUMN security_events.user_agent_hash; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.security_events.user_agent_hash IS 'Hash of user agent where retained.';


--
-- Name: COLUMN security_events.request_fingerprint_hash; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.security_events.request_fingerprint_hash IS 'Hash of request fingerprint where retained.';


--
-- Name: COLUMN security_events.incident_record_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.security_events.incident_record_id IS 'Related incident, where material.';


--
-- Name: COLUMN security_events.detected_at; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.security_events.detected_at IS 'Timestamp when event was detected.';


--
-- Name: COLUMN security_events.recorded_at; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.security_events.recorded_at IS 'Timestamp when event was recorded.';


--
-- Name: COLUMN security_events.resolved_at; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.security_events.resolved_at IS 'Timestamp when security event was resolved or closed.';


--
-- Name: COLUMN security_events.resolved_by_user_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.security_events.resolved_by_user_id IS 'User who resolved or reviewed the event.';


--
-- Name: COLUMN security_events.resolution_reason_code; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.security_events.resolution_reason_code IS 'Controlled resolution reason.';


--
-- Name: COLUMN security_events.correlation_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.security_events.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN security_events.created_at; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.security_events.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN security_events.created_by_service_identity_id; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.security_events.created_by_service_identity_id IS 'Service identity that wrote the security event.';


--
-- Name: COLUMN security_events.row_version; Type: COMMENT; Schema: audit; Owner: -
--

COMMENT ON COLUMN audit.security_events.row_version IS 'Optimistic concurrency version if status can change.';


--
-- Name: controlled_code_sets; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config.controlled_code_sets (
    controlled_code_set_id uuid DEFAULT gen_random_uuid() NOT NULL,
    code_set_name character varying(96) NOT NULL,
    code_value character varying(96) NOT NULL,
    code_label character varying(128) NOT NULL,
    code_description text,
    code_domain character varying(64) NOT NULL,
    code_status config.controlled_code_status_enum NOT NULL,
    sort_order integer,
    requires_comment boolean DEFAULT false NOT NULL,
    requires_approval boolean DEFAULT false NOT NULL,
    is_sensitive boolean DEFAULT false NOT NULL,
    effective_from timestamp with time zone NOT NULL,
    effective_to timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_controlled_code_sets__effective_window CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT ck_controlled_code_sets__row_version_positive CHECK ((row_version > 0)),
    CONSTRAINT ck_controlled_code_sets__sort_order_non_negative CHECK (((sort_order IS NULL) OR (sort_order >= 0)))
);


--
-- Name: TABLE controlled_code_sets; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON TABLE config.controlled_code_sets IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN controlled_code_sets.controlled_code_set_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.controlled_code_sets.controlled_code_set_id IS 'Canonical identifier of the controlled code.';


--
-- Name: COLUMN controlled_code_sets.code_set_name; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.controlled_code_sets.code_set_name IS 'Name of the code set.';


--
-- Name: COLUMN controlled_code_sets.code_value; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.controlled_code_sets.code_value IS 'Controlled code value.';


--
-- Name: COLUMN controlled_code_sets.code_label; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.controlled_code_sets.code_label IS 'Human-readable label.';


--
-- Name: COLUMN controlled_code_sets.code_description; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.controlled_code_sets.code_description IS 'Description of code meaning and use.';


--
-- Name: COLUMN controlled_code_sets.code_domain; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.controlled_code_sets.code_domain IS 'Domain where code primarily applies.';


--
-- Name: COLUMN controlled_code_sets.code_status; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.controlled_code_sets.code_status IS 'Code lifecycle status.';


--
-- Name: COLUMN controlled_code_sets.sort_order; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.controlled_code_sets.sort_order IS 'Optional display or evaluation order.';


--
-- Name: COLUMN controlled_code_sets.requires_comment; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.controlled_code_sets.requires_comment IS 'Indicates whether use of the code requires a note.';


--
-- Name: COLUMN controlled_code_sets.requires_approval; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.controlled_code_sets.requires_approval IS 'Indicates whether use of the code requires approval.';


--
-- Name: COLUMN controlled_code_sets.is_sensitive; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.controlled_code_sets.is_sensitive IS 'Indicates whether the code is sensitive or restricted in use.';


--
-- Name: COLUMN controlled_code_sets.effective_from; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.controlled_code_sets.effective_from IS 'Start of code effectiveness.';


--
-- Name: COLUMN controlled_code_sets.effective_to; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.controlled_code_sets.effective_to IS 'End of code effectiveness.';


--
-- Name: COLUMN controlled_code_sets.created_at; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.controlled_code_sets.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN controlled_code_sets.created_by_user_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.controlled_code_sets.created_by_user_id IS 'User who created the code.';


--
-- Name: COLUMN controlled_code_sets.created_by_service_identity_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.controlled_code_sets.created_by_service_identity_id IS 'Service identity that created the code.';


--
-- Name: COLUMN controlled_code_sets.updated_at; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.controlled_code_sets.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN controlled_code_sets.updated_by_user_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.controlled_code_sets.updated_by_user_id IS 'User who last updated the code.';


--
-- Name: COLUMN controlled_code_sets.updated_by_service_identity_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.controlled_code_sets.updated_by_service_identity_id IS 'Service identity that last updated the code.';


--
-- Name: COLUMN controlled_code_sets.row_version; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.controlled_code_sets.row_version IS 'Optimistic concurrency version.';


--
-- Name: feature_flags; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config.feature_flags (
    feature_flag_id uuid DEFAULT gen_random_uuid() NOT NULL,
    flag_code character varying(96) NOT NULL,
    flag_name character varying(128) NOT NULL,
    flag_description text,
    flag_domain character varying(64) NOT NULL,
    flag_status config.feature_flag_status_enum NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    environment_code character varying(32),
    site_group_id uuid,
    site_id uuid,
    merchant_id uuid,
    payment_rail_id uuid,
    service_identity_id uuid,
    requires_approval boolean DEFAULT false NOT NULL,
    effective_from timestamp with time zone NOT NULL,
    effective_to timestamp with time zone,
    approved_at timestamp with time zone,
    approved_by_user_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_feature_flags__effective_window CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT ck_feature_flags__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE feature_flags; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON TABLE config.feature_flags IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN feature_flags.feature_flag_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.feature_flags.feature_flag_id IS 'Canonical identifier of the feature flag.';


--
-- Name: COLUMN feature_flags.flag_code; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.feature_flags.flag_code IS 'Stable feature flag code.';


--
-- Name: COLUMN feature_flags.flag_name; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.feature_flags.flag_name IS 'Human-readable flag name.';


--
-- Name: COLUMN feature_flags.flag_description; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.feature_flags.flag_description IS 'Description of flag purpose and effect.';


--
-- Name: COLUMN feature_flags.flag_domain; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.feature_flags.flag_domain IS 'Domain or service area where flag applies.';


--
-- Name: COLUMN feature_flags.flag_status; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.feature_flags.flag_status IS 'Flag lifecycle status.';


--
-- Name: COLUMN feature_flags.enabled; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.feature_flags.enabled IS 'Current enabled state.';


--
-- Name: COLUMN feature_flags.environment_code; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.feature_flags.environment_code IS 'Environment where the flag applies.';


--
-- Name: COLUMN feature_flags.site_group_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.feature_flags.site_group_id IS 'Site group scope, where applicable.';


--
-- Name: COLUMN feature_flags.site_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.feature_flags.site_id IS 'Site scope, where applicable.';


--
-- Name: COLUMN feature_flags.merchant_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.feature_flags.merchant_id IS 'Merchant scope, where applicable.';


--
-- Name: COLUMN feature_flags.payment_rail_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.feature_flags.payment_rail_id IS 'Payment rail scope, where applicable.';


--
-- Name: COLUMN feature_flags.service_identity_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.feature_flags.service_identity_id IS 'Service identity scope, where applicable.';


--
-- Name: COLUMN feature_flags.requires_approval; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.feature_flags.requires_approval IS 'Indicates whether changes require approval.';


--
-- Name: COLUMN feature_flags.effective_from; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.feature_flags.effective_from IS 'Start of flag effectiveness.';


--
-- Name: COLUMN feature_flags.effective_to; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.feature_flags.effective_to IS 'End of flag effectiveness.';


--
-- Name: COLUMN feature_flags.approved_at; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.feature_flags.approved_at IS 'Approval timestamp, where required.';


--
-- Name: COLUMN feature_flags.approved_by_user_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.feature_flags.approved_by_user_id IS 'User who approved the flag.';


--
-- Name: COLUMN feature_flags.created_at; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.feature_flags.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN feature_flags.created_by_user_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.feature_flags.created_by_user_id IS 'User who created the flag.';


--
-- Name: COLUMN feature_flags.created_by_service_identity_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.feature_flags.created_by_service_identity_id IS 'Service identity that created the flag.';


--
-- Name: COLUMN feature_flags.updated_at; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.feature_flags.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN feature_flags.updated_by_user_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.feature_flags.updated_by_user_id IS 'User who last updated the flag.';


--
-- Name: COLUMN feature_flags.updated_by_service_identity_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.feature_flags.updated_by_service_identity_id IS 'Service identity that last updated the flag.';


--
-- Name: COLUMN feature_flags.row_version; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.feature_flags.row_version IS 'Optimistic concurrency version.';


--
-- Name: rate_limit_policies; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config.rate_limit_policies (
    rate_limit_policy_id uuid DEFAULT gen_random_uuid() NOT NULL,
    policy_code character varying(96) NOT NULL,
    policy_name character varying(128) NOT NULL,
    policy_description text,
    policy_domain character varying(64) NOT NULL,
    scope_type config.rate_limit_scope_type_enum NOT NULL,
    window_seconds integer NOT NULL,
    max_requests integer NOT NULL,
    burst_limit integer,
    penalty_seconds integer,
    policy_status config.rate_limit_policy_status_enum NOT NULL,
    enforcement_mode config.rate_limit_enforcement_mode_enum NOT NULL,
    effective_from timestamp with time zone NOT NULL,
    effective_to timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_rate_limit_policies__burst_limit_non_negative CHECK (((burst_limit IS NULL) OR (burst_limit >= 0))),
    CONSTRAINT ck_rate_limit_policies__effective_window CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT ck_rate_limit_policies__max_requests_positive CHECK ((max_requests > 0)),
    CONSTRAINT ck_rate_limit_policies__penalty_seconds_non_negative CHECK (((penalty_seconds IS NULL) OR (penalty_seconds >= 0))),
    CONSTRAINT ck_rate_limit_policies__row_version_positive CHECK ((row_version > 0)),
    CONSTRAINT ck_rate_limit_policies__window_seconds_non_negative CHECK (((window_seconds IS NULL) OR (window_seconds >= 0))),
    CONSTRAINT ck_rate_limit_policies__window_seconds_positive CHECK ((window_seconds > 0))
);


--
-- Name: TABLE rate_limit_policies; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON TABLE config.rate_limit_policies IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN rate_limit_policies.rate_limit_policy_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.rate_limit_policies.rate_limit_policy_id IS 'Canonical identifier of the rate-limit policy.';


--
-- Name: COLUMN rate_limit_policies.policy_code; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.rate_limit_policies.policy_code IS 'Stable policy code.';


--
-- Name: COLUMN rate_limit_policies.policy_name; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.rate_limit_policies.policy_name IS 'Human-readable policy name.';


--
-- Name: COLUMN rate_limit_policies.policy_description; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.rate_limit_policies.policy_description IS 'Description of policy purpose.';


--
-- Name: COLUMN rate_limit_policies.policy_domain; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.rate_limit_policies.policy_domain IS 'Domain or service area where policy applies.';


--
-- Name: COLUMN rate_limit_policies.scope_type; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.rate_limit_policies.scope_type IS 'Scope of the rate limit.';


--
-- Name: COLUMN rate_limit_policies.window_seconds; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.rate_limit_policies.window_seconds IS 'Rolling or fixed window duration in seconds.';


--
-- Name: COLUMN rate_limit_policies.max_requests; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.rate_limit_policies.max_requests IS 'Maximum allowed requests in the window.';


--
-- Name: COLUMN rate_limit_policies.burst_limit; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.rate_limit_policies.burst_limit IS 'Optional burst allowance.';


--
-- Name: COLUMN rate_limit_policies.penalty_seconds; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.rate_limit_policies.penalty_seconds IS 'Lockout or penalty duration after violation.';


--
-- Name: COLUMN rate_limit_policies.policy_status; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.rate_limit_policies.policy_status IS 'Policy lifecycle status.';


--
-- Name: COLUMN rate_limit_policies.enforcement_mode; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.rate_limit_policies.enforcement_mode IS 'Enforcement behavior.';


--
-- Name: COLUMN rate_limit_policies.effective_from; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.rate_limit_policies.effective_from IS 'Start of policy effectiveness.';


--
-- Name: COLUMN rate_limit_policies.effective_to; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.rate_limit_policies.effective_to IS 'End of policy effectiveness.';


--
-- Name: COLUMN rate_limit_policies.created_at; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.rate_limit_policies.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN rate_limit_policies.created_by_user_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.rate_limit_policies.created_by_user_id IS 'User who created the policy.';


--
-- Name: COLUMN rate_limit_policies.created_by_service_identity_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.rate_limit_policies.created_by_service_identity_id IS 'Service identity that created the policy.';


--
-- Name: COLUMN rate_limit_policies.updated_at; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.rate_limit_policies.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN rate_limit_policies.updated_by_user_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.rate_limit_policies.updated_by_user_id IS 'User who last updated the policy.';


--
-- Name: COLUMN rate_limit_policies.updated_by_service_identity_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.rate_limit_policies.updated_by_service_identity_id IS 'Service identity that last updated the policy.';


--
-- Name: COLUMN rate_limit_policies.row_version; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.rate_limit_policies.row_version IS 'Optimistic concurrency version.';


--
-- Name: system_parameters; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config.system_parameters (
    system_parameter_id uuid DEFAULT gen_random_uuid() NOT NULL,
    parameter_code character varying(96) NOT NULL,
    parameter_name character varying(128) NOT NULL,
    parameter_description text,
    parameter_domain character varying(64) NOT NULL,
    parameter_type config.system_parameter_type_enum NOT NULL,
    value_text text,
    value_numeric numeric(18,4),
    value_boolean boolean,
    value_json_ref character varying(256),
    parameter_status config.system_parameter_status_enum NOT NULL,
    requires_approval boolean DEFAULT false NOT NULL,
    is_sensitive boolean DEFAULT false NOT NULL,
    effective_from timestamp with time zone NOT NULL,
    effective_to timestamp with time zone,
    approved_at timestamp with time zone,
    approved_by_user_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_system_parameters__effective_window CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT ck_system_parameters__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE system_parameters; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON TABLE config.system_parameters IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN system_parameters.system_parameter_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.system_parameters.system_parameter_id IS 'Canonical identifier of the system parameter.';


--
-- Name: COLUMN system_parameters.parameter_code; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.system_parameters.parameter_code IS 'Stable parameter code.';


--
-- Name: COLUMN system_parameters.parameter_name; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.system_parameters.parameter_name IS 'Human-readable parameter name.';


--
-- Name: COLUMN system_parameters.parameter_description; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.system_parameters.parameter_description IS 'Description of the parameter and intended use.';


--
-- Name: COLUMN system_parameters.parameter_domain; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.system_parameters.parameter_domain IS 'Domain or service area where parameter applies.';


--
-- Name: COLUMN system_parameters.parameter_type; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.system_parameters.parameter_type IS 'Data type of the parameter value.';


--
-- Name: COLUMN system_parameters.value_text; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.system_parameters.value_text IS 'Text parameter value.';


--
-- Name: COLUMN system_parameters.value_numeric; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.system_parameters.value_numeric IS 'Numeric parameter value.';


--
-- Name: COLUMN system_parameters.value_boolean; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.system_parameters.value_boolean IS 'Boolean parameter value.';


--
-- Name: COLUMN system_parameters.value_json_ref; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.system_parameters.value_json_ref IS 'Reference to structured configuration if stored externally.';


--
-- Name: COLUMN system_parameters.parameter_status; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.system_parameters.parameter_status IS 'Parameter lifecycle status.';


--
-- Name: COLUMN system_parameters.requires_approval; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.system_parameters.requires_approval IS 'Indicates whether changes require approval.';


--
-- Name: COLUMN system_parameters.is_sensitive; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.system_parameters.is_sensitive IS 'Indicates sensitive configuration metadata. Must not mean secret storage.';


--
-- Name: COLUMN system_parameters.effective_from; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.system_parameters.effective_from IS 'Start of parameter effectiveness.';


--
-- Name: COLUMN system_parameters.effective_to; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.system_parameters.effective_to IS 'End of parameter effectiveness.';


--
-- Name: COLUMN system_parameters.approved_at; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.system_parameters.approved_at IS 'Approval timestamp, where required.';


--
-- Name: COLUMN system_parameters.approved_by_user_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.system_parameters.approved_by_user_id IS 'User who approved the parameter.';


--
-- Name: COLUMN system_parameters.created_at; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.system_parameters.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN system_parameters.created_by_user_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.system_parameters.created_by_user_id IS 'User who created the parameter.';


--
-- Name: COLUMN system_parameters.created_by_service_identity_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.system_parameters.created_by_service_identity_id IS 'Service identity that created the parameter.';


--
-- Name: COLUMN system_parameters.updated_at; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.system_parameters.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN system_parameters.updated_by_user_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.system_parameters.updated_by_user_id IS 'User who last updated the parameter.';


--
-- Name: COLUMN system_parameters.updated_by_service_identity_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.system_parameters.updated_by_service_identity_id IS 'Service identity that last updated the parameter.';


--
-- Name: COLUMN system_parameters.row_version; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.system_parameters.row_version IS 'Optimistic concurrency version.';


--
-- Name: ttl_policies; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config.ttl_policies (
    ttl_policy_id uuid DEFAULT gen_random_uuid() NOT NULL,
    policy_code character varying(96) NOT NULL,
    policy_name character varying(128) NOT NULL,
    policy_description text,
    policy_domain character varying(64) NOT NULL,
    ttl_scope_type config.ttl_scope_type_enum NOT NULL,
    ttl_seconds integer NOT NULL,
    grace_period_seconds integer,
    expiry_action config.ttl_expiry_action_enum NOT NULL,
    policy_status config.ttl_policy_status_enum NOT NULL,
    effective_from timestamp with time zone NOT NULL,
    effective_to timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_ttl_policies__effective_window CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT ck_ttl_policies__grace_period_seconds_non_negative CHECK (((grace_period_seconds IS NULL) OR (grace_period_seconds >= 0))),
    CONSTRAINT ck_ttl_policies__row_version_positive CHECK ((row_version > 0)),
    CONSTRAINT ck_ttl_policies__ttl_seconds_non_negative CHECK (((ttl_seconds IS NULL) OR (ttl_seconds >= 0))),
    CONSTRAINT ck_ttl_policies__ttl_seconds_positive CHECK ((ttl_seconds > 0))
);


--
-- Name: TABLE ttl_policies; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON TABLE config.ttl_policies IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN ttl_policies.ttl_policy_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.ttl_policies.ttl_policy_id IS 'Canonical identifier of the TTL policy.';


--
-- Name: COLUMN ttl_policies.policy_code; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.ttl_policies.policy_code IS 'Stable TTL policy code.';


--
-- Name: COLUMN ttl_policies.policy_name; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.ttl_policies.policy_name IS 'Human-readable policy name.';


--
-- Name: COLUMN ttl_policies.policy_description; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.ttl_policies.policy_description IS 'Description of policy purpose.';


--
-- Name: COLUMN ttl_policies.policy_domain; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.ttl_policies.policy_domain IS 'Domain or workflow where policy applies.';


--
-- Name: COLUMN ttl_policies.ttl_scope_type; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.ttl_policies.ttl_scope_type IS 'Expiry scope.';


--
-- Name: COLUMN ttl_policies.ttl_seconds; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.ttl_policies.ttl_seconds IS 'TTL duration in seconds.';


--
-- Name: COLUMN ttl_policies.grace_period_seconds; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.ttl_policies.grace_period_seconds IS 'Optional grace period for support or cleanup, not validity extension unless domain allows.';


--
-- Name: COLUMN ttl_policies.expiry_action; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.ttl_policies.expiry_action IS 'Action expected when TTL expires.';


--
-- Name: COLUMN ttl_policies.policy_status; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.ttl_policies.policy_status IS 'TTL policy lifecycle status.';


--
-- Name: COLUMN ttl_policies.effective_from; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.ttl_policies.effective_from IS 'Start of policy effectiveness.';


--
-- Name: COLUMN ttl_policies.effective_to; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.ttl_policies.effective_to IS 'End of policy effectiveness.';


--
-- Name: COLUMN ttl_policies.created_at; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.ttl_policies.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN ttl_policies.created_by_user_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.ttl_policies.created_by_user_id IS 'User who created the policy.';


--
-- Name: COLUMN ttl_policies.created_by_service_identity_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.ttl_policies.created_by_service_identity_id IS 'Service identity that created the policy.';


--
-- Name: COLUMN ttl_policies.updated_at; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.ttl_policies.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN ttl_policies.updated_by_user_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.ttl_policies.updated_by_user_id IS 'User who last updated the policy.';


--
-- Name: COLUMN ttl_policies.updated_by_service_identity_id; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.ttl_policies.updated_by_service_identity_id IS 'Service identity that last updated the policy.';


--
-- Name: COLUMN ttl_policies.row_version; Type: COMMENT; Schema: config; Owner: -
--

COMMENT ON COLUMN config.ttl_policies.row_version IS 'Optimistic concurrency version.';


--
-- Name: exit_authorizations; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.exit_authorizations (
    exit_authorization_id uuid DEFAULT gen_random_uuid() NOT NULL,
    parking_session_id uuid NOT NULL,
    payment_attempt_id uuid NOT NULL,
    payment_confirmation_id uuid NOT NULL,
    authorization_token_hash character(64) NOT NULL,
    authorization_status core.exit_authorization_status_enum NOT NULL,
    issued_at timestamp with time zone NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    invalidated_at timestamp with time zone,
    invalidation_reason_code character varying(64),
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_service_identity_id uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_exit_authorizations__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE exit_authorizations; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON TABLE core.exit_authorizations IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN exit_authorizations.exit_authorization_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.exit_authorizations.exit_authorization_id IS 'Canonical identifier of the exit authorization.';


--
-- Name: COLUMN exit_authorizations.parking_session_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.exit_authorizations.parking_session_id IS 'Parking session for which exit is authorized.';


--
-- Name: COLUMN exit_authorizations.payment_attempt_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.exit_authorizations.payment_attempt_id IS 'Confirmed payment attempt that established financial control state.';


--
-- Name: COLUMN exit_authorizations.payment_confirmation_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.exit_authorizations.payment_confirmation_id IS 'Canonical payment confirmation supporting issuance.';


--
-- Name: COLUMN exit_authorizations.authorization_token_hash; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.exit_authorizations.authorization_token_hash IS 'Hash of opaque token used for secure lookup and replay-safe validation.';


--
-- Name: COLUMN exit_authorizations.authorization_status; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.exit_authorizations.authorization_status IS 'Current validity status of the authorization.';


--
-- Name: COLUMN exit_authorizations.issued_at; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.exit_authorizations.issued_at IS 'Issuance timestamp.';


--
-- Name: COLUMN exit_authorizations.expires_at; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.exit_authorizations.expires_at IS 'Expiration boundary for authorization validity.';


--
-- Name: COLUMN exit_authorizations.invalidated_at; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.exit_authorizations.invalidated_at IS 'Timestamp when authorization was invalidated, if applicable.';


--
-- Name: COLUMN exit_authorizations.invalidation_reason_code; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.exit_authorizations.invalidation_reason_code IS 'Controlled reason for invalidation.';


--
-- Name: COLUMN exit_authorizations.correlation_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.exit_authorizations.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN exit_authorizations.created_at; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.exit_authorizations.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN exit_authorizations.created_by_service_identity_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.exit_authorizations.created_by_service_identity_id IS 'Creating service identity.';


--
-- Name: COLUMN exit_authorizations.updated_at; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.exit_authorizations.updated_at IS 'Last mutation timestamp.';


--
-- Name: COLUMN exit_authorizations.updated_by_service_identity_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.exit_authorizations.updated_by_service_identity_id IS 'Updating service identity.';


--
-- Name: COLUMN exit_authorizations.row_version; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.exit_authorizations.row_version IS 'Optimistic concurrency version.';


--
-- Name: parking_sessions; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.parking_sessions (
    parking_session_id uuid DEFAULT gen_random_uuid() NOT NULL,
    site_group_id uuid NOT NULL,
    site_id uuid NOT NULL,
    vendor_system_id uuid NOT NULL,
    vendor_session_ref character varying(128) NOT NULL,
    plate_number_hash character(64),
    plate_number_masked character varying(32),
    ticket_number_hash character(64),
    ticket_number_masked character varying(64),
    entry_at timestamp with time zone,
    vendor_session_status character varying(64),
    session_status core.parking_session_status_enum NOT NULL,
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_service_identity_id uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_parking_sessions__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE parking_sessions; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON TABLE core.parking_sessions IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN parking_sessions.parking_session_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.parking_sessions.parking_session_id IS 'Canonical ExitPass identifier for the parking session.';


--
-- Name: COLUMN parking_sessions.site_group_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.parking_sessions.site_group_id IS 'Site group used for lookup scope and business context.';


--
-- Name: COLUMN parking_sessions.site_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.parking_sessions.site_id IS 'Site where the parking session belongs.';


--
-- Name: COLUMN parking_sessions.vendor_system_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.parking_sessions.vendor_system_id IS 'Vendor PMS that owns the raw parking session lifecycle.';


--
-- Name: COLUMN parking_sessions.vendor_session_ref; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.parking_sessions.vendor_session_ref IS 'Vendor PMS session reference.';


--
-- Name: COLUMN parking_sessions.plate_number_hash; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.parking_sessions.plate_number_hash IS 'Hash of normalized plate number for lookup and privacy-aware traceability.';


--
-- Name: COLUMN parking_sessions.plate_number_masked; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.parking_sessions.plate_number_masked IS 'Masked or partially redacted plate display value.';


--
-- Name: COLUMN parking_sessions.ticket_number_hash; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.parking_sessions.ticket_number_hash IS 'Hash of normalized ticket number where applicable.';


--
-- Name: COLUMN parking_sessions.ticket_number_masked; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.parking_sessions.ticket_number_masked IS 'Masked or partially redacted ticket display value.';


--
-- Name: COLUMN parking_sessions.entry_at; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.parking_sessions.entry_at IS 'Entry timestamp as reported by Vendor PMS.';


--
-- Name: COLUMN parking_sessions.vendor_session_status; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.parking_sessions.vendor_session_status IS 'Vendor-reported session status for traceability.';


--
-- Name: COLUMN parking_sessions.session_status; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.parking_sessions.session_status IS 'ExitPass control status for the canonical session reference.';


--
-- Name: COLUMN parking_sessions.correlation_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.parking_sessions.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN parking_sessions.created_at; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.parking_sessions.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN parking_sessions.created_by_service_identity_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.parking_sessions.created_by_service_identity_id IS 'Service identity that created the record.';


--
-- Name: COLUMN parking_sessions.updated_at; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.parking_sessions.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN parking_sessions.updated_by_service_identity_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.parking_sessions.updated_by_service_identity_id IS 'Service identity that last updated the record.';


--
-- Name: COLUMN parking_sessions.row_version; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.parking_sessions.row_version IS 'Optimistic concurrency version.';


--
-- Name: payment_attempts; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.payment_attempts (
    payment_attempt_id uuid DEFAULT gen_random_uuid() NOT NULL,
    parking_session_id uuid NOT NULL,
    tariff_snapshot_id uuid NOT NULL,
    idempotency_key character varying(128) NOT NULL,
    payment_rail_id uuid,
    currency_code character(3) NOT NULL,
    amount numeric(18,2) NOT NULL,
    attempt_status core.payment_attempt_status_enum NOT NULL,
    requested_at timestamp with time zone NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    finalized_at timestamp with time zone,
    failure_reason_code character varying(64),
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_service_identity_id uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_payment_attempts__amount_non_negative CHECK (((amount IS NULL) OR (amount >= (0)::numeric))),
    CONSTRAINT ck_payment_attempts__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE payment_attempts; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON TABLE core.payment_attempts IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN payment_attempts.payment_attempt_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_attempts.payment_attempt_id IS 'Canonical identifier of the payment attempt.';


--
-- Name: COLUMN payment_attempts.parking_session_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_attempts.parking_session_id IS 'Parking session being paid for.';


--
-- Name: COLUMN payment_attempts.tariff_snapshot_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_attempts.tariff_snapshot_id IS 'Immutable payable basis used by this attempt.';


--
-- Name: COLUMN payment_attempts.idempotency_key; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_attempts.idempotency_key IS 'Client or service-supplied idempotency key.';


--
-- Name: COLUMN payment_attempts.payment_rail_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_attempts.payment_rail_id IS 'Intended or selected payment rail.';


--
-- Name: COLUMN payment_attempts.currency_code; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_attempts.currency_code IS 'Currency code.';


--
-- Name: COLUMN payment_attempts.amount; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_attempts.amount IS 'Amount to be paid, copied from bound tariff snapshot.';


--
-- Name: COLUMN payment_attempts.attempt_status; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_attempts.attempt_status IS 'Lifecycle state of the payment attempt.';


--
-- Name: COLUMN payment_attempts.requested_at; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_attempts.requested_at IS 'Timestamp when the attempt was requested.';


--
-- Name: COLUMN payment_attempts.expires_at; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_attempts.expires_at IS 'Expiry boundary for the payment attempt.';


--
-- Name: COLUMN payment_attempts.finalized_at; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_attempts.finalized_at IS 'Timestamp when attempt reached terminal finality.';


--
-- Name: COLUMN payment_attempts.failure_reason_code; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_attempts.failure_reason_code IS 'Controlled failure reason.';


--
-- Name: COLUMN payment_attempts.correlation_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_attempts.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN payment_attempts.created_at; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_attempts.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN payment_attempts.created_by_service_identity_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_attempts.created_by_service_identity_id IS 'Service identity that created the attempt.';


--
-- Name: COLUMN payment_attempts.updated_at; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_attempts.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN payment_attempts.updated_by_service_identity_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_attempts.updated_by_service_identity_id IS 'Service identity that last updated the record.';


--
-- Name: COLUMN payment_attempts.row_version; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_attempts.row_version IS 'Optimistic concurrency version.';


--
-- Name: payment_confirmations; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.payment_confirmations (
    payment_confirmation_id uuid DEFAULT gen_random_uuid() NOT NULL,
    payment_attempt_id uuid NOT NULL,
    provider_outcome_id uuid,
    payment_rail_id uuid,
    provider_transaction_ref character varying(128),
    currency_code character(3) NOT NULL,
    confirmed_amount numeric(18,2) NOT NULL,
    confirmation_status core.payment_confirmation_status_enum NOT NULL,
    verified_at timestamp with time zone NOT NULL,
    confirmed_at timestamp with time zone NOT NULL,
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_service_identity_id uuid NOT NULL,
    CONSTRAINT ck_payment_confirmations__confirmed_amount_non_negative CHECK (((confirmed_amount IS NULL) OR (confirmed_amount >= (0)::numeric)))
);


--
-- Name: TABLE payment_confirmations; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON TABLE core.payment_confirmations IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN payment_confirmations.payment_confirmation_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_confirmations.payment_confirmation_id IS 'Canonical identifier of the payment confirmation.';


--
-- Name: COLUMN payment_confirmations.payment_attempt_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_confirmations.payment_attempt_id IS 'Payment attempt confirmed by this record.';


--
-- Name: COLUMN payment_confirmations.provider_outcome_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_confirmations.provider_outcome_id IS 'Verified provider outcome that supported confirmation.';


--
-- Name: COLUMN payment_confirmations.payment_rail_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_confirmations.payment_rail_id IS 'Rail through which the payment was completed.';


--
-- Name: COLUMN payment_confirmations.provider_transaction_ref; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_confirmations.provider_transaction_ref IS 'Provider transaction reference used for traceability.';


--
-- Name: COLUMN payment_confirmations.currency_code; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_confirmations.currency_code IS 'Currency code.';


--
-- Name: COLUMN payment_confirmations.confirmed_amount; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_confirmations.confirmed_amount IS 'Amount confirmed as paid.';


--
-- Name: COLUMN payment_confirmations.confirmation_status; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_confirmations.confirmation_status IS 'Confirmation record state.';


--
-- Name: COLUMN payment_confirmations.verified_at; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_confirmations.verified_at IS 'Timestamp when provider evidence was verified.';


--
-- Name: COLUMN payment_confirmations.confirmed_at; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_confirmations.confirmed_at IS 'Timestamp when Central PMS recorded canonical confirmation.';


--
-- Name: COLUMN payment_confirmations.correlation_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_confirmations.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN payment_confirmations.created_at; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_confirmations.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN payment_confirmations.created_by_service_identity_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.payment_confirmations.created_by_service_identity_id IS 'Service identity that created confirmation.';


--
-- Name: tariff_snapshots; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.tariff_snapshots (
    tariff_snapshot_id uuid DEFAULT gen_random_uuid() NOT NULL,
    parking_session_id uuid NOT NULL,
    superseded_by_tariff_snapshot_id uuid,
    vendor_system_id uuid NOT NULL,
    vendor_tariff_ref character varying(128),
    tariff_version_reference character varying(128),
    currency_code character(3) NOT NULL,
    gross_amount numeric(18,2) NOT NULL,
    statutory_discount_amount numeric(18,2) NOT NULL,
    coupon_discount_amount numeric(18,2) NOT NULL,
    net_amount numeric(18,2) NOT NULL,
    statutory_discount_validation_id uuid,
    coupon_application_id uuid,
    snapshot_status core.tariff_snapshot_status_enum NOT NULL,
    calculated_at timestamp with time zone NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    consumed_at timestamp with time zone,
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_service_identity_id uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_tariff_snapshots__coupon_discount_amount_non_negative CHECK (((coupon_discount_amount IS NULL) OR (coupon_discount_amount >= (0)::numeric))),
    CONSTRAINT ck_tariff_snapshots__gross_amount_non_negative CHECK (((gross_amount IS NULL) OR (gross_amount >= (0)::numeric))),
    CONSTRAINT ck_tariff_snapshots__net_amount_non_negative CHECK (((net_amount IS NULL) OR (net_amount >= (0)::numeric))),
    CONSTRAINT ck_tariff_snapshots__row_version_positive CHECK ((row_version > 0)),
    CONSTRAINT ck_tariff_snapshots__statutory_discount_amount_non_negative CHECK (((statutory_discount_amount IS NULL) OR (statutory_discount_amount >= (0)::numeric)))
);


--
-- Name: TABLE tariff_snapshots; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON TABLE core.tariff_snapshots IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN tariff_snapshots.tariff_snapshot_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.tariff_snapshots.tariff_snapshot_id IS 'Canonical identifier of the tariff snapshot.';


--
-- Name: COLUMN tariff_snapshots.parking_session_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.tariff_snapshots.parking_session_id IS 'Parking session for which this payable basis was created.';


--
-- Name: COLUMN tariff_snapshots.superseded_by_tariff_snapshot_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.tariff_snapshots.superseded_by_tariff_snapshot_id IS 'Later snapshot that superseded this snapshot.';


--
-- Name: COLUMN tariff_snapshots.vendor_system_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.tariff_snapshots.vendor_system_id IS 'Vendor PMS that supplied the tariff basis.';


--
-- Name: COLUMN tariff_snapshots.vendor_tariff_ref; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.tariff_snapshots.vendor_tariff_ref IS 'Vendor tariff calculation reference, where available.';


--
-- Name: COLUMN tariff_snapshots.tariff_version_reference; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.tariff_snapshots.tariff_version_reference IS 'Vendor or configured tariff version reference used for traceability.';


--
-- Name: COLUMN tariff_snapshots.currency_code; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.tariff_snapshots.currency_code IS 'Currency code.';


--
-- Name: COLUMN tariff_snapshots.gross_amount; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.tariff_snapshots.gross_amount IS 'Vendor-authoritative amount before discounts and coupons.';


--
-- Name: COLUMN tariff_snapshots.statutory_discount_amount; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.tariff_snapshots.statutory_discount_amount IS 'Total statutory discount amount included in the snapshot.';


--
-- Name: COLUMN tariff_snapshots.coupon_discount_amount; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.tariff_snapshots.coupon_discount_amount IS 'Total coupon amount included in the snapshot.';


--
-- Name: COLUMN tariff_snapshots.net_amount; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.tariff_snapshots.net_amount IS 'Final payable amount used for payment.';


--
-- Name: COLUMN tariff_snapshots.statutory_discount_validation_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.tariff_snapshots.statutory_discount_validation_id IS 'Approved statutory validation reflected in the snapshot, if any.';


--
-- Name: COLUMN tariff_snapshots.coupon_application_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.tariff_snapshots.coupon_application_id IS 'Coupon application reflected in the snapshot, if any.';


--
-- Name: COLUMN tariff_snapshots.snapshot_status; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.tariff_snapshots.snapshot_status IS 'Current lifecycle state of the snapshot.';


--
-- Name: COLUMN tariff_snapshots.calculated_at; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.tariff_snapshots.calculated_at IS 'Timestamp when payable basis was calculated or accepted.';


--
-- Name: COLUMN tariff_snapshots.expires_at; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.tariff_snapshots.expires_at IS 'Timestamp after which the snapshot may no longer create a payment attempt.';


--
-- Name: COLUMN tariff_snapshots.consumed_at; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.tariff_snapshots.consumed_at IS 'Timestamp when snapshot became bound to a payment attempt.';


--
-- Name: COLUMN tariff_snapshots.correlation_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.tariff_snapshots.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN tariff_snapshots.created_at; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.tariff_snapshots.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN tariff_snapshots.created_by_service_identity_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.tariff_snapshots.created_by_service_identity_id IS 'Service identity that created the snapshot.';


--
-- Name: COLUMN tariff_snapshots.updated_at; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.tariff_snapshots.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN tariff_snapshots.updated_by_service_identity_id; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.tariff_snapshots.updated_by_service_identity_id IS 'Service identity that last updated the record.';


--
-- Name: COLUMN tariff_snapshots.row_version; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.tariff_snapshots.row_version IS 'Optimistic concurrency version.';


--
-- Name: coupon_applications; Type: TABLE; Schema: coupons; Owner: -
--

CREATE TABLE coupons.coupon_applications (
    coupon_application_id uuid DEFAULT gen_random_uuid() NOT NULL,
    coupon_id uuid NOT NULL,
    merchant_id uuid NOT NULL,
    merchant_wallet_id uuid,
    parking_session_id uuid NOT NULL,
    tariff_snapshot_id uuid,
    payment_attempt_id uuid,
    idempotency_key character varying(128) NOT NULL,
    application_status coupons.coupon_application_status_enum NOT NULL,
    currency_code character(3) NOT NULL,
    gross_amount_at_application numeric(18,2) NOT NULL,
    coupon_discount_amount numeric(18,2) NOT NULL,
    net_amount_after_coupon numeric(18,2) NOT NULL,
    reservation_ref character varying(128),
    reserved_at timestamp with time zone,
    reservation_expires_at timestamp with time zone,
    applied_at timestamp with time zone,
    committed_at timestamp with time zone,
    released_at timestamp with time zone,
    expired_at timestamp with time zone,
    rejected_at timestamp with time zone,
    cancelled_at timestamp with time zone,
    reversed_at timestamp with time zone,
    rejection_reason_code character varying(64),
    release_reason_code character varying(64),
    reversal_reason_code character varying(64),
    requested_by_user_id uuid,
    requested_by_service_identity_id uuid,
    approved_by_user_id uuid,
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_coupon_applications__coupon_discount_amount_non_negative CHECK (((coupon_discount_amount IS NULL) OR (coupon_discount_amount >= (0)::numeric))),
    CONSTRAINT ck_coupon_applications__gross_amount_at_application_non_nega CHECK (((gross_amount_at_application IS NULL) OR (gross_amount_at_application >= (0)::numeric))),
    CONSTRAINT ck_coupon_applications__net_amount_after_coupon_non_negative CHECK (((net_amount_after_coupon IS NULL) OR (net_amount_after_coupon >= (0)::numeric))),
    CONSTRAINT ck_coupon_applications__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE coupon_applications; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON TABLE coupons.coupon_applications IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN coupon_applications.coupon_application_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.coupon_application_id IS 'Canonical identifier of the coupon application.';


--
-- Name: COLUMN coupon_applications.coupon_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.coupon_id IS 'Coupon being applied.';


--
-- Name: COLUMN coupon_applications.merchant_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.merchant_id IS 'Merchant sponsor of the coupon application.';


--
-- Name: COLUMN coupon_applications.merchant_wallet_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.merchant_wallet_id IS 'Merchant wallet or funding context backing the application.';


--
-- Name: COLUMN coupon_applications.parking_session_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.parking_session_id IS 'Parking session to which the coupon is applied.';


--
-- Name: COLUMN coupon_applications.tariff_snapshot_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.tariff_snapshot_id IS 'Tariff snapshot in which the coupon effect was materialized.';


--
-- Name: COLUMN coupon_applications.payment_attempt_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.payment_attempt_id IS 'Payment attempt whose finality governs commit.';


--
-- Name: COLUMN coupon_applications.idempotency_key; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.idempotency_key IS 'Idempotency key for coupon application request.';


--
-- Name: COLUMN coupon_applications.application_status; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.application_status IS 'Coupon application lifecycle state.';


--
-- Name: COLUMN coupon_applications.currency_code; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.currency_code IS 'Currency code.';


--
-- Name: COLUMN coupon_applications.gross_amount_at_application; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.gross_amount_at_application IS 'Gross amount when coupon was evaluated.';


--
-- Name: COLUMN coupon_applications.coupon_discount_amount; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.coupon_discount_amount IS 'Coupon amount applied or reserved.';


--
-- Name: COLUMN coupon_applications.net_amount_after_coupon; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.net_amount_after_coupon IS 'Amount after coupon effect, before or after other allowed effects depending on flow.';


--
-- Name: COLUMN coupon_applications.reservation_ref; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.reservation_ref IS 'Internal or wallet reservation reference.';


--
-- Name: COLUMN coupon_applications.reserved_at; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.reserved_at IS 'Timestamp when coupon value was reserved.';


--
-- Name: COLUMN coupon_applications.reservation_expires_at; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.reservation_expires_at IS 'Reservation expiry timestamp.';


--
-- Name: COLUMN coupon_applications.applied_at; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.applied_at IS 'Timestamp when coupon effect was applied to payable basis.';


--
-- Name: COLUMN coupon_applications.committed_at; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.committed_at IS 'Timestamp when coupon usage was committed after confirmed payment finality.';


--
-- Name: COLUMN coupon_applications.released_at; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.released_at IS 'Timestamp when reservation was released.';


--
-- Name: COLUMN coupon_applications.expired_at; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.expired_at IS 'Timestamp when application or reservation expired.';


--
-- Name: COLUMN coupon_applications.rejected_at; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.rejected_at IS 'Timestamp when application was rejected.';


--
-- Name: COLUMN coupon_applications.cancelled_at; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.cancelled_at IS 'Timestamp when application was cancelled.';


--
-- Name: COLUMN coupon_applications.reversed_at; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.reversed_at IS 'Timestamp when committed application was reversed, if supported.';


--
-- Name: COLUMN coupon_applications.rejection_reason_code; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.rejection_reason_code IS 'Controlled rejection reason.';


--
-- Name: COLUMN coupon_applications.release_reason_code; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.release_reason_code IS 'Controlled release reason.';


--
-- Name: COLUMN coupon_applications.reversal_reason_code; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.reversal_reason_code IS 'Controlled reversal reason.';


--
-- Name: COLUMN coupon_applications.requested_by_user_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.requested_by_user_id IS 'User who requested the coupon application.';


--
-- Name: COLUMN coupon_applications.requested_by_service_identity_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.requested_by_service_identity_id IS 'Service identity that requested the application.';


--
-- Name: COLUMN coupon_applications.approved_by_user_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.approved_by_user_id IS 'Approver for elevated coupon or full-waiver use.';


--
-- Name: COLUMN coupon_applications.correlation_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN coupon_applications.created_at; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN coupon_applications.created_by_user_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.created_by_user_id IS 'User who created the record.';


--
-- Name: COLUMN coupon_applications.created_by_service_identity_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.created_by_service_identity_id IS 'Service identity that created the record.';


--
-- Name: COLUMN coupon_applications.updated_at; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN coupon_applications.updated_by_user_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.updated_by_user_id IS 'User who last updated the record.';


--
-- Name: COLUMN coupon_applications.updated_by_service_identity_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.updated_by_service_identity_id IS 'Service identity that last updated the record.';


--
-- Name: COLUMN coupon_applications.row_version; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_applications.row_version IS 'Optimistic concurrency version.';


--
-- Name: coupon_rule_groups; Type: TABLE; Schema: coupons; Owner: -
--

CREATE TABLE coupons.coupon_rule_groups (
    coupon_rule_group_id uuid DEFAULT gen_random_uuid() NOT NULL,
    coupon_id uuid NOT NULL,
    rule_group_code character varying(64) NOT NULL,
    rule_group_name character varying(128) NOT NULL,
    rule_group_description text,
    evaluation_strategy coupons.coupon_rule_evaluation_strategy_enum NOT NULL,
    evaluation_priority integer NOT NULL,
    is_required boolean DEFAULT false NOT NULL,
    rule_group_status coupons.coupon_rule_group_status_enum NOT NULL,
    effective_from timestamp with time zone NOT NULL,
    effective_to timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_coupon_rule_groups__effective_window CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT ck_coupon_rule_groups__evaluation_priority_non_negative CHECK (((evaluation_priority IS NULL) OR (evaluation_priority >= 0))),
    CONSTRAINT ck_coupon_rule_groups__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE coupon_rule_groups; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON TABLE coupons.coupon_rule_groups IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN coupon_rule_groups.coupon_rule_group_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rule_groups.coupon_rule_group_id IS 'Canonical identifier of the coupon rule group.';


--
-- Name: COLUMN coupon_rule_groups.coupon_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rule_groups.coupon_id IS 'Coupon to which the rule group belongs.';


--
-- Name: COLUMN coupon_rule_groups.rule_group_code; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rule_groups.rule_group_code IS 'Stable code for the rule group.';


--
-- Name: COLUMN coupon_rule_groups.rule_group_name; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rule_groups.rule_group_name IS 'Human-readable name.';


--
-- Name: COLUMN coupon_rule_groups.rule_group_description; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rule_groups.rule_group_description IS 'Description of the rule group.';


--
-- Name: COLUMN coupon_rule_groups.evaluation_strategy; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rule_groups.evaluation_strategy IS 'Rule group evaluation strategy.';


--
-- Name: COLUMN coupon_rule_groups.evaluation_priority; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rule_groups.evaluation_priority IS 'Evaluation priority when multiple groups exist.';


--
-- Name: COLUMN coupon_rule_groups.is_required; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rule_groups.is_required IS 'Indicates whether the group must pass for eligibility.';


--
-- Name: COLUMN coupon_rule_groups.rule_group_status; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rule_groups.rule_group_status IS 'Rule group lifecycle status.';


--
-- Name: COLUMN coupon_rule_groups.effective_from; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rule_groups.effective_from IS 'Start of rule group effectiveness.';


--
-- Name: COLUMN coupon_rule_groups.effective_to; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rule_groups.effective_to IS 'End of rule group effectiveness.';


--
-- Name: COLUMN coupon_rule_groups.created_at; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rule_groups.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN coupon_rule_groups.created_by_user_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rule_groups.created_by_user_id IS 'User who created the rule group.';


--
-- Name: COLUMN coupon_rule_groups.created_by_service_identity_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rule_groups.created_by_service_identity_id IS 'Service identity that created the rule group.';


--
-- Name: COLUMN coupon_rule_groups.updated_at; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rule_groups.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN coupon_rule_groups.updated_by_user_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rule_groups.updated_by_user_id IS 'User who last updated the rule group.';


--
-- Name: COLUMN coupon_rule_groups.updated_by_service_identity_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rule_groups.updated_by_service_identity_id IS 'Service identity that last updated the rule group.';


--
-- Name: COLUMN coupon_rule_groups.row_version; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rule_groups.row_version IS 'Optimistic concurrency version.';


--
-- Name: coupon_rules; Type: TABLE; Schema: coupons; Owner: -
--

CREATE TABLE coupons.coupon_rules (
    coupon_rule_id uuid DEFAULT gen_random_uuid() NOT NULL,
    coupon_rule_group_id uuid NOT NULL,
    rule_code character varying(64) NOT NULL,
    rule_name character varying(128) NOT NULL,
    rule_type coupons.coupon_rule_type_enum NOT NULL,
    rule_operator coupons.coupon_rule_operator_enum NOT NULL,
    rule_value_text character varying(256),
    rule_value_numeric numeric(18,2),
    rule_value_boolean boolean,
    site_group_id uuid,
    site_id uuid,
    merchant_id uuid,
    rule_status coupons.coupon_rule_status_enum NOT NULL,
    effective_from timestamp with time zone NOT NULL,
    effective_to timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_coupon_rules__effective_window CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT ck_coupon_rules__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE coupon_rules; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON TABLE coupons.coupon_rules IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN coupon_rules.coupon_rule_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rules.coupon_rule_id IS 'Canonical identifier of the coupon rule.';


--
-- Name: COLUMN coupon_rules.coupon_rule_group_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rules.coupon_rule_group_id IS 'Parent rule group.';


--
-- Name: COLUMN coupon_rules.rule_code; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rules.rule_code IS 'Stable rule code.';


--
-- Name: COLUMN coupon_rules.rule_name; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rules.rule_name IS 'Human-readable rule name.';


--
-- Name: COLUMN coupon_rules.rule_type; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rules.rule_type IS 'Type of rule.';


--
-- Name: COLUMN coupon_rules.rule_operator; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rules.rule_operator IS 'Operator used for evaluation.';


--
-- Name: COLUMN coupon_rules.rule_value_text; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rules.rule_value_text IS 'Text value for rule evaluation.';


--
-- Name: COLUMN coupon_rules.rule_value_numeric; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rules.rule_value_numeric IS 'Numeric value for rule evaluation.';


--
-- Name: COLUMN coupon_rules.rule_value_boolean; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rules.rule_value_boolean IS 'Boolean value for rule evaluation.';


--
-- Name: COLUMN coupon_rules.site_group_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rules.site_group_id IS 'Site group scope where the rule applies.';


--
-- Name: COLUMN coupon_rules.site_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rules.site_id IS 'Site scope where the rule applies.';


--
-- Name: COLUMN coupon_rules.merchant_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rules.merchant_id IS 'Merchant scope where the rule applies.';


--
-- Name: COLUMN coupon_rules.rule_status; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rules.rule_status IS 'Rule lifecycle status.';


--
-- Name: COLUMN coupon_rules.effective_from; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rules.effective_from IS 'Start of rule effectiveness.';


--
-- Name: COLUMN coupon_rules.effective_to; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rules.effective_to IS 'End of rule effectiveness.';


--
-- Name: COLUMN coupon_rules.created_at; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rules.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN coupon_rules.created_by_user_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rules.created_by_user_id IS 'User who created the rule.';


--
-- Name: COLUMN coupon_rules.created_by_service_identity_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rules.created_by_service_identity_id IS 'Service identity that created the rule.';


--
-- Name: COLUMN coupon_rules.updated_at; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rules.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN coupon_rules.updated_by_user_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rules.updated_by_user_id IS 'User who last updated the rule.';


--
-- Name: COLUMN coupon_rules.updated_by_service_identity_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rules.updated_by_service_identity_id IS 'Service identity that last updated the rule.';


--
-- Name: COLUMN coupon_rules.row_version; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupon_rules.row_version IS 'Optimistic concurrency version.';


--
-- Name: coupons; Type: TABLE; Schema: coupons; Owner: -
--

CREATE TABLE coupons.coupons (
    coupon_id uuid DEFAULT gen_random_uuid() NOT NULL,
    merchant_id uuid NOT NULL,
    coupon_code character varying(64) NOT NULL,
    coupon_name character varying(128) NOT NULL,
    coupon_description text,
    coupon_type coupons.coupon_type_enum NOT NULL,
    denomination_type coupons.coupon_denomination_type_enum NOT NULL,
    denomination_value numeric(18,2) NOT NULL,
    currency_code character(3),
    maximum_discount_amount numeric(18,2),
    minimum_gross_amount numeric(18,2),
    stacking_policy coupons.coupon_stacking_policy_enum NOT NULL,
    allows_full_waiver boolean DEFAULT false NOT NULL,
    requires_elevated_approval boolean DEFAULT false NOT NULL,
    coupon_status coupons.coupon_status_enum NOT NULL,
    valid_from timestamp with time zone NOT NULL,
    valid_to timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_coupons__denomination_value_non_negative CHECK (((denomination_value IS NULL) OR (denomination_value >= (0)::numeric))),
    CONSTRAINT ck_coupons__maximum_discount_amount_non_negative CHECK (((maximum_discount_amount IS NULL) OR (maximum_discount_amount >= (0)::numeric))),
    CONSTRAINT ck_coupons__minimum_gross_amount_non_negative CHECK (((minimum_gross_amount IS NULL) OR (minimum_gross_amount >= (0)::numeric))),
    CONSTRAINT ck_coupons__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE coupons; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON TABLE coupons.coupons IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN coupons.coupon_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupons.coupon_id IS 'Canonical identifier of the coupon.';


--
-- Name: COLUMN coupons.merchant_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupons.merchant_id IS 'Merchant sponsor of the coupon.';


--
-- Name: COLUMN coupons.coupon_code; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupons.coupon_code IS 'Stable coupon code.';


--
-- Name: COLUMN coupons.coupon_name; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupons.coupon_name IS 'Human-readable coupon name.';


--
-- Name: COLUMN coupons.coupon_description; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupons.coupon_description IS 'Description of the coupon program.';


--
-- Name: COLUMN coupons.coupon_type; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupons.coupon_type IS 'Coupon type or commercial category.';


--
-- Name: COLUMN coupons.denomination_type; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupons.denomination_type IS 'Discount denomination type.';


--
-- Name: COLUMN coupons.denomination_value; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupons.denomination_value IS 'Fixed amount, percentage, or controlled value depending on denomination type.';


--
-- Name: COLUMN coupons.currency_code; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupons.currency_code IS 'Currency code for fixed-amount coupons.';


--
-- Name: COLUMN coupons.maximum_discount_amount; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupons.maximum_discount_amount IS 'Maximum discount amount where capped.';


--
-- Name: COLUMN coupons.minimum_gross_amount; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupons.minimum_gross_amount IS 'Minimum gross amount required for coupon use.';


--
-- Name: COLUMN coupons.stacking_policy; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupons.stacking_policy IS 'Stacking behavior with other coupons or statutory discounts.';


--
-- Name: COLUMN coupons.allows_full_waiver; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupons.allows_full_waiver IS 'Indicates whether the coupon may waive the full payable amount.';


--
-- Name: COLUMN coupons.requires_elevated_approval; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupons.requires_elevated_approval IS 'Indicates whether coupon use requires elevated approval.';


--
-- Name: COLUMN coupons.coupon_status; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupons.coupon_status IS 'Coupon lifecycle status.';


--
-- Name: COLUMN coupons.valid_from; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupons.valid_from IS 'Start of coupon validity.';


--
-- Name: COLUMN coupons.valid_to; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupons.valid_to IS 'End of coupon validity.';


--
-- Name: COLUMN coupons.created_at; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupons.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN coupons.created_by_user_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupons.created_by_user_id IS 'User who created the coupon.';


--
-- Name: COLUMN coupons.created_by_service_identity_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupons.created_by_service_identity_id IS 'Service identity that created the coupon.';


--
-- Name: COLUMN coupons.updated_at; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupons.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN coupons.updated_by_user_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupons.updated_by_user_id IS 'User who last updated the coupon.';


--
-- Name: COLUMN coupons.updated_by_service_identity_id; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupons.updated_by_service_identity_id IS 'Service identity that last updated the coupon.';


--
-- Name: COLUMN coupons.row_version; Type: COMMENT; Schema: coupons; Owner: -
--

COMMENT ON COLUMN coupons.coupons.row_version IS 'Optimistic concurrency version.';


--
-- Name: discount_evidence_references; Type: TABLE; Schema: discounts; Owner: -
--

CREATE TABLE discounts.discount_evidence_references (
    discount_evidence_reference_id uuid DEFAULT gen_random_uuid() NOT NULL,
    statutory_discount_validation_id uuid NOT NULL,
    evidence_type discounts.discount_evidence_type_enum NOT NULL,
    evidence_storage_type discounts.evidence_storage_type_enum NOT NULL,
    evidence_storage_ref character varying(256),
    evidence_hash character(64),
    evidence_capture_status discounts.evidence_capture_status_enum NOT NULL,
    access_classification discounts.evidence_access_classification_enum NOT NULL,
    redaction_status discounts.evidence_redaction_status_enum NOT NULL,
    retention_policy_code character varying(64) NOT NULL,
    retention_expires_at timestamp with time zone,
    captured_at timestamp with time zone NOT NULL,
    captured_by_user_id uuid,
    captured_by_service_identity_id uuid,
    purged_at timestamp with time zone,
    purged_by_user_id uuid,
    purged_by_service_identity_id uuid,
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_discount_evidence_references__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE discount_evidence_references; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON TABLE discounts.discount_evidence_references IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN discount_evidence_references.discount_evidence_reference_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_evidence_references.discount_evidence_reference_id IS 'Canonical identifier of the evidence reference.';


--
-- Name: COLUMN discount_evidence_references.statutory_discount_validation_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_evidence_references.statutory_discount_validation_id IS 'Validation record supported by this evidence reference.';


--
-- Name: COLUMN discount_evidence_references.evidence_type; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_evidence_references.evidence_type IS 'Type of evidence referenced.';


--
-- Name: COLUMN discount_evidence_references.evidence_storage_type; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_evidence_references.evidence_storage_type IS 'Storage mechanism or reference type.';


--
-- Name: COLUMN discount_evidence_references.evidence_storage_ref; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_evidence_references.evidence_storage_ref IS 'Object key, evidence vault reference, URI reference, or controlled storage reference.';


--
-- Name: COLUMN discount_evidence_references.evidence_hash; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_evidence_references.evidence_hash IS 'Hash of evidence content where retained.';


--
-- Name: COLUMN discount_evidence_references.evidence_capture_status; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_evidence_references.evidence_capture_status IS 'Evidence reference lifecycle state.';


--
-- Name: COLUMN discount_evidence_references.access_classification; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_evidence_references.access_classification IS 'Access classification.';


--
-- Name: COLUMN discount_evidence_references.redaction_status; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_evidence_references.redaction_status IS 'Redaction or minimization state.';


--
-- Name: COLUMN discount_evidence_references.retention_policy_code; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_evidence_references.retention_policy_code IS 'Retention policy applied to the evidence.';


--
-- Name: COLUMN discount_evidence_references.retention_expires_at; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_evidence_references.retention_expires_at IS 'Date/time when evidence becomes eligible for purge or redaction.';


--
-- Name: COLUMN discount_evidence_references.captured_at; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_evidence_references.captured_at IS 'Timestamp when evidence reference was captured.';


--
-- Name: COLUMN discount_evidence_references.captured_by_user_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_evidence_references.captured_by_user_id IS 'User who captured the evidence.';


--
-- Name: COLUMN discount_evidence_references.captured_by_service_identity_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_evidence_references.captured_by_service_identity_id IS 'Service identity that captured the evidence.';


--
-- Name: COLUMN discount_evidence_references.purged_at; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_evidence_references.purged_at IS 'Timestamp when evidence payload was purged, if applicable.';


--
-- Name: COLUMN discount_evidence_references.purged_by_user_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_evidence_references.purged_by_user_id IS 'User who purged the evidence.';


--
-- Name: COLUMN discount_evidence_references.purged_by_service_identity_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_evidence_references.purged_by_service_identity_id IS 'Service identity that purged the evidence.';


--
-- Name: COLUMN discount_evidence_references.correlation_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_evidence_references.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN discount_evidence_references.created_at; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_evidence_references.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN discount_evidence_references.created_by_user_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_evidence_references.created_by_user_id IS 'User who created the reference.';


--
-- Name: COLUMN discount_evidence_references.created_by_service_identity_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_evidence_references.created_by_service_identity_id IS 'Service identity that created the reference.';


--
-- Name: COLUMN discount_evidence_references.updated_at; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_evidence_references.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN discount_evidence_references.updated_by_user_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_evidence_references.updated_by_user_id IS 'User who last updated the reference.';


--
-- Name: COLUMN discount_evidence_references.updated_by_service_identity_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_evidence_references.updated_by_service_identity_id IS 'Service identity that last updated the reference.';


--
-- Name: COLUMN discount_evidence_references.row_version; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_evidence_references.row_version IS 'Optimistic concurrency version.';


--
-- Name: discount_policy_references; Type: TABLE; Schema: discounts; Owner: -
--

CREATE TABLE discounts.discount_policy_references (
    discount_policy_reference_id uuid DEFAULT gen_random_uuid() NOT NULL,
    policy_code character varying(64) NOT NULL,
    policy_name character varying(256) NOT NULL,
    policy_description text,
    policy_type discounts.discount_policy_type_enum NOT NULL,
    policy_level discounts.discount_policy_level_enum NOT NULL,
    entitlement_type discounts.statutory_entitlement_type_enum NOT NULL,
    national_law_reference character varying(128),
    local_ordinance_reference character varying(128),
    lgu_code character varying(32),
    jurisdiction_name character varying(128),
    site_group_id uuid,
    site_id uuid,
    parent_policy_reference_id uuid,
    fallback_policy_reference_id uuid,
    precedence_rank integer NOT NULL,
    policy_version character varying(32) NOT NULL,
    requires_operator_validation boolean DEFAULT false NOT NULL,
    requires_evidence_capture boolean DEFAULT false NOT NULL,
    evidence_retention_policy_code character varying(64),
    policy_status discounts.discount_policy_status_enum NOT NULL,
    effective_from timestamp with time zone NOT NULL,
    effective_to timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_discount_policy_references__effective_window CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT ck_discount_policy_references__precedence_rank_non_negative CHECK (((precedence_rank IS NULL) OR (precedence_rank >= 0))),
    CONSTRAINT ck_discount_policy_references__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE discount_policy_references; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON TABLE discounts.discount_policy_references IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN discount_policy_references.discount_policy_reference_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.discount_policy_reference_id IS 'Canonical identifier of the discount policy reference.';


--
-- Name: COLUMN discount_policy_references.policy_code; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.policy_code IS 'Stable internal policy code.';


--
-- Name: COLUMN discount_policy_references.policy_name; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.policy_name IS 'Human-readable policy name.';


--
-- Name: COLUMN discount_policy_references.policy_description; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.policy_description IS 'Description of the policy reference.';


--
-- Name: COLUMN discount_policy_references.policy_type; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.policy_type IS 'Type of policy reference.';


--
-- Name: COLUMN discount_policy_references.policy_level; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.policy_level IS 'Legal or operational level of the policy.';


--
-- Name: COLUMN discount_policy_references.entitlement_type; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.entitlement_type IS 'Statutory entitlement category governed by the policy.';


--
-- Name: COLUMN discount_policy_references.national_law_reference; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.national_law_reference IS 'National law reference where applicable.';


--
-- Name: COLUMN discount_policy_references.local_ordinance_reference; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.local_ordinance_reference IS 'Local ordinance number or code where applicable.';


--
-- Name: COLUMN discount_policy_references.lgu_code; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.lgu_code IS 'LGU or jurisdiction code where applicable.';


--
-- Name: COLUMN discount_policy_references.jurisdiction_name; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.jurisdiction_name IS 'Human-readable jurisdiction name.';


--
-- Name: COLUMN discount_policy_references.site_group_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.site_group_id IS 'Site group scope where policy applies.';


--
-- Name: COLUMN discount_policy_references.site_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.site_id IS 'Site scope where policy applies.';


--
-- Name: COLUMN discount_policy_references.parent_policy_reference_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.parent_policy_reference_id IS 'Parent policy reference.';


--
-- Name: COLUMN discount_policy_references.fallback_policy_reference_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.fallback_policy_reference_id IS 'Fallback policy reference, usually national law.';


--
-- Name: COLUMN discount_policy_references.precedence_rank; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.precedence_rank IS 'Policy precedence within applicable scope.';


--
-- Name: COLUMN discount_policy_references.policy_version; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.policy_version IS 'Policy version or controlled implementation version.';


--
-- Name: COLUMN discount_policy_references.requires_operator_validation; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.requires_operator_validation IS 'Indicates whether assisted operator validation is required.';


--
-- Name: COLUMN discount_policy_references.requires_evidence_capture; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.requires_evidence_capture IS 'Indicates whether evidence reference is required.';


--
-- Name: COLUMN discount_policy_references.evidence_retention_policy_code; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.evidence_retention_policy_code IS 'Retention policy code for evidence.';


--
-- Name: COLUMN discount_policy_references.policy_status; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.policy_status IS 'Policy lifecycle status.';


--
-- Name: COLUMN discount_policy_references.effective_from; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.effective_from IS 'Start of policy effectiveness.';


--
-- Name: COLUMN discount_policy_references.effective_to; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.effective_to IS 'End of policy effectiveness.';


--
-- Name: COLUMN discount_policy_references.created_at; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN discount_policy_references.created_by_user_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.created_by_user_id IS 'User who created the policy reference.';


--
-- Name: COLUMN discount_policy_references.created_by_service_identity_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.created_by_service_identity_id IS 'Service identity that created the policy reference.';


--
-- Name: COLUMN discount_policy_references.updated_at; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN discount_policy_references.updated_by_user_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.updated_by_user_id IS 'User who last updated the policy reference.';


--
-- Name: COLUMN discount_policy_references.updated_by_service_identity_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.updated_by_service_identity_id IS 'Service identity that last updated the policy reference.';


--
-- Name: COLUMN discount_policy_references.row_version; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.discount_policy_references.row_version IS 'Optimistic concurrency version.';


--
-- Name: statutory_discount_validations; Type: TABLE; Schema: discounts; Owner: -
--

CREATE TABLE discounts.statutory_discount_validations (
    statutory_discount_validation_id uuid DEFAULT gen_random_uuid() NOT NULL,
    parking_session_id uuid NOT NULL,
    tariff_snapshot_id uuid,
    entitlement_type discounts.statutory_entitlement_type_enum NOT NULL,
    evaluated_policy_reference_id uuid,
    applied_policy_reference_id uuid,
    fallback_policy_reference_id uuid,
    policy_resolution_basis discounts.policy_resolution_basis_enum NOT NULL,
    local_ordinance_applied boolean DEFAULT false NOT NULL,
    national_law_fallback_applied boolean DEFAULT false NOT NULL,
    validation_channel discounts.statutory_discount_validations_channel_enum NOT NULL,
    validation_status discounts.statutory_discount_validations_status_enum NOT NULL,
    currency_code character(3),
    gross_amount_at_validation numeric(18,2),
    statutory_discount_amount numeric(18,2),
    net_amount_after_discount numeric(18,2),
    evidence_required boolean DEFAULT false NOT NULL,
    evidence_captured boolean DEFAULT false NOT NULL,
    decision_reason_code character varying(64),
    failure_reason_code character varying(64),
    requested_at timestamp with time zone NOT NULL,
    validated_at timestamp with time zone,
    expires_at timestamp with time zone,
    validated_by_user_id uuid,
    validated_by_service_identity_id uuid,
    requested_by_user_id uuid,
    requested_by_service_identity_id uuid,
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_statutory_discount_validations__gross_amount_at_validatio CHECK (((gross_amount_at_validation IS NULL) OR (gross_amount_at_validation >= (0)::numeric))),
    CONSTRAINT ck_statutory_discount_validations__net_amount_after_discount CHECK (((net_amount_after_discount IS NULL) OR (net_amount_after_discount >= (0)::numeric))),
    CONSTRAINT ck_statutory_discount_validations__row_version_positive CHECK ((row_version > 0)),
    CONSTRAINT ck_statutory_discount_validations__statutory_discount_amount CHECK (((statutory_discount_amount IS NULL) OR (statutory_discount_amount >= (0)::numeric)))
);


--
-- Name: TABLE statutory_discount_validations; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON TABLE discounts.statutory_discount_validations IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN statutory_discount_validations.statutory_discount_validation_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.statutory_discount_validation_id IS 'Canonical identifier of the statutory discount validation.';


--
-- Name: COLUMN statutory_discount_validations.parking_session_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.parking_session_id IS 'Parking session for which validation was requested.';


--
-- Name: COLUMN statutory_discount_validations.tariff_snapshot_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.tariff_snapshot_id IS 'Tariff snapshot where approved discount effect was materialized.';


--
-- Name: COLUMN statutory_discount_validations.entitlement_type; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.entitlement_type IS 'Entitlement category requested.';


--
-- Name: COLUMN statutory_discount_validations.evaluated_policy_reference_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.evaluated_policy_reference_id IS 'Policy initially evaluated.';


--
-- Name: COLUMN statutory_discount_validations.applied_policy_reference_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.applied_policy_reference_id IS 'Final policy applied to the decision.';


--
-- Name: COLUMN statutory_discount_validations.fallback_policy_reference_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.fallback_policy_reference_id IS 'Fallback policy used, usually national law.';


--
-- Name: COLUMN statutory_discount_validations.policy_resolution_basis; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.policy_resolution_basis IS 'How policy was selected.';


--
-- Name: COLUMN statutory_discount_validations.local_ordinance_applied; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.local_ordinance_applied IS 'Indicates whether a local ordinance governed the validation.';


--
-- Name: COLUMN statutory_discount_validations.national_law_fallback_applied; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.national_law_fallback_applied IS 'Indicates whether national law fallback was used.';


--
-- Name: COLUMN statutory_discount_validations.validation_channel; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.validation_channel IS 'Channel used for validation.';


--
-- Name: COLUMN statutory_discount_validations.validation_status; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.validation_status IS 'Validation lifecycle state.';


--
-- Name: COLUMN statutory_discount_validations.currency_code; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.currency_code IS 'Currency code for discount amount fields.';


--
-- Name: COLUMN statutory_discount_validations.gross_amount_at_validation; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.gross_amount_at_validation IS 'Gross amount at time of validation.';


--
-- Name: COLUMN statutory_discount_validations.statutory_discount_amount; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.statutory_discount_amount IS 'Approved statutory discount amount.';


--
-- Name: COLUMN statutory_discount_validations.net_amount_after_discount; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.net_amount_after_discount IS 'Amount after approved statutory discount.';


--
-- Name: COLUMN statutory_discount_validations.evidence_required; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.evidence_required IS 'Indicates whether evidence was required.';


--
-- Name: COLUMN statutory_discount_validations.evidence_captured; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.evidence_captured IS 'Indicates whether evidence reference exists or was captured.';


--
-- Name: COLUMN statutory_discount_validations.decision_reason_code; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.decision_reason_code IS 'Controlled decision reason.';


--
-- Name: COLUMN statutory_discount_validations.failure_reason_code; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.failure_reason_code IS 'Controlled failure reason.';


--
-- Name: COLUMN statutory_discount_validations.requested_at; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.requested_at IS 'Timestamp when validation was requested.';


--
-- Name: COLUMN statutory_discount_validations.validated_at; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.validated_at IS 'Timestamp when validation decision was completed.';


--
-- Name: COLUMN statutory_discount_validations.expires_at; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.expires_at IS 'Expiry timestamp for validation usability.';


--
-- Name: COLUMN statutory_discount_validations.validated_by_user_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.validated_by_user_id IS 'Human operator who performed validation.';


--
-- Name: COLUMN statutory_discount_validations.validated_by_service_identity_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.validated_by_service_identity_id IS 'Service identity that performed validation.';


--
-- Name: COLUMN statutory_discount_validations.requested_by_user_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.requested_by_user_id IS 'User who requested the validation.';


--
-- Name: COLUMN statutory_discount_validations.requested_by_service_identity_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.requested_by_service_identity_id IS 'Service identity that requested the validation.';


--
-- Name: COLUMN statutory_discount_validations.correlation_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN statutory_discount_validations.created_at; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN statutory_discount_validations.created_by_user_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.created_by_user_id IS 'User who created the record.';


--
-- Name: COLUMN statutory_discount_validations.created_by_service_identity_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.created_by_service_identity_id IS 'Service identity that created the record.';


--
-- Name: COLUMN statutory_discount_validations.updated_at; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN statutory_discount_validations.updated_by_user_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.updated_by_user_id IS 'User who last updated the record.';


--
-- Name: COLUMN statutory_discount_validations.updated_by_service_identity_id; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.updated_by_service_identity_id IS 'Service identity that last updated the record.';


--
-- Name: COLUMN statutory_discount_validations.row_version; Type: COMMENT; Schema: discounts; Owner: -
--

COMMENT ON COLUMN discounts.statutory_discount_validations.row_version IS 'Optimistic concurrency version.';


--
-- Name: consumer_checkpoints; Type: TABLE; Schema: events; Owner: -
--

CREATE TABLE events.consumer_checkpoints (
    consumer_checkpoint_id uuid DEFAULT gen_random_uuid() NOT NULL,
    consumer_name character varying(128) NOT NULL,
    consumer_group character varying(128),
    subscription_name character varying(128),
    event_type character varying(128),
    aggregate_type character varying(96),
    last_outbox_event_id uuid,
    last_domain_event_id uuid,
    last_broker_offset character varying(128),
    checkpoint_status events.consumer_checkpoint_status_enum NOT NULL,
    processed_count bigint DEFAULT 0 NOT NULL,
    failure_count bigint DEFAULT 0 NOT NULL,
    last_processed_at timestamp with time zone,
    last_failed_at timestamp with time zone,
    failure_reason_code character varying(64),
    locked_at timestamp with time zone,
    locked_by_service_identity_id uuid,
    updated_by_service_identity_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    correlation_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_consumer_checkpoints__failure_count_non_negative CHECK (((failure_count IS NULL) OR (failure_count >= 0))),
    CONSTRAINT ck_consumer_checkpoints__processed_count_non_negative CHECK (((processed_count IS NULL) OR (processed_count >= 0))),
    CONSTRAINT ck_consumer_checkpoints__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE consumer_checkpoints; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON TABLE events.consumer_checkpoints IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN consumer_checkpoints.consumer_checkpoint_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.consumer_checkpoints.consumer_checkpoint_id IS 'Canonical identifier of the consumer checkpoint.';


--
-- Name: COLUMN consumer_checkpoints.consumer_name; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.consumer_checkpoints.consumer_name IS 'Stable consumer name.';


--
-- Name: COLUMN consumer_checkpoints.consumer_group; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.consumer_checkpoints.consumer_group IS 'Consumer group name, where applicable.';


--
-- Name: COLUMN consumer_checkpoints.subscription_name; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.consumer_checkpoints.subscription_name IS 'Queue, subscription, topic, or routing subscription name.';


--
-- Name: COLUMN consumer_checkpoints.event_type; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.consumer_checkpoints.event_type IS 'Event type checkpoint applies to, if scoped.';


--
-- Name: COLUMN consumer_checkpoints.aggregate_type; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.consumer_checkpoints.aggregate_type IS 'Aggregate type checkpoint applies to, if scoped.';


--
-- Name: COLUMN consumer_checkpoints.last_outbox_event_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.consumer_checkpoints.last_outbox_event_id IS 'Last processed outbox event.';


--
-- Name: COLUMN consumer_checkpoints.last_domain_event_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.consumer_checkpoints.last_domain_event_id IS 'Last processed domain event, where applicable.';


--
-- Name: COLUMN consumer_checkpoints.last_broker_offset; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.consumer_checkpoints.last_broker_offset IS 'Broker offset, delivery tag, sequence, or cursor.';


--
-- Name: COLUMN consumer_checkpoints.checkpoint_status; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.consumer_checkpoints.checkpoint_status IS 'Checkpoint lifecycle or processing status.';


--
-- Name: COLUMN consumer_checkpoints.processed_count; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.consumer_checkpoints.processed_count IS 'Count of processed events tracked by this checkpoint.';


--
-- Name: COLUMN consumer_checkpoints.failure_count; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.consumer_checkpoints.failure_count IS 'Count of processing failures tracked by this checkpoint.';


--
-- Name: COLUMN consumer_checkpoints.last_processed_at; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.consumer_checkpoints.last_processed_at IS 'Timestamp when last event was processed.';


--
-- Name: COLUMN consumer_checkpoints.last_failed_at; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.consumer_checkpoints.last_failed_at IS 'Timestamp of last processing failure.';


--
-- Name: COLUMN consumer_checkpoints.failure_reason_code; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.consumer_checkpoints.failure_reason_code IS 'Controlled failure reason.';


--
-- Name: COLUMN consumer_checkpoints.locked_at; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.consumer_checkpoints.locked_at IS 'Timestamp when checkpoint was locked for processing.';


--
-- Name: COLUMN consumer_checkpoints.locked_by_service_identity_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.consumer_checkpoints.locked_by_service_identity_id IS 'Consumer service identity holding the lock.';


--
-- Name: COLUMN consumer_checkpoints.updated_by_service_identity_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.consumer_checkpoints.updated_by_service_identity_id IS 'Consumer service identity that last updated the checkpoint.';


--
-- Name: COLUMN consumer_checkpoints.created_at; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.consumer_checkpoints.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN consumer_checkpoints.updated_at; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.consumer_checkpoints.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN consumer_checkpoints.correlation_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.consumer_checkpoints.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN consumer_checkpoints.row_version; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.consumer_checkpoints.row_version IS 'Optimistic concurrency version for checkpoint safety.';


--
-- Name: dead_letter_records; Type: TABLE; Schema: events; Owner: -
--

CREATE TABLE events.dead_letter_records (
    dead_letter_record_id uuid DEFAULT gen_random_uuid() NOT NULL,
    outbox_event_id uuid,
    event_publication_id uuid,
    consumer_name character varying(128),
    dead_letter_type events.dead_letter_type_enum NOT NULL,
    dead_letter_status events.dead_letter_status_enum NOT NULL,
    failure_reason_code character varying(64) NOT NULL,
    failure_detail_ref character varying(256),
    payload_hash character(64),
    dead_lettered_at timestamp with time zone DEFAULT now() NOT NULL,
    resolved_at timestamp with time zone,
    resolved_by_user_id uuid,
    resolved_by_service_identity_id uuid,
    resolution_reason_code character varying(64),
    replay_requested_at timestamp with time zone,
    replay_requested_by_user_id uuid,
    replay_requested_by_service_identity_id uuid,
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_dead_letter_records__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE dead_letter_records; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON TABLE events.dead_letter_records IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN dead_letter_records.dead_letter_record_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.dead_letter_records.dead_letter_record_id IS 'Canonical identifier of the dead-letter record.';


--
-- Name: COLUMN dead_letter_records.outbox_event_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.dead_letter_records.outbox_event_id IS 'Outbox event that dead-lettered.';


--
-- Name: COLUMN dead_letter_records.event_publication_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.dead_letter_records.event_publication_id IS 'Publication attempt that caused dead-lettering, where applicable.';


--
-- Name: COLUMN dead_letter_records.consumer_name; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.dead_letter_records.consumer_name IS 'Consumer that dead-lettered the event, where consumer-side dead-lettering is recorded.';


--
-- Name: COLUMN dead_letter_records.dead_letter_type; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.dead_letter_records.dead_letter_type IS 'Dead-letter category.';


--
-- Name: COLUMN dead_letter_records.dead_letter_status; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.dead_letter_records.dead_letter_status IS 'Dead-letter lifecycle status.';


--
-- Name: COLUMN dead_letter_records.failure_reason_code; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.dead_letter_records.failure_reason_code IS 'Controlled failure reason.';


--
-- Name: COLUMN dead_letter_records.failure_detail_ref; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.dead_letter_records.failure_detail_ref IS 'Reference to detailed failure evidence.';


--
-- Name: COLUMN dead_letter_records.payload_hash; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.dead_letter_records.payload_hash IS 'Payload hash associated with dead-lettered event.';


--
-- Name: COLUMN dead_letter_records.dead_lettered_at; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.dead_letter_records.dead_lettered_at IS 'Timestamp when event was dead-lettered.';


--
-- Name: COLUMN dead_letter_records.resolved_at; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.dead_letter_records.resolved_at IS 'Timestamp when dead-letter was resolved.';


--
-- Name: COLUMN dead_letter_records.resolved_by_user_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.dead_letter_records.resolved_by_user_id IS 'User who resolved dead-letter record.';


--
-- Name: COLUMN dead_letter_records.resolved_by_service_identity_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.dead_letter_records.resolved_by_service_identity_id IS 'Service identity that resolved dead-letter record.';


--
-- Name: COLUMN dead_letter_records.resolution_reason_code; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.dead_letter_records.resolution_reason_code IS 'Controlled resolution reason.';


--
-- Name: COLUMN dead_letter_records.replay_requested_at; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.dead_letter_records.replay_requested_at IS 'Timestamp when replay was requested.';


--
-- Name: COLUMN dead_letter_records.replay_requested_by_user_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.dead_letter_records.replay_requested_by_user_id IS 'User who requested replay.';


--
-- Name: COLUMN dead_letter_records.replay_requested_by_service_identity_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.dead_letter_records.replay_requested_by_service_identity_id IS 'Service identity that requested replay.';


--
-- Name: COLUMN dead_letter_records.correlation_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.dead_letter_records.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN dead_letter_records.created_at; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.dead_letter_records.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN dead_letter_records.created_by_service_identity_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.dead_letter_records.created_by_service_identity_id IS 'Service identity that created the dead-letter record.';


--
-- Name: COLUMN dead_letter_records.updated_at; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.dead_letter_records.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN dead_letter_records.updated_by_user_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.dead_letter_records.updated_by_user_id IS 'User who last updated the dead-letter record.';


--
-- Name: COLUMN dead_letter_records.updated_by_service_identity_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.dead_letter_records.updated_by_service_identity_id IS 'Service identity that last updated the dead-letter record.';


--
-- Name: COLUMN dead_letter_records.row_version; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.dead_letter_records.row_version IS 'Optimistic concurrency version.';


--
-- Name: domain_events; Type: TABLE; Schema: events; Owner: -
--

CREATE TABLE events.domain_events (
    domain_event_id uuid DEFAULT gen_random_uuid() NOT NULL,
    source_schema character varying(64) NOT NULL,
    source_table character varying(96),
    event_type character varying(128) NOT NULL,
    event_version integer DEFAULT 1 NOT NULL,
    aggregate_type character varying(96) NOT NULL,
    aggregate_id uuid NOT NULL,
    related_entity_type character varying(96),
    related_entity_id uuid,
    event_status events.domain_event_status_enum NOT NULL,
    payload_ref character varying(256),
    payload_hash character(64),
    metadata_ref character varying(256),
    occurred_at timestamp with time zone NOT NULL,
    recorded_at timestamp with time zone DEFAULT now() NOT NULL,
    actor_user_id uuid,
    actor_service_identity_id uuid,
    correlation_id uuid,
    causation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_service_identity_id uuid,
    CONSTRAINT ck_domain_events__event_version_positive CHECK ((event_version > 0))
);


--
-- Name: TABLE domain_events; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON TABLE events.domain_events IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN domain_events.domain_event_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.domain_events.domain_event_id IS 'Canonical identifier of the domain event.';


--
-- Name: COLUMN domain_events.source_schema; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.domain_events.source_schema IS 'Source schema that raised the event.';


--
-- Name: COLUMN domain_events.source_table; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.domain_events.source_table IS 'Source table associated with the event.';


--
-- Name: COLUMN domain_events.event_type; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.domain_events.event_type IS 'Stable domain event type.';


--
-- Name: COLUMN domain_events.event_version; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.domain_events.event_version IS 'Event schema version.';


--
-- Name: COLUMN domain_events.aggregate_type; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.domain_events.aggregate_type IS 'Aggregate or domain object type.';


--
-- Name: COLUMN domain_events.aggregate_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.domain_events.aggregate_id IS 'Aggregate or domain record identifier.';


--
-- Name: COLUMN domain_events.related_entity_type; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.domain_events.related_entity_type IS 'Related entity type, where applicable.';


--
-- Name: COLUMN domain_events.related_entity_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.domain_events.related_entity_id IS 'Related entity identifier, where applicable.';


--
-- Name: COLUMN domain_events.event_status; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.domain_events.event_status IS 'Domain event lifecycle status.';


--
-- Name: COLUMN domain_events.payload_ref; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.domain_events.payload_ref IS 'Reference to event payload if stored externally.';


--
-- Name: COLUMN domain_events.payload_hash; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.domain_events.payload_hash IS 'Hash of event payload.';


--
-- Name: COLUMN domain_events.metadata_ref; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.domain_events.metadata_ref IS 'Reference to event metadata if stored externally.';


--
-- Name: COLUMN domain_events.occurred_at; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.domain_events.occurred_at IS 'Timestamp when source-domain fact occurred.';


--
-- Name: COLUMN domain_events.recorded_at; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.domain_events.recorded_at IS 'Timestamp when event was recorded.';


--
-- Name: COLUMN domain_events.actor_user_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.domain_events.actor_user_id IS 'Human actor associated with the event, where applicable.';


--
-- Name: COLUMN domain_events.actor_service_identity_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.domain_events.actor_service_identity_id IS 'Service, worker, adapter, or device actor associated with the event.';


--
-- Name: COLUMN domain_events.correlation_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.domain_events.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN domain_events.causation_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.domain_events.causation_id IS 'Causation identifier where this event was caused by another action or event.';


--
-- Name: COLUMN domain_events.created_at; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.domain_events.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN domain_events.created_by_service_identity_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.domain_events.created_by_service_identity_id IS 'Service identity that wrote the event record.';


--
-- Name: event_publications; Type: TABLE; Schema: events; Owner: -
--

CREATE TABLE events.event_publications (
    event_publication_id uuid DEFAULT gen_random_uuid() NOT NULL,
    outbox_event_id uuid NOT NULL,
    publication_attempt_number integer NOT NULL,
    publisher_service_identity_id uuid NOT NULL,
    broker_type events.event_broker_type_enum NOT NULL,
    exchange_name character varying(128),
    routing_key character varying(160),
    publication_status events.event_publication_status_enum NOT NULL,
    broker_message_id character varying(128),
    broker_acknowledged boolean,
    failure_reason_code character varying(64),
    failure_detail_ref character varying(256),
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone,
    duration_ms integer,
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_event_publications__completed_after_started CHECK (((completed_at IS NULL) OR (completed_at >= started_at))),
    CONSTRAINT ck_event_publications__duration_ms_non_negative CHECK (((duration_ms IS NULL) OR (duration_ms >= 0)))
);


--
-- Name: TABLE event_publications; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON TABLE events.event_publications IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN event_publications.event_publication_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.event_publications.event_publication_id IS 'Canonical identifier of the publication attempt.';


--
-- Name: COLUMN event_publications.outbox_event_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.event_publications.outbox_event_id IS 'Outbox event being published.';


--
-- Name: COLUMN event_publications.publication_attempt_number; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.event_publications.publication_attempt_number IS 'Sequential attempt number for the outbox event.';


--
-- Name: COLUMN event_publications.publisher_service_identity_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.event_publications.publisher_service_identity_id IS 'Dispatcher or publisher service identity.';


--
-- Name: COLUMN event_publications.broker_type; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.event_publications.broker_type IS 'Broker or transport type.';


--
-- Name: COLUMN event_publications.exchange_name; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.event_publications.exchange_name IS 'Exchange name used.';


--
-- Name: COLUMN event_publications.routing_key; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.event_publications.routing_key IS 'Routing key or topic used.';


--
-- Name: COLUMN event_publications.publication_status; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.event_publications.publication_status IS 'Publication attempt result.';


--
-- Name: COLUMN event_publications.broker_message_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.event_publications.broker_message_id IS 'Broker-assigned message ID, where available.';


--
-- Name: COLUMN event_publications.broker_acknowledged; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.event_publications.broker_acknowledged IS 'Whether broker acknowledged the publication.';


--
-- Name: COLUMN event_publications.failure_reason_code; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.event_publications.failure_reason_code IS 'Controlled publication failure reason.';


--
-- Name: COLUMN event_publications.failure_detail_ref; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.event_publications.failure_detail_ref IS 'Reference to detailed failure evidence, if retained.';


--
-- Name: COLUMN event_publications.started_at; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.event_publications.started_at IS 'Publication attempt start timestamp.';


--
-- Name: COLUMN event_publications.completed_at; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.event_publications.completed_at IS 'Publication attempt completion timestamp.';


--
-- Name: COLUMN event_publications.duration_ms; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.event_publications.duration_ms IS 'Publication duration in milliseconds.';


--
-- Name: COLUMN event_publications.correlation_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.event_publications.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN event_publications.created_at; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.event_publications.created_at IS 'Record creation timestamp.';


--
-- Name: outbox_events; Type: TABLE; Schema: events; Owner: -
--

CREATE TABLE events.outbox_events (
    outbox_event_id uuid DEFAULT gen_random_uuid() NOT NULL,
    domain_event_id uuid,
    source_schema character varying(64) NOT NULL,
    source_table character varying(96),
    event_type character varying(128) NOT NULL,
    event_version integer DEFAULT 1 NOT NULL,
    aggregate_type character varying(96) NOT NULL,
    aggregate_id uuid NOT NULL,
    routing_key character varying(160) NOT NULL,
    exchange_name character varying(128),
    payload_ref character varying(256),
    payload_hash character(64),
    payload_content_type character varying(64) NOT NULL,
    publication_status events.outbox_publication_status_enum NOT NULL,
    available_at timestamp with time zone DEFAULT now() NOT NULL,
    locked_at timestamp with time zone,
    locked_by_service_identity_id uuid,
    published_at timestamp with time zone,
    next_retry_at timestamp with time zone,
    retry_count integer DEFAULT 0 NOT NULL,
    max_retry_count integer DEFAULT 10 NOT NULL,
    failure_reason_code character varying(64),
    correlation_id uuid,
    causation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_outbox_events__event_version_positive CHECK ((event_version > 0)),
    CONSTRAINT ck_outbox_events__max_retry_count_non_negative CHECK (((max_retry_count IS NULL) OR (max_retry_count >= 0))),
    CONSTRAINT ck_outbox_events__retry_count_non_negative CHECK (((retry_count IS NULL) OR (retry_count >= 0))),
    CONSTRAINT ck_outbox_events__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE outbox_events; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON TABLE events.outbox_events IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN outbox_events.outbox_event_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.outbox_event_id IS 'Canonical identifier of the outbox event.';


--
-- Name: COLUMN outbox_events.domain_event_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.domain_event_id IS 'Related domain event, where domain_events is used.';


--
-- Name: COLUMN outbox_events.source_schema; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.source_schema IS 'Source schema that produced the outbox event.';


--
-- Name: COLUMN outbox_events.source_table; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.source_table IS 'Source table associated with the event.';


--
-- Name: COLUMN outbox_events.event_type; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.event_type IS 'Event type to publish.';


--
-- Name: COLUMN outbox_events.event_version; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.event_version IS 'Published event schema version.';


--
-- Name: COLUMN outbox_events.aggregate_type; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.aggregate_type IS 'Aggregate or source domain object type.';


--
-- Name: COLUMN outbox_events.aggregate_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.aggregate_id IS 'Aggregate or source domain object identifier.';


--
-- Name: COLUMN outbox_events.routing_key; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.routing_key IS 'Broker routing key or topic name.';


--
-- Name: COLUMN outbox_events.exchange_name; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.exchange_name IS 'Broker exchange name, where applicable.';


--
-- Name: COLUMN outbox_events.payload_ref; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.payload_ref IS 'Reference to event payload if stored externally.';


--
-- Name: COLUMN outbox_events.payload_hash; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.payload_hash IS 'Hash of event payload.';


--
-- Name: COLUMN outbox_events.payload_content_type; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.payload_content_type IS 'Payload content type.';


--
-- Name: COLUMN outbox_events.publication_status; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.publication_status IS 'Outbox publication lifecycle status.';


--
-- Name: COLUMN outbox_events.available_at; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.available_at IS 'Timestamp when event becomes eligible for dispatch.';


--
-- Name: COLUMN outbox_events.locked_at; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.locked_at IS 'Timestamp when dispatcher locked the event for processing.';


--
-- Name: COLUMN outbox_events.locked_by_service_identity_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.locked_by_service_identity_id IS 'Dispatcher service identity that locked the event.';


--
-- Name: COLUMN outbox_events.published_at; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.published_at IS 'Timestamp when publication succeeded.';


--
-- Name: COLUMN outbox_events.next_retry_at; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.next_retry_at IS 'Next retry timestamp after failed publication.';


--
-- Name: COLUMN outbox_events.retry_count; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.retry_count IS 'Number of publication attempts.';


--
-- Name: COLUMN outbox_events.max_retry_count; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.max_retry_count IS 'Maximum allowed retry attempts before dead-letter handling.';


--
-- Name: COLUMN outbox_events.failure_reason_code; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.failure_reason_code IS 'Controlled failure reason.';


--
-- Name: COLUMN outbox_events.correlation_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN outbox_events.causation_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.causation_id IS 'Causation identifier.';


--
-- Name: COLUMN outbox_events.created_at; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN outbox_events.created_by_service_identity_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.created_by_service_identity_id IS 'Service identity that created the outbox event.';


--
-- Name: COLUMN outbox_events.updated_at; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN outbox_events.updated_by_service_identity_id; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.updated_by_service_identity_id IS 'Service identity that last updated the outbox event.';


--
-- Name: COLUMN outbox_events.row_version; Type: COMMENT; Schema: events; Owner: -
--

COMMENT ON COLUMN events.outbox_events.row_version IS 'Optimistic concurrency version for dispatcher safety.';


--
-- Name: gate_authorization_consumptions; Type: TABLE; Schema: gates; Owner: -
--

CREATE TABLE gates.gate_authorization_consumptions (
    gate_authorization_consumption_id uuid DEFAULT gen_random_uuid() NOT NULL,
    exit_authorization_id uuid,
    authorization_token_hash character(64),
    gate_device_id uuid,
    site_id uuid NOT NULL,
    lane_id uuid,
    consume_status gates.gate_authorization_consumption_status_enum NOT NULL,
    consume_reason_code character varying(64),
    requested_at timestamp with time zone NOT NULL,
    validated_at timestamp with time zone,
    consumed_at timestamp with time zone,
    command_requested boolean DEFAULT false NOT NULL,
    command_result_status gates.gate_command_result_status_enum,
    command_result_at timestamp with time zone,
    failure_detail text,
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_service_identity_id uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_gate_authorization_consumptions__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE gate_authorization_consumptions; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON TABLE gates.gate_authorization_consumptions IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN gate_authorization_consumptions.gate_authorization_consumption_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_authorization_consumptions.gate_authorization_consumption_id IS 'Canonical identifier of the consume attempt.';


--
-- Name: COLUMN gate_authorization_consumptions.exit_authorization_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_authorization_consumptions.exit_authorization_id IS 'Authorization presented or consumed, where known.';


--
-- Name: COLUMN gate_authorization_consumptions.authorization_token_hash; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_authorization_consumptions.authorization_token_hash IS 'Hash of presented token where authorization ID is not yet known or for replay analysis.';


--
-- Name: COLUMN gate_authorization_consumptions.gate_device_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_authorization_consumptions.gate_device_id IS 'Gate device involved in the consume attempt.';


--
-- Name: COLUMN gate_authorization_consumptions.site_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_authorization_consumptions.site_id IS 'Site where consume attempt occurred.';


--
-- Name: COLUMN gate_authorization_consumptions.lane_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_authorization_consumptions.lane_id IS 'Lane where consume attempt occurred.';


--
-- Name: COLUMN gate_authorization_consumptions.consume_status; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_authorization_consumptions.consume_status IS 'Consume result.';


--
-- Name: COLUMN gate_authorization_consumptions.consume_reason_code; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_authorization_consumptions.consume_reason_code IS 'Controlled reason for denial, failure, or exception.';


--
-- Name: COLUMN gate_authorization_consumptions.requested_at; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_authorization_consumptions.requested_at IS 'Timestamp when consume request was received.';


--
-- Name: COLUMN gate_authorization_consumptions.validated_at; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_authorization_consumptions.validated_at IS 'Timestamp when authorization validation completed.';


--
-- Name: COLUMN gate_authorization_consumptions.consumed_at; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_authorization_consumptions.consumed_at IS 'Timestamp when authorization was consumed through the approved path.';


--
-- Name: COLUMN gate_authorization_consumptions.command_requested; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_authorization_consumptions.command_requested IS 'Indicates whether gate-open command was requested after consume.';


--
-- Name: COLUMN gate_authorization_consumptions.command_result_status; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_authorization_consumptions.command_result_status IS 'Result of gate-open command, if captured here.';


--
-- Name: COLUMN gate_authorization_consumptions.command_result_at; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_authorization_consumptions.command_result_at IS 'Timestamp when command result was known.';


--
-- Name: COLUMN gate_authorization_consumptions.failure_detail; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_authorization_consumptions.failure_detail IS 'Controlled troubleshooting detail.';


--
-- Name: COLUMN gate_authorization_consumptions.correlation_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_authorization_consumptions.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN gate_authorization_consumptions.created_at; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_authorization_consumptions.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN gate_authorization_consumptions.created_by_service_identity_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_authorization_consumptions.created_by_service_identity_id IS 'Service identity that recorded the consume attempt.';


--
-- Name: COLUMN gate_authorization_consumptions.updated_at; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_authorization_consumptions.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN gate_authorization_consumptions.updated_by_service_identity_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_authorization_consumptions.updated_by_service_identity_id IS 'Service identity that updated the consume record.';


--
-- Name: COLUMN gate_authorization_consumptions.row_version; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_authorization_consumptions.row_version IS 'Optimistic concurrency version.';


--
-- Name: gate_devices; Type: TABLE; Schema: gates; Owner: -
--

CREATE TABLE gates.gate_devices (
    gate_device_id uuid DEFAULT gen_random_uuid() NOT NULL,
    site_id uuid NOT NULL,
    lane_id uuid,
    service_identity_id uuid,
    device_code character varying(64) NOT NULL,
    device_name character varying(128) NOT NULL,
    device_type gates.gate_device_type_enum NOT NULL,
    vendor_device_ref character varying(128),
    serial_number character varying(128),
    device_status gates.gate_device_status_enum NOT NULL,
    installed_at timestamp with time zone,
    activated_at timestamp with time zone,
    retired_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_gate_devices__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE gate_devices; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON TABLE gates.gate_devices IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN gate_devices.gate_device_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_devices.gate_device_id IS 'Canonical identifier of the gate device.';


--
-- Name: COLUMN gate_devices.site_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_devices.site_id IS 'Site where the device operates.';


--
-- Name: COLUMN gate_devices.lane_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_devices.lane_id IS 'Lane where the device is assigned.';


--
-- Name: COLUMN gate_devices.service_identity_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_devices.service_identity_id IS 'Authenticated service or device principal.';


--
-- Name: COLUMN gate_devices.device_code; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_devices.device_code IS 'Stable internal device code.';


--
-- Name: COLUMN gate_devices.device_name; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_devices.device_name IS 'Human-readable device name.';


--
-- Name: COLUMN gate_devices.device_type; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_devices.device_type IS 'Device classification.';


--
-- Name: COLUMN gate_devices.vendor_device_ref; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_devices.vendor_device_ref IS 'Vendor or controller reference for the device.';


--
-- Name: COLUMN gate_devices.serial_number; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_devices.serial_number IS 'Manufacturer serial number where available.';


--
-- Name: COLUMN gate_devices.device_status; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_devices.device_status IS 'Device lifecycle or operational status.';


--
-- Name: COLUMN gate_devices.installed_at; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_devices.installed_at IS 'Installation timestamp.';


--
-- Name: COLUMN gate_devices.activated_at; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_devices.activated_at IS 'Activation timestamp.';


--
-- Name: COLUMN gate_devices.retired_at; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_devices.retired_at IS 'Retirement timestamp.';


--
-- Name: COLUMN gate_devices.created_at; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_devices.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN gate_devices.created_by_user_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_devices.created_by_user_id IS 'User who created the record.';


--
-- Name: COLUMN gate_devices.created_by_service_identity_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_devices.created_by_service_identity_id IS 'Service identity that created the record.';


--
-- Name: COLUMN gate_devices.updated_at; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_devices.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN gate_devices.updated_by_user_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_devices.updated_by_user_id IS 'User who last updated the record.';


--
-- Name: COLUMN gate_devices.updated_by_service_identity_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_devices.updated_by_service_identity_id IS 'Service identity that last updated the record.';


--
-- Name: COLUMN gate_devices.row_version; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_devices.row_version IS 'Optimistic concurrency version.';


--
-- Name: gate_events; Type: TABLE; Schema: gates; Owner: -
--

CREATE TABLE gates.gate_events (
    gate_event_id uuid DEFAULT gen_random_uuid() NOT NULL,
    gate_device_id uuid,
    gate_authorization_consumption_id uuid,
    exit_authorization_id uuid,
    site_id uuid NOT NULL,
    lane_id uuid,
    event_type gates.gate_event_type_enum NOT NULL,
    event_status gates.gate_event_status_enum NOT NULL,
    event_reason_code character varying(64),
    event_payload_ref character varying(256),
    event_payload_hash character(64),
    source_event_ref character varying(128),
    occurred_at timestamp with time zone NOT NULL,
    received_at timestamp with time zone NOT NULL,
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_service_identity_id uuid NOT NULL
);


--
-- Name: TABLE gate_events; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON TABLE gates.gate_events IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN gate_events.gate_event_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_events.gate_event_id IS 'Canonical identifier of the gate event.';


--
-- Name: COLUMN gate_events.gate_device_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_events.gate_device_id IS 'Gate device that emitted or was associated with the event.';


--
-- Name: COLUMN gate_events.gate_authorization_consumption_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_events.gate_authorization_consumption_id IS 'Related authorization consume attempt.';


--
-- Name: COLUMN gate_events.exit_authorization_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_events.exit_authorization_id IS 'Related exit authorization where applicable.';


--
-- Name: COLUMN gate_events.site_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_events.site_id IS 'Site where the event occurred.';


--
-- Name: COLUMN gate_events.lane_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_events.lane_id IS 'Lane where the event occurred.';


--
-- Name: COLUMN gate_events.event_type; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_events.event_type IS 'Gate event type.';


--
-- Name: COLUMN gate_events.event_status; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_events.event_status IS 'Event result or classification.';


--
-- Name: COLUMN gate_events.event_reason_code; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_events.event_reason_code IS 'Controlled reason or classification.';


--
-- Name: COLUMN gate_events.event_payload_ref; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_events.event_payload_ref IS 'Reference to detailed event payload if retained.';


--
-- Name: COLUMN gate_events.event_payload_hash; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_events.event_payload_hash IS 'Hash of detailed payload where retained.';


--
-- Name: COLUMN gate_events.source_event_ref; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_events.source_event_ref IS 'Vendor or device event reference where available.';


--
-- Name: COLUMN gate_events.occurred_at; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_events.occurred_at IS 'Timestamp when event occurred or was observed.';


--
-- Name: COLUMN gate_events.received_at; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_events.received_at IS 'Timestamp when ExitPass received or recorded the event.';


--
-- Name: COLUMN gate_events.correlation_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_events.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN gate_events.created_at; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_events.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN gate_events.created_by_service_identity_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_events.created_by_service_identity_id IS 'Service identity that created the event.';


--
-- Name: gate_heartbeats; Type: TABLE; Schema: gates; Owner: -
--

CREATE TABLE gates.gate_heartbeats (
    gate_heartbeat_id uuid DEFAULT gen_random_uuid() NOT NULL,
    gate_device_id uuid NOT NULL,
    site_id uuid NOT NULL,
    lane_id uuid,
    heartbeat_status gates.gate_heartbeat_status_enum NOT NULL,
    device_reported_status character varying(64),
    latency_ms integer,
    error_code character varying(64),
    error_detail text,
    observed_at timestamp with time zone NOT NULL,
    received_at timestamp with time zone NOT NULL,
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_service_identity_id uuid NOT NULL,
    CONSTRAINT ck_gate_heartbeats__latency_ms_non_negative CHECK (((latency_ms IS NULL) OR (latency_ms >= 0)))
);


--
-- Name: TABLE gate_heartbeats; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON TABLE gates.gate_heartbeats IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN gate_heartbeats.gate_heartbeat_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_heartbeats.gate_heartbeat_id IS 'Canonical identifier of the heartbeat record.';


--
-- Name: COLUMN gate_heartbeats.gate_device_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_heartbeats.gate_device_id IS 'Gate device that produced or is represented by the heartbeat.';


--
-- Name: COLUMN gate_heartbeats.site_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_heartbeats.site_id IS 'Site where the device operates.';


--
-- Name: COLUMN gate_heartbeats.lane_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_heartbeats.lane_id IS 'Lane where the device operates.';


--
-- Name: COLUMN gate_heartbeats.heartbeat_status; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_heartbeats.heartbeat_status IS 'Health status.';


--
-- Name: COLUMN gate_heartbeats.device_reported_status; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_heartbeats.device_reported_status IS 'Native status from device or adapter.';


--
-- Name: COLUMN gate_heartbeats.latency_ms; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_heartbeats.latency_ms IS 'Measured latency in milliseconds.';


--
-- Name: COLUMN gate_heartbeats.error_code; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_heartbeats.error_code IS 'Device or adapter error code.';


--
-- Name: COLUMN gate_heartbeats.error_detail; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_heartbeats.error_detail IS 'Controlled error detail or diagnostic note.';


--
-- Name: COLUMN gate_heartbeats.observed_at; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_heartbeats.observed_at IS 'Timestamp when health was observed.';


--
-- Name: COLUMN gate_heartbeats.received_at; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_heartbeats.received_at IS 'Timestamp when ExitPass recorded heartbeat.';


--
-- Name: COLUMN gate_heartbeats.correlation_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_heartbeats.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN gate_heartbeats.created_at; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_heartbeats.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN gate_heartbeats.created_by_service_identity_id; Type: COMMENT; Schema: gates; Owner: -
--

COMMENT ON COLUMN gates.gate_heartbeats.created_by_service_identity_id IS 'Service identity that recorded the heartbeat.';


--
-- Name: permissions; Type: TABLE; Schema: identity; Owner: -
--

CREATE TABLE identity.permissions (
    permission_id uuid DEFAULT gen_random_uuid() NOT NULL,
    permission_code character varying(96) NOT NULL,
    permission_name character varying(128) NOT NULL,
    permission_description text,
    permission_domain character varying(64) NOT NULL,
    permission_action character varying(64) NOT NULL,
    permission_status identity.permission_status_enum NOT NULL,
    is_sensitive boolean DEFAULT false NOT NULL,
    requires_audit boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_permissions__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE permissions; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON TABLE identity.permissions IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN permissions.permission_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.permissions.permission_id IS 'Canonical identifier of the permission.';


--
-- Name: COLUMN permissions.permission_code; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.permissions.permission_code IS 'Stable permission code.';


--
-- Name: COLUMN permissions.permission_name; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.permissions.permission_name IS 'Human-readable permission name.';


--
-- Name: COLUMN permissions.permission_description; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.permissions.permission_description IS 'Description of the permission.';


--
-- Name: COLUMN permissions.permission_domain; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.permissions.permission_domain IS 'Domain or schema to which the permission belongs.';


--
-- Name: COLUMN permissions.permission_action; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.permissions.permission_action IS 'Action category.';


--
-- Name: COLUMN permissions.permission_status; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.permissions.permission_status IS 'Permission lifecycle status.';


--
-- Name: COLUMN permissions.is_sensitive; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.permissions.is_sensitive IS 'Indicates whether the permission grants sensitive access.';


--
-- Name: COLUMN permissions.requires_audit; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.permissions.requires_audit IS 'Indicates whether use of the permission should be auditable.';


--
-- Name: COLUMN permissions.created_at; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.permissions.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN permissions.created_by_user_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.permissions.created_by_user_id IS 'User who created the permission.';


--
-- Name: COLUMN permissions.created_by_service_identity_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.permissions.created_by_service_identity_id IS 'Service identity that created the permission.';


--
-- Name: COLUMN permissions.updated_at; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.permissions.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN permissions.updated_by_user_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.permissions.updated_by_user_id IS 'User who last updated the permission.';


--
-- Name: COLUMN permissions.updated_by_service_identity_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.permissions.updated_by_service_identity_id IS 'Service identity that last updated the permission.';


--
-- Name: COLUMN permissions.row_version; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.permissions.row_version IS 'Optimistic concurrency version.';


--
-- Name: role_permissions; Type: TABLE; Schema: identity; Owner: -
--

CREATE TABLE identity.role_permissions (
    role_permission_id uuid DEFAULT gen_random_uuid() NOT NULL,
    role_id uuid NOT NULL,
    permission_id uuid NOT NULL,
    binding_status identity.role_permission_binding_status_enum NOT NULL,
    binding_reason_code character varying(64),
    assigned_at timestamp with time zone DEFAULT now() NOT NULL,
    assigned_by_user_id uuid,
    assigned_by_service_identity_id uuid,
    effective_from timestamp with time zone NOT NULL,
    effective_to timestamp with time zone,
    revoked_at timestamp with time zone,
    revoked_by_user_id uuid,
    revoked_by_service_identity_id uuid,
    revocation_reason_code character varying(64),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_role_permissions__effective_window CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT ck_role_permissions__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE role_permissions; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON TABLE identity.role_permissions IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN role_permissions.role_permission_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.role_permissions.role_permission_id IS 'Canonical identifier of the role-permission binding.';


--
-- Name: COLUMN role_permissions.role_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.role_permissions.role_id IS 'Role receiving the permission.';


--
-- Name: COLUMN role_permissions.permission_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.role_permissions.permission_id IS 'Permission assigned to the role.';


--
-- Name: COLUMN role_permissions.binding_status; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.role_permissions.binding_status IS 'Binding lifecycle status.';


--
-- Name: COLUMN role_permissions.binding_reason_code; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.role_permissions.binding_reason_code IS 'Controlled reason for binding.';


--
-- Name: COLUMN role_permissions.assigned_at; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.role_permissions.assigned_at IS 'Timestamp when permission binding was assigned.';


--
-- Name: COLUMN role_permissions.assigned_by_user_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.role_permissions.assigned_by_user_id IS 'User who assigned the permission to the role.';


--
-- Name: COLUMN role_permissions.assigned_by_service_identity_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.role_permissions.assigned_by_service_identity_id IS 'Service identity that assigned the permission.';


--
-- Name: COLUMN role_permissions.effective_from; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.role_permissions.effective_from IS 'Start of binding effectiveness.';


--
-- Name: COLUMN role_permissions.effective_to; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.role_permissions.effective_to IS 'End of binding effectiveness.';


--
-- Name: COLUMN role_permissions.revoked_at; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.role_permissions.revoked_at IS 'Timestamp when permission binding was revoked.';


--
-- Name: COLUMN role_permissions.revoked_by_user_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.role_permissions.revoked_by_user_id IS 'User who revoked the binding.';


--
-- Name: COLUMN role_permissions.revoked_by_service_identity_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.role_permissions.revoked_by_service_identity_id IS 'Service identity that revoked the binding.';


--
-- Name: COLUMN role_permissions.revocation_reason_code; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.role_permissions.revocation_reason_code IS 'Controlled reason for revocation.';


--
-- Name: COLUMN role_permissions.created_at; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.role_permissions.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN role_permissions.created_by_user_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.role_permissions.created_by_user_id IS 'User who created the binding.';


--
-- Name: COLUMN role_permissions.created_by_service_identity_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.role_permissions.created_by_service_identity_id IS 'Service identity that created the binding.';


--
-- Name: COLUMN role_permissions.updated_at; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.role_permissions.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN role_permissions.updated_by_user_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.role_permissions.updated_by_user_id IS 'User who last updated the binding.';


--
-- Name: COLUMN role_permissions.updated_by_service_identity_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.role_permissions.updated_by_service_identity_id IS 'Service identity that last updated the binding.';


--
-- Name: COLUMN role_permissions.row_version; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.role_permissions.row_version IS 'Optimistic concurrency version.';


--
-- Name: roles; Type: TABLE; Schema: identity; Owner: -
--

CREATE TABLE identity.roles (
    role_id uuid DEFAULT gen_random_uuid() NOT NULL,
    role_code character varying(64) NOT NULL,
    role_name character varying(128) NOT NULL,
    role_description text,
    role_type identity.role_type_enum NOT NULL,
    role_status identity.role_status_enum NOT NULL,
    is_privileged boolean DEFAULT false NOT NULL,
    requires_elevated_approval boolean DEFAULT false NOT NULL,
    effective_from timestamp with time zone NOT NULL,
    effective_to timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_roles__effective_window CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT ck_roles__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE roles; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON TABLE identity.roles IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN roles.role_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.roles.role_id IS 'Canonical identifier of the role.';


--
-- Name: COLUMN roles.role_code; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.roles.role_code IS 'Stable role code.';


--
-- Name: COLUMN roles.role_name; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.roles.role_name IS 'Human-readable role name.';


--
-- Name: COLUMN roles.role_description; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.roles.role_description IS 'Description of the role.';


--
-- Name: COLUMN roles.role_type; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.roles.role_type IS 'Role classification.';


--
-- Name: COLUMN roles.role_status; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.roles.role_status IS 'Role lifecycle status.';


--
-- Name: COLUMN roles.is_privileged; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.roles.is_privileged IS 'Indicates whether the role grants privileged or sensitive access.';


--
-- Name: COLUMN roles.requires_elevated_approval; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.roles.requires_elevated_approval IS 'Indicates whether assignment requires elevated approval.';


--
-- Name: COLUMN roles.effective_from; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.roles.effective_from IS 'Start of role effectiveness.';


--
-- Name: COLUMN roles.effective_to; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.roles.effective_to IS 'End of role effectiveness.';


--
-- Name: COLUMN roles.created_at; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.roles.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN roles.created_by_user_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.roles.created_by_user_id IS 'User who created the role.';


--
-- Name: COLUMN roles.created_by_service_identity_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.roles.created_by_service_identity_id IS 'Service identity that created the role.';


--
-- Name: COLUMN roles.updated_at; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.roles.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN roles.updated_by_user_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.roles.updated_by_user_id IS 'User who last updated the role.';


--
-- Name: COLUMN roles.updated_by_service_identity_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.roles.updated_by_service_identity_id IS 'Service identity that last updated the role.';


--
-- Name: COLUMN roles.row_version; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.roles.row_version IS 'Optimistic concurrency version.';


--
-- Name: service_identities; Type: TABLE; Schema: identity; Owner: -
--

CREATE TABLE identity.service_identities (
    service_identity_id uuid DEFAULT gen_random_uuid() NOT NULL,
    service_identity_code character varying(64) NOT NULL,
    service_identity_name character varying(128) NOT NULL,
    identity_type identity.service_identity_type_enum NOT NULL,
    identity_status identity.service_identity_status_enum NOT NULL,
    owning_service_name character varying(128),
    credential_reference character varying(256),
    credential_type identity.service_credential_type_enum,
    credential_expires_at timestamp with time zone,
    last_rotated_at timestamp with time zone,
    last_authenticated_at timestamp with time zone,
    revoked_at timestamp with time zone,
    revocation_reason_code character varying(64),
    effective_from timestamp with time zone NOT NULL,
    effective_to timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_service_identities__effective_window CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT ck_service_identities__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE service_identities; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON TABLE identity.service_identities IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN service_identities.service_identity_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.service_identities.service_identity_id IS 'Canonical identifier of the service identity.';


--
-- Name: COLUMN service_identities.service_identity_code; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.service_identities.service_identity_code IS 'Stable internal service identity code.';


--
-- Name: COLUMN service_identities.service_identity_name; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.service_identities.service_identity_name IS 'Human-readable service identity name.';


--
-- Name: COLUMN service_identities.identity_type; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.service_identities.identity_type IS 'Type of non-human principal.';


--
-- Name: COLUMN service_identities.identity_status; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.service_identities.identity_status IS 'Service identity lifecycle status.';


--
-- Name: COLUMN service_identities.owning_service_name; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.service_identities.owning_service_name IS 'Owning service, worker, adapter, or component name.';


--
-- Name: COLUMN service_identities.credential_reference; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.service_identities.credential_reference IS 'Reference to secret, certificate, key vault entry, or credential profile.';


--
-- Name: COLUMN service_identities.credential_type; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.service_identities.credential_type IS 'Credential type used by the service identity.';


--
-- Name: COLUMN service_identities.credential_expires_at; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.service_identities.credential_expires_at IS 'Credential expiry timestamp, where applicable.';


--
-- Name: COLUMN service_identities.last_rotated_at; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.service_identities.last_rotated_at IS 'Last credential rotation timestamp.';


--
-- Name: COLUMN service_identities.last_authenticated_at; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.service_identities.last_authenticated_at IS 'Last successful authentication timestamp.';


--
-- Name: COLUMN service_identities.revoked_at; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.service_identities.revoked_at IS 'Timestamp when identity was revoked.';


--
-- Name: COLUMN service_identities.revocation_reason_code; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.service_identities.revocation_reason_code IS 'Controlled revocation reason.';


--
-- Name: COLUMN service_identities.effective_from; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.service_identities.effective_from IS 'Start of service identity effectiveness.';


--
-- Name: COLUMN service_identities.effective_to; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.service_identities.effective_to IS 'End of service identity effectiveness.';


--
-- Name: COLUMN service_identities.created_at; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.service_identities.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN service_identities.created_by_user_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.service_identities.created_by_user_id IS 'User who created the service identity.';


--
-- Name: COLUMN service_identities.created_by_service_identity_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.service_identities.created_by_service_identity_id IS 'Service identity that created this service identity.';


--
-- Name: COLUMN service_identities.updated_at; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.service_identities.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN service_identities.updated_by_user_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.service_identities.updated_by_user_id IS 'User who last updated the service identity.';


--
-- Name: COLUMN service_identities.updated_by_service_identity_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.service_identities.updated_by_service_identity_id IS 'Service identity that last updated this service identity.';


--
-- Name: COLUMN service_identities.row_version; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.service_identities.row_version IS 'Optimistic concurrency version.';


--
-- Name: user_roles; Type: TABLE; Schema: identity; Owner: -
--

CREATE TABLE identity.user_roles (
    user_role_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    role_id uuid NOT NULL,
    assignment_status identity.user_role_assignment_status_enum NOT NULL,
    assignment_reason_code character varying(64),
    assigned_at timestamp with time zone DEFAULT now() NOT NULL,
    assigned_by_user_id uuid,
    assigned_by_service_identity_id uuid,
    effective_from timestamp with time zone NOT NULL,
    effective_to timestamp with time zone,
    revoked_at timestamp with time zone,
    revoked_by_user_id uuid,
    revoked_by_service_identity_id uuid,
    revocation_reason_code character varying(64),
    last_reviewed_at timestamp with time zone,
    last_reviewed_by_user_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_user_roles__effective_window CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT ck_user_roles__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE user_roles; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON TABLE identity.user_roles IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN user_roles.user_role_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.user_roles.user_role_id IS 'Canonical identifier of the user-role assignment.';


--
-- Name: COLUMN user_roles.user_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.user_roles.user_id IS 'User receiving the role.';


--
-- Name: COLUMN user_roles.role_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.user_roles.role_id IS 'Role assigned to the user.';


--
-- Name: COLUMN user_roles.assignment_status; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.user_roles.assignment_status IS 'Assignment lifecycle status.';


--
-- Name: COLUMN user_roles.assignment_reason_code; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.user_roles.assignment_reason_code IS 'Controlled reason for assignment.';


--
-- Name: COLUMN user_roles.assigned_at; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.user_roles.assigned_at IS 'Timestamp when role assignment became effective or was created.';


--
-- Name: COLUMN user_roles.assigned_by_user_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.user_roles.assigned_by_user_id IS 'User who assigned the role.';


--
-- Name: COLUMN user_roles.assigned_by_service_identity_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.user_roles.assigned_by_service_identity_id IS 'Service identity that assigned the role.';


--
-- Name: COLUMN user_roles.effective_from; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.user_roles.effective_from IS 'Start of role assignment effectiveness.';


--
-- Name: COLUMN user_roles.effective_to; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.user_roles.effective_to IS 'End of role assignment effectiveness.';


--
-- Name: COLUMN user_roles.revoked_at; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.user_roles.revoked_at IS 'Timestamp when assignment was revoked.';


--
-- Name: COLUMN user_roles.revoked_by_user_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.user_roles.revoked_by_user_id IS 'User who revoked the assignment.';


--
-- Name: COLUMN user_roles.revoked_by_service_identity_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.user_roles.revoked_by_service_identity_id IS 'Service identity that revoked the assignment.';


--
-- Name: COLUMN user_roles.revocation_reason_code; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.user_roles.revocation_reason_code IS 'Controlled reason for revocation.';


--
-- Name: COLUMN user_roles.last_reviewed_at; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.user_roles.last_reviewed_at IS 'Last access-review timestamp.';


--
-- Name: COLUMN user_roles.last_reviewed_by_user_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.user_roles.last_reviewed_by_user_id IS 'User who reviewed the assignment.';


--
-- Name: COLUMN user_roles.created_at; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.user_roles.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN user_roles.created_by_user_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.user_roles.created_by_user_id IS 'User who created the assignment.';


--
-- Name: COLUMN user_roles.created_by_service_identity_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.user_roles.created_by_service_identity_id IS 'Service identity that created the assignment.';


--
-- Name: COLUMN user_roles.updated_at; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.user_roles.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN user_roles.updated_by_user_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.user_roles.updated_by_user_id IS 'User who last updated the assignment.';


--
-- Name: COLUMN user_roles.updated_by_service_identity_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.user_roles.updated_by_service_identity_id IS 'Service identity that last updated the assignment.';


--
-- Name: COLUMN user_roles.row_version; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.user_roles.row_version IS 'Optimistic concurrency version.';


--
-- Name: users; Type: TABLE; Schema: identity; Owner: -
--

CREATE TABLE identity.users (
    user_id uuid DEFAULT gen_random_uuid() NOT NULL,
    username character varying(128) NOT NULL,
    email character varying(256),
    email_normalized character varying(256),
    display_name character varying(128) NOT NULL,
    mobile_number_masked character varying(32),
    user_type identity.user_type_enum NOT NULL,
    user_status identity.user_status_enum NOT NULL,
    last_login_at timestamp with time zone,
    locked_at timestamp with time zone,
    suspended_at timestamp with time zone,
    retired_at timestamp with time zone,
    effective_from timestamp with time zone NOT NULL,
    effective_to timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_users__effective_window CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT ck_users__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE users; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON TABLE identity.users IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN users.user_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.users.user_id IS 'Canonical identifier of the human user.';


--
-- Name: COLUMN users.username; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.users.username IS 'Stable login or platform username.';


--
-- Name: COLUMN users.email; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.users.email IS 'User email address.';


--
-- Name: COLUMN users.email_normalized; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.users.email_normalized IS 'Normalized email for uniqueness and lookup.';


--
-- Name: COLUMN users.display_name; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.users.display_name IS 'Human-readable display name.';


--
-- Name: COLUMN users.mobile_number_masked; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.users.mobile_number_masked IS 'Masked mobile number where retained.';


--
-- Name: COLUMN users.user_type; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.users.user_type IS 'User classification.';


--
-- Name: COLUMN users.user_status; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.users.user_status IS 'User lifecycle status.';


--
-- Name: COLUMN users.last_login_at; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.users.last_login_at IS 'Last successful login timestamp.';


--
-- Name: COLUMN users.locked_at; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.users.locked_at IS 'Timestamp when user was locked, if applicable.';


--
-- Name: COLUMN users.suspended_at; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.users.suspended_at IS 'Timestamp when user was suspended, if applicable.';


--
-- Name: COLUMN users.retired_at; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.users.retired_at IS 'Timestamp when user was retired.';


--
-- Name: COLUMN users.effective_from; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.users.effective_from IS 'Start of user effectiveness.';


--
-- Name: COLUMN users.effective_to; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.users.effective_to IS 'End of user effectiveness.';


--
-- Name: COLUMN users.created_at; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.users.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN users.created_by_user_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.users.created_by_user_id IS 'User who created the user record.';


--
-- Name: COLUMN users.created_by_service_identity_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.users.created_by_service_identity_id IS 'Service identity that created the user record.';


--
-- Name: COLUMN users.updated_at; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.users.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN users.updated_by_user_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.users.updated_by_user_id IS 'User who last updated the user record.';


--
-- Name: COLUMN users.updated_by_service_identity_id; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.users.updated_by_service_identity_id IS 'Service identity that last updated the user record.';


--
-- Name: COLUMN users.row_version; Type: COMMENT; Schema: identity; Owner: -
--

COMMENT ON COLUMN identity.users.row_version IS 'Optimistic concurrency version.';


--
-- Name: adapter_mappings; Type: TABLE; Schema: integration; Owner: -
--

CREATE TABLE integration.adapter_mappings (
    adapter_mapping_id uuid DEFAULT gen_random_uuid() NOT NULL,
    vendor_system_id uuid NOT NULL,
    mapping_type integration.adapter_mapping_type_enum NOT NULL,
    site_group_id uuid,
    site_id uuid,
    lane_id uuid,
    gate_device_id uuid,
    payment_rail_id uuid,
    vendor_object_type character varying(64) NOT NULL,
    vendor_object_ref character varying(128) NOT NULL,
    vendor_object_name character varying(128),
    mapping_status integration.adapter_mapping_status_enum NOT NULL,
    mapping_confidence integration.adapter_mapping_confidence_enum,
    effective_from timestamp with time zone NOT NULL,
    effective_to timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_adapter_mappings__effective_window CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT ck_adapter_mappings__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE adapter_mappings; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON TABLE integration.adapter_mappings IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN adapter_mappings.adapter_mapping_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.adapter_mappings.adapter_mapping_id IS 'Canonical identifier of the adapter mapping.';


--
-- Name: COLUMN adapter_mappings.vendor_system_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.adapter_mappings.vendor_system_id IS 'Vendor system to which the mapping applies.';


--
-- Name: COLUMN adapter_mappings.mapping_type; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.adapter_mappings.mapping_type IS 'Type of mapping.';


--
-- Name: COLUMN adapter_mappings.site_group_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.adapter_mappings.site_group_id IS 'ExitPass site group being mapped.';


--
-- Name: COLUMN adapter_mappings.site_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.adapter_mappings.site_id IS 'ExitPass site being mapped.';


--
-- Name: COLUMN adapter_mappings.lane_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.adapter_mappings.lane_id IS 'ExitPass lane being mapped.';


--
-- Name: COLUMN adapter_mappings.gate_device_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.adapter_mappings.gate_device_id IS 'ExitPass gate device being mapped.';


--
-- Name: COLUMN adapter_mappings.payment_rail_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.adapter_mappings.payment_rail_id IS 'ExitPass payment rail being mapped.';


--
-- Name: COLUMN adapter_mappings.vendor_object_type; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.adapter_mappings.vendor_object_type IS 'Vendor object type.';


--
-- Name: COLUMN adapter_mappings.vendor_object_ref; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.adapter_mappings.vendor_object_ref IS 'Vendor object identifier.';


--
-- Name: COLUMN adapter_mappings.vendor_object_name; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.adapter_mappings.vendor_object_name IS 'Vendor object display name.';


--
-- Name: COLUMN adapter_mappings.mapping_status; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.adapter_mappings.mapping_status IS 'Mapping lifecycle status.';


--
-- Name: COLUMN adapter_mappings.mapping_confidence; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.adapter_mappings.mapping_confidence IS 'Confidence or source of mapping.';


--
-- Name: COLUMN adapter_mappings.effective_from; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.adapter_mappings.effective_from IS 'Start of mapping effectiveness.';


--
-- Name: COLUMN adapter_mappings.effective_to; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.adapter_mappings.effective_to IS 'End of mapping effectiveness.';


--
-- Name: COLUMN adapter_mappings.created_at; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.adapter_mappings.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN adapter_mappings.created_by_user_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.adapter_mappings.created_by_user_id IS 'User who created the mapping.';


--
-- Name: COLUMN adapter_mappings.created_by_service_identity_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.adapter_mappings.created_by_service_identity_id IS 'Service identity that created the mapping.';


--
-- Name: COLUMN adapter_mappings.updated_at; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.adapter_mappings.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN adapter_mappings.updated_by_user_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.adapter_mappings.updated_by_user_id IS 'User who last updated the mapping.';


--
-- Name: COLUMN adapter_mappings.updated_by_service_identity_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.adapter_mappings.updated_by_service_identity_id IS 'Service identity that last updated the mapping.';


--
-- Name: COLUMN adapter_mappings.row_version; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.adapter_mappings.row_version IS 'Optimistic concurrency version.';


--
-- Name: integration_credential_references; Type: TABLE; Schema: integration; Owner: -
--

CREATE TABLE integration.integration_credential_references (
    integration_credential_reference_id uuid DEFAULT gen_random_uuid() NOT NULL,
    vendor_system_id uuid NOT NULL,
    service_identity_id uuid,
    credential_code character varying(64) NOT NULL,
    credential_name character varying(128) NOT NULL,
    credential_type integration.integration_credential_type_enum NOT NULL,
    secret_store_type integration.secret_store_type_enum NOT NULL,
    secret_reference character varying(256) NOT NULL,
    credential_status integration.integration_credential_status_enum NOT NULL,
    credential_version_ref character varying(128),
    last_rotated_at timestamp with time zone,
    next_rotation_due_at timestamp with time zone,
    expires_at timestamp with time zone,
    revoked_at timestamp with time zone,
    revocation_reason_code character varying(64),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_integration_credential_references__expires_after_rotation CHECK (((expires_at IS NULL) OR (last_rotated_at IS NULL) OR (expires_at > last_rotated_at))),
    CONSTRAINT ck_integration_credential_references__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE integration_credential_references; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON TABLE integration.integration_credential_references IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN integration_credential_references.integration_credential_reference_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_credential_references.integration_credential_reference_id IS 'Canonical identifier of the credential reference.';


--
-- Name: COLUMN integration_credential_references.vendor_system_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_credential_references.vendor_system_id IS 'Vendor system using the credential.';


--
-- Name: COLUMN integration_credential_references.service_identity_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_credential_references.service_identity_id IS 'Service identity associated with the credential.';


--
-- Name: COLUMN integration_credential_references.credential_code; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_credential_references.credential_code IS 'Stable credential reference code.';


--
-- Name: COLUMN integration_credential_references.credential_name; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_credential_references.credential_name IS 'Human-readable credential reference name.';


--
-- Name: COLUMN integration_credential_references.credential_type; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_credential_references.credential_type IS 'Credential type.';


--
-- Name: COLUMN integration_credential_references.secret_store_type; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_credential_references.secret_store_type IS 'Secret store type.';


--
-- Name: COLUMN integration_credential_references.secret_reference; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_credential_references.secret_reference IS 'Vault/key-store reference to secret material.';


--
-- Name: COLUMN integration_credential_references.credential_status; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_credential_references.credential_status IS 'Credential reference lifecycle status.';


--
-- Name: COLUMN integration_credential_references.credential_version_ref; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_credential_references.credential_version_ref IS 'Secret version or certificate version reference.';


--
-- Name: COLUMN integration_credential_references.last_rotated_at; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_credential_references.last_rotated_at IS 'Last rotation timestamp.';


--
-- Name: COLUMN integration_credential_references.next_rotation_due_at; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_credential_references.next_rotation_due_at IS 'Next required rotation timestamp.';


--
-- Name: COLUMN integration_credential_references.expires_at; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_credential_references.expires_at IS 'Credential expiry timestamp.';


--
-- Name: COLUMN integration_credential_references.revoked_at; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_credential_references.revoked_at IS 'Credential revocation timestamp.';


--
-- Name: COLUMN integration_credential_references.revocation_reason_code; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_credential_references.revocation_reason_code IS 'Controlled revocation reason.';


--
-- Name: COLUMN integration_credential_references.created_at; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_credential_references.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN integration_credential_references.created_by_user_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_credential_references.created_by_user_id IS 'User who created the credential reference.';


--
-- Name: COLUMN integration_credential_references.created_by_service_identity_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_credential_references.created_by_service_identity_id IS 'Service identity that created the credential reference.';


--
-- Name: COLUMN integration_credential_references.updated_at; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_credential_references.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN integration_credential_references.updated_by_user_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_credential_references.updated_by_user_id IS 'User who last updated the credential reference.';


--
-- Name: COLUMN integration_credential_references.updated_by_service_identity_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_credential_references.updated_by_service_identity_id IS 'Service identity that last updated the credential reference.';


--
-- Name: COLUMN integration_credential_references.row_version; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_credential_references.row_version IS 'Optimistic concurrency version.';


--
-- Name: integration_health_records; Type: TABLE; Schema: integration; Owner: -
--

CREATE TABLE integration.integration_health_records (
    integration_health_record_id uuid DEFAULT gen_random_uuid() NOT NULL,
    vendor_system_id uuid NOT NULL,
    vendor_endpoint_id uuid,
    site_group_id uuid,
    site_id uuid,
    incident_record_id uuid,
    health_status integration.integration_health_status_enum NOT NULL,
    health_check_type integration.integration_health_check_type_enum NOT NULL,
    http_status_code integer,
    latency_ms integer,
    failure_reason_code character varying(64),
    error_code character varying(64),
    error_detail_ref character varying(256),
    observed_at timestamp with time zone NOT NULL,
    recovered_at timestamp with time zone,
    observed_by_service_identity_id uuid NOT NULL,
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_integration_health_records__latency_ms_non_negative CHECK (((latency_ms IS NULL) OR (latency_ms >= 0)))
);


--
-- Name: TABLE integration_health_records; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON TABLE integration.integration_health_records IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN integration_health_records.integration_health_record_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_health_records.integration_health_record_id IS 'Canonical identifier of the health record.';


--
-- Name: COLUMN integration_health_records.vendor_system_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_health_records.vendor_system_id IS 'Vendor system being observed.';


--
-- Name: COLUMN integration_health_records.vendor_endpoint_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_health_records.vendor_endpoint_id IS 'Endpoint being observed, where endpoint-specific.';


--
-- Name: COLUMN integration_health_records.site_group_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_health_records.site_group_id IS 'Site group affected, where applicable.';


--
-- Name: COLUMN integration_health_records.site_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_health_records.site_id IS 'Site affected, where applicable.';


--
-- Name: COLUMN integration_health_records.incident_record_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_health_records.incident_record_id IS 'Related incident, where material.';


--
-- Name: COLUMN integration_health_records.health_status; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_health_records.health_status IS 'Health status.';


--
-- Name: COLUMN integration_health_records.health_check_type; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_health_records.health_check_type IS 'Health check type.';


--
-- Name: COLUMN integration_health_records.http_status_code; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_health_records.http_status_code IS 'HTTP status code where applicable.';


--
-- Name: COLUMN integration_health_records.latency_ms; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_health_records.latency_ms IS 'Observed latency in milliseconds.';


--
-- Name: COLUMN integration_health_records.failure_reason_code; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_health_records.failure_reason_code IS 'Controlled failure or degradation reason.';


--
-- Name: COLUMN integration_health_records.error_code; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_health_records.error_code IS 'Vendor or adapter error code.';


--
-- Name: COLUMN integration_health_records.error_detail_ref; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_health_records.error_detail_ref IS 'Reference to detailed diagnostic payload if retained.';


--
-- Name: COLUMN integration_health_records.observed_at; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_health_records.observed_at IS 'Timestamp when health was observed.';


--
-- Name: COLUMN integration_health_records.recovered_at; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_health_records.recovered_at IS 'Recovery timestamp, where recorded in this health record.';


--
-- Name: COLUMN integration_health_records.observed_by_service_identity_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_health_records.observed_by_service_identity_id IS 'Service identity that observed or recorded health.';


--
-- Name: COLUMN integration_health_records.correlation_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_health_records.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN integration_health_records.created_at; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.integration_health_records.created_at IS 'Record creation timestamp.';


--
-- Name: vendor_endpoints; Type: TABLE; Schema: integration; Owner: -
--

CREATE TABLE integration.vendor_endpoints (
    vendor_endpoint_id uuid DEFAULT gen_random_uuid() NOT NULL,
    vendor_system_id uuid NOT NULL,
    endpoint_code character varying(96) NOT NULL,
    endpoint_name character varying(128) NOT NULL,
    endpoint_description text,
    endpoint_type integration.vendor_endpoint_type_enum NOT NULL,
    http_method integration.http_method_enum,
    path_template character varying(512),
    operation_ref character varying(128),
    credential_reference_id uuid,
    timeout_policy_code character varying(64),
    retry_policy_code character varying(64),
    rate_limit_policy_code character varying(64),
    endpoint_status integration.vendor_endpoint_status_enum NOT NULL,
    effective_from timestamp with time zone NOT NULL,
    effective_to timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_vendor_endpoints__effective_window CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT ck_vendor_endpoints__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE vendor_endpoints; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON TABLE integration.vendor_endpoints IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN vendor_endpoints.vendor_endpoint_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_endpoints.vendor_endpoint_id IS 'Canonical identifier of the vendor endpoint.';


--
-- Name: COLUMN vendor_endpoints.vendor_system_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_endpoints.vendor_system_id IS 'Vendor system that exposes the endpoint.';


--
-- Name: COLUMN vendor_endpoints.endpoint_code; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_endpoints.endpoint_code IS 'Stable internal endpoint operation code.';


--
-- Name: COLUMN vendor_endpoints.endpoint_name; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_endpoints.endpoint_name IS 'Human-readable endpoint name.';


--
-- Name: COLUMN vendor_endpoints.endpoint_description; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_endpoints.endpoint_description IS 'Endpoint description.';


--
-- Name: COLUMN vendor_endpoints.endpoint_type; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_endpoints.endpoint_type IS 'Endpoint classification.';


--
-- Name: COLUMN vendor_endpoints.http_method; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_endpoints.http_method IS 'HTTP method where REST-based.';


--
-- Name: COLUMN vendor_endpoints.path_template; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_endpoints.path_template IS 'Endpoint path template.';


--
-- Name: COLUMN vendor_endpoints.operation_ref; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_endpoints.operation_ref IS 'Vendor SDK, SOAP, OpenAPI, or operation reference.';


--
-- Name: COLUMN vendor_endpoints.credential_reference_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_endpoints.credential_reference_id IS 'Credential reference used by the endpoint.';


--
-- Name: COLUMN vendor_endpoints.timeout_policy_code; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_endpoints.timeout_policy_code IS 'Timeout policy code.';


--
-- Name: COLUMN vendor_endpoints.retry_policy_code; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_endpoints.retry_policy_code IS 'Retry policy code.';


--
-- Name: COLUMN vendor_endpoints.rate_limit_policy_code; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_endpoints.rate_limit_policy_code IS 'Rate-limit policy code.';


--
-- Name: COLUMN vendor_endpoints.endpoint_status; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_endpoints.endpoint_status IS 'Endpoint lifecycle status.';


--
-- Name: COLUMN vendor_endpoints.effective_from; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_endpoints.effective_from IS 'Start of endpoint effectiveness.';


--
-- Name: COLUMN vendor_endpoints.effective_to; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_endpoints.effective_to IS 'End of endpoint effectiveness.';


--
-- Name: COLUMN vendor_endpoints.created_at; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_endpoints.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN vendor_endpoints.created_by_user_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_endpoints.created_by_user_id IS 'User who created the endpoint.';


--
-- Name: COLUMN vendor_endpoints.created_by_service_identity_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_endpoints.created_by_service_identity_id IS 'Service identity that created the endpoint.';


--
-- Name: COLUMN vendor_endpoints.updated_at; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_endpoints.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN vendor_endpoints.updated_by_user_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_endpoints.updated_by_user_id IS 'User who last updated the endpoint.';


--
-- Name: COLUMN vendor_endpoints.updated_by_service_identity_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_endpoints.updated_by_service_identity_id IS 'Service identity that last updated the endpoint.';


--
-- Name: COLUMN vendor_endpoints.row_version; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_endpoints.row_version IS 'Optimistic concurrency version.';


--
-- Name: vendor_systems; Type: TABLE; Schema: integration; Owner: -
--

CREATE TABLE integration.vendor_systems (
    vendor_system_id uuid DEFAULT gen_random_uuid() NOT NULL,
    vendor_code character varying(64) NOT NULL,
    vendor_name character varying(128) NOT NULL,
    vendor_system_type integration.vendor_system_type_enum NOT NULL,
    vendor_system_status integration.vendor_system_status_enum NOT NULL,
    environment_code character varying(32) NOT NULL,
    base_url_ref character varying(256),
    api_version character varying(64),
    owner_team character varying(128),
    support_contact_ref character varying(128),
    effective_from timestamp with time zone NOT NULL,
    effective_to timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_vendor_systems__effective_window CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT ck_vendor_systems__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE vendor_systems; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON TABLE integration.vendor_systems IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN vendor_systems.vendor_system_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_systems.vendor_system_id IS 'Canonical identifier of the vendor system.';


--
-- Name: COLUMN vendor_systems.vendor_code; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_systems.vendor_code IS 'Stable internal vendor code.';


--
-- Name: COLUMN vendor_systems.vendor_name; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_systems.vendor_name IS 'Human-readable vendor or system name.';


--
-- Name: COLUMN vendor_systems.vendor_system_type; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_systems.vendor_system_type IS 'Vendor system classification.';


--
-- Name: COLUMN vendor_systems.vendor_system_status; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_systems.vendor_system_status IS 'Vendor system lifecycle status.';


--
-- Name: COLUMN vendor_systems.environment_code; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_systems.environment_code IS 'Environment where vendor profile applies.';


--
-- Name: COLUMN vendor_systems.base_url_ref; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_systems.base_url_ref IS 'Reference or non-secret base URL configuration.';


--
-- Name: COLUMN vendor_systems.api_version; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_systems.api_version IS 'Vendor API version used.';


--
-- Name: COLUMN vendor_systems.owner_team; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_systems.owner_team IS 'Internal owner team or responsible unit.';


--
-- Name: COLUMN vendor_systems.support_contact_ref; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_systems.support_contact_ref IS 'Support contact or vendor support reference.';


--
-- Name: COLUMN vendor_systems.effective_from; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_systems.effective_from IS 'Start of vendor system effectiveness.';


--
-- Name: COLUMN vendor_systems.effective_to; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_systems.effective_to IS 'End of vendor system effectiveness.';


--
-- Name: COLUMN vendor_systems.created_at; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_systems.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN vendor_systems.created_by_user_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_systems.created_by_user_id IS 'User who created the vendor system record.';


--
-- Name: COLUMN vendor_systems.created_by_service_identity_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_systems.created_by_service_identity_id IS 'Service identity that created the vendor system record.';


--
-- Name: COLUMN vendor_systems.updated_at; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_systems.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN vendor_systems.updated_by_user_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_systems.updated_by_user_id IS 'User who last updated the vendor system record.';


--
-- Name: COLUMN vendor_systems.updated_by_service_identity_id; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_systems.updated_by_service_identity_id IS 'Service identity that last updated the vendor system record.';


--
-- Name: COLUMN vendor_systems.row_version; Type: COMMENT; Schema: integration; Owner: -
--

COMMENT ON COLUMN integration.vendor_systems.row_version IS 'Optimistic concurrency version.';


--
-- Name: merchant_site_scopes; Type: TABLE; Schema: merchants; Owner: -
--

CREATE TABLE merchants.merchant_site_scopes (
    merchant_site_scope_id uuid DEFAULT gen_random_uuid() NOT NULL,
    merchant_id uuid NOT NULL,
    site_group_id uuid,
    site_id uuid,
    scope_type merchants.merchant_scope_type_enum NOT NULL,
    scope_status merchants.merchant_site_scope_status_enum NOT NULL,
    scope_reason_code character varying(64),
    allows_coupon_sponsorship boolean DEFAULT false NOT NULL,
    allows_full_waiver boolean DEFAULT false NOT NULL,
    requires_elevated_approval boolean DEFAULT false NOT NULL,
    effective_from timestamp with time zone NOT NULL,
    effective_to timestamp with time zone,
    approved_at timestamp with time zone,
    approved_by_user_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_merchant_site_scopes__effective_window CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT ck_merchant_site_scopes__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE merchant_site_scopes; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON TABLE merchants.merchant_site_scopes IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN merchant_site_scopes.merchant_site_scope_id; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_site_scopes.merchant_site_scope_id IS 'Canonical identifier of the merchant site scope.';


--
-- Name: COLUMN merchant_site_scopes.merchant_id; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_site_scopes.merchant_id IS 'Merchant to which the scope belongs.';


--
-- Name: COLUMN merchant_site_scopes.site_group_id; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_site_scopes.site_group_id IS 'Site group scope.';


--
-- Name: COLUMN merchant_site_scopes.site_id; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_site_scopes.site_id IS 'Site scope.';


--
-- Name: COLUMN merchant_site_scopes.scope_type; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_site_scopes.scope_type IS 'Scope level.';


--
-- Name: COLUMN merchant_site_scopes.scope_status; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_site_scopes.scope_status IS 'Scope lifecycle status.';


--
-- Name: COLUMN merchant_site_scopes.scope_reason_code; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_site_scopes.scope_reason_code IS 'Controlled reason for granting or changing scope.';


--
-- Name: COLUMN merchant_site_scopes.allows_coupon_sponsorship; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_site_scopes.allows_coupon_sponsorship IS 'Indicates whether merchant may sponsor coupons in this scope.';


--
-- Name: COLUMN merchant_site_scopes.allows_full_waiver; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_site_scopes.allows_full_waiver IS 'Indicates whether full-waiver coupons may be used in this scope.';


--
-- Name: COLUMN merchant_site_scopes.requires_elevated_approval; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_site_scopes.requires_elevated_approval IS 'Indicates whether merchant actions in this scope require elevated approval.';


--
-- Name: COLUMN merchant_site_scopes.effective_from; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_site_scopes.effective_from IS 'Start of scope effectiveness.';


--
-- Name: COLUMN merchant_site_scopes.effective_to; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_site_scopes.effective_to IS 'End of scope effectiveness.';


--
-- Name: COLUMN merchant_site_scopes.approved_at; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_site_scopes.approved_at IS 'Timestamp when scope was approved.';


--
-- Name: COLUMN merchant_site_scopes.approved_by_user_id; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_site_scopes.approved_by_user_id IS 'User who approved the scope.';


--
-- Name: COLUMN merchant_site_scopes.created_at; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_site_scopes.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN merchant_site_scopes.created_by_user_id; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_site_scopes.created_by_user_id IS 'User who created the scope.';


--
-- Name: COLUMN merchant_site_scopes.created_by_service_identity_id; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_site_scopes.created_by_service_identity_id IS 'Service identity that created the scope.';


--
-- Name: COLUMN merchant_site_scopes.updated_at; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_site_scopes.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN merchant_site_scopes.updated_by_user_id; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_site_scopes.updated_by_user_id IS 'User who last updated the scope.';


--
-- Name: COLUMN merchant_site_scopes.updated_by_service_identity_id; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_site_scopes.updated_by_service_identity_id IS 'Service identity that last updated the scope.';


--
-- Name: COLUMN merchant_site_scopes.row_version; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_site_scopes.row_version IS 'Optimistic concurrency version.';


--
-- Name: merchant_users; Type: TABLE; Schema: merchants; Owner: -
--

CREATE TABLE merchants.merchant_users (
    merchant_user_id uuid DEFAULT gen_random_uuid() NOT NULL,
    merchant_id uuid NOT NULL,
    user_id uuid NOT NULL,
    merchant_user_status merchants.merchant_user_status_enum NOT NULL,
    merchant_user_type merchants.merchant_user_type_enum NOT NULL,
    can_request_coupon boolean DEFAULT false NOT NULL,
    can_manage_coupon boolean DEFAULT false NOT NULL,
    can_view_wallet boolean DEFAULT false NOT NULL,
    can_view_reports boolean DEFAULT false NOT NULL,
    effective_from timestamp with time zone NOT NULL,
    effective_to timestamp with time zone,
    invited_at timestamp with time zone,
    accepted_at timestamp with time zone,
    revoked_at timestamp with time zone,
    revoked_by_user_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_merchant_users__effective_window CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT ck_merchant_users__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE merchant_users; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON TABLE merchants.merchant_users IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN merchant_users.merchant_user_id; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_users.merchant_user_id IS 'Canonical identifier of the merchant-user association.';


--
-- Name: COLUMN merchant_users.merchant_id; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_users.merchant_id IS 'Merchant context.';


--
-- Name: COLUMN merchant_users.user_id; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_users.user_id IS 'Platform user associated with the merchant.';


--
-- Name: COLUMN merchant_users.merchant_user_status; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_users.merchant_user_status IS 'Association lifecycle status.';


--
-- Name: COLUMN merchant_users.merchant_user_type; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_users.merchant_user_type IS 'Merchant-side user classification.';


--
-- Name: COLUMN merchant_users.can_request_coupon; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_users.can_request_coupon IS 'Indicates whether the user may request coupon application.';


--
-- Name: COLUMN merchant_users.can_manage_coupon; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_users.can_manage_coupon IS 'Indicates whether the user may manage coupon setup, subject to RBAC.';


--
-- Name: COLUMN merchant_users.can_view_wallet; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_users.can_view_wallet IS 'Indicates whether the user may view merchant wallet context, subject to RBAC.';


--
-- Name: COLUMN merchant_users.can_view_reports; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_users.can_view_reports IS 'Indicates whether the user may view merchant reports, subject to RBAC.';


--
-- Name: COLUMN merchant_users.effective_from; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_users.effective_from IS 'Start of association effectiveness.';


--
-- Name: COLUMN merchant_users.effective_to; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_users.effective_to IS 'End of association effectiveness.';


--
-- Name: COLUMN merchant_users.invited_at; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_users.invited_at IS 'Timestamp when association was invited.';


--
-- Name: COLUMN merchant_users.accepted_at; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_users.accepted_at IS 'Timestamp when association was accepted.';


--
-- Name: COLUMN merchant_users.revoked_at; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_users.revoked_at IS 'Timestamp when association was revoked.';


--
-- Name: COLUMN merchant_users.revoked_by_user_id; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_users.revoked_by_user_id IS 'User who revoked the association.';


--
-- Name: COLUMN merchant_users.created_at; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_users.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN merchant_users.created_by_user_id; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_users.created_by_user_id IS 'User who created the association.';


--
-- Name: COLUMN merchant_users.created_by_service_identity_id; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_users.created_by_service_identity_id IS 'Service identity that created the association.';


--
-- Name: COLUMN merchant_users.updated_at; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_users.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN merchant_users.updated_by_user_id; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_users.updated_by_user_id IS 'User who last updated the association.';


--
-- Name: COLUMN merchant_users.updated_by_service_identity_id; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_users.updated_by_service_identity_id IS 'Service identity that last updated the association.';


--
-- Name: COLUMN merchant_users.row_version; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_users.row_version IS 'Optimistic concurrency version.';


--
-- Name: merchant_wallets; Type: TABLE; Schema: merchants; Owner: -
--

CREATE TABLE merchants.merchant_wallets (
    merchant_wallet_id uuid DEFAULT gen_random_uuid() NOT NULL,
    merchant_id uuid NOT NULL,
    wallet_code character varying(64) NOT NULL,
    wallet_name character varying(128) NOT NULL,
    wallet_type merchants.merchant_wallet_type_enum NOT NULL,
    wallet_status merchants.merchant_wallet_status_enum NOT NULL,
    currency_code character(3) NOT NULL,
    available_balance numeric(18,2),
    reserved_balance numeric(18,2),
    committed_balance numeric(18,2),
    external_ledger_ref character varying(128),
    allows_coupon_funding boolean DEFAULT false NOT NULL,
    allows_statutory_discount_funding boolean DEFAULT false NOT NULL,
    effective_from timestamp with time zone NOT NULL,
    effective_to timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_merchant_wallets__available_balance_non_negative CHECK (((available_balance IS NULL) OR (available_balance >= (0)::numeric))),
    CONSTRAINT ck_merchant_wallets__committed_balance_non_negative CHECK (((committed_balance IS NULL) OR (committed_balance >= (0)::numeric))),
    CONSTRAINT ck_merchant_wallets__effective_window CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT ck_merchant_wallets__reserved_balance_non_negative CHECK (((reserved_balance IS NULL) OR (reserved_balance >= (0)::numeric))),
    CONSTRAINT ck_merchant_wallets__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE merchant_wallets; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON TABLE merchants.merchant_wallets IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN merchant_wallets.merchant_wallet_id; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_wallets.merchant_wallet_id IS 'Canonical identifier of the merchant wallet or sponsorship funding context.';


--
-- Name: COLUMN merchant_wallets.merchant_id; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_wallets.merchant_id IS 'Merchant that owns the wallet context.';


--
-- Name: COLUMN merchant_wallets.wallet_code; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_wallets.wallet_code IS 'Stable wallet or funding context code.';


--
-- Name: COLUMN merchant_wallets.wallet_name; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_wallets.wallet_name IS 'Human-readable wallet name.';


--
-- Name: COLUMN merchant_wallets.wallet_type; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_wallets.wallet_type IS 'Wallet or funding context type.';


--
-- Name: COLUMN merchant_wallets.wallet_status; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_wallets.wallet_status IS 'Wallet lifecycle status.';


--
-- Name: COLUMN merchant_wallets.currency_code; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_wallets.currency_code IS 'Wallet currency.';


--
-- Name: COLUMN merchant_wallets.available_balance; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_wallets.available_balance IS 'Available commercial sponsorship balance, if locally tracked.';


--
-- Name: COLUMN merchant_wallets.reserved_balance; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_wallets.reserved_balance IS 'Reserved amount for pending coupon applications, if locally tracked.';


--
-- Name: COLUMN merchant_wallets.committed_balance; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_wallets.committed_balance IS 'Committed or consumed sponsorship value, if locally tracked.';


--
-- Name: COLUMN merchant_wallets.external_ledger_ref; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_wallets.external_ledger_ref IS 'External ledger or wallet reference, if ledger is externalized.';


--
-- Name: COLUMN merchant_wallets.allows_coupon_funding; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_wallets.allows_coupon_funding IS 'Indicates whether wallet may fund merchant coupons.';


--
-- Name: COLUMN merchant_wallets.allows_statutory_discount_funding; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_wallets.allows_statutory_discount_funding IS 'Must be false. Merchant wallets must not fund statutory discounts.';


--
-- Name: COLUMN merchant_wallets.effective_from; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_wallets.effective_from IS 'Start of wallet effectiveness.';


--
-- Name: COLUMN merchant_wallets.effective_to; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_wallets.effective_to IS 'End of wallet effectiveness.';


--
-- Name: COLUMN merchant_wallets.created_at; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_wallets.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN merchant_wallets.created_by_user_id; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_wallets.created_by_user_id IS 'User who created the wallet context.';


--
-- Name: COLUMN merchant_wallets.created_by_service_identity_id; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_wallets.created_by_service_identity_id IS 'Service identity that created the wallet context.';


--
-- Name: COLUMN merchant_wallets.updated_at; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_wallets.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN merchant_wallets.updated_by_user_id; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_wallets.updated_by_user_id IS 'User who last updated the wallet context.';


--
-- Name: COLUMN merchant_wallets.updated_by_service_identity_id; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_wallets.updated_by_service_identity_id IS 'Service identity that last updated the wallet context.';


--
-- Name: COLUMN merchant_wallets.row_version; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchant_wallets.row_version IS 'Optimistic concurrency version.';


--
-- Name: merchants; Type: TABLE; Schema: merchants; Owner: -
--

CREATE TABLE merchants.merchants (
    merchant_id uuid DEFAULT gen_random_uuid() NOT NULL,
    merchant_code character varying(64) NOT NULL,
    merchant_name character varying(256) NOT NULL,
    merchant_display_name character varying(128),
    merchant_type merchants.merchant_type_enum NOT NULL,
    merchant_status merchants.merchant_status_enum NOT NULL,
    tax_identification_number_hash character(64),
    contact_email character varying(256),
    contact_mobile_masked character varying(32),
    default_currency_code character(3) NOT NULL,
    effective_from timestamp with time zone NOT NULL,
    effective_to timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_merchants__effective_window CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT ck_merchants__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE merchants; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON TABLE merchants.merchants IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN merchants.merchant_id; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchants.merchant_id IS 'Canonical identifier of the merchant.';


--
-- Name: COLUMN merchants.merchant_code; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchants.merchant_code IS 'Stable internal merchant code.';


--
-- Name: COLUMN merchants.merchant_name; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchants.merchant_name IS 'Legal or operating merchant name.';


--
-- Name: COLUMN merchants.merchant_display_name; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchants.merchant_display_name IS 'Short display name used in UI or reports.';


--
-- Name: COLUMN merchants.merchant_type; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchants.merchant_type IS 'Merchant classification.';


--
-- Name: COLUMN merchants.merchant_status; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchants.merchant_status IS 'Merchant lifecycle status.';


--
-- Name: COLUMN merchants.tax_identification_number_hash; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchants.tax_identification_number_hash IS 'Hash of merchant TIN or equivalent identifier, where retained.';


--
-- Name: COLUMN merchants.contact_email; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchants.contact_email IS 'Merchant contact email.';


--
-- Name: COLUMN merchants.contact_mobile_masked; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchants.contact_mobile_masked IS 'Masked merchant contact number.';


--
-- Name: COLUMN merchants.default_currency_code; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchants.default_currency_code IS 'Default currency for merchant-sponsored benefits.';


--
-- Name: COLUMN merchants.effective_from; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchants.effective_from IS 'Start of merchant effectiveness.';


--
-- Name: COLUMN merchants.effective_to; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchants.effective_to IS 'End of merchant effectiveness.';


--
-- Name: COLUMN merchants.created_at; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchants.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN merchants.created_by_user_id; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchants.created_by_user_id IS 'User who created the merchant.';


--
-- Name: COLUMN merchants.created_by_service_identity_id; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchants.created_by_service_identity_id IS 'Service identity that created the merchant.';


--
-- Name: COLUMN merchants.updated_at; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchants.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN merchants.updated_by_user_id; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchants.updated_by_user_id IS 'User who last updated the merchant.';


--
-- Name: COLUMN merchants.updated_by_service_identity_id; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchants.updated_by_service_identity_id IS 'Service identity that last updated the merchant.';


--
-- Name: COLUMN merchants.row_version; Type: COMMENT; Schema: merchants; Owner: -
--

COMMENT ON COLUMN merchants.merchants.row_version IS 'Optimistic concurrency version.';


--
-- Name: incident_records; Type: TABLE; Schema: operations; Owner: -
--

CREATE TABLE operations.incident_records (
    incident_record_id uuid DEFAULT gen_random_uuid() NOT NULL,
    incident_code character varying(64) NOT NULL,
    incident_title character varying(256) NOT NULL,
    incident_description text,
    incident_category character varying(64) NOT NULL,
    incident_severity operations.incident_severity_enum NOT NULL,
    incident_status operations.incident_status_enum NOT NULL,
    site_group_id uuid,
    site_id uuid,
    lane_id uuid,
    gate_device_id uuid,
    vendor_system_id uuid,
    payment_rail_id uuid,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    detected_at timestamp with time zone NOT NULL,
    resolved_at timestamp with time zone,
    closed_at timestamp with time zone,
    closure_reason_code character varying(64),
    owner_user_id uuid,
    owner_service_identity_id uuid,
    requires_reconciliation boolean DEFAULT false NOT NULL,
    requires_post_incident_review boolean DEFAULT false NOT NULL,
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_incident_records__resolved_after_detected CHECK (((resolved_at IS NULL) OR (resolved_at >= detected_at))),
    CONSTRAINT ck_incident_records__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE incident_records; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON TABLE operations.incident_records IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN incident_records.incident_record_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.incident_record_id IS 'Canonical identifier of the incident.';


--
-- Name: COLUMN incident_records.incident_code; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.incident_code IS 'Human-readable or generated incident code.';


--
-- Name: COLUMN incident_records.incident_title; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.incident_title IS 'Short incident title.';


--
-- Name: COLUMN incident_records.incident_description; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.incident_description IS 'Incident description.';


--
-- Name: COLUMN incident_records.incident_category; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.incident_category IS 'Controlled incident category.';


--
-- Name: COLUMN incident_records.incident_severity; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.incident_severity IS 'Incident severity.';


--
-- Name: COLUMN incident_records.incident_status; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.incident_status IS 'Incident lifecycle state.';


--
-- Name: COLUMN incident_records.site_group_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.site_group_id IS 'Affected site group, where applicable.';


--
-- Name: COLUMN incident_records.site_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.site_id IS 'Affected site, where applicable.';


--
-- Name: COLUMN incident_records.lane_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.lane_id IS 'Affected lane, where applicable.';


--
-- Name: COLUMN incident_records.gate_device_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.gate_device_id IS 'Affected gate device, where applicable.';


--
-- Name: COLUMN incident_records.vendor_system_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.vendor_system_id IS 'Affected vendor system, where applicable.';


--
-- Name: COLUMN incident_records.payment_rail_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.payment_rail_id IS 'Affected payment rail, where applicable.';


--
-- Name: COLUMN incident_records.started_at; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.started_at IS 'Incident start timestamp.';


--
-- Name: COLUMN incident_records.detected_at; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.detected_at IS 'Incident detection timestamp.';


--
-- Name: COLUMN incident_records.resolved_at; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.resolved_at IS 'Incident technical resolution timestamp.';


--
-- Name: COLUMN incident_records.closed_at; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.closed_at IS 'Incident closure timestamp.';


--
-- Name: COLUMN incident_records.closure_reason_code; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.closure_reason_code IS 'Controlled closure reason.';


--
-- Name: COLUMN incident_records.owner_user_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.owner_user_id IS 'User assigned as incident owner.';


--
-- Name: COLUMN incident_records.owner_service_identity_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.owner_service_identity_id IS 'Service identity assigned as owner, where automated.';


--
-- Name: COLUMN incident_records.requires_reconciliation; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.requires_reconciliation IS 'Indicates whether incident requires reconciliation.';


--
-- Name: COLUMN incident_records.requires_post_incident_review; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.requires_post_incident_review IS 'Indicates whether post-incident review is required.';


--
-- Name: COLUMN incident_records.correlation_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN incident_records.created_at; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN incident_records.created_by_user_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.created_by_user_id IS 'User who created the incident.';


--
-- Name: COLUMN incident_records.created_by_service_identity_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.created_by_service_identity_id IS 'Service identity that created the incident.';


--
-- Name: COLUMN incident_records.updated_at; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN incident_records.updated_by_user_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.updated_by_user_id IS 'User who last updated the incident.';


--
-- Name: COLUMN incident_records.updated_by_service_identity_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.updated_by_service_identity_id IS 'Service identity that last updated the incident.';


--
-- Name: COLUMN incident_records.row_version; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.incident_records.row_version IS 'Optimistic concurrency version.';


--
-- Name: manual_gate_logs; Type: TABLE; Schema: operations; Owner: -
--

CREATE TABLE operations.manual_gate_logs (
    manual_gate_log_id uuid DEFAULT gen_random_uuid() NOT NULL,
    parking_session_id uuid,
    exit_authorization_id uuid,
    gate_authorization_consumption_id uuid,
    incident_record_id uuid,
    override_approval_id uuid,
    site_id uuid NOT NULL,
    lane_id uuid,
    gate_device_id uuid,
    manual_action_type operations.manual_gate_action_type_enum NOT NULL,
    manual_action_status operations.manual_gate_action_status_enum NOT NULL,
    manual_reason_code character varying(64) NOT NULL,
    operator_notes text,
    requires_reconciliation boolean DEFAULT false NOT NULL,
    reconciliation_item_id uuid,
    performed_at timestamp with time zone NOT NULL,
    performed_by_user_id uuid NOT NULL,
    recorded_at timestamp with time zone DEFAULT now() NOT NULL,
    recorded_by_user_id uuid,
    recorded_by_service_identity_id uuid,
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_manual_gate_logs__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE manual_gate_logs; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON TABLE operations.manual_gate_logs IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN manual_gate_logs.manual_gate_log_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.manual_gate_logs.manual_gate_log_id IS 'Canonical identifier of the manual gate log.';


--
-- Name: COLUMN manual_gate_logs.parking_session_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.manual_gate_logs.parking_session_id IS 'Related parking session, where known.';


--
-- Name: COLUMN manual_gate_logs.exit_authorization_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.manual_gate_logs.exit_authorization_id IS 'Related exit authorization, where known.';


--
-- Name: COLUMN manual_gate_logs.gate_authorization_consumption_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.manual_gate_logs.gate_authorization_consumption_id IS 'Related failed or uncertain consume attempt, where applicable.';


--
-- Name: COLUMN manual_gate_logs.incident_record_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.manual_gate_logs.incident_record_id IS 'Incident that caused or justified the manual action.';


--
-- Name: COLUMN manual_gate_logs.override_approval_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.manual_gate_logs.override_approval_id IS 'Approval record authorizing the manual action, where required.';


--
-- Name: COLUMN manual_gate_logs.site_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.manual_gate_logs.site_id IS 'Site where manual gate action occurred.';


--
-- Name: COLUMN manual_gate_logs.lane_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.manual_gate_logs.lane_id IS 'Lane where manual gate action occurred.';


--
-- Name: COLUMN manual_gate_logs.gate_device_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.manual_gate_logs.gate_device_id IS 'Gate device involved, where known.';


--
-- Name: COLUMN manual_gate_logs.manual_action_type; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.manual_gate_logs.manual_action_type IS 'Type of manual gate action.';


--
-- Name: COLUMN manual_gate_logs.manual_action_status; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.manual_gate_logs.manual_action_status IS 'Result of manual action.';


--
-- Name: COLUMN manual_gate_logs.manual_reason_code; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.manual_gate_logs.manual_reason_code IS 'Controlled reason for manual action.';


--
-- Name: COLUMN manual_gate_logs.operator_notes; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.manual_gate_logs.operator_notes IS 'Controlled operational note. Must not store sensitive evidence casually.';


--
-- Name: COLUMN manual_gate_logs.requires_reconciliation; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.manual_gate_logs.requires_reconciliation IS 'Indicates whether the action requires reconciliation or review.';


--
-- Name: COLUMN manual_gate_logs.reconciliation_item_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.manual_gate_logs.reconciliation_item_id IS 'Reconciliation item created for review or closure.';


--
-- Name: COLUMN manual_gate_logs.performed_at; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.manual_gate_logs.performed_at IS 'Timestamp when manual action occurred.';


--
-- Name: COLUMN manual_gate_logs.performed_by_user_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.manual_gate_logs.performed_by_user_id IS 'Operator who performed the manual action.';


--
-- Name: COLUMN manual_gate_logs.recorded_at; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.manual_gate_logs.recorded_at IS 'Timestamp when the action was recorded.';


--
-- Name: COLUMN manual_gate_logs.recorded_by_user_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.manual_gate_logs.recorded_by_user_id IS 'User who recorded the action.';


--
-- Name: COLUMN manual_gate_logs.recorded_by_service_identity_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.manual_gate_logs.recorded_by_service_identity_id IS 'Service identity that recorded the action.';


--
-- Name: COLUMN manual_gate_logs.correlation_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.manual_gate_logs.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN manual_gate_logs.created_at; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.manual_gate_logs.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN manual_gate_logs.created_by_user_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.manual_gate_logs.created_by_user_id IS 'User who created the record.';


--
-- Name: COLUMN manual_gate_logs.created_by_service_identity_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.manual_gate_logs.created_by_service_identity_id IS 'Service identity that created the record.';


--
-- Name: COLUMN manual_gate_logs.updated_at; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.manual_gate_logs.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN manual_gate_logs.updated_by_user_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.manual_gate_logs.updated_by_user_id IS 'User who last updated the record.';


--
-- Name: COLUMN manual_gate_logs.updated_by_service_identity_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.manual_gate_logs.updated_by_service_identity_id IS 'Service identity that last updated the record.';


--
-- Name: COLUMN manual_gate_logs.row_version; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.manual_gate_logs.row_version IS 'Optimistic concurrency version.';


--
-- Name: operator_action_logs; Type: TABLE; Schema: operations; Owner: -
--

CREATE TABLE operations.operator_action_logs (
    operator_action_log_id uuid DEFAULT gen_random_uuid() NOT NULL,
    operator_user_id uuid NOT NULL,
    action_type operations.operator_action_type_enum NOT NULL,
    action_reason_code character varying(64),
    target_entity_type character varying(64),
    target_entity_id uuid,
    site_id uuid,
    incident_record_id uuid,
    action_status operations.operator_action_status_enum NOT NULL,
    action_notes text,
    performed_at timestamp with time zone NOT NULL,
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid
);


--
-- Name: TABLE operator_action_logs; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON TABLE operations.operator_action_logs IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN operator_action_logs.operator_action_log_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.operator_action_logs.operator_action_log_id IS 'Canonical identifier of the operator action log.';


--
-- Name: COLUMN operator_action_logs.operator_user_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.operator_action_logs.operator_user_id IS 'User who performed the action.';


--
-- Name: COLUMN operator_action_logs.action_type; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.operator_action_logs.action_type IS 'Type of operator action.';


--
-- Name: COLUMN operator_action_logs.action_reason_code; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.operator_action_logs.action_reason_code IS 'Controlled reason for the action.';


--
-- Name: COLUMN operator_action_logs.target_entity_type; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.operator_action_logs.target_entity_type IS 'Type of affected entity.';


--
-- Name: COLUMN operator_action_logs.target_entity_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.operator_action_logs.target_entity_id IS 'Affected entity identifier.';


--
-- Name: COLUMN operator_action_logs.site_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.operator_action_logs.site_id IS 'Site context, where applicable.';


--
-- Name: COLUMN operator_action_logs.incident_record_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.operator_action_logs.incident_record_id IS 'Related incident, where applicable.';


--
-- Name: COLUMN operator_action_logs.action_status; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.operator_action_logs.action_status IS 'Result of action.';


--
-- Name: COLUMN operator_action_logs.action_notes; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.operator_action_logs.action_notes IS 'Controlled note. Must not store sensitive evidence casually.';


--
-- Name: COLUMN operator_action_logs.performed_at; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.operator_action_logs.performed_at IS 'Timestamp when operator action occurred.';


--
-- Name: COLUMN operator_action_logs.correlation_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.operator_action_logs.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN operator_action_logs.created_at; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.operator_action_logs.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN operator_action_logs.created_by_user_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.operator_action_logs.created_by_user_id IS 'User who created the log.';


--
-- Name: COLUMN operator_action_logs.created_by_service_identity_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.operator_action_logs.created_by_service_identity_id IS 'Service identity that created the log.';


--
-- Name: override_approvals; Type: TABLE; Schema: operations; Owner: -
--

CREATE TABLE operations.override_approvals (
    override_approval_id uuid DEFAULT gen_random_uuid() NOT NULL,
    override_request_id uuid NOT NULL,
    approval_sequence integer NOT NULL,
    approval_decision operations.override_approval_decision_enum NOT NULL,
    approval_reason_code character varying(64),
    rejection_reason_code character varying(64),
    approval_notes text,
    decided_at timestamp with time zone NOT NULL,
    decided_by_user_id uuid NOT NULL,
    expires_at timestamp with time zone,
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid
);


--
-- Name: TABLE override_approvals; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON TABLE operations.override_approvals IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN override_approvals.override_approval_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_approvals.override_approval_id IS 'Canonical identifier of the approval record.';


--
-- Name: COLUMN override_approvals.override_request_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_approvals.override_request_id IS 'Override request being reviewed.';


--
-- Name: COLUMN override_approvals.approval_sequence; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_approvals.approval_sequence IS 'Approval sequence or level.';


--
-- Name: COLUMN override_approvals.approval_decision; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_approvals.approval_decision IS 'Approval decision.';


--
-- Name: COLUMN override_approvals.approval_reason_code; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_approvals.approval_reason_code IS 'Controlled approval reason.';


--
-- Name: COLUMN override_approvals.rejection_reason_code; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_approvals.rejection_reason_code IS 'Controlled rejection reason.';


--
-- Name: COLUMN override_approvals.approval_notes; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_approvals.approval_notes IS 'Controlled note. Must not store sensitive evidence casually.';


--
-- Name: COLUMN override_approvals.decided_at; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_approvals.decided_at IS 'Timestamp when decision was made.';


--
-- Name: COLUMN override_approvals.decided_by_user_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_approvals.decided_by_user_id IS 'User who approved, rejected, escalated, or cancelled.';


--
-- Name: COLUMN override_approvals.expires_at; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_approvals.expires_at IS 'Expiry timestamp for approval usability.';


--
-- Name: COLUMN override_approvals.correlation_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_approvals.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN override_approvals.created_at; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_approvals.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN override_approvals.created_by_user_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_approvals.created_by_user_id IS 'User who created the approval record.';


--
-- Name: COLUMN override_approvals.created_by_service_identity_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_approvals.created_by_service_identity_id IS 'Service identity that created the approval record.';


--
-- Name: override_requests; Type: TABLE; Schema: operations; Owner: -
--

CREATE TABLE operations.override_requests (
    override_request_id uuid DEFAULT gen_random_uuid() NOT NULL,
    incident_record_id uuid,
    target_entity_type character varying(64),
    target_entity_id uuid,
    site_id uuid,
    lane_id uuid,
    override_type operations.override_type_enum NOT NULL,
    override_reason_code character varying(64) NOT NULL,
    request_status operations.override_request_status_enum NOT NULL,
    request_notes text,
    requires_approval boolean DEFAULT false NOT NULL,
    requested_at timestamp with time zone NOT NULL,
    requested_by_user_id uuid NOT NULL,
    expires_at timestamp with time zone,
    closed_at timestamp with time zone,
    closure_reason_code character varying(64),
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_override_requests__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE override_requests; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON TABLE operations.override_requests IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN override_requests.override_request_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_requests.override_request_id IS 'Canonical identifier of the override request.';


--
-- Name: COLUMN override_requests.incident_record_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_requests.incident_record_id IS 'Related incident, where applicable.';


--
-- Name: COLUMN override_requests.target_entity_type; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_requests.target_entity_type IS 'Type of affected entity.';


--
-- Name: COLUMN override_requests.target_entity_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_requests.target_entity_id IS 'Identifier of affected entity.';


--
-- Name: COLUMN override_requests.site_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_requests.site_id IS 'Site affected by the override request.';


--
-- Name: COLUMN override_requests.lane_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_requests.lane_id IS 'Lane affected by the override request.';


--
-- Name: COLUMN override_requests.override_type; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_requests.override_type IS 'Type of override requested.';


--
-- Name: COLUMN override_requests.override_reason_code; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_requests.override_reason_code IS 'Controlled reason for request.';


--
-- Name: COLUMN override_requests.request_status; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_requests.request_status IS 'Request lifecycle state.';


--
-- Name: COLUMN override_requests.request_notes; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_requests.request_notes IS 'Controlled operational note. Must not store sensitive evidence casually.';


--
-- Name: COLUMN override_requests.requires_approval; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_requests.requires_approval IS 'Indicates whether approval is required.';


--
-- Name: COLUMN override_requests.requested_at; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_requests.requested_at IS 'Timestamp when request was made.';


--
-- Name: COLUMN override_requests.requested_by_user_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_requests.requested_by_user_id IS 'User who requested the override.';


--
-- Name: COLUMN override_requests.expires_at; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_requests.expires_at IS 'Expiry timestamp for request validity.';


--
-- Name: COLUMN override_requests.closed_at; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_requests.closed_at IS 'Closure timestamp.';


--
-- Name: COLUMN override_requests.closure_reason_code; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_requests.closure_reason_code IS 'Controlled closure reason.';


--
-- Name: COLUMN override_requests.correlation_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_requests.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN override_requests.created_at; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_requests.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN override_requests.created_by_user_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_requests.created_by_user_id IS 'User who created the request.';


--
-- Name: COLUMN override_requests.created_by_service_identity_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_requests.created_by_service_identity_id IS 'Service identity that created the request.';


--
-- Name: COLUMN override_requests.updated_at; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_requests.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN override_requests.updated_by_user_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_requests.updated_by_user_id IS 'User who last updated the request.';


--
-- Name: COLUMN override_requests.updated_by_service_identity_id; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_requests.updated_by_service_identity_id IS 'Service identity that last updated the request.';


--
-- Name: COLUMN override_requests.row_version; Type: COMMENT; Schema: operations; Owner: -
--

COMMENT ON COLUMN operations.override_requests.row_version IS 'Optimistic concurrency version.';


--
-- Name: payment_provider_routing_policies; Type: TABLE; Schema: payments; Owner: -
--

CREATE TABLE payments.payment_provider_routing_policies (
    payment_routing_policy_id uuid DEFAULT gen_random_uuid() NOT NULL,
    site_id uuid,
    site_group_id uuid,
    payment_method_code character varying(32) NOT NULL,
    primary_provider_code character varying(64) NOT NULL,
    fallback_provider_code character varying(64),
    currency_code character(3) NOT NULL,
    min_amount_minor_units bigint,
    max_amount_minor_units bigint,
    is_enabled boolean DEFAULT true NOT NULL,
    primary_provider_enabled boolean DEFAULT true NOT NULL,
    fallback_provider_enabled boolean DEFAULT true NOT NULL,
    effective_from timestamp with time zone DEFAULT now() NOT NULL,
    effective_until timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_payment_provider_routing_policies__amount_bounds CHECK (((min_amount_minor_units IS NULL) OR (max_amount_minor_units IS NULL) OR (max_amount_minor_units >= min_amount_minor_units))),
    CONSTRAINT ck_payment_provider_routing_policies__effective_window CHECK (((effective_until IS NULL) OR (effective_until > effective_from))),
    CONSTRAINT ck_payment_provider_routing_policies__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE payment_provider_routing_policies; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON TABLE payments.payment_provider_routing_policies IS 'Payment provider routing policy for Payment Orchestrator provider selection.';


--
-- Name: COLUMN payment_provider_routing_policies.payment_method_code; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.payment_provider_routing_policies.payment_method_code IS 'Customer-selected payment method code, for example QRPH, CARD, GCASH, or MAYA.';


--
-- Name: COLUMN payment_provider_routing_policies.primary_provider_code; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.payment_provider_routing_policies.primary_provider_code IS 'Primary provider selected when no valid preferred provider is supplied.';


--
-- Name: COLUMN payment_provider_routing_policies.fallback_provider_code; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.payment_provider_routing_policies.fallback_provider_code IS 'Fallback provider selected when the primary provider is disabled and fallback is enabled.';


--
-- Name: COLUMN payment_provider_routing_policies.primary_provider_enabled; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.payment_provider_routing_policies.primary_provider_enabled IS 'Controls whether the configured primary provider is selectable.';


--
-- Name: COLUMN payment_provider_routing_policies.fallback_provider_enabled; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.payment_provider_routing_policies.fallback_provider_enabled IS 'Controls whether the configured fallback provider is selectable.';


--
-- Name: payment_rails; Type: TABLE; Schema: payments; Owner: -
--

CREATE TABLE payments.payment_rails (
    payment_rail_id uuid DEFAULT gen_random_uuid() NOT NULL,
    rail_code character varying(64) NOT NULL,
    rail_name character varying(128) NOT NULL,
    provider_code character varying(64) NOT NULL,
    rail_type payments.payment_rail_type_enum NOT NULL,
    supported_currency_code character(3) NOT NULL,
    rail_status payments.payment_rail_status_enum NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    is_fallback boolean DEFAULT false NOT NULL,
    provider_profile_ref character varying(128),
    configuration_ref character varying(128),
    effective_from timestamp with time zone NOT NULL,
    effective_to timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_payment_rails__effective_window CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT ck_payment_rails__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE payment_rails; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON TABLE payments.payment_rails IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN payment_rails.payment_rail_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.payment_rails.payment_rail_id IS 'Canonical identifier of the payment rail.';


--
-- Name: COLUMN payment_rails.rail_code; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.payment_rails.rail_code IS 'Stable internal code for the rail.';


--
-- Name: COLUMN payment_rails.rail_name; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.payment_rails.rail_name IS 'Human-readable payment rail name.';


--
-- Name: COLUMN payment_rails.provider_code; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.payment_rails.provider_code IS 'Provider code.';


--
-- Name: COLUMN payment_rails.rail_type; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.payment_rails.rail_type IS 'Type of rail.';


--
-- Name: COLUMN payment_rails.supported_currency_code; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.payment_rails.supported_currency_code IS 'Supported currency.';


--
-- Name: COLUMN payment_rails.rail_status; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.payment_rails.rail_status IS 'Lifecycle status of the payment rail.';


--
-- Name: COLUMN payment_rails.is_primary; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.payment_rails.is_primary IS 'Indicates whether this is the preferred rail for its type.';


--
-- Name: COLUMN payment_rails.is_fallback; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.payment_rails.is_fallback IS 'Indicates whether this rail may be used as fallback.';


--
-- Name: COLUMN payment_rails.provider_profile_ref; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.payment_rails.provider_profile_ref IS 'External or internal provider profile reference.';


--
-- Name: COLUMN payment_rails.configuration_ref; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.payment_rails.configuration_ref IS 'Configuration profile reference.';


--
-- Name: COLUMN payment_rails.effective_from; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.payment_rails.effective_from IS 'Start of rail effectiveness.';


--
-- Name: COLUMN payment_rails.effective_to; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.payment_rails.effective_to IS 'End of rail effectiveness.';


--
-- Name: COLUMN payment_rails.created_at; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.payment_rails.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN payment_rails.created_by_user_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.payment_rails.created_by_user_id IS 'User who created the rail record.';


--
-- Name: COLUMN payment_rails.created_by_service_identity_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.payment_rails.created_by_service_identity_id IS 'Service identity that created the rail record.';


--
-- Name: COLUMN payment_rails.updated_at; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.payment_rails.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN payment_rails.updated_by_user_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.payment_rails.updated_by_user_id IS 'User who last updated the rail record.';


--
-- Name: COLUMN payment_rails.updated_by_service_identity_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.payment_rails.updated_by_service_identity_id IS 'Service identity that last updated the rail record.';


--
-- Name: COLUMN payment_rails.row_version; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.payment_rails.row_version IS 'Optimistic concurrency version.';


--
-- Name: provider_callbacks; Type: TABLE; Schema: payments; Owner: -
--

CREATE TABLE payments.provider_callbacks (
    provider_callback_id uuid DEFAULT gen_random_uuid() NOT NULL,
    payment_rail_id uuid NOT NULL,
    provider_session_id uuid,
    payment_attempt_id uuid,
    provider_event_ref character varying(128),
    provider_transaction_ref character varying(128),
    callback_type character varying(64) NOT NULL,
    payload_hash character(64) NOT NULL,
    payload_storage_ref character varying(256),
    headers_hash character(64),
    signature_valid boolean,
    timestamp_valid boolean,
    source_valid boolean,
    verification_status payments.provider_callback_verification_status_enum NOT NULL,
    processing_status payments.provider_callback_processing_status_enum NOT NULL,
    received_at timestamp with time zone NOT NULL,
    processed_at timestamp with time zone,
    failure_reason_code character varying(64),
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_service_identity_id uuid NOT NULL
);


--
-- Name: TABLE provider_callbacks; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON TABLE payments.provider_callbacks IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN provider_callbacks.provider_callback_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_callbacks.provider_callback_id IS 'Canonical identifier of the provider callback record.';


--
-- Name: COLUMN provider_callbacks.payment_rail_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_callbacks.payment_rail_id IS 'Payment rail or provider profile that received the callback.';


--
-- Name: COLUMN provider_callbacks.provider_session_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_callbacks.provider_session_id IS 'Provider session correlated to the callback, where known.';


--
-- Name: COLUMN provider_callbacks.payment_attempt_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_callbacks.payment_attempt_id IS 'Payment attempt correlated to the callback, where known.';


--
-- Name: COLUMN provider_callbacks.provider_event_ref; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_callbacks.provider_event_ref IS 'Provider event ID or callback reference.';


--
-- Name: COLUMN provider_callbacks.provider_transaction_ref; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_callbacks.provider_transaction_ref IS 'Provider transaction reference in the callback.';


--
-- Name: COLUMN provider_callbacks.callback_type; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_callbacks.callback_type IS 'Provider callback type or normalized event type.';


--
-- Name: COLUMN provider_callbacks.payload_hash; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_callbacks.payload_hash IS 'SHA-256 hash of raw callback payload.';


--
-- Name: COLUMN provider_callbacks.payload_storage_ref; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_callbacks.payload_storage_ref IS 'Reference to raw payload storage if stored outside table.';


--
-- Name: COLUMN provider_callbacks.headers_hash; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_callbacks.headers_hash IS 'Hash of relevant callback headers where retained.';


--
-- Name: COLUMN provider_callbacks.signature_valid; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_callbacks.signature_valid IS 'Result of signature verification where applicable.';


--
-- Name: COLUMN provider_callbacks.timestamp_valid; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_callbacks.timestamp_valid IS 'Result of timestamp-window verification where applicable.';


--
-- Name: COLUMN provider_callbacks.source_valid; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_callbacks.source_valid IS 'Result of source validation where applicable.';


--
-- Name: COLUMN provider_callbacks.verification_status; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_callbacks.verification_status IS 'Trust verification result.';


--
-- Name: COLUMN provider_callbacks.processing_status; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_callbacks.processing_status IS 'Processing lifecycle state.';


--
-- Name: COLUMN provider_callbacks.received_at; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_callbacks.received_at IS 'Timestamp when callback was received.';


--
-- Name: COLUMN provider_callbacks.processed_at; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_callbacks.processed_at IS 'Timestamp when callback processing completed.';


--
-- Name: COLUMN provider_callbacks.failure_reason_code; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_callbacks.failure_reason_code IS 'Controlled failure reason.';


--
-- Name: COLUMN provider_callbacks.correlation_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_callbacks.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN provider_callbacks.created_at; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_callbacks.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN provider_callbacks.created_by_service_identity_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_callbacks.created_by_service_identity_id IS 'Receiving service identity.';


--
-- Name: provider_outcomes; Type: TABLE; Schema: payments; Owner: -
--

CREATE TABLE payments.provider_outcomes (
    provider_outcome_id uuid DEFAULT gen_random_uuid() NOT NULL,
    payment_attempt_id uuid NOT NULL,
    provider_session_id uuid,
    provider_callback_id uuid,
    provider_status_query_id uuid,
    payment_rail_id uuid NOT NULL,
    provider_transaction_ref character varying(128),
    provider_outcome_status payments.provider_outcome_status_enum NOT NULL,
    provider_native_status character varying(64),
    currency_code character(3) NOT NULL,
    amount numeric(18,2) NOT NULL,
    verified_at timestamp with time zone NOT NULL,
    reported_to_central_pms_at timestamp with time zone,
    central_pms_report_status payments.central_pms_report_status_enum NOT NULL,
    failure_reason_code character varying(64),
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_service_identity_id uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_provider_outcomes__amount_non_negative CHECK (((amount IS NULL) OR (amount >= (0)::numeric))),
    CONSTRAINT ck_provider_outcomes__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE provider_outcomes; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON TABLE payments.provider_outcomes IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN provider_outcomes.provider_outcome_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_outcomes.provider_outcome_id IS 'Canonical identifier of the provider outcome.';


--
-- Name: COLUMN provider_outcomes.payment_attempt_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_outcomes.payment_attempt_id IS 'Payment attempt that the outcome relates to.';


--
-- Name: COLUMN provider_outcomes.provider_session_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_outcomes.provider_session_id IS 'Provider session that produced the outcome.';


--
-- Name: COLUMN provider_outcomes.provider_callback_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_outcomes.provider_callback_id IS 'Callback that supported the outcome, if applicable.';


--
-- Name: COLUMN provider_outcomes.provider_status_query_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_outcomes.provider_status_query_id IS 'Status query that supported the outcome, if applicable.';


--
-- Name: COLUMN provider_outcomes.payment_rail_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_outcomes.payment_rail_id IS 'Payment rail that produced the outcome.';


--
-- Name: COLUMN provider_outcomes.provider_transaction_ref; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_outcomes.provider_transaction_ref IS 'Provider transaction reference.';


--
-- Name: COLUMN provider_outcomes.provider_outcome_status; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_outcomes.provider_outcome_status IS 'Canonicalized provider-side result.';


--
-- Name: COLUMN provider_outcomes.provider_native_status; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_outcomes.provider_native_status IS 'Native provider status value.';


--
-- Name: COLUMN provider_outcomes.currency_code; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_outcomes.currency_code IS 'Currency code.';


--
-- Name: COLUMN provider_outcomes.amount; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_outcomes.amount IS 'Amount verified from provider evidence.';


--
-- Name: COLUMN provider_outcomes.verified_at; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_outcomes.verified_at IS 'Timestamp when evidence was verified.';


--
-- Name: COLUMN provider_outcomes.reported_to_central_pms_at; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_outcomes.reported_to_central_pms_at IS 'Timestamp when verified outcome was reported to Central PMS.';


--
-- Name: COLUMN provider_outcomes.central_pms_report_status; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_outcomes.central_pms_report_status IS 'Report-to-Central-PMS lifecycle state.';


--
-- Name: COLUMN provider_outcomes.failure_reason_code; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_outcomes.failure_reason_code IS 'Controlled failure or rejection reason.';


--
-- Name: COLUMN provider_outcomes.correlation_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_outcomes.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN provider_outcomes.created_at; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_outcomes.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN provider_outcomes.created_by_service_identity_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_outcomes.created_by_service_identity_id IS 'Service identity that created the outcome.';


--
-- Name: COLUMN provider_outcomes.updated_at; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_outcomes.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN provider_outcomes.updated_by_service_identity_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_outcomes.updated_by_service_identity_id IS 'Service identity that last updated the record.';


--
-- Name: COLUMN provider_outcomes.row_version; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_outcomes.row_version IS 'Optimistic concurrency version.';


--
-- Name: provider_sessions; Type: TABLE; Schema: payments; Owner: -
--

CREATE TABLE payments.provider_sessions (
    provider_session_id uuid DEFAULT gen_random_uuid() NOT NULL,
    payment_attempt_id uuid NOT NULL,
    payment_rail_id uuid NOT NULL,
    provider_session_ref character varying(128),
    provider_transaction_ref character varying(128),
    idempotency_key character varying(128) NOT NULL,
    session_status payments.provider_session_status_enum NOT NULL,
    currency_code character(3) NOT NULL,
    amount numeric(18,2) NOT NULL,
    checkout_url text,
    qr_payload text,
    expires_at timestamp with time zone,
    provider_created_at timestamp with time zone,
    provider_expires_at timestamp with time zone,
    raw_provider_metadata_ref character varying(128),
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_service_identity_id uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_provider_sessions__amount_non_negative CHECK (((amount IS NULL) OR (amount >= (0)::numeric))),
    CONSTRAINT ck_provider_sessions__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE provider_sessions; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON TABLE payments.provider_sessions IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN provider_sessions.provider_session_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_sessions.provider_session_id IS 'Canonical identifier of the provider session.';


--
-- Name: COLUMN provider_sessions.payment_attempt_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_sessions.payment_attempt_id IS 'Target payment attempt.';


--
-- Name: COLUMN provider_sessions.payment_rail_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_sessions.payment_rail_id IS 'Payment rail used for provider execution.';


--
-- Name: COLUMN provider_sessions.provider_session_ref; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_sessions.provider_session_ref IS 'Provider-side session, checkout, intent, or order reference.';


--
-- Name: COLUMN provider_sessions.provider_transaction_ref; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_sessions.provider_transaction_ref IS 'Provider transaction reference where known at session creation.';


--
-- Name: COLUMN provider_sessions.idempotency_key; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_sessions.idempotency_key IS 'Idempotency key for provider-session creation.';


--
-- Name: COLUMN provider_sessions.session_status; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_sessions.session_status IS 'Provider session lifecycle state.';


--
-- Name: COLUMN provider_sessions.currency_code; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_sessions.currency_code IS 'Currency code.';


--
-- Name: COLUMN provider_sessions.amount; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_sessions.amount IS 'Amount submitted to provider.';


--
-- Name: COLUMN provider_sessions.checkout_url; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_sessions.checkout_url IS 'Hosted checkout URL where applicable.';


--
-- Name: COLUMN provider_sessions.qr_payload; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_sessions.qr_payload IS 'QR or QRPh payload where applicable.';


--
-- Name: COLUMN provider_sessions.expires_at; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_sessions.expires_at IS 'Provider session expiry timestamp.';


--
-- Name: COLUMN provider_sessions.provider_created_at; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_sessions.provider_created_at IS 'Provider-side creation timestamp where known.';


--
-- Name: COLUMN provider_sessions.provider_expires_at; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_sessions.provider_expires_at IS 'Provider-side expiry timestamp where known.';


--
-- Name: COLUMN provider_sessions.raw_provider_metadata_ref; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_sessions.raw_provider_metadata_ref IS 'Reference to stored provider metadata if retained separately.';


--
-- Name: COLUMN provider_sessions.correlation_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_sessions.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN provider_sessions.created_at; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_sessions.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN provider_sessions.created_by_service_identity_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_sessions.created_by_service_identity_id IS 'Service identity that created the provider session.';


--
-- Name: COLUMN provider_sessions.updated_at; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_sessions.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN provider_sessions.updated_by_service_identity_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_sessions.updated_by_service_identity_id IS 'Service identity that last updated the provider session.';


--
-- Name: COLUMN provider_sessions.row_version; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_sessions.row_version IS 'Optimistic concurrency version.';


--
-- Name: provider_status_queries; Type: TABLE; Schema: payments; Owner: -
--

CREATE TABLE payments.provider_status_queries (
    provider_status_query_id uuid DEFAULT gen_random_uuid() NOT NULL,
    payment_attempt_id uuid NOT NULL,
    provider_session_id uuid,
    payment_rail_id uuid NOT NULL,
    provider_transaction_ref character varying(128),
    query_status payments.provider_status_query_status_enum NOT NULL,
    provider_result_status character varying(64),
    http_status_code integer,
    request_hash character(64),
    response_hash character(64),
    response_storage_ref character varying(256),
    failure_reason_code character varying(64),
    requested_at timestamp with time zone NOT NULL,
    completed_at timestamp with time zone,
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_service_identity_id uuid NOT NULL
);


--
-- Name: TABLE provider_status_queries; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON TABLE payments.provider_status_queries IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN provider_status_queries.provider_status_query_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_status_queries.provider_status_query_id IS 'Canonical identifier of the provider status query.';


--
-- Name: COLUMN provider_status_queries.payment_attempt_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_status_queries.payment_attempt_id IS 'Payment attempt being investigated or verified.';


--
-- Name: COLUMN provider_status_queries.provider_session_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_status_queries.provider_session_id IS 'Provider session being queried.';


--
-- Name: COLUMN provider_status_queries.payment_rail_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_status_queries.payment_rail_id IS 'Payment rail queried.';


--
-- Name: COLUMN provider_status_queries.provider_transaction_ref; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_status_queries.provider_transaction_ref IS 'Provider transaction reference used for query.';


--
-- Name: COLUMN provider_status_queries.query_status; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_status_queries.query_status IS 'Query lifecycle state.';


--
-- Name: COLUMN provider_status_queries.provider_result_status; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_status_queries.provider_result_status IS 'Raw or provider-normalized result status.';


--
-- Name: COLUMN provider_status_queries.http_status_code; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_status_queries.http_status_code IS 'HTTP status returned by provider.';


--
-- Name: COLUMN provider_status_queries.request_hash; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_status_queries.request_hash IS 'Hash of request payload or request signature basis.';


--
-- Name: COLUMN provider_status_queries.response_hash; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_status_queries.response_hash IS 'Hash of provider response payload where retained.';


--
-- Name: COLUMN provider_status_queries.response_storage_ref; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_status_queries.response_storage_ref IS 'Reference to response payload if stored externally.';


--
-- Name: COLUMN provider_status_queries.failure_reason_code; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_status_queries.failure_reason_code IS 'Controlled failure reason.';


--
-- Name: COLUMN provider_status_queries.requested_at; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_status_queries.requested_at IS 'Query request timestamp.';


--
-- Name: COLUMN provider_status_queries.completed_at; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_status_queries.completed_at IS 'Query completion timestamp.';


--
-- Name: COLUMN provider_status_queries.correlation_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_status_queries.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN provider_status_queries.created_at; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_status_queries.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN provider_status_queries.created_by_service_identity_id; Type: COMMENT; Schema: payments; Owner: -
--

COMMENT ON COLUMN payments.provider_status_queries.created_by_service_identity_id IS 'Querying service identity.';


--
-- Name: mops_transaction_records; Type: TABLE; Schema: reconciliation; Owner: -
--

CREATE TABLE reconciliation.mops_transaction_records (
    mops_transaction_record_id uuid DEFAULT gen_random_uuid() NOT NULL,
    parking_session_id uuid,
    manual_gate_log_id uuid,
    incident_record_id uuid,
    site_id uuid NOT NULL,
    lane_id uuid,
    source_system_code character varying(64) NOT NULL,
    source_transaction_ref character varying(128),
    source_batch_ref character varying(128),
    collection_reference character varying(128),
    currency_code character(3),
    amount numeric(18,2),
    payment_method_label character varying(64),
    continuity_reason_code character varying(64) NOT NULL,
    record_status reconciliation.mops_transaction_record_status_enum NOT NULL,
    captured_at timestamp with time zone NOT NULL,
    imported_at timestamp with time zone,
    reconciled_at timestamp with time zone,
    rejected_at timestamp with time zone,
    disputed_at timestamp with time zone,
    failure_reason_code character varying(64),
    evidence_ref character varying(256),
    evidence_hash character(64),
    captured_by_user_id uuid,
    captured_by_service_identity_id uuid,
    imported_by_service_identity_id uuid,
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_mops_transaction_records__amount_non_negative CHECK (((amount IS NULL) OR (amount >= (0)::numeric))),
    CONSTRAINT ck_mops_transaction_records__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE mops_transaction_records; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON TABLE reconciliation.mops_transaction_records IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN mops_transaction_records.mops_transaction_record_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.mops_transaction_record_id IS 'Canonical identifier of the MoPS or continuity-origin record.';


--
-- Name: COLUMN mops_transaction_records.parking_session_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.parking_session_id IS 'Related parking session, where identifiable.';


--
-- Name: COLUMN mops_transaction_records.manual_gate_log_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.manual_gate_log_id IS 'Related manual gate action, where applicable.';


--
-- Name: COLUMN mops_transaction_records.incident_record_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.incident_record_id IS 'Incident or continuity event that caused the record.';


--
-- Name: COLUMN mops_transaction_records.site_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.site_id IS 'Site where the continuity event occurred.';


--
-- Name: COLUMN mops_transaction_records.lane_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.lane_id IS 'Lane where the continuity event occurred.';


--
-- Name: COLUMN mops_transaction_records.source_system_code; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.source_system_code IS 'Source system or continuity tool code.';


--
-- Name: COLUMN mops_transaction_records.source_transaction_ref; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.source_transaction_ref IS 'Source transaction reference.';


--
-- Name: COLUMN mops_transaction_records.source_batch_ref; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.source_batch_ref IS 'Import batch or source batch reference.';


--
-- Name: COLUMN mops_transaction_records.collection_reference; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.collection_reference IS 'Manual or continuity collection reference.';


--
-- Name: COLUMN mops_transaction_records.currency_code; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.currency_code IS 'Currency code for amount fields.';


--
-- Name: COLUMN mops_transaction_records.amount; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.amount IS 'Amount captured in continuity path.';


--
-- Name: COLUMN mops_transaction_records.payment_method_label; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.payment_method_label IS 'Continuity-recorded payment method label.';


--
-- Name: COLUMN mops_transaction_records.continuity_reason_code; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.continuity_reason_code IS 'Controlled reason for continuity handling.';


--
-- Name: COLUMN mops_transaction_records.record_status; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.record_status IS 'Lifecycle state of the continuity-origin record.';


--
-- Name: COLUMN mops_transaction_records.captured_at; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.captured_at IS 'Timestamp when continuity event was captured.';


--
-- Name: COLUMN mops_transaction_records.imported_at; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.imported_at IS 'Timestamp when record was imported into Central PMS.';


--
-- Name: COLUMN mops_transaction_records.reconciled_at; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.reconciled_at IS 'Timestamp when record reached reconciled state.';


--
-- Name: COLUMN mops_transaction_records.rejected_at; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.rejected_at IS 'Timestamp when record was rejected.';


--
-- Name: COLUMN mops_transaction_records.disputed_at; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.disputed_at IS 'Timestamp when record was disputed.';


--
-- Name: COLUMN mops_transaction_records.failure_reason_code; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.failure_reason_code IS 'Controlled failure or rejection reason.';


--
-- Name: COLUMN mops_transaction_records.evidence_ref; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.evidence_ref IS 'Reference to supporting evidence or import file.';


--
-- Name: COLUMN mops_transaction_records.evidence_hash; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.evidence_hash IS 'Hash of supporting evidence where applicable.';


--
-- Name: COLUMN mops_transaction_records.captured_by_user_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.captured_by_user_id IS 'Human actor who captured the record.';


--
-- Name: COLUMN mops_transaction_records.captured_by_service_identity_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.captured_by_service_identity_id IS 'Service or tool identity that captured the record.';


--
-- Name: COLUMN mops_transaction_records.imported_by_service_identity_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.imported_by_service_identity_id IS 'Service identity that imported the record.';


--
-- Name: COLUMN mops_transaction_records.correlation_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN mops_transaction_records.created_at; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN mops_transaction_records.created_by_user_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.created_by_user_id IS 'User who created the record.';


--
-- Name: COLUMN mops_transaction_records.created_by_service_identity_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.created_by_service_identity_id IS 'Service identity that created the record.';


--
-- Name: COLUMN mops_transaction_records.updated_at; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN mops_transaction_records.updated_by_user_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.updated_by_user_id IS 'User who last updated the record.';


--
-- Name: COLUMN mops_transaction_records.updated_by_service_identity_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.updated_by_service_identity_id IS 'Service identity that last updated the record.';


--
-- Name: COLUMN mops_transaction_records.row_version; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.mops_transaction_records.row_version IS 'Optimistic concurrency version.';


--
-- Name: reconciliation_exceptions; Type: TABLE; Schema: reconciliation; Owner: -
--

CREATE TABLE reconciliation.reconciliation_exceptions (
    reconciliation_exception_id uuid DEFAULT gen_random_uuid() NOT NULL,
    reconciliation_run_id uuid NOT NULL,
    reconciliation_item_id uuid,
    incident_record_id uuid,
    exception_type reconciliation.reconciliation_exception_type_enum NOT NULL,
    exception_severity reconciliation.reconciliation_exception_severity_enum NOT NULL,
    exception_status reconciliation.reconciliation_exception_status_enum NOT NULL,
    exception_reason_code character varying(64) NOT NULL,
    exception_summary character varying(256) NOT NULL,
    exception_detail text,
    assigned_to_user_id uuid,
    assigned_to_service_identity_id uuid,
    created_from_status character varying(64),
    detected_at timestamp with time zone NOT NULL,
    assigned_at timestamp with time zone DEFAULT now(),
    resolved_at timestamp with time zone,
    closed_at timestamp with time zone,
    resolution_reason_code character varying(64),
    closure_reason_code character varying(64),
    resolved_by_user_id uuid,
    resolved_by_service_identity_id uuid,
    closed_by_user_id uuid,
    closed_by_service_identity_id uuid,
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_reconciliation_exceptions__resolved_after_detected CHECK (((resolved_at IS NULL) OR (resolved_at >= detected_at))),
    CONSTRAINT ck_reconciliation_exceptions__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE reconciliation_exceptions; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON TABLE reconciliation.reconciliation_exceptions IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN reconciliation_exceptions.reconciliation_exception_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.reconciliation_exception_id IS 'Canonical identifier of the reconciliation exception.';


--
-- Name: COLUMN reconciliation_exceptions.reconciliation_run_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.reconciliation_run_id IS 'Run where the exception was discovered.';


--
-- Name: COLUMN reconciliation_exceptions.reconciliation_item_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.reconciliation_item_id IS 'Item that produced the exception.';


--
-- Name: COLUMN reconciliation_exceptions.incident_record_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.incident_record_id IS 'Related incident, where applicable.';


--
-- Name: COLUMN reconciliation_exceptions.exception_type; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.exception_type IS 'Type of reconciliation exception.';


--
-- Name: COLUMN reconciliation_exceptions.exception_severity; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.exception_severity IS 'Severity of exception.';


--
-- Name: COLUMN reconciliation_exceptions.exception_status; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.exception_status IS 'Exception lifecycle state.';


--
-- Name: COLUMN reconciliation_exceptions.exception_reason_code; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.exception_reason_code IS 'Controlled reason for exception.';


--
-- Name: COLUMN reconciliation_exceptions.exception_summary; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.exception_summary IS 'Short human-readable summary.';


--
-- Name: COLUMN reconciliation_exceptions.exception_detail; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.exception_detail IS 'Controlled detailed note. Must not store sensitive evidence casually.';


--
-- Name: COLUMN reconciliation_exceptions.assigned_to_user_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.assigned_to_user_id IS 'User assigned to resolve the exception.';


--
-- Name: COLUMN reconciliation_exceptions.assigned_to_service_identity_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.assigned_to_service_identity_id IS 'Service identity assigned to resolve the exception.';


--
-- Name: COLUMN reconciliation_exceptions.created_from_status; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.created_from_status IS 'Item or source status that triggered the exception.';


--
-- Name: COLUMN reconciliation_exceptions.detected_at; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.detected_at IS 'Timestamp when exception was detected.';


--
-- Name: COLUMN reconciliation_exceptions.assigned_at; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.assigned_at IS 'Timestamp when exception was assigned.';


--
-- Name: COLUMN reconciliation_exceptions.resolved_at; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.resolved_at IS 'Timestamp when exception was resolved.';


--
-- Name: COLUMN reconciliation_exceptions.closed_at; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.closed_at IS 'Timestamp when exception was closed.';


--
-- Name: COLUMN reconciliation_exceptions.resolution_reason_code; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.resolution_reason_code IS 'Controlled resolution reason.';


--
-- Name: COLUMN reconciliation_exceptions.closure_reason_code; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.closure_reason_code IS 'Controlled closure reason.';


--
-- Name: COLUMN reconciliation_exceptions.resolved_by_user_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.resolved_by_user_id IS 'User who resolved the exception.';


--
-- Name: COLUMN reconciliation_exceptions.resolved_by_service_identity_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.resolved_by_service_identity_id IS 'Service identity that resolved the exception.';


--
-- Name: COLUMN reconciliation_exceptions.closed_by_user_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.closed_by_user_id IS 'User who closed the exception.';


--
-- Name: COLUMN reconciliation_exceptions.closed_by_service_identity_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.closed_by_service_identity_id IS 'Service identity that closed the exception.';


--
-- Name: COLUMN reconciliation_exceptions.correlation_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN reconciliation_exceptions.created_at; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN reconciliation_exceptions.created_by_user_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.created_by_user_id IS 'User who created the exception.';


--
-- Name: COLUMN reconciliation_exceptions.created_by_service_identity_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.created_by_service_identity_id IS 'Service identity that created the exception.';


--
-- Name: COLUMN reconciliation_exceptions.updated_at; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN reconciliation_exceptions.updated_by_user_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.updated_by_user_id IS 'User who last updated the exception.';


--
-- Name: COLUMN reconciliation_exceptions.updated_by_service_identity_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.updated_by_service_identity_id IS 'Service identity that last updated the exception.';


--
-- Name: COLUMN reconciliation_exceptions.row_version; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_exceptions.row_version IS 'Optimistic concurrency version.';


--
-- Name: reconciliation_items; Type: TABLE; Schema: reconciliation; Owner: -
--

CREATE TABLE reconciliation.reconciliation_items (
    reconciliation_item_id uuid DEFAULT gen_random_uuid() NOT NULL,
    reconciliation_run_id uuid NOT NULL,
    mops_transaction_record_id uuid,
    manual_gate_log_id uuid,
    payment_attempt_id uuid,
    payment_confirmation_id uuid,
    provider_outcome_id uuid,
    target_entity_type character varying(64),
    target_entity_id uuid,
    comparison_basis reconciliation.reconciliation_comparison_basis_enum NOT NULL,
    item_status reconciliation.reconciliation_item_status_enum NOT NULL,
    match_status reconciliation.reconciliation_match_status_enum NOT NULL,
    expected_amount numeric(18,2),
    actual_amount numeric(18,2),
    currency_code character(3),
    variance_amount numeric(18,2),
    exception_reason_code character varying(64),
    resolved_at timestamp with time zone,
    resolved_by_user_id uuid,
    resolved_by_service_identity_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    correlation_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_reconciliation_items__actual_amount_non_negative CHECK (((actual_amount IS NULL) OR (actual_amount >= (0)::numeric))),
    CONSTRAINT ck_reconciliation_items__expected_amount_non_negative CHECK (((expected_amount IS NULL) OR (expected_amount >= (0)::numeric))),
    CONSTRAINT ck_reconciliation_items__row_version_positive CHECK ((row_version > 0)),
    CONSTRAINT ck_reconciliation_items__variance_amount_non_negative CHECK (((variance_amount IS NULL) OR (variance_amount >= (0)::numeric)))
);


--
-- Name: TABLE reconciliation_items; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON TABLE reconciliation.reconciliation_items IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN reconciliation_items.reconciliation_item_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_items.reconciliation_item_id IS 'Canonical identifier of the reconciliation item.';


--
-- Name: COLUMN reconciliation_items.reconciliation_run_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_items.reconciliation_run_id IS 'Parent reconciliation run.';


--
-- Name: COLUMN reconciliation_items.mops_transaction_record_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_items.mops_transaction_record_id IS 'MoPS or continuity-origin record being reconciled.';


--
-- Name: COLUMN reconciliation_items.manual_gate_log_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_items.manual_gate_log_id IS 'Manual gate log being reconciled, where applicable.';


--
-- Name: COLUMN reconciliation_items.payment_attempt_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_items.payment_attempt_id IS 'Related payment attempt, where applicable.';


--
-- Name: COLUMN reconciliation_items.payment_confirmation_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_items.payment_confirmation_id IS 'Related payment confirmation, where applicable.';


--
-- Name: COLUMN reconciliation_items.provider_outcome_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_items.provider_outcome_id IS 'Related provider outcome, where applicable.';


--
-- Name: COLUMN reconciliation_items.target_entity_type; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_items.target_entity_type IS 'Generic target entity type where a specific FK is not available.';


--
-- Name: COLUMN reconciliation_items.target_entity_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_items.target_entity_id IS 'Generic target entity ID where a specific FK is not available.';


--
-- Name: COLUMN reconciliation_items.comparison_basis; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_items.comparison_basis IS 'Basis used for comparison.';


--
-- Name: COLUMN reconciliation_items.item_status; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_items.item_status IS 'Item-level reconciliation outcome.';


--
-- Name: COLUMN reconciliation_items.match_status; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_items.match_status IS 'Match classification.';


--
-- Name: COLUMN reconciliation_items.expected_amount; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_items.expected_amount IS 'Expected amount, where applicable.';


--
-- Name: COLUMN reconciliation_items.actual_amount; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_items.actual_amount IS 'Actual amount from compared evidence.';


--
-- Name: COLUMN reconciliation_items.currency_code; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_items.currency_code IS 'Currency code for amount comparison.';


--
-- Name: COLUMN reconciliation_items.variance_amount; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_items.variance_amount IS 'Difference between expected and actual amount.';


--
-- Name: COLUMN reconciliation_items.exception_reason_code; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_items.exception_reason_code IS 'Controlled exception reason.';


--
-- Name: COLUMN reconciliation_items.resolved_at; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_items.resolved_at IS 'Timestamp when item was resolved.';


--
-- Name: COLUMN reconciliation_items.resolved_by_user_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_items.resolved_by_user_id IS 'User who resolved the item.';


--
-- Name: COLUMN reconciliation_items.resolved_by_service_identity_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_items.resolved_by_service_identity_id IS 'Service identity that resolved the item.';


--
-- Name: COLUMN reconciliation_items.created_at; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_items.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN reconciliation_items.created_by_user_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_items.created_by_user_id IS 'User who created the item.';


--
-- Name: COLUMN reconciliation_items.created_by_service_identity_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_items.created_by_service_identity_id IS 'Service identity that created the item.';


--
-- Name: COLUMN reconciliation_items.updated_at; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_items.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN reconciliation_items.updated_by_user_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_items.updated_by_user_id IS 'User who last updated the item.';


--
-- Name: COLUMN reconciliation_items.updated_by_service_identity_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_items.updated_by_service_identity_id IS 'Service identity that last updated the item.';


--
-- Name: COLUMN reconciliation_items.correlation_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_items.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN reconciliation_items.row_version; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_items.row_version IS 'Optimistic concurrency version.';


--
-- Name: reconciliation_runs; Type: TABLE; Schema: reconciliation; Owner: -
--

CREATE TABLE reconciliation.reconciliation_runs (
    reconciliation_run_id uuid DEFAULT gen_random_uuid() NOT NULL,
    run_code character varying(64) NOT NULL,
    run_type reconciliation.reconciliation_run_type_enum NOT NULL,
    run_status reconciliation.reconciliation_run_status_enum NOT NULL,
    scope_type reconciliation.reconciliation_scope_type_enum NOT NULL,
    site_group_id uuid,
    site_id uuid,
    incident_record_id uuid,
    payment_rail_id uuid,
    vendor_system_id uuid,
    source_batch_ref character varying(128),
    window_start_at timestamp with time zone,
    window_end_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone,
    failed_at timestamp with time zone,
    failure_reason_code character varying(64),
    item_count integer NOT NULL,
    matched_count integer NOT NULL,
    exception_count integer NOT NULL,
    rejected_count integer NOT NULL,
    disputed_count integer NOT NULL,
    initiated_by_user_id uuid,
    initiated_by_service_identity_id uuid,
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_reconciliation_runs__completed_after_started CHECK (((completed_at IS NULL) OR (completed_at >= started_at))),
    CONSTRAINT ck_reconciliation_runs__disputed_count_non_negative CHECK (((disputed_count IS NULL) OR (disputed_count >= 0))),
    CONSTRAINT ck_reconciliation_runs__exception_count_non_negative CHECK (((exception_count IS NULL) OR (exception_count >= 0))),
    CONSTRAINT ck_reconciliation_runs__item_count_non_negative CHECK (((item_count IS NULL) OR (item_count >= 0))),
    CONSTRAINT ck_reconciliation_runs__matched_count_non_negative CHECK (((matched_count IS NULL) OR (matched_count >= 0))),
    CONSTRAINT ck_reconciliation_runs__rejected_count_non_negative CHECK (((rejected_count IS NULL) OR (rejected_count >= 0))),
    CONSTRAINT ck_reconciliation_runs__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE reconciliation_runs; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON TABLE reconciliation.reconciliation_runs IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN reconciliation_runs.reconciliation_run_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.reconciliation_run_id IS 'Canonical identifier of the reconciliation run.';


--
-- Name: COLUMN reconciliation_runs.run_code; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.run_code IS 'Human-readable or generated run code.';


--
-- Name: COLUMN reconciliation_runs.run_type; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.run_type IS 'Type of reconciliation run.';


--
-- Name: COLUMN reconciliation_runs.run_status; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.run_status IS 'Run lifecycle state.';


--
-- Name: COLUMN reconciliation_runs.scope_type; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.scope_type IS 'Scope type for the run.';


--
-- Name: COLUMN reconciliation_runs.site_group_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.site_group_id IS 'Site group scope.';


--
-- Name: COLUMN reconciliation_runs.site_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.site_id IS 'Site scope.';


--
-- Name: COLUMN reconciliation_runs.incident_record_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.incident_record_id IS 'Incident being reconciled, where applicable.';


--
-- Name: COLUMN reconciliation_runs.payment_rail_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.payment_rail_id IS 'Payment rail scope, where applicable.';


--
-- Name: COLUMN reconciliation_runs.vendor_system_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.vendor_system_id IS 'Vendor system scope, where applicable.';


--
-- Name: COLUMN reconciliation_runs.source_batch_ref; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.source_batch_ref IS 'Source batch reference being reconciled.';


--
-- Name: COLUMN reconciliation_runs.window_start_at; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.window_start_at IS 'Reconciliation window start.';


--
-- Name: COLUMN reconciliation_runs.window_end_at; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.window_end_at IS 'Reconciliation window end.';


--
-- Name: COLUMN reconciliation_runs.started_at; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.started_at IS 'Run start timestamp.';


--
-- Name: COLUMN reconciliation_runs.completed_at; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.completed_at IS 'Run completion timestamp.';


--
-- Name: COLUMN reconciliation_runs.failed_at; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.failed_at IS 'Run failure timestamp.';


--
-- Name: COLUMN reconciliation_runs.failure_reason_code; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.failure_reason_code IS 'Controlled failure reason.';


--
-- Name: COLUMN reconciliation_runs.item_count; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.item_count IS 'Total item count.';


--
-- Name: COLUMN reconciliation_runs.matched_count; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.matched_count IS 'Matched item count.';


--
-- Name: COLUMN reconciliation_runs.exception_count; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.exception_count IS 'Exception item count.';


--
-- Name: COLUMN reconciliation_runs.rejected_count; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.rejected_count IS 'Rejected item count.';


--
-- Name: COLUMN reconciliation_runs.disputed_count; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.disputed_count IS 'Disputed item count.';


--
-- Name: COLUMN reconciliation_runs.initiated_by_user_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.initiated_by_user_id IS 'User who initiated the run.';


--
-- Name: COLUMN reconciliation_runs.initiated_by_service_identity_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.initiated_by_service_identity_id IS 'Service identity that initiated the run.';


--
-- Name: COLUMN reconciliation_runs.correlation_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN reconciliation_runs.created_at; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN reconciliation_runs.created_by_user_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.created_by_user_id IS 'User who created the run record.';


--
-- Name: COLUMN reconciliation_runs.created_by_service_identity_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.created_by_service_identity_id IS 'Service identity that created the run record.';


--
-- Name: COLUMN reconciliation_runs.updated_at; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN reconciliation_runs.updated_by_user_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.updated_by_user_id IS 'User who last updated the run record.';


--
-- Name: COLUMN reconciliation_runs.updated_by_service_identity_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.updated_by_service_identity_id IS 'Service identity that last updated the run record.';


--
-- Name: COLUMN reconciliation_runs.row_version; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.reconciliation_runs.row_version IS 'Optimistic concurrency version.';


--
-- Name: settlement_comparison_records; Type: TABLE; Schema: reconciliation; Owner: -
--

CREATE TABLE reconciliation.settlement_comparison_records (
    settlement_comparison_record_id uuid DEFAULT gen_random_uuid() NOT NULL,
    reconciliation_item_id uuid NOT NULL,
    mops_transaction_record_id uuid,
    reconciliation_exception_id uuid,
    payment_confirmation_id uuid,
    provider_outcome_id uuid,
    comparison_source_type reconciliation.settlement_comparison_source_type_enum NOT NULL,
    comparison_source_ref character varying(128),
    currency_code character(3) NOT NULL,
    expected_amount numeric(18,2) NOT NULL,
    actual_amount numeric(18,2) NOT NULL,
    variance_amount numeric(18,2) NOT NULL,
    comparison_result reconciliation.settlement_comparison_result_enum NOT NULL,
    mismatch_reason_code character varying(64),
    evidence_ref character varying(256),
    evidence_hash character(64),
    compared_at timestamp with time zone NOT NULL,
    compared_by_user_id uuid,
    compared_by_service_identity_id uuid,
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    CONSTRAINT ck_settlement_comparison_records__actual_amount_non_negative CHECK (((actual_amount IS NULL) OR (actual_amount >= (0)::numeric))),
    CONSTRAINT ck_settlement_comparison_records__expected_amount_non_negati CHECK (((expected_amount IS NULL) OR (expected_amount >= (0)::numeric))),
    CONSTRAINT ck_settlement_comparison_records__variance_amount_non_negati CHECK (((variance_amount IS NULL) OR (variance_amount >= (0)::numeric)))
);


--
-- Name: TABLE settlement_comparison_records; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON TABLE reconciliation.settlement_comparison_records IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN settlement_comparison_records.settlement_comparison_record_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.settlement_comparison_records.settlement_comparison_record_id IS 'Canonical identifier of the settlement comparison record.';


--
-- Name: COLUMN settlement_comparison_records.reconciliation_item_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.settlement_comparison_records.reconciliation_item_id IS 'Reconciliation item supported by this comparison.';


--
-- Name: COLUMN settlement_comparison_records.mops_transaction_record_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.settlement_comparison_records.mops_transaction_record_id IS 'Related MoPS or continuity-origin record.';


--
-- Name: COLUMN settlement_comparison_records.reconciliation_exception_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.settlement_comparison_records.reconciliation_exception_id IS 'Related reconciliation exception, where applicable.';


--
-- Name: COLUMN settlement_comparison_records.payment_confirmation_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.settlement_comparison_records.payment_confirmation_id IS 'Related payment confirmation, where applicable.';


--
-- Name: COLUMN settlement_comparison_records.provider_outcome_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.settlement_comparison_records.provider_outcome_id IS 'Related provider outcome, where applicable.';


--
-- Name: COLUMN settlement_comparison_records.comparison_source_type; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.settlement_comparison_records.comparison_source_type IS 'Type of settlement or financial source used.';


--
-- Name: COLUMN settlement_comparison_records.comparison_source_ref; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.settlement_comparison_records.comparison_source_ref IS 'Source settlement, bank, batch, or report reference.';


--
-- Name: COLUMN settlement_comparison_records.currency_code; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.settlement_comparison_records.currency_code IS 'Currency code.';


--
-- Name: COLUMN settlement_comparison_records.expected_amount; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.settlement_comparison_records.expected_amount IS 'Expected amount.';


--
-- Name: COLUMN settlement_comparison_records.actual_amount; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.settlement_comparison_records.actual_amount IS 'Actual amount from settlement evidence.';


--
-- Name: COLUMN settlement_comparison_records.variance_amount; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.settlement_comparison_records.variance_amount IS 'Actual minus expected amount.';


--
-- Name: COLUMN settlement_comparison_records.comparison_result; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.settlement_comparison_records.comparison_result IS 'Result of settlement comparison.';


--
-- Name: COLUMN settlement_comparison_records.mismatch_reason_code; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.settlement_comparison_records.mismatch_reason_code IS 'Controlled mismatch reason.';


--
-- Name: COLUMN settlement_comparison_records.evidence_ref; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.settlement_comparison_records.evidence_ref IS 'Reference to settlement file, report, or evidence.';


--
-- Name: COLUMN settlement_comparison_records.evidence_hash; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.settlement_comparison_records.evidence_hash IS 'Hash of settlement evidence where applicable.';


--
-- Name: COLUMN settlement_comparison_records.compared_at; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.settlement_comparison_records.compared_at IS 'Timestamp when comparison was performed.';


--
-- Name: COLUMN settlement_comparison_records.compared_by_user_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.settlement_comparison_records.compared_by_user_id IS 'User who performed comparison.';


--
-- Name: COLUMN settlement_comparison_records.compared_by_service_identity_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.settlement_comparison_records.compared_by_service_identity_id IS 'Service identity that performed comparison.';


--
-- Name: COLUMN settlement_comparison_records.correlation_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.settlement_comparison_records.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN settlement_comparison_records.created_at; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.settlement_comparison_records.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN settlement_comparison_records.created_by_user_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.settlement_comparison_records.created_by_user_id IS 'User who created the comparison.';


--
-- Name: COLUMN settlement_comparison_records.created_by_service_identity_id; Type: COMMENT; Schema: reconciliation; Owner: -
--

COMMENT ON COLUMN reconciliation.settlement_comparison_records.created_by_service_identity_id IS 'Service identity that created the comparison.';


--
-- Name: session_identifier_indexes; Type: TABLE; Schema: sessions; Owner: -
--

CREATE TABLE sessions.session_identifier_indexes (
    session_identifier_index_id uuid DEFAULT gen_random_uuid() NOT NULL,
    parking_session_id uuid,
    site_group_id uuid NOT NULL,
    site_id uuid,
    vendor_system_id uuid,
    identifier_type sessions.session_lookup_type_enum NOT NULL,
    identifier_hash character(64) NOT NULL,
    identifier_masked character varying(64),
    identifier_status sessions.session_identifier_status_enum NOT NULL,
    effective_from timestamp with time zone NOT NULL,
    effective_to timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_service_identity_id uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_service_identity_id uuid,
    correlation_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_session_identifier_indexes__effective_window CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT ck_session_identifier_indexes__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE session_identifier_indexes; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON TABLE sessions.session_identifier_indexes IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN session_identifier_indexes.session_identifier_index_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_identifier_indexes.session_identifier_index_id IS 'Canonical identifier of the identifier index record.';


--
-- Name: COLUMN session_identifier_indexes.parking_session_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_identifier_indexes.parking_session_id IS 'Canonical parking session associated with the identifier.';


--
-- Name: COLUMN session_identifier_indexes.site_group_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_identifier_indexes.site_group_id IS 'Site group scope for identifier lookup.';


--
-- Name: COLUMN session_identifier_indexes.site_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_identifier_indexes.site_id IS 'Site context where known.';


--
-- Name: COLUMN session_identifier_indexes.vendor_system_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_identifier_indexes.vendor_system_id IS 'Vendor system context where identifier is vendor-originated.';


--
-- Name: COLUMN session_identifier_indexes.identifier_type; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_identifier_indexes.identifier_type IS 'Identifier type.';


--
-- Name: COLUMN session_identifier_indexes.identifier_hash; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_identifier_indexes.identifier_hash IS 'Hash of normalized identifier.';


--
-- Name: COLUMN session_identifier_indexes.identifier_masked; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_identifier_indexes.identifier_masked IS 'Masked display value.';


--
-- Name: COLUMN session_identifier_indexes.identifier_status; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_identifier_indexes.identifier_status IS 'Identifier lifecycle state.';


--
-- Name: COLUMN session_identifier_indexes.effective_from; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_identifier_indexes.effective_from IS 'Start of identifier validity.';


--
-- Name: COLUMN session_identifier_indexes.effective_to; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_identifier_indexes.effective_to IS 'End of identifier validity.';


--
-- Name: COLUMN session_identifier_indexes.created_at; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_identifier_indexes.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN session_identifier_indexes.created_by_service_identity_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_identifier_indexes.created_by_service_identity_id IS 'Service identity that created the identifier index.';


--
-- Name: COLUMN session_identifier_indexes.updated_at; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_identifier_indexes.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN session_identifier_indexes.updated_by_service_identity_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_identifier_indexes.updated_by_service_identity_id IS 'Service identity that last updated the identifier index.';


--
-- Name: COLUMN session_identifier_indexes.correlation_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_identifier_indexes.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN session_identifier_indexes.row_version; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_identifier_indexes.row_version IS 'Optimistic concurrency version.';


--
-- Name: session_lookup_cache; Type: TABLE; Schema: sessions; Owner: -
--

CREATE TABLE sessions.session_lookup_cache (
    session_lookup_cache_id uuid DEFAULT gen_random_uuid() NOT NULL,
    site_group_id uuid NOT NULL,
    site_id uuid,
    parking_session_id uuid,
    vendor_system_id uuid,
    lookup_type sessions.session_lookup_type_enum NOT NULL,
    lookup_identifier_hash character(64) NOT NULL,
    result_status sessions.session_resolution_result_status_enum NOT NULL,
    cache_status sessions.session_lookup_cache_status_enum NOT NULL,
    cached_at timestamp with time zone NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    invalidated_at timestamp with time zone,
    invalidation_reason_code character varying(64),
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_service_identity_id uuid NOT NULL,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_session_lookup_cache__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE session_lookup_cache; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON TABLE sessions.session_lookup_cache IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN session_lookup_cache.session_lookup_cache_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_lookup_cache.session_lookup_cache_id IS 'Canonical identifier of the cache entry.';


--
-- Name: COLUMN session_lookup_cache.site_group_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_lookup_cache.site_group_id IS 'Site group scope of the cached lookup.';


--
-- Name: COLUMN session_lookup_cache.site_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_lookup_cache.site_id IS 'Site context where known.';


--
-- Name: COLUMN session_lookup_cache.parking_session_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_lookup_cache.parking_session_id IS 'Canonical parking session if lookup was resolved.';


--
-- Name: COLUMN session_lookup_cache.vendor_system_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_lookup_cache.vendor_system_id IS 'Vendor PMS that produced the cached result.';


--
-- Name: COLUMN session_lookup_cache.lookup_type; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_lookup_cache.lookup_type IS 'Lookup identifier type.';


--
-- Name: COLUMN session_lookup_cache.lookup_identifier_hash; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_lookup_cache.lookup_identifier_hash IS 'Hash of normalized lookup identifier.';


--
-- Name: COLUMN session_lookup_cache.result_status; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_lookup_cache.result_status IS 'Cached result status.';


--
-- Name: COLUMN session_lookup_cache.cache_status; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_lookup_cache.cache_status IS 'Cache entry lifecycle state.';


--
-- Name: COLUMN session_lookup_cache.cached_at; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_lookup_cache.cached_at IS 'Timestamp when cache entry was created.';


--
-- Name: COLUMN session_lookup_cache.expires_at; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_lookup_cache.expires_at IS 'Cache entry expiry timestamp.';


--
-- Name: COLUMN session_lookup_cache.invalidated_at; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_lookup_cache.invalidated_at IS 'Timestamp when cache entry was invalidated.';


--
-- Name: COLUMN session_lookup_cache.invalidation_reason_code; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_lookup_cache.invalidation_reason_code IS 'Controlled invalidation reason.';


--
-- Name: COLUMN session_lookup_cache.correlation_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_lookup_cache.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN session_lookup_cache.created_at; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_lookup_cache.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN session_lookup_cache.created_by_service_identity_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_lookup_cache.created_by_service_identity_id IS 'Service identity that created the cache entry.';


--
-- Name: COLUMN session_lookup_cache.row_version; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_lookup_cache.row_version IS 'Optimistic concurrency version.';


--
-- Name: session_resolution_requests; Type: TABLE; Schema: sessions; Owner: -
--

CREATE TABLE sessions.session_resolution_requests (
    session_resolution_request_id uuid DEFAULT gen_random_uuid() NOT NULL,
    site_group_id uuid NOT NULL,
    site_id uuid,
    lookup_type sessions.session_lookup_type_enum NOT NULL,
    lookup_identifier_hash character(64) NOT NULL,
    lookup_identifier_masked character varying(64),
    request_channel sessions.session_resolution_channel_enum NOT NULL,
    request_status sessions.session_resolution_request_status_enum NOT NULL,
    client_reference character varying(128),
    idempotency_key character varying(128),
    rate_limit_key_hash character(64),
    requested_at timestamp with time zone NOT NULL,
    expires_at timestamp with time zone,
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_session_resolution_requests__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE session_resolution_requests; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON TABLE sessions.session_resolution_requests IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN session_resolution_requests.session_resolution_request_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_requests.session_resolution_request_id IS 'Canonical identifier of the lookup request.';


--
-- Name: COLUMN session_resolution_requests.site_group_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_requests.site_group_id IS 'Site group scope used for lookup.';


--
-- Name: COLUMN session_resolution_requests.site_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_requests.site_id IS 'Specific site scope, if already known.';


--
-- Name: COLUMN session_resolution_requests.lookup_type; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_requests.lookup_type IS 'Type of lookup submitted.';


--
-- Name: COLUMN session_resolution_requests.lookup_identifier_hash; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_requests.lookup_identifier_hash IS 'Hash of normalized lookup identifier.';


--
-- Name: COLUMN session_resolution_requests.lookup_identifier_masked; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_requests.lookup_identifier_masked IS 'Masked display value of submitted identifier.';


--
-- Name: COLUMN session_resolution_requests.request_channel; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_requests.request_channel IS 'Channel where request originated.';


--
-- Name: COLUMN session_resolution_requests.request_status; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_requests.request_status IS 'Request lifecycle state.';


--
-- Name: COLUMN session_resolution_requests.client_reference; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_requests.client_reference IS 'Optional client-side or UI flow reference.';


--
-- Name: COLUMN session_resolution_requests.idempotency_key; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_requests.idempotency_key IS 'Idempotency key for repeated lookup request, where used.';


--
-- Name: COLUMN session_resolution_requests.rate_limit_key_hash; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_requests.rate_limit_key_hash IS 'Hashed rate-limit key where lookup throttling applies.';


--
-- Name: COLUMN session_resolution_requests.requested_at; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_requests.requested_at IS 'Lookup request timestamp.';


--
-- Name: COLUMN session_resolution_requests.expires_at; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_requests.expires_at IS 'Request expiry timestamp where lookup has a bounded validity window.';


--
-- Name: COLUMN session_resolution_requests.correlation_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_requests.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN session_resolution_requests.created_at; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_requests.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN session_resolution_requests.created_by_user_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_requests.created_by_user_id IS 'Human user who created the request, if operator-assisted.';


--
-- Name: COLUMN session_resolution_requests.created_by_service_identity_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_requests.created_by_service_identity_id IS 'Service identity that created the request.';


--
-- Name: COLUMN session_resolution_requests.row_version; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_requests.row_version IS 'Optimistic concurrency version.';


--
-- Name: session_resolution_results; Type: TABLE; Schema: sessions; Owner: -
--

CREATE TABLE sessions.session_resolution_results (
    session_resolution_result_id uuid DEFAULT gen_random_uuid() NOT NULL,
    session_resolution_request_id uuid NOT NULL,
    parking_session_id uuid,
    site_group_id uuid NOT NULL,
    site_id uuid,
    vendor_system_id uuid,
    vendor_session_ref character varying(128),
    result_status sessions.session_resolution_result_status_enum NOT NULL,
    match_count integer NOT NULL,
    ambiguity_reason_code character varying(64),
    failure_reason_code character varying(64),
    resolved_at timestamp with time zone NOT NULL,
    expires_at timestamp with time zone,
    raw_result_ref character varying(256),
    correlation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_service_identity_id uuid NOT NULL,
    CONSTRAINT ck_session_resolution_results__match_count_non_negative CHECK (((match_count IS NULL) OR (match_count >= 0)))
);


--
-- Name: TABLE session_resolution_results; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON TABLE sessions.session_resolution_results IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN session_resolution_results.session_resolution_result_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_results.session_resolution_result_id IS 'Canonical identifier of the lookup result.';


--
-- Name: COLUMN session_resolution_results.session_resolution_request_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_results.session_resolution_request_id IS 'Lookup request that produced this result.';


--
-- Name: COLUMN session_resolution_results.parking_session_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_results.parking_session_id IS 'Canonical parking session created or reused after deterministic match.';


--
-- Name: COLUMN session_resolution_results.site_group_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_results.site_group_id IS 'Site group scope used for lookup.';


--
-- Name: COLUMN session_resolution_results.site_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_results.site_id IS 'Resolved site, where known.';


--
-- Name: COLUMN session_resolution_results.vendor_system_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_results.vendor_system_id IS 'Vendor PMS that produced the lookup result.';


--
-- Name: COLUMN session_resolution_results.vendor_session_ref; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_results.vendor_session_ref IS 'Vendor PMS session reference if resolved.';


--
-- Name: COLUMN session_resolution_results.result_status; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_results.result_status IS 'Lookup outcome.';


--
-- Name: COLUMN session_resolution_results.match_count; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_results.match_count IS 'Number of matches returned or determined.';


--
-- Name: COLUMN session_resolution_results.ambiguity_reason_code; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_results.ambiguity_reason_code IS 'Controlled reason when result is ambiguous.';


--
-- Name: COLUMN session_resolution_results.failure_reason_code; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_results.failure_reason_code IS 'Controlled reason when lookup failed.';


--
-- Name: COLUMN session_resolution_results.resolved_at; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_results.resolved_at IS 'Timestamp when result was resolved.';


--
-- Name: COLUMN session_resolution_results.expires_at; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_results.expires_at IS 'Expiry of result usability.';


--
-- Name: COLUMN session_resolution_results.raw_result_ref; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_results.raw_result_ref IS 'Reference to raw vendor lookup result where retained.';


--
-- Name: COLUMN session_resolution_results.correlation_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_results.correlation_id IS 'Cross-service correlation identifier.';


--
-- Name: COLUMN session_resolution_results.created_at; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_results.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN session_resolution_results.created_by_service_identity_id; Type: COMMENT; Schema: sessions; Owner: -
--

COMMENT ON COLUMN sessions.session_resolution_results.created_by_service_identity_id IS 'Service identity that created the result.';


--
-- Name: device_assignments; Type: TABLE; Schema: sites; Owner: -
--

CREATE TABLE sites.device_assignments (
    device_assignment_id uuid DEFAULT gen_random_uuid() NOT NULL,
    site_id uuid NOT NULL,
    lane_id uuid,
    gate_device_id uuid,
    service_identity_id uuid,
    assignment_type sites.device_assignment_type_enum NOT NULL,
    assignment_status sites.device_assignment_status_enum NOT NULL,
    assignment_reason_code character varying(64),
    assigned_at timestamp with time zone DEFAULT now() NOT NULL,
    unassigned_at timestamp with time zone,
    assigned_by_user_id uuid,
    assigned_by_service_identity_id uuid,
    unassigned_by_user_id uuid,
    unassigned_by_service_identity_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_device_assignments__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE device_assignments; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON TABLE sites.device_assignments IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN device_assignments.device_assignment_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.device_assignments.device_assignment_id IS 'Canonical identifier of the device assignment.';


--
-- Name: COLUMN device_assignments.site_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.device_assignments.site_id IS 'Site where the device is assigned.';


--
-- Name: COLUMN device_assignments.lane_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.device_assignments.lane_id IS 'Lane where the device is assigned, if lane-specific.';


--
-- Name: COLUMN device_assignments.gate_device_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.device_assignments.gate_device_id IS 'Gate device being assigned, where applicable.';


--
-- Name: COLUMN device_assignments.service_identity_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.device_assignments.service_identity_id IS 'Service or device principal associated with the assignment, where applicable.';


--
-- Name: COLUMN device_assignments.assignment_type; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.device_assignments.assignment_type IS 'Type of assignment.';


--
-- Name: COLUMN device_assignments.assignment_status; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.device_assignments.assignment_status IS 'Assignment lifecycle state.';


--
-- Name: COLUMN device_assignments.assignment_reason_code; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.device_assignments.assignment_reason_code IS 'Controlled assignment or reassignment reason.';


--
-- Name: COLUMN device_assignments.assigned_at; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.device_assignments.assigned_at IS 'Assignment start timestamp.';


--
-- Name: COLUMN device_assignments.unassigned_at; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.device_assignments.unassigned_at IS 'Assignment end timestamp.';


--
-- Name: COLUMN device_assignments.assigned_by_user_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.device_assignments.assigned_by_user_id IS 'User who assigned the device.';


--
-- Name: COLUMN device_assignments.assigned_by_service_identity_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.device_assignments.assigned_by_service_identity_id IS 'Service identity that assigned the device.';


--
-- Name: COLUMN device_assignments.unassigned_by_user_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.device_assignments.unassigned_by_user_id IS 'User who ended the assignment.';


--
-- Name: COLUMN device_assignments.unassigned_by_service_identity_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.device_assignments.unassigned_by_service_identity_id IS 'Service identity that ended the assignment.';


--
-- Name: COLUMN device_assignments.created_at; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.device_assignments.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN device_assignments.created_by_user_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.device_assignments.created_by_user_id IS 'User who created the record.';


--
-- Name: COLUMN device_assignments.created_by_service_identity_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.device_assignments.created_by_service_identity_id IS 'Service identity that created the record.';


--
-- Name: COLUMN device_assignments.updated_at; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.device_assignments.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN device_assignments.updated_by_user_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.device_assignments.updated_by_user_id IS 'User who last updated the record.';


--
-- Name: COLUMN device_assignments.updated_by_service_identity_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.device_assignments.updated_by_service_identity_id IS 'Service identity that last updated the record.';


--
-- Name: COLUMN device_assignments.row_version; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.device_assignments.row_version IS 'Optimistic concurrency version.';


--
-- Name: lanes; Type: TABLE; Schema: sites; Owner: -
--

CREATE TABLE sites.lanes (
    lane_id uuid DEFAULT gen_random_uuid() NOT NULL,
    site_id uuid NOT NULL,
    lane_code character varying(64) NOT NULL,
    lane_name character varying(128) NOT NULL,
    lane_description text,
    lane_type sites.lane_type_enum NOT NULL,
    lane_direction sites.lane_direction_enum NOT NULL,
    lane_status sites.lane_status_enum NOT NULL,
    display_order integer,
    effective_from timestamp with time zone NOT NULL,
    effective_to timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_lanes__display_order_non_negative CHECK (((display_order IS NULL) OR (display_order >= 0))),
    CONSTRAINT ck_lanes__effective_window CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT ck_lanes__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE lanes; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON TABLE sites.lanes IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN lanes.lane_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.lanes.lane_id IS 'Canonical identifier of the lane.';


--
-- Name: COLUMN lanes.site_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.lanes.site_id IS 'Parent site.';


--
-- Name: COLUMN lanes.lane_code; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.lanes.lane_code IS 'Stable internal lane code.';


--
-- Name: COLUMN lanes.lane_name; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.lanes.lane_name IS 'Human-readable lane name.';


--
-- Name: COLUMN lanes.lane_description; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.lanes.lane_description IS 'Lane description.';


--
-- Name: COLUMN lanes.lane_type; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.lanes.lane_type IS 'Lane purpose or physical classification.';


--
-- Name: COLUMN lanes.lane_direction; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.lanes.lane_direction IS 'Directional use of the lane.';


--
-- Name: COLUMN lanes.lane_status; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.lanes.lane_status IS 'Lane lifecycle or operational status.';


--
-- Name: COLUMN lanes.display_order; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.lanes.display_order IS 'Optional display order in UI or reports.';


--
-- Name: COLUMN lanes.effective_from; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.lanes.effective_from IS 'Start of lane effectiveness.';


--
-- Name: COLUMN lanes.effective_to; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.lanes.effective_to IS 'End of lane effectiveness.';


--
-- Name: COLUMN lanes.created_at; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.lanes.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN lanes.created_by_user_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.lanes.created_by_user_id IS 'User who created the lane.';


--
-- Name: COLUMN lanes.created_by_service_identity_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.lanes.created_by_service_identity_id IS 'Service identity that created the lane.';


--
-- Name: COLUMN lanes.updated_at; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.lanes.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN lanes.updated_by_user_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.lanes.updated_by_user_id IS 'User who last updated the lane.';


--
-- Name: COLUMN lanes.updated_by_service_identity_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.lanes.updated_by_service_identity_id IS 'Service identity that last updated the lane.';


--
-- Name: COLUMN lanes.row_version; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.lanes.row_version IS 'Optimistic concurrency version.';


--
-- Name: site_groups; Type: TABLE; Schema: sites; Owner: -
--

CREATE TABLE sites.site_groups (
    site_group_id uuid DEFAULT gen_random_uuid() NOT NULL,
    site_group_code character varying(64) NOT NULL,
    site_group_name character varying(128) NOT NULL,
    business_label character varying(64),
    description text,
    operator_entity_name character varying(128),
    timezone_name character varying(64) NOT NULL,
    default_currency_code character(3) NOT NULL,
    site_group_status sites.site_group_status_enum NOT NULL,
    public_lookup_enabled boolean DEFAULT false NOT NULL,
    default_payment_enabled boolean DEFAULT false NOT NULL,
    effective_from timestamp with time zone NOT NULL,
    effective_to timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_site_groups__effective_window CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT ck_site_groups__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE site_groups; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON TABLE sites.site_groups IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN site_groups.site_group_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.site_groups.site_group_id IS 'Canonical identifier of the site group.';


--
-- Name: COLUMN site_groups.site_group_code; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.site_groups.site_group_code IS 'Stable internal code for the site group.';


--
-- Name: COLUMN site_groups.site_group_name; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.site_groups.site_group_name IS 'Human-readable name.';


--
-- Name: COLUMN site_groups.business_label; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.site_groups.business_label IS 'Business-facing label such as PROPERTY, CLUSTER, or CAMPUS.';


--
-- Name: COLUMN site_groups.description; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.site_groups.description IS 'Description of the site group.';


--
-- Name: COLUMN site_groups.operator_entity_name; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.site_groups.operator_entity_name IS 'Parking operator or business entity name, where applicable.';


--
-- Name: COLUMN site_groups.timezone_name; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.site_groups.timezone_name IS 'IANA time zone used for local operational interpretation.';


--
-- Name: COLUMN site_groups.default_currency_code; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.site_groups.default_currency_code IS 'Default currency for the site group.';


--
-- Name: COLUMN site_groups.site_group_status; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.site_groups.site_group_status IS 'Site group lifecycle status.';


--
-- Name: COLUMN site_groups.public_lookup_enabled; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.site_groups.public_lookup_enabled IS 'Indicates whether public Web Pay lookup is enabled for this site group.';


--
-- Name: COLUMN site_groups.default_payment_enabled; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.site_groups.default_payment_enabled IS 'Indicates whether payment flow is enabled by default.';


--
-- Name: COLUMN site_groups.effective_from; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.site_groups.effective_from IS 'Start of site group effectiveness.';


--
-- Name: COLUMN site_groups.effective_to; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.site_groups.effective_to IS 'End of site group effectiveness.';


--
-- Name: COLUMN site_groups.created_at; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.site_groups.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN site_groups.created_by_user_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.site_groups.created_by_user_id IS 'User who created the site group.';


--
-- Name: COLUMN site_groups.created_by_service_identity_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.site_groups.created_by_service_identity_id IS 'Service identity that created the site group.';


--
-- Name: COLUMN site_groups.updated_at; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.site_groups.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN site_groups.updated_by_user_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.site_groups.updated_by_user_id IS 'User who last updated the site group.';


--
-- Name: COLUMN site_groups.updated_by_service_identity_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.site_groups.updated_by_service_identity_id IS 'Service identity that last updated the site group.';


--
-- Name: COLUMN site_groups.row_version; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.site_groups.row_version IS 'Optimistic concurrency version.';


--
-- Name: sites; Type: TABLE; Schema: sites; Owner: -
--

CREATE TABLE sites.sites (
    site_id uuid DEFAULT gen_random_uuid() NOT NULL,
    site_group_id uuid NOT NULL,
    site_code character varying(64) NOT NULL,
    site_name character varying(128) NOT NULL,
    site_description text,
    site_type sites.site_type_enum NOT NULL,
    timezone_name character varying(64) NOT NULL,
    address_line1 character varying(256),
    address_line2 character varying(256),
    city character varying(128),
    province character varying(128),
    country_code character(2) NOT NULL,
    lgu_code character varying(32),
    site_status sites.site_status_enum NOT NULL,
    public_lookup_enabled boolean DEFAULT false NOT NULL,
    payment_enabled boolean DEFAULT false NOT NULL,
    effective_from timestamp with time zone NOT NULL,
    effective_to timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_sites__effective_window CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT ck_sites__row_version_positive CHECK ((row_version > 0))
);


--
-- Name: TABLE sites; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON TABLE sites.sites IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';


--
-- Name: COLUMN sites.site_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.sites.site_id IS 'Canonical identifier of the site.';


--
-- Name: COLUMN sites.site_group_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.sites.site_group_id IS 'Parent site group.';


--
-- Name: COLUMN sites.site_code; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.sites.site_code IS 'Stable internal site code.';


--
-- Name: COLUMN sites.site_name; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.sites.site_name IS 'Human-readable site name.';


--
-- Name: COLUMN sites.site_description; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.sites.site_description IS 'Site description.';


--
-- Name: COLUMN sites.site_type; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.sites.site_type IS 'Site type or operational classification.';


--
-- Name: COLUMN sites.timezone_name; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.sites.timezone_name IS 'IANA time zone used for the site.';


--
-- Name: COLUMN sites.address_line1; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.sites.address_line1 IS 'Address line 1.';


--
-- Name: COLUMN sites.address_line2; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.sites.address_line2 IS 'Address line 2.';


--
-- Name: COLUMN sites.city; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.sites.city IS 'City or municipality.';


--
-- Name: COLUMN sites.province; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.sites.province IS 'Province or region.';


--
-- Name: COLUMN sites.country_code; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.sites.country_code IS 'Country code.';


--
-- Name: COLUMN sites.lgu_code; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.sites.lgu_code IS 'LGU or jurisdiction code for statutory discount policy applicability.';


--
-- Name: COLUMN sites.site_status; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.sites.site_status IS 'Site lifecycle status.';


--
-- Name: COLUMN sites.public_lookup_enabled; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.sites.public_lookup_enabled IS 'Indicates whether public lookup is enabled at site level.';


--
-- Name: COLUMN sites.payment_enabled; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.sites.payment_enabled IS 'Indicates whether payment flow is enabled at site level.';


--
-- Name: COLUMN sites.effective_from; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.sites.effective_from IS 'Start of site effectiveness.';


--
-- Name: COLUMN sites.effective_to; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.sites.effective_to IS 'End of site effectiveness.';


--
-- Name: COLUMN sites.created_at; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.sites.created_at IS 'Record creation timestamp.';


--
-- Name: COLUMN sites.created_by_user_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.sites.created_by_user_id IS 'User who created the site.';


--
-- Name: COLUMN sites.created_by_service_identity_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.sites.created_by_service_identity_id IS 'Service identity that created the site.';


--
-- Name: COLUMN sites.updated_at; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.sites.updated_at IS 'Last update timestamp.';


--
-- Name: COLUMN sites.updated_by_user_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.sites.updated_by_user_id IS 'User who last updated the site.';


--
-- Name: COLUMN sites.updated_by_service_identity_id; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.sites.updated_by_service_identity_id IS 'Service identity that last updated the site.';


--
-- Name: COLUMN sites.row_version; Type: COMMENT; Schema: sites; Owner: -
--

COMMENT ON COLUMN sites.sites.row_version IS 'Optimistic concurrency version.';


--
-- Name: audit_events pk_audit_events; Type: CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.audit_events
    ADD CONSTRAINT pk_audit_events PRIMARY KEY (audit_event_id);


--
-- Name: audit_trail_entries pk_audit_trail_entries; Type: CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.audit_trail_entries
    ADD CONSTRAINT pk_audit_trail_entries PRIMARY KEY (audit_trail_entry_id);


--
-- Name: evidence_links pk_evidence_links; Type: CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.evidence_links
    ADD CONSTRAINT pk_evidence_links PRIMARY KEY (evidence_link_id);


--
-- Name: security_events pk_security_events; Type: CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.security_events
    ADD CONSTRAINT pk_security_events PRIMARY KEY (security_event_id);


--
-- Name: controlled_code_sets pk_controlled_code_sets; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.controlled_code_sets
    ADD CONSTRAINT pk_controlled_code_sets PRIMARY KEY (controlled_code_set_id);


--
-- Name: feature_flags pk_feature_flags; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.feature_flags
    ADD CONSTRAINT pk_feature_flags PRIMARY KEY (feature_flag_id);


--
-- Name: rate_limit_policies pk_rate_limit_policies; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.rate_limit_policies
    ADD CONSTRAINT pk_rate_limit_policies PRIMARY KEY (rate_limit_policy_id);


--
-- Name: system_parameters pk_system_parameters; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.system_parameters
    ADD CONSTRAINT pk_system_parameters PRIMARY KEY (system_parameter_id);


--
-- Name: ttl_policies pk_ttl_policies; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.ttl_policies
    ADD CONSTRAINT pk_ttl_policies PRIMARY KEY (ttl_policy_id);


--
-- Name: controlled_code_sets uq_controlled_code_sets__set_value_domain; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.controlled_code_sets
    ADD CONSTRAINT uq_controlled_code_sets__set_value_domain UNIQUE (code_set_name, code_value, code_domain);


--
-- Name: rate_limit_policies uq_rate_limit_policies__policy_code; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.rate_limit_policies
    ADD CONSTRAINT uq_rate_limit_policies__policy_code UNIQUE (policy_code);


--
-- Name: system_parameters uq_system_parameters__parameter_code; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.system_parameters
    ADD CONSTRAINT uq_system_parameters__parameter_code UNIQUE (parameter_code);


--
-- Name: ttl_policies uq_ttl_policies__policy_code; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.ttl_policies
    ADD CONSTRAINT uq_ttl_policies__policy_code UNIQUE (policy_code);


--
-- Name: exit_authorizations pk_exit_authorizations; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.exit_authorizations
    ADD CONSTRAINT pk_exit_authorizations PRIMARY KEY (exit_authorization_id);


--
-- Name: parking_sessions pk_parking_sessions; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.parking_sessions
    ADD CONSTRAINT pk_parking_sessions PRIMARY KEY (parking_session_id);


--
-- Name: payment_attempts pk_payment_attempts; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.payment_attempts
    ADD CONSTRAINT pk_payment_attempts PRIMARY KEY (payment_attempt_id);


--
-- Name: payment_confirmations pk_payment_confirmations; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.payment_confirmations
    ADD CONSTRAINT pk_payment_confirmations PRIMARY KEY (payment_confirmation_id);


--
-- Name: tariff_snapshots pk_tariff_snapshots; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.tariff_snapshots
    ADD CONSTRAINT pk_tariff_snapshots PRIMARY KEY (tariff_snapshot_id);


--
-- Name: exit_authorizations uq_exit_authorizations__payment_attempt; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.exit_authorizations
    ADD CONSTRAINT uq_exit_authorizations__payment_attempt UNIQUE (payment_attempt_id);


--
-- Name: exit_authorizations uq_exit_authorizations__payment_confirmation; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.exit_authorizations
    ADD CONSTRAINT uq_exit_authorizations__payment_confirmation UNIQUE (payment_confirmation_id);


--
-- Name: exit_authorizations uq_exit_authorizations__token_hash; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.exit_authorizations
    ADD CONSTRAINT uq_exit_authorizations__token_hash UNIQUE (authorization_token_hash);


--
-- Name: payment_attempts uq_payment_attempts__idempotency_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.payment_attempts
    ADD CONSTRAINT uq_payment_attempts__idempotency_key UNIQUE (idempotency_key);


--
-- Name: payment_attempts uq_payment_attempts__tariff_snapshot; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.payment_attempts
    ADD CONSTRAINT uq_payment_attempts__tariff_snapshot UNIQUE (tariff_snapshot_id);


--
-- Name: payment_confirmations uq_payment_confirmations__payment_attempt; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.payment_confirmations
    ADD CONSTRAINT uq_payment_confirmations__payment_attempt UNIQUE (payment_attempt_id);


--
-- Name: coupon_applications pk_coupon_applications; Type: CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_applications
    ADD CONSTRAINT pk_coupon_applications PRIMARY KEY (coupon_application_id);


--
-- Name: coupon_rule_groups pk_coupon_rule_groups; Type: CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_rule_groups
    ADD CONSTRAINT pk_coupon_rule_groups PRIMARY KEY (coupon_rule_group_id);


--
-- Name: coupon_rules pk_coupon_rules; Type: CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_rules
    ADD CONSTRAINT pk_coupon_rules PRIMARY KEY (coupon_rule_id);


--
-- Name: coupons pk_coupons; Type: CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupons
    ADD CONSTRAINT pk_coupons PRIMARY KEY (coupon_id);


--
-- Name: coupon_applications uq_coupon_applications__idempotency_key; Type: CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_applications
    ADD CONSTRAINT uq_coupon_applications__idempotency_key UNIQUE (idempotency_key);


--
-- Name: coupon_rule_groups uq_coupon_rule_groups__coupon_rule_group_code; Type: CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_rule_groups
    ADD CONSTRAINT uq_coupon_rule_groups__coupon_rule_group_code UNIQUE (coupon_id, rule_group_code);


--
-- Name: coupon_rules uq_coupon_rules__group_rule_code; Type: CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_rules
    ADD CONSTRAINT uq_coupon_rules__group_rule_code UNIQUE (coupon_rule_group_id, rule_code);


--
-- Name: coupons uq_coupons__merchant_coupon_code; Type: CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupons
    ADD CONSTRAINT uq_coupons__merchant_coupon_code UNIQUE (merchant_id, coupon_code);


--
-- Name: discount_evidence_references pk_discount_evidence_references; Type: CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.discount_evidence_references
    ADD CONSTRAINT pk_discount_evidence_references PRIMARY KEY (discount_evidence_reference_id);


--
-- Name: discount_policy_references pk_discount_policy_references; Type: CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.discount_policy_references
    ADD CONSTRAINT pk_discount_policy_references PRIMARY KEY (discount_policy_reference_id);


--
-- Name: statutory_discount_validations pk_statutory_discount_validations; Type: CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.statutory_discount_validations
    ADD CONSTRAINT pk_statutory_discount_validations PRIMARY KEY (statutory_discount_validation_id);


--
-- Name: discount_policy_references uq_discount_policy_references__policy_code_version; Type: CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.discount_policy_references
    ADD CONSTRAINT uq_discount_policy_references__policy_code_version UNIQUE (policy_code, policy_version);


--
-- Name: consumer_checkpoints pk_consumer_checkpoints; Type: CONSTRAINT; Schema: events; Owner: -
--

ALTER TABLE ONLY events.consumer_checkpoints
    ADD CONSTRAINT pk_consumer_checkpoints PRIMARY KEY (consumer_checkpoint_id);


--
-- Name: dead_letter_records pk_dead_letter_records; Type: CONSTRAINT; Schema: events; Owner: -
--

ALTER TABLE ONLY events.dead_letter_records
    ADD CONSTRAINT pk_dead_letter_records PRIMARY KEY (dead_letter_record_id);


--
-- Name: domain_events pk_domain_events; Type: CONSTRAINT; Schema: events; Owner: -
--

ALTER TABLE ONLY events.domain_events
    ADD CONSTRAINT pk_domain_events PRIMARY KEY (domain_event_id);


--
-- Name: event_publications pk_event_publications; Type: CONSTRAINT; Schema: events; Owner: -
--

ALTER TABLE ONLY events.event_publications
    ADD CONSTRAINT pk_event_publications PRIMARY KEY (event_publication_id);


--
-- Name: outbox_events pk_outbox_events; Type: CONSTRAINT; Schema: events; Owner: -
--

ALTER TABLE ONLY events.outbox_events
    ADD CONSTRAINT pk_outbox_events PRIMARY KEY (outbox_event_id);


--
-- Name: event_publications uq_event_publications__outbox_attempt_number; Type: CONSTRAINT; Schema: events; Owner: -
--

ALTER TABLE ONLY events.event_publications
    ADD CONSTRAINT uq_event_publications__outbox_attempt_number UNIQUE (outbox_event_id, publication_attempt_number);


--
-- Name: gate_authorization_consumptions pk_gate_authorization_consumptions; Type: CONSTRAINT; Schema: gates; Owner: -
--

ALTER TABLE ONLY gates.gate_authorization_consumptions
    ADD CONSTRAINT pk_gate_authorization_consumptions PRIMARY KEY (gate_authorization_consumption_id);


--
-- Name: gate_devices pk_gate_devices; Type: CONSTRAINT; Schema: gates; Owner: -
--

ALTER TABLE ONLY gates.gate_devices
    ADD CONSTRAINT pk_gate_devices PRIMARY KEY (gate_device_id);


--
-- Name: gate_events pk_gate_events; Type: CONSTRAINT; Schema: gates; Owner: -
--

ALTER TABLE ONLY gates.gate_events
    ADD CONSTRAINT pk_gate_events PRIMARY KEY (gate_event_id);


--
-- Name: gate_heartbeats pk_gate_heartbeats; Type: CONSTRAINT; Schema: gates; Owner: -
--

ALTER TABLE ONLY gates.gate_heartbeats
    ADD CONSTRAINT pk_gate_heartbeats PRIMARY KEY (gate_heartbeat_id);


--
-- Name: gate_devices uq_gate_devices__site_device_code; Type: CONSTRAINT; Schema: gates; Owner: -
--

ALTER TABLE ONLY gates.gate_devices
    ADD CONSTRAINT uq_gate_devices__site_device_code UNIQUE (site_id, device_code);


--
-- Name: permissions pk_permissions; Type: CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.permissions
    ADD CONSTRAINT pk_permissions PRIMARY KEY (permission_id);


--
-- Name: role_permissions pk_role_permissions; Type: CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.role_permissions
    ADD CONSTRAINT pk_role_permissions PRIMARY KEY (role_permission_id);


--
-- Name: roles pk_roles; Type: CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.roles
    ADD CONSTRAINT pk_roles PRIMARY KEY (role_id);


--
-- Name: service_identities pk_service_identities; Type: CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.service_identities
    ADD CONSTRAINT pk_service_identities PRIMARY KEY (service_identity_id);


--
-- Name: user_roles pk_user_roles; Type: CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.user_roles
    ADD CONSTRAINT pk_user_roles PRIMARY KEY (user_role_id);


--
-- Name: users pk_users; Type: CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.users
    ADD CONSTRAINT pk_users PRIMARY KEY (user_id);


--
-- Name: permissions uq_permissions__permission_code; Type: CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.permissions
    ADD CONSTRAINT uq_permissions__permission_code UNIQUE (permission_code);


--
-- Name: roles uq_roles__role_code; Type: CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.roles
    ADD CONSTRAINT uq_roles__role_code UNIQUE (role_code);


--
-- Name: service_identities uq_service_identities__service_identity_code; Type: CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.service_identities
    ADD CONSTRAINT uq_service_identities__service_identity_code UNIQUE (service_identity_code);


--
-- Name: users uq_users__email_normalized; Type: CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.users
    ADD CONSTRAINT uq_users__email_normalized UNIQUE (email_normalized);


--
-- Name: users uq_users__username; Type: CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.users
    ADD CONSTRAINT uq_users__username UNIQUE (username);


--
-- Name: adapter_mappings pk_adapter_mappings; Type: CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.adapter_mappings
    ADD CONSTRAINT pk_adapter_mappings PRIMARY KEY (adapter_mapping_id);


--
-- Name: integration_credential_references pk_integration_credential_references; Type: CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.integration_credential_references
    ADD CONSTRAINT pk_integration_credential_references PRIMARY KEY (integration_credential_reference_id);


--
-- Name: integration_health_records pk_integration_health_records; Type: CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.integration_health_records
    ADD CONSTRAINT pk_integration_health_records PRIMARY KEY (integration_health_record_id);


--
-- Name: vendor_endpoints pk_vendor_endpoints; Type: CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.vendor_endpoints
    ADD CONSTRAINT pk_vendor_endpoints PRIMARY KEY (vendor_endpoint_id);


--
-- Name: vendor_systems pk_vendor_systems; Type: CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.vendor_systems
    ADD CONSTRAINT pk_vendor_systems PRIMARY KEY (vendor_system_id);


--
-- Name: integration_credential_references uq_integration_credential_references__vendor_credential_code; Type: CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.integration_credential_references
    ADD CONSTRAINT uq_integration_credential_references__vendor_credential_code UNIQUE (vendor_system_id, credential_code);


--
-- Name: vendor_endpoints uq_vendor_endpoints__vendor_endpoint_code; Type: CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.vendor_endpoints
    ADD CONSTRAINT uq_vendor_endpoints__vendor_endpoint_code UNIQUE (vendor_system_id, endpoint_code);


--
-- Name: vendor_systems uq_vendor_systems__vendor_code_environment; Type: CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.vendor_systems
    ADD CONSTRAINT uq_vendor_systems__vendor_code_environment UNIQUE (vendor_code, environment_code);


--
-- Name: merchant_site_scopes pk_merchant_site_scopes; Type: CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchant_site_scopes
    ADD CONSTRAINT pk_merchant_site_scopes PRIMARY KEY (merchant_site_scope_id);


--
-- Name: merchant_users pk_merchant_users; Type: CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchant_users
    ADD CONSTRAINT pk_merchant_users PRIMARY KEY (merchant_user_id);


--
-- Name: merchant_wallets pk_merchant_wallets; Type: CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchant_wallets
    ADD CONSTRAINT pk_merchant_wallets PRIMARY KEY (merchant_wallet_id);


--
-- Name: merchants pk_merchants; Type: CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchants
    ADD CONSTRAINT pk_merchants PRIMARY KEY (merchant_id);


--
-- Name: merchant_wallets uq_merchant_wallets__merchant_wallet_code; Type: CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchant_wallets
    ADD CONSTRAINT uq_merchant_wallets__merchant_wallet_code UNIQUE (merchant_id, wallet_code);


--
-- Name: merchants uq_merchants__merchant_code; Type: CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchants
    ADD CONSTRAINT uq_merchants__merchant_code UNIQUE (merchant_code);


--
-- Name: incident_records pk_incident_records; Type: CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.incident_records
    ADD CONSTRAINT pk_incident_records PRIMARY KEY (incident_record_id);


--
-- Name: manual_gate_logs pk_manual_gate_logs; Type: CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.manual_gate_logs
    ADD CONSTRAINT pk_manual_gate_logs PRIMARY KEY (manual_gate_log_id);


--
-- Name: operator_action_logs pk_operator_action_logs; Type: CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.operator_action_logs
    ADD CONSTRAINT pk_operator_action_logs PRIMARY KEY (operator_action_log_id);


--
-- Name: override_approvals pk_override_approvals; Type: CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.override_approvals
    ADD CONSTRAINT pk_override_approvals PRIMARY KEY (override_approval_id);


--
-- Name: override_requests pk_override_requests; Type: CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.override_requests
    ADD CONSTRAINT pk_override_requests PRIMARY KEY (override_request_id);


--
-- Name: incident_records uq_incident_records__site_group_incident_code; Type: CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.incident_records
    ADD CONSTRAINT uq_incident_records__site_group_incident_code UNIQUE (site_group_id, incident_code);


--
-- Name: override_approvals uq_override_approvals__request_sequence; Type: CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.override_approvals
    ADD CONSTRAINT uq_override_approvals__request_sequence UNIQUE (override_request_id, approval_sequence);


--
-- Name: payment_provider_routing_policies pk_payment_provider_routing_policies; Type: CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.payment_provider_routing_policies
    ADD CONSTRAINT pk_payment_provider_routing_policies PRIMARY KEY (payment_routing_policy_id);


--
-- Name: payment_rails pk_payment_rails; Type: CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.payment_rails
    ADD CONSTRAINT pk_payment_rails PRIMARY KEY (payment_rail_id);


--
-- Name: provider_callbacks pk_provider_callbacks; Type: CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.provider_callbacks
    ADD CONSTRAINT pk_provider_callbacks PRIMARY KEY (provider_callback_id);


--
-- Name: provider_outcomes pk_provider_outcomes; Type: CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.provider_outcomes
    ADD CONSTRAINT pk_provider_outcomes PRIMARY KEY (provider_outcome_id);


--
-- Name: provider_sessions pk_provider_sessions; Type: CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.provider_sessions
    ADD CONSTRAINT pk_provider_sessions PRIMARY KEY (provider_session_id);


--
-- Name: provider_status_queries pk_provider_status_queries; Type: CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.provider_status_queries
    ADD CONSTRAINT pk_provider_status_queries PRIMARY KEY (provider_status_query_id);


--
-- Name: payment_rails uq_payment_rails__rail_code; Type: CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.payment_rails
    ADD CONSTRAINT uq_payment_rails__rail_code UNIQUE (rail_code);


--
-- Name: provider_callbacks uq_provider_callbacks__payload_hash; Type: CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.provider_callbacks
    ADD CONSTRAINT uq_provider_callbacks__payload_hash UNIQUE (payment_rail_id, payload_hash);


--
-- Name: provider_sessions uq_provider_sessions__idempotency_key; Type: CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.provider_sessions
    ADD CONSTRAINT uq_provider_sessions__idempotency_key UNIQUE (idempotency_key);


--
-- Name: mops_transaction_records pk_mops_transaction_records; Type: CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.mops_transaction_records
    ADD CONSTRAINT pk_mops_transaction_records PRIMARY KEY (mops_transaction_record_id);


--
-- Name: reconciliation_exceptions pk_reconciliation_exceptions; Type: CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_exceptions
    ADD CONSTRAINT pk_reconciliation_exceptions PRIMARY KEY (reconciliation_exception_id);


--
-- Name: reconciliation_items pk_reconciliation_items; Type: CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_items
    ADD CONSTRAINT pk_reconciliation_items PRIMARY KEY (reconciliation_item_id);


--
-- Name: reconciliation_runs pk_reconciliation_runs; Type: CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_runs
    ADD CONSTRAINT pk_reconciliation_runs PRIMARY KEY (reconciliation_run_id);


--
-- Name: settlement_comparison_records pk_settlement_comparison_records; Type: CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.settlement_comparison_records
    ADD CONSTRAINT pk_settlement_comparison_records PRIMARY KEY (settlement_comparison_record_id);


--
-- Name: reconciliation_runs uq_reconciliation_runs__run_code; Type: CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_runs
    ADD CONSTRAINT uq_reconciliation_runs__run_code UNIQUE (run_code);


--
-- Name: session_identifier_indexes pk_session_identifier_indexes; Type: CONSTRAINT; Schema: sessions; Owner: -
--

ALTER TABLE ONLY sessions.session_identifier_indexes
    ADD CONSTRAINT pk_session_identifier_indexes PRIMARY KEY (session_identifier_index_id);


--
-- Name: session_lookup_cache pk_session_lookup_cache; Type: CONSTRAINT; Schema: sessions; Owner: -
--

ALTER TABLE ONLY sessions.session_lookup_cache
    ADD CONSTRAINT pk_session_lookup_cache PRIMARY KEY (session_lookup_cache_id);


--
-- Name: session_resolution_requests pk_session_resolution_requests; Type: CONSTRAINT; Schema: sessions; Owner: -
--

ALTER TABLE ONLY sessions.session_resolution_requests
    ADD CONSTRAINT pk_session_resolution_requests PRIMARY KEY (session_resolution_request_id);


--
-- Name: session_resolution_results pk_session_resolution_results; Type: CONSTRAINT; Schema: sessions; Owner: -
--

ALTER TABLE ONLY sessions.session_resolution_results
    ADD CONSTRAINT pk_session_resolution_results PRIMARY KEY (session_resolution_result_id);


--
-- Name: session_resolution_results uq_session_resolution_results__request; Type: CONSTRAINT; Schema: sessions; Owner: -
--

ALTER TABLE ONLY sessions.session_resolution_results
    ADD CONSTRAINT uq_session_resolution_results__request UNIQUE (session_resolution_request_id);


--
-- Name: device_assignments pk_device_assignments; Type: CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.device_assignments
    ADD CONSTRAINT pk_device_assignments PRIMARY KEY (device_assignment_id);


--
-- Name: lanes pk_lanes; Type: CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.lanes
    ADD CONSTRAINT pk_lanes PRIMARY KEY (lane_id);


--
-- Name: site_groups pk_site_groups; Type: CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.site_groups
    ADD CONSTRAINT pk_site_groups PRIMARY KEY (site_group_id);


--
-- Name: sites pk_sites; Type: CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.sites
    ADD CONSTRAINT pk_sites PRIMARY KEY (site_id);


--
-- Name: lanes uq_lanes__site_lane_code; Type: CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.lanes
    ADD CONSTRAINT uq_lanes__site_lane_code UNIQUE (site_id, lane_code);


--
-- Name: site_groups uq_site_groups__site_group_code; Type: CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.site_groups
    ADD CONSTRAINT uq_site_groups__site_group_code UNIQUE (site_group_code);


--
-- Name: sites uq_sites__site_group_site_code; Type: CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.sites
    ADD CONSTRAINT uq_sites__site_group_site_code UNIQUE (site_group_id, site_code);


--
-- Name: ix_audit_events__actor_service_identity_id; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_audit_events__actor_service_identity_id ON audit.audit_events USING btree (actor_service_identity_id);


--
-- Name: ix_audit_events__actor_user_id; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_audit_events__actor_user_id ON audit.audit_events USING btree (actor_user_id);


--
-- Name: ix_audit_events__causation_id; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_audit_events__causation_id ON audit.audit_events USING btree (causation_id) WHERE (causation_id IS NOT NULL);


--
-- Name: ix_audit_events__correlation_id; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_audit_events__correlation_id ON audit.audit_events USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_audit_events__created_by_service_identity_id; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_audit_events__created_by_service_identity_id ON audit.audit_events USING btree (created_by_service_identity_id);


--
-- Name: ix_audit_events__occurred_at; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_audit_events__occurred_at ON audit.audit_events USING btree (occurred_at);


--
-- Name: ix_audit_events__recorded_at; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_audit_events__recorded_at ON audit.audit_events USING btree (recorded_at);


--
-- Name: ix_audit_trail_entries__audit_event_id; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_audit_trail_entries__audit_event_id ON audit.audit_trail_entries USING btree (audit_event_id);


--
-- Name: ix_audit_trail_entries__changed_at; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_audit_trail_entries__changed_at ON audit.audit_trail_entries USING btree (changed_at);


--
-- Name: ix_audit_trail_entries__changed_by_service_identity_id; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_audit_trail_entries__changed_by_service_identity_id ON audit.audit_trail_entries USING btree (changed_by_service_identity_id);


--
-- Name: ix_audit_trail_entries__changed_by_user_id; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_audit_trail_entries__changed_by_user_id ON audit.audit_trail_entries USING btree (changed_by_user_id);


--
-- Name: ix_audit_trail_entries__correlation_id; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_audit_trail_entries__correlation_id ON audit.audit_trail_entries USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_audit_trail_entries__created_by_service_identity_id; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_audit_trail_entries__created_by_service_identity_id ON audit.audit_trail_entries USING btree (created_by_service_identity_id);


--
-- Name: ix_evidence_links__audit_event_id; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_evidence_links__audit_event_id ON audit.evidence_links USING btree (audit_event_id);


--
-- Name: ix_evidence_links__correlation_id; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_evidence_links__correlation_id ON audit.evidence_links USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_evidence_links__linked_by_service_identity_id; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_evidence_links__linked_by_service_identity_id ON audit.evidence_links USING btree (linked_by_service_identity_id);


--
-- Name: ix_evidence_links__linked_by_user_id; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_evidence_links__linked_by_user_id ON audit.evidence_links USING btree (linked_by_user_id);


--
-- Name: ix_evidence_links__purged_by_user_id; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_evidence_links__purged_by_user_id ON audit.evidence_links USING btree (purged_by_user_id);


--
-- Name: ix_evidence_links__retention_expires_at; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_evidence_links__retention_expires_at ON audit.evidence_links USING btree (retention_expires_at);


--
-- Name: ix_evidence_links__security_event_id; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_evidence_links__security_event_id ON audit.evidence_links USING btree (security_event_id);


--
-- Name: ix_security_events__actor_service_identity_id; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_security_events__actor_service_identity_id ON audit.security_events USING btree (actor_service_identity_id);


--
-- Name: ix_security_events__actor_user_id; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_security_events__actor_user_id ON audit.security_events USING btree (actor_user_id);


--
-- Name: ix_security_events__audit_event_id; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_security_events__audit_event_id ON audit.security_events USING btree (audit_event_id);


--
-- Name: ix_security_events__correlation_id; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_security_events__correlation_id ON audit.security_events USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_security_events__created_by_service_identity_id; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_security_events__created_by_service_identity_id ON audit.security_events USING btree (created_by_service_identity_id);


--
-- Name: ix_security_events__incident_record_id; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_security_events__incident_record_id ON audit.security_events USING btree (incident_record_id);


--
-- Name: ix_security_events__resolved_by_user_id; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_security_events__resolved_by_user_id ON audit.security_events USING btree (resolved_by_user_id);


--
-- Name: ix_controlled_code_sets__code_status; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX ix_controlled_code_sets__code_status ON config.controlled_code_sets USING btree (code_status);


--
-- Name: ix_feature_flags__merchant_id; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX ix_feature_flags__merchant_id ON config.feature_flags USING btree (merchant_id);


--
-- Name: ix_feature_flags__site_group_id; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX ix_feature_flags__site_group_id ON config.feature_flags USING btree (site_group_id);


--
-- Name: ix_feature_flags__site_id; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX ix_feature_flags__site_id ON config.feature_flags USING btree (site_id);


--
-- Name: ix_rate_limit_policies__policy_status; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX ix_rate_limit_policies__policy_status ON config.rate_limit_policies USING btree (policy_status);


--
-- Name: ix_system_parameters__approved_at; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX ix_system_parameters__approved_at ON config.system_parameters USING btree (approved_at);


--
-- Name: ix_system_parameters__parameter_status; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX ix_system_parameters__parameter_status ON config.system_parameters USING btree (parameter_status);


--
-- Name: ix_ttl_policies__policy_status; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX ix_ttl_policies__policy_status ON config.ttl_policies USING btree (policy_status);


--
-- Name: ux_feature_flags__scoped_flag; Type: INDEX; Schema: config; Owner: -
--

CREATE UNIQUE INDEX ux_feature_flags__scoped_flag ON config.feature_flags USING btree (flag_code, environment_code, COALESCE(site_group_id, '00000000-0000-0000-0000-000000000000'::uuid), COALESCE(site_id, '00000000-0000-0000-0000-000000000000'::uuid), COALESCE(merchant_id, '00000000-0000-0000-0000-000000000000'::uuid), COALESCE(payment_rail_id, '00000000-0000-0000-0000-000000000000'::uuid), COALESCE(service_identity_id, '00000000-0000-0000-0000-000000000000'::uuid));


--
-- Name: ix_exit_authorizations__authorization_status; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_exit_authorizations__authorization_status ON core.exit_authorizations USING btree (authorization_status);


--
-- Name: ix_exit_authorizations__correlation_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_exit_authorizations__correlation_id ON core.exit_authorizations USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_exit_authorizations__parking_session_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_exit_authorizations__parking_session_id ON core.exit_authorizations USING btree (parking_session_id);


--
-- Name: ix_exit_authorizations__payment_attempt_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_exit_authorizations__payment_attempt_id ON core.exit_authorizations USING btree (payment_attempt_id);


--
-- Name: ix_exit_authorizations__payment_confirmation_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_exit_authorizations__payment_confirmation_id ON core.exit_authorizations USING btree (payment_confirmation_id);


--
-- Name: ix_parking_sessions__correlation_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_parking_sessions__correlation_id ON core.parking_sessions USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_parking_sessions__site_group_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_parking_sessions__site_group_id ON core.parking_sessions USING btree (site_group_id);


--
-- Name: ix_parking_sessions__site_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_parking_sessions__site_id ON core.parking_sessions USING btree (site_id);


--
-- Name: ix_parking_sessions__vendor_session_status; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_parking_sessions__vendor_session_status ON core.parking_sessions USING btree (vendor_session_status);


--
-- Name: ix_parking_sessions__vendor_system_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_parking_sessions__vendor_system_id ON core.parking_sessions USING btree (vendor_system_id);


--
-- Name: ix_payment_attempts__attempt_status; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_payment_attempts__attempt_status ON core.payment_attempts USING btree (attempt_status);


--
-- Name: ix_payment_attempts__correlation_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_payment_attempts__correlation_id ON core.payment_attempts USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_payment_attempts__parking_session_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_payment_attempts__parking_session_id ON core.payment_attempts USING btree (parking_session_id);


--
-- Name: ix_payment_attempts__payment_rail_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_payment_attempts__payment_rail_id ON core.payment_attempts USING btree (payment_rail_id);


--
-- Name: ix_payment_attempts__tariff_snapshot_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_payment_attempts__tariff_snapshot_id ON core.payment_attempts USING btree (tariff_snapshot_id);


--
-- Name: ix_payment_confirmations__confirmation_status; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_payment_confirmations__confirmation_status ON core.payment_confirmations USING btree (confirmation_status);


--
-- Name: ix_payment_confirmations__correlation_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_payment_confirmations__correlation_id ON core.payment_confirmations USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_payment_confirmations__payment_attempt_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_payment_confirmations__payment_attempt_id ON core.payment_confirmations USING btree (payment_attempt_id);


--
-- Name: ix_payment_confirmations__payment_rail_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_payment_confirmations__payment_rail_id ON core.payment_confirmations USING btree (payment_rail_id);


--
-- Name: ix_payment_confirmations__provider_outcome_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_payment_confirmations__provider_outcome_id ON core.payment_confirmations USING btree (provider_outcome_id);


--
-- Name: ix_tariff_snapshots__correlation_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_tariff_snapshots__correlation_id ON core.tariff_snapshots USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_tariff_snapshots__parking_session_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_tariff_snapshots__parking_session_id ON core.tariff_snapshots USING btree (parking_session_id);


--
-- Name: ix_tariff_snapshots__statutory_discount_validation_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_tariff_snapshots__statutory_discount_validation_id ON core.tariff_snapshots USING btree (statutory_discount_validation_id);


--
-- Name: ix_tariff_snapshots__superseded_by_tariff_snapshot_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_tariff_snapshots__superseded_by_tariff_snapshot_id ON core.tariff_snapshots USING btree (superseded_by_tariff_snapshot_id);


--
-- Name: ix_tariff_snapshots__vendor_system_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_tariff_snapshots__vendor_system_id ON core.tariff_snapshots USING btree (vendor_system_id);


--
-- Name: ux_exit_authorizations__active_by_session; Type: INDEX; Schema: core; Owner: -
--

CREATE UNIQUE INDEX ux_exit_authorizations__active_by_session ON core.exit_authorizations USING btree (parking_session_id) WHERE (authorization_status = 'ISSUED'::core.exit_authorization_status_enum);


--
-- Name: ux_payment_attempts__active_by_session; Type: INDEX; Schema: core; Owner: -
--

CREATE UNIQUE INDEX ux_payment_attempts__active_by_session ON core.payment_attempts USING btree (parking_session_id) WHERE (attempt_status = ANY (ARRAY['REQUESTED'::core.payment_attempt_status_enum, 'PENDING_PROVIDER'::core.payment_attempt_status_enum, 'PENDING_FINALIZATION'::core.payment_attempt_status_enum]));


--
-- Name: ux_payment_confirmations__provider_outcome; Type: INDEX; Schema: core; Owner: -
--

CREATE UNIQUE INDEX ux_payment_confirmations__provider_outcome ON core.payment_confirmations USING btree (provider_outcome_id) WHERE (provider_outcome_id IS NOT NULL);


--
-- Name: ux_payment_confirmations__provider_transaction_ref; Type: INDEX; Schema: core; Owner: -
--

CREATE UNIQUE INDEX ux_payment_confirmations__provider_transaction_ref ON core.payment_confirmations USING btree (payment_rail_id, provider_transaction_ref) WHERE (provider_transaction_ref IS NOT NULL);


--
-- Name: ux_tariff_snapshots__active_by_session; Type: INDEX; Schema: core; Owner: -
--

CREATE UNIQUE INDEX ux_tariff_snapshots__active_by_session ON core.tariff_snapshots USING btree (parking_session_id) WHERE (snapshot_status = 'ACTIVE'::core.tariff_snapshot_status_enum);


--
-- Name: ux_tariff_snapshots__superseded_by; Type: INDEX; Schema: core; Owner: -
--

CREATE UNIQUE INDEX ux_tariff_snapshots__superseded_by ON core.tariff_snapshots USING btree (superseded_by_tariff_snapshot_id) WHERE (superseded_by_tariff_snapshot_id IS NOT NULL);


--
-- Name: ix_coupon_applications__correlation_id; Type: INDEX; Schema: coupons; Owner: -
--

CREATE INDEX ix_coupon_applications__correlation_id ON coupons.coupon_applications USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_coupon_applications__coupon_id; Type: INDEX; Schema: coupons; Owner: -
--

CREATE INDEX ix_coupon_applications__coupon_id ON coupons.coupon_applications USING btree (coupon_id);


--
-- Name: ix_coupon_applications__merchant_id; Type: INDEX; Schema: coupons; Owner: -
--

CREATE INDEX ix_coupon_applications__merchant_id ON coupons.coupon_applications USING btree (merchant_id);


--
-- Name: ix_coupon_applications__merchant_wallet_id; Type: INDEX; Schema: coupons; Owner: -
--

CREATE INDEX ix_coupon_applications__merchant_wallet_id ON coupons.coupon_applications USING btree (merchant_wallet_id);


--
-- Name: ix_coupon_applications__parking_session_id; Type: INDEX; Schema: coupons; Owner: -
--

CREATE INDEX ix_coupon_applications__parking_session_id ON coupons.coupon_applications USING btree (parking_session_id);


--
-- Name: ix_coupon_rule_groups__coupon_id; Type: INDEX; Schema: coupons; Owner: -
--

CREATE INDEX ix_coupon_rule_groups__coupon_id ON coupons.coupon_rule_groups USING btree (coupon_id);


--
-- Name: ix_coupon_rule_groups__rule_group_status; Type: INDEX; Schema: coupons; Owner: -
--

CREATE INDEX ix_coupon_rule_groups__rule_group_status ON coupons.coupon_rule_groups USING btree (rule_group_status);


--
-- Name: ix_coupon_rules__coupon_rule_group_id; Type: INDEX; Schema: coupons; Owner: -
--

CREATE INDEX ix_coupon_rules__coupon_rule_group_id ON coupons.coupon_rules USING btree (coupon_rule_group_id);


--
-- Name: ix_coupon_rules__site_group_id; Type: INDEX; Schema: coupons; Owner: -
--

CREATE INDEX ix_coupon_rules__site_group_id ON coupons.coupon_rules USING btree (site_group_id);


--
-- Name: ix_coupon_rules__site_id; Type: INDEX; Schema: coupons; Owner: -
--

CREATE INDEX ix_coupon_rules__site_id ON coupons.coupon_rules USING btree (site_id);


--
-- Name: ix_coupons__coupon_status; Type: INDEX; Schema: coupons; Owner: -
--

CREATE INDEX ix_coupons__coupon_status ON coupons.coupons USING btree (coupon_status);


--
-- Name: ix_coupons__merchant_id; Type: INDEX; Schema: coupons; Owner: -
--

CREATE INDEX ix_coupons__merchant_id ON coupons.coupons USING btree (merchant_id);


--
-- Name: ux_coupon_applications__active_merchant_session; Type: INDEX; Schema: coupons; Owner: -
--

CREATE UNIQUE INDEX ux_coupon_applications__active_merchant_session ON coupons.coupon_applications USING btree (merchant_id, parking_session_id) WHERE (application_status = ANY (ARRAY['REQUESTED'::coupons.coupon_application_status_enum, 'RESERVED'::coupons.coupon_application_status_enum, 'APPLIED'::coupons.coupon_application_status_enum]));


--
-- Name: ux_coupon_applications__reservation_ref; Type: INDEX; Schema: coupons; Owner: -
--

CREATE UNIQUE INDEX ux_coupon_applications__reservation_ref ON coupons.coupon_applications USING btree (reservation_ref) WHERE (reservation_ref IS NOT NULL);


--
-- Name: ix_discount_evidence_references__correlation_id; Type: INDEX; Schema: discounts; Owner: -
--

CREATE INDEX ix_discount_evidence_references__correlation_id ON discounts.discount_evidence_references USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_discount_evidence_references__evidence_capture_status; Type: INDEX; Schema: discounts; Owner: -
--

CREATE INDEX ix_discount_evidence_references__evidence_capture_status ON discounts.discount_evidence_references USING btree (evidence_capture_status);


--
-- Name: ix_discount_evidence_references__redaction_status; Type: INDEX; Schema: discounts; Owner: -
--

CREATE INDEX ix_discount_evidence_references__redaction_status ON discounts.discount_evidence_references USING btree (redaction_status);


--
-- Name: ix_discount_evidence_references__retention_expires_at; Type: INDEX; Schema: discounts; Owner: -
--

CREATE INDEX ix_discount_evidence_references__retention_expires_at ON discounts.discount_evidence_references USING btree (retention_expires_at);


--
-- Name: ix_discount_evidence_references__statutory_discount_validati; Type: INDEX; Schema: discounts; Owner: -
--

CREATE INDEX ix_discount_evidence_references__statutory_discount_validati ON discounts.discount_evidence_references USING btree (statutory_discount_validation_id);


--
-- Name: ix_discount_policy_references__parent_policy_reference_id; Type: INDEX; Schema: discounts; Owner: -
--

CREATE INDEX ix_discount_policy_references__parent_policy_reference_id ON discounts.discount_policy_references USING btree (parent_policy_reference_id);


--
-- Name: ix_discount_policy_references__site_group_id; Type: INDEX; Schema: discounts; Owner: -
--

CREATE INDEX ix_discount_policy_references__site_group_id ON discounts.discount_policy_references USING btree (site_group_id);


--
-- Name: ix_discount_policy_references__site_id; Type: INDEX; Schema: discounts; Owner: -
--

CREATE INDEX ix_discount_policy_references__site_id ON discounts.discount_policy_references USING btree (site_id);


--
-- Name: ix_statutory_discount_validations__applied_policy_reference_; Type: INDEX; Schema: discounts; Owner: -
--

CREATE INDEX ix_statutory_discount_validations__applied_policy_reference_ ON discounts.statutory_discount_validations USING btree (applied_policy_reference_id);


--
-- Name: ix_statutory_discount_validations__correlation_id; Type: INDEX; Schema: discounts; Owner: -
--

CREATE INDEX ix_statutory_discount_validations__correlation_id ON discounts.statutory_discount_validations USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_statutory_discount_validations__fallback_policy_reference; Type: INDEX; Schema: discounts; Owner: -
--

CREATE INDEX ix_statutory_discount_validations__fallback_policy_reference ON discounts.statutory_discount_validations USING btree (fallback_policy_reference_id);


--
-- Name: ix_statutory_discount_validations__parking_session_id; Type: INDEX; Schema: discounts; Owner: -
--

CREATE INDEX ix_statutory_discount_validations__parking_session_id ON discounts.statutory_discount_validations USING btree (parking_session_id);


--
-- Name: ix_statutory_discount_validations__tariff_snapshot_id; Type: INDEX; Schema: discounts; Owner: -
--

CREATE INDEX ix_statutory_discount_validations__tariff_snapshot_id ON discounts.statutory_discount_validations USING btree (tariff_snapshot_id);


--
-- Name: ux_discount_evidence_references__evidence_hash; Type: INDEX; Schema: discounts; Owner: -
--

CREATE UNIQUE INDEX ux_discount_evidence_references__evidence_hash ON discounts.discount_evidence_references USING btree (evidence_hash) WHERE (evidence_hash IS NOT NULL);


--
-- Name: ux_discount_policy_references__active_local_policy; Type: INDEX; Schema: discounts; Owner: -
--

CREATE UNIQUE INDEX ux_discount_policy_references__active_local_policy ON discounts.discount_policy_references USING btree (entitlement_type, lgu_code, site_group_id, site_id, policy_level, policy_version) WHERE ((policy_status = 'ACTIVE'::discounts.discount_policy_status_enum) AND (lgu_code IS NOT NULL));


--
-- Name: ux_statutory_discount_validations__active_session_entitlement; Type: INDEX; Schema: discounts; Owner: -
--

CREATE UNIQUE INDEX ux_statutory_discount_validations__active_session_entitlement ON discounts.statutory_discount_validations USING btree (parking_session_id, entitlement_type) WHERE (validation_status = ANY (ARRAY['REQUESTED'::discounts.statutory_discount_validations_status_enum, 'PENDING_OPERATOR_REVIEW'::discounts.statutory_discount_validations_status_enum, 'APPROVED'::discounts.statutory_discount_validations_status_enum]));


--
-- Name: ix_consumer_checkpoints__checkpoint_status; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_consumer_checkpoints__checkpoint_status ON events.consumer_checkpoints USING btree (checkpoint_status);


--
-- Name: ix_consumer_checkpoints__correlation_id; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_consumer_checkpoints__correlation_id ON events.consumer_checkpoints USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_consumer_checkpoints__last_domain_event_id; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_consumer_checkpoints__last_domain_event_id ON events.consumer_checkpoints USING btree (last_domain_event_id);


--
-- Name: ix_consumer_checkpoints__last_outbox_event_id; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_consumer_checkpoints__last_outbox_event_id ON events.consumer_checkpoints USING btree (last_outbox_event_id);


--
-- Name: ix_consumer_checkpoints__last_processed_at; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_consumer_checkpoints__last_processed_at ON events.consumer_checkpoints USING btree (last_processed_at);


--
-- Name: ix_dead_letter_records__correlation_id; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_dead_letter_records__correlation_id ON events.dead_letter_records USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_dead_letter_records__dead_letter_status; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_dead_letter_records__dead_letter_status ON events.dead_letter_records USING btree (dead_letter_status);


--
-- Name: ix_dead_letter_records__dead_lettered_at; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_dead_letter_records__dead_lettered_at ON events.dead_letter_records USING btree (dead_lettered_at);


--
-- Name: ix_dead_letter_records__event_publication_id; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_dead_letter_records__event_publication_id ON events.dead_letter_records USING btree (event_publication_id);


--
-- Name: ix_dead_letter_records__outbox_event_id; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_dead_letter_records__outbox_event_id ON events.dead_letter_records USING btree (outbox_event_id);


--
-- Name: ix_dead_letter_records__replay_requested_at; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_dead_letter_records__replay_requested_at ON events.dead_letter_records USING btree (replay_requested_at);


--
-- Name: ix_dead_letter_records__resolved_at; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_dead_letter_records__resolved_at ON events.dead_letter_records USING btree (resolved_at);


--
-- Name: ix_domain_events__actor_service_identity_id; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_domain_events__actor_service_identity_id ON events.domain_events USING btree (actor_service_identity_id);


--
-- Name: ix_domain_events__actor_user_id; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_domain_events__actor_user_id ON events.domain_events USING btree (actor_user_id);


--
-- Name: ix_domain_events__causation_id; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_domain_events__causation_id ON events.domain_events USING btree (causation_id) WHERE (causation_id IS NOT NULL);


--
-- Name: ix_domain_events__correlation_id; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_domain_events__correlation_id ON events.domain_events USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_domain_events__event_status; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_domain_events__event_status ON events.domain_events USING btree (event_status);


--
-- Name: ix_event_publications__completed_at; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_event_publications__completed_at ON events.event_publications USING btree (completed_at);


--
-- Name: ix_event_publications__correlation_id; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_event_publications__correlation_id ON events.event_publications USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_event_publications__outbox_event_id; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_event_publications__outbox_event_id ON events.event_publications USING btree (outbox_event_id);


--
-- Name: ix_event_publications__publication_status; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_event_publications__publication_status ON events.event_publications USING btree (publication_status);


--
-- Name: ix_event_publications__started_at; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_event_publications__started_at ON events.event_publications USING btree (started_at);


--
-- Name: ix_outbox_events__available_at; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_outbox_events__available_at ON events.outbox_events USING btree (available_at);


--
-- Name: ix_outbox_events__causation_id; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_outbox_events__causation_id ON events.outbox_events USING btree (causation_id) WHERE (causation_id IS NOT NULL);


--
-- Name: ix_outbox_events__correlation_id; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_outbox_events__correlation_id ON events.outbox_events USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_outbox_events__domain_event_id; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_outbox_events__domain_event_id ON events.outbox_events USING btree (domain_event_id);


--
-- Name: ix_outbox_events__next_retry_at; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_outbox_events__next_retry_at ON events.outbox_events USING btree (next_retry_at);


--
-- Name: ix_outbox_events__publication_status; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_outbox_events__publication_status ON events.outbox_events USING btree (publication_status);


--
-- Name: ix_outbox_events__published_at; Type: INDEX; Schema: events; Owner: -
--

CREATE INDEX ix_outbox_events__published_at ON events.outbox_events USING btree (published_at);


--
-- Name: ux_consumer_checkpoints__consumer_scope; Type: INDEX; Schema: events; Owner: -
--

CREATE UNIQUE INDEX ux_consumer_checkpoints__consumer_scope ON events.consumer_checkpoints USING btree (consumer_name, COALESCE(consumer_group, ''::character varying), COALESCE(subscription_name, ''::character varying), COALESCE(event_type, ''::character varying), COALESCE(aggregate_type, ''::character varying));


--
-- Name: ux_outbox_events__domain_event; Type: INDEX; Schema: events; Owner: -
--

CREATE UNIQUE INDEX ux_outbox_events__domain_event ON events.outbox_events USING btree (domain_event_id) WHERE (domain_event_id IS NOT NULL);


--
-- Name: ix_gate_authorization_consumptions__command_result_status; Type: INDEX; Schema: gates; Owner: -
--

CREATE INDEX ix_gate_authorization_consumptions__command_result_status ON gates.gate_authorization_consumptions USING btree (command_result_status);


--
-- Name: ix_gate_authorization_consumptions__consume_status; Type: INDEX; Schema: gates; Owner: -
--

CREATE INDEX ix_gate_authorization_consumptions__consume_status ON gates.gate_authorization_consumptions USING btree (consume_status);


--
-- Name: ix_gate_authorization_consumptions__correlation_id; Type: INDEX; Schema: gates; Owner: -
--

CREATE INDEX ix_gate_authorization_consumptions__correlation_id ON gates.gate_authorization_consumptions USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_gate_authorization_consumptions__exit_authorization_id; Type: INDEX; Schema: gates; Owner: -
--

CREATE INDEX ix_gate_authorization_consumptions__exit_authorization_id ON gates.gate_authorization_consumptions USING btree (exit_authorization_id);


--
-- Name: ix_gate_authorization_consumptions__gate_device_id; Type: INDEX; Schema: gates; Owner: -
--

CREATE INDEX ix_gate_authorization_consumptions__gate_device_id ON gates.gate_authorization_consumptions USING btree (gate_device_id);


--
-- Name: ix_gate_authorization_consumptions__lane_id; Type: INDEX; Schema: gates; Owner: -
--

CREATE INDEX ix_gate_authorization_consumptions__lane_id ON gates.gate_authorization_consumptions USING btree (lane_id);


--
-- Name: ix_gate_authorization_consumptions__site_id; Type: INDEX; Schema: gates; Owner: -
--

CREATE INDEX ix_gate_authorization_consumptions__site_id ON gates.gate_authorization_consumptions USING btree (site_id);


--
-- Name: ix_gate_devices__lane_id; Type: INDEX; Schema: gates; Owner: -
--

CREATE INDEX ix_gate_devices__lane_id ON gates.gate_devices USING btree (lane_id);


--
-- Name: ix_gate_devices__service_identity_id; Type: INDEX; Schema: gates; Owner: -
--

CREATE INDEX ix_gate_devices__service_identity_id ON gates.gate_devices USING btree (service_identity_id);


--
-- Name: ix_gate_devices__site_id; Type: INDEX; Schema: gates; Owner: -
--

CREATE INDEX ix_gate_devices__site_id ON gates.gate_devices USING btree (site_id);


--
-- Name: ix_gate_events__correlation_id; Type: INDEX; Schema: gates; Owner: -
--

CREATE INDEX ix_gate_events__correlation_id ON gates.gate_events USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_gate_events__event_status; Type: INDEX; Schema: gates; Owner: -
--

CREATE INDEX ix_gate_events__event_status ON gates.gate_events USING btree (event_status);


--
-- Name: ix_gate_events__exit_authorization_id; Type: INDEX; Schema: gates; Owner: -
--

CREATE INDEX ix_gate_events__exit_authorization_id ON gates.gate_events USING btree (exit_authorization_id);


--
-- Name: ix_gate_events__gate_device_id; Type: INDEX; Schema: gates; Owner: -
--

CREATE INDEX ix_gate_events__gate_device_id ON gates.gate_events USING btree (gate_device_id);


--
-- Name: ix_gate_events__lane_id; Type: INDEX; Schema: gates; Owner: -
--

CREATE INDEX ix_gate_events__lane_id ON gates.gate_events USING btree (lane_id);


--
-- Name: ix_gate_events__occurred_at; Type: INDEX; Schema: gates; Owner: -
--

CREATE INDEX ix_gate_events__occurred_at ON gates.gate_events USING btree (occurred_at);


--
-- Name: ix_gate_events__site_id; Type: INDEX; Schema: gates; Owner: -
--

CREATE INDEX ix_gate_events__site_id ON gates.gate_events USING btree (site_id);


--
-- Name: ix_gate_heartbeats__correlation_id; Type: INDEX; Schema: gates; Owner: -
--

CREATE INDEX ix_gate_heartbeats__correlation_id ON gates.gate_heartbeats USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_gate_heartbeats__device_reported_status; Type: INDEX; Schema: gates; Owner: -
--

CREATE INDEX ix_gate_heartbeats__device_reported_status ON gates.gate_heartbeats USING btree (device_reported_status);


--
-- Name: ix_gate_heartbeats__gate_device_id; Type: INDEX; Schema: gates; Owner: -
--

CREATE INDEX ix_gate_heartbeats__gate_device_id ON gates.gate_heartbeats USING btree (gate_device_id);


--
-- Name: ix_gate_heartbeats__heartbeat_status; Type: INDEX; Schema: gates; Owner: -
--

CREATE INDEX ix_gate_heartbeats__heartbeat_status ON gates.gate_heartbeats USING btree (heartbeat_status);


--
-- Name: ix_gate_heartbeats__lane_id; Type: INDEX; Schema: gates; Owner: -
--

CREATE INDEX ix_gate_heartbeats__lane_id ON gates.gate_heartbeats USING btree (lane_id);


--
-- Name: ix_gate_heartbeats__observed_at; Type: INDEX; Schema: gates; Owner: -
--

CREATE INDEX ix_gate_heartbeats__observed_at ON gates.gate_heartbeats USING btree (observed_at);


--
-- Name: ix_gate_heartbeats__site_id; Type: INDEX; Schema: gates; Owner: -
--

CREATE INDEX ix_gate_heartbeats__site_id ON gates.gate_heartbeats USING btree (site_id);


--
-- Name: ux_gate_auth_consumptions__successful_exit_auth; Type: INDEX; Schema: gates; Owner: -
--

CREATE UNIQUE INDEX ux_gate_auth_consumptions__successful_exit_auth ON gates.gate_authorization_consumptions USING btree (exit_authorization_id) WHERE (consume_status = 'CONSUMED'::gates.gate_authorization_consumption_status_enum);


--
-- Name: ux_gate_devices__serial_number; Type: INDEX; Schema: gates; Owner: -
--

CREATE UNIQUE INDEX ux_gate_devices__serial_number ON gates.gate_devices USING btree (serial_number) WHERE (serial_number IS NOT NULL);


--
-- Name: ux_gate_devices__service_identity; Type: INDEX; Schema: gates; Owner: -
--

CREATE UNIQUE INDEX ux_gate_devices__service_identity ON gates.gate_devices USING btree (service_identity_id) WHERE (service_identity_id IS NOT NULL);


--
-- Name: ux_gate_devices__vendor_device_ref; Type: INDEX; Schema: gates; Owner: -
--

CREATE UNIQUE INDEX ux_gate_devices__vendor_device_ref ON gates.gate_devices USING btree (site_id, vendor_device_ref) WHERE (vendor_device_ref IS NOT NULL);


--
-- Name: ix_permissions__permission_status; Type: INDEX; Schema: identity; Owner: -
--

CREATE INDEX ix_permissions__permission_status ON identity.permissions USING btree (permission_status);


--
-- Name: ix_role_permissions__assigned_by_user_id; Type: INDEX; Schema: identity; Owner: -
--

CREATE INDEX ix_role_permissions__assigned_by_user_id ON identity.role_permissions USING btree (assigned_by_user_id);


--
-- Name: ix_role_permissions__permission_id; Type: INDEX; Schema: identity; Owner: -
--

CREATE INDEX ix_role_permissions__permission_id ON identity.role_permissions USING btree (permission_id);


--
-- Name: ix_role_permissions__role_id; Type: INDEX; Schema: identity; Owner: -
--

CREATE INDEX ix_role_permissions__role_id ON identity.role_permissions USING btree (role_id);


--
-- Name: ix_roles__role_status; Type: INDEX; Schema: identity; Owner: -
--

CREATE INDEX ix_roles__role_status ON identity.roles USING btree (role_status);


--
-- Name: ix_service_identities__credential_expires_at; Type: INDEX; Schema: identity; Owner: -
--

CREATE INDEX ix_service_identities__credential_expires_at ON identity.service_identities USING btree (credential_expires_at);


--
-- Name: ix_service_identities__identity_status; Type: INDEX; Schema: identity; Owner: -
--

CREATE INDEX ix_service_identities__identity_status ON identity.service_identities USING btree (identity_status);


--
-- Name: ix_service_identities__last_rotated_at; Type: INDEX; Schema: identity; Owner: -
--

CREATE INDEX ix_service_identities__last_rotated_at ON identity.service_identities USING btree (last_rotated_at);


--
-- Name: ix_user_roles__assigned_by_user_id; Type: INDEX; Schema: identity; Owner: -
--

CREATE INDEX ix_user_roles__assigned_by_user_id ON identity.user_roles USING btree (assigned_by_user_id);


--
-- Name: ix_user_roles__role_id; Type: INDEX; Schema: identity; Owner: -
--

CREATE INDEX ix_user_roles__role_id ON identity.user_roles USING btree (role_id);


--
-- Name: ix_user_roles__user_id; Type: INDEX; Schema: identity; Owner: -
--

CREATE INDEX ix_user_roles__user_id ON identity.user_roles USING btree (user_id);


--
-- Name: ix_users__last_login_at; Type: INDEX; Schema: identity; Owner: -
--

CREATE INDEX ix_users__last_login_at ON identity.users USING btree (last_login_at);


--
-- Name: ix_users__locked_at; Type: INDEX; Schema: identity; Owner: -
--

CREATE INDEX ix_users__locked_at ON identity.users USING btree (locked_at);


--
-- Name: ix_users__user_status; Type: INDEX; Schema: identity; Owner: -
--

CREATE INDEX ix_users__user_status ON identity.users USING btree (user_status);


--
-- Name: ux_role_permissions__active_role_permission; Type: INDEX; Schema: identity; Owner: -
--

CREATE UNIQUE INDEX ux_role_permissions__active_role_permission ON identity.role_permissions USING btree (role_id, permission_id) WHERE (binding_status = 'ACTIVE'::identity.role_permission_binding_status_enum);


--
-- Name: ux_user_roles__active_user_role; Type: INDEX; Schema: identity; Owner: -
--

CREATE UNIQUE INDEX ux_user_roles__active_user_role ON identity.user_roles USING btree (user_id, role_id) WHERE (assignment_status = 'ACTIVE'::identity.user_role_assignment_status_enum);


--
-- Name: ix_adapter_mappings__gate_device_id; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX ix_adapter_mappings__gate_device_id ON integration.adapter_mappings USING btree (gate_device_id);


--
-- Name: ix_adapter_mappings__lane_id; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX ix_adapter_mappings__lane_id ON integration.adapter_mappings USING btree (lane_id);


--
-- Name: ix_adapter_mappings__site_group_id; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX ix_adapter_mappings__site_group_id ON integration.adapter_mappings USING btree (site_group_id);


--
-- Name: ix_adapter_mappings__site_id; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX ix_adapter_mappings__site_id ON integration.adapter_mappings USING btree (site_id);


--
-- Name: ix_adapter_mappings__vendor_system_id; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX ix_adapter_mappings__vendor_system_id ON integration.adapter_mappings USING btree (vendor_system_id);


--
-- Name: ix_integration_credential_references__credential_status; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX ix_integration_credential_references__credential_status ON integration.integration_credential_references USING btree (credential_status);


--
-- Name: ix_integration_credential_references__last_rotated_at; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX ix_integration_credential_references__last_rotated_at ON integration.integration_credential_references USING btree (last_rotated_at);


--
-- Name: ix_integration_credential_references__next_rotation_due_at; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX ix_integration_credential_references__next_rotation_due_at ON integration.integration_credential_references USING btree (next_rotation_due_at);


--
-- Name: ix_integration_credential_references__service_identity_id; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX ix_integration_credential_references__service_identity_id ON integration.integration_credential_references USING btree (service_identity_id);


--
-- Name: ix_integration_credential_references__vendor_system_id; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX ix_integration_credential_references__vendor_system_id ON integration.integration_credential_references USING btree (vendor_system_id);


--
-- Name: ix_integration_health_records__correlation_id; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX ix_integration_health_records__correlation_id ON integration.integration_health_records USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_integration_health_records__site_group_id; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX ix_integration_health_records__site_group_id ON integration.integration_health_records USING btree (site_group_id);


--
-- Name: ix_integration_health_records__site_id; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX ix_integration_health_records__site_id ON integration.integration_health_records USING btree (site_id);


--
-- Name: ix_integration_health_records__vendor_endpoint_id; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX ix_integration_health_records__vendor_endpoint_id ON integration.integration_health_records USING btree (vendor_endpoint_id);


--
-- Name: ix_integration_health_records__vendor_system_id; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX ix_integration_health_records__vendor_system_id ON integration.integration_health_records USING btree (vendor_system_id);


--
-- Name: ix_vendor_endpoints__credential_reference_id; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX ix_vendor_endpoints__credential_reference_id ON integration.vendor_endpoints USING btree (credential_reference_id);


--
-- Name: ix_vendor_endpoints__endpoint_status; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX ix_vendor_endpoints__endpoint_status ON integration.vendor_endpoints USING btree (endpoint_status);


--
-- Name: ix_vendor_endpoints__vendor_system_id; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX ix_vendor_endpoints__vendor_system_id ON integration.vendor_endpoints USING btree (vendor_system_id);


--
-- Name: ix_vendor_systems__vendor_system_status; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX ix_vendor_systems__vendor_system_status ON integration.vendor_systems USING btree (vendor_system_status);


--
-- Name: ux_adapter_mappings__vendor_object_active; Type: INDEX; Schema: integration; Owner: -
--

CREATE UNIQUE INDEX ux_adapter_mappings__vendor_object_active ON integration.adapter_mappings USING btree (vendor_system_id, mapping_type, vendor_object_type, vendor_object_ref) WHERE (mapping_status = 'ACTIVE'::integration.adapter_mapping_status_enum);


--
-- Name: ix_merchant_site_scopes__merchant_id; Type: INDEX; Schema: merchants; Owner: -
--

CREATE INDEX ix_merchant_site_scopes__merchant_id ON merchants.merchant_site_scopes USING btree (merchant_id);


--
-- Name: ix_merchant_site_scopes__site_group_id; Type: INDEX; Schema: merchants; Owner: -
--

CREATE INDEX ix_merchant_site_scopes__site_group_id ON merchants.merchant_site_scopes USING btree (site_group_id);


--
-- Name: ix_merchant_site_scopes__site_id; Type: INDEX; Schema: merchants; Owner: -
--

CREATE INDEX ix_merchant_site_scopes__site_id ON merchants.merchant_site_scopes USING btree (site_id);


--
-- Name: ix_merchant_users__merchant_id; Type: INDEX; Schema: merchants; Owner: -
--

CREATE INDEX ix_merchant_users__merchant_id ON merchants.merchant_users USING btree (merchant_id);


--
-- Name: ix_merchant_users__merchant_user_status; Type: INDEX; Schema: merchants; Owner: -
--

CREATE INDEX ix_merchant_users__merchant_user_status ON merchants.merchant_users USING btree (merchant_user_status);


--
-- Name: ix_merchant_users__user_id; Type: INDEX; Schema: merchants; Owner: -
--

CREATE INDEX ix_merchant_users__user_id ON merchants.merchant_users USING btree (user_id);


--
-- Name: ix_merchant_wallets__merchant_id; Type: INDEX; Schema: merchants; Owner: -
--

CREATE INDEX ix_merchant_wallets__merchant_id ON merchants.merchant_wallets USING btree (merchant_id);


--
-- Name: ix_merchant_wallets__wallet_status; Type: INDEX; Schema: merchants; Owner: -
--

CREATE INDEX ix_merchant_wallets__wallet_status ON merchants.merchant_wallets USING btree (wallet_status);


--
-- Name: ix_merchants__merchant_status; Type: INDEX; Schema: merchants; Owner: -
--

CREATE INDEX ix_merchants__merchant_status ON merchants.merchants USING btree (merchant_status);


--
-- Name: ux_merchant_site_scopes__active_site_group_scope; Type: INDEX; Schema: merchants; Owner: -
--

CREATE UNIQUE INDEX ux_merchant_site_scopes__active_site_group_scope ON merchants.merchant_site_scopes USING btree (merchant_id, site_group_id, scope_type) WHERE ((scope_status = 'ACTIVE'::merchants.merchant_site_scope_status_enum) AND (site_group_id IS NOT NULL) AND (site_id IS NULL));


--
-- Name: ux_merchant_site_scopes__active_site_scope; Type: INDEX; Schema: merchants; Owner: -
--

CREATE UNIQUE INDEX ux_merchant_site_scopes__active_site_scope ON merchants.merchant_site_scopes USING btree (merchant_id, site_id, scope_type) WHERE ((scope_status = 'ACTIVE'::merchants.merchant_site_scope_status_enum) AND (site_id IS NOT NULL));


--
-- Name: ux_merchant_users__active_user_merchant; Type: INDEX; Schema: merchants; Owner: -
--

CREATE UNIQUE INDEX ux_merchant_users__active_user_merchant ON merchants.merchant_users USING btree (merchant_id, user_id) WHERE (merchant_user_status = 'ACTIVE'::merchants.merchant_user_status_enum);


--
-- Name: ux_merchant_wallets__active_currency_type; Type: INDEX; Schema: merchants; Owner: -
--

CREATE UNIQUE INDEX ux_merchant_wallets__active_currency_type ON merchants.merchant_wallets USING btree (merchant_id, currency_code, wallet_type) WHERE (wallet_status = 'ACTIVE'::merchants.merchant_wallet_status_enum);


--
-- Name: ix_incident_records__correlation_id; Type: INDEX; Schema: operations; Owner: -
--

CREATE INDEX ix_incident_records__correlation_id ON operations.incident_records USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_incident_records__gate_device_id; Type: INDEX; Schema: operations; Owner: -
--

CREATE INDEX ix_incident_records__gate_device_id ON operations.incident_records USING btree (gate_device_id);


--
-- Name: ix_incident_records__lane_id; Type: INDEX; Schema: operations; Owner: -
--

CREATE INDEX ix_incident_records__lane_id ON operations.incident_records USING btree (lane_id);


--
-- Name: ix_incident_records__site_group_id; Type: INDEX; Schema: operations; Owner: -
--

CREATE INDEX ix_incident_records__site_group_id ON operations.incident_records USING btree (site_group_id);


--
-- Name: ix_incident_records__site_id; Type: INDEX; Schema: operations; Owner: -
--

CREATE INDEX ix_incident_records__site_id ON operations.incident_records USING btree (site_id);


--
-- Name: ix_manual_gate_logs__correlation_id; Type: INDEX; Schema: operations; Owner: -
--

CREATE INDEX ix_manual_gate_logs__correlation_id ON operations.manual_gate_logs USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_manual_gate_logs__exit_authorization_id; Type: INDEX; Schema: operations; Owner: -
--

CREATE INDEX ix_manual_gate_logs__exit_authorization_id ON operations.manual_gate_logs USING btree (exit_authorization_id);


--
-- Name: ix_manual_gate_logs__incident_record_id; Type: INDEX; Schema: operations; Owner: -
--

CREATE INDEX ix_manual_gate_logs__incident_record_id ON operations.manual_gate_logs USING btree (incident_record_id);


--
-- Name: ix_manual_gate_logs__lane_id; Type: INDEX; Schema: operations; Owner: -
--

CREATE INDEX ix_manual_gate_logs__lane_id ON operations.manual_gate_logs USING btree (lane_id);


--
-- Name: ix_manual_gate_logs__override_approval_id; Type: INDEX; Schema: operations; Owner: -
--

CREATE INDEX ix_manual_gate_logs__override_approval_id ON operations.manual_gate_logs USING btree (override_approval_id);


--
-- Name: ix_manual_gate_logs__parking_session_id; Type: INDEX; Schema: operations; Owner: -
--

CREATE INDEX ix_manual_gate_logs__parking_session_id ON operations.manual_gate_logs USING btree (parking_session_id);


--
-- Name: ix_manual_gate_logs__site_id; Type: INDEX; Schema: operations; Owner: -
--

CREATE INDEX ix_manual_gate_logs__site_id ON operations.manual_gate_logs USING btree (site_id);


--
-- Name: ix_operator_action_logs__correlation_id; Type: INDEX; Schema: operations; Owner: -
--

CREATE INDEX ix_operator_action_logs__correlation_id ON operations.operator_action_logs USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_operator_action_logs__operator_user_id; Type: INDEX; Schema: operations; Owner: -
--

CREATE INDEX ix_operator_action_logs__operator_user_id ON operations.operator_action_logs USING btree (operator_user_id);


--
-- Name: ix_operator_action_logs__site_id; Type: INDEX; Schema: operations; Owner: -
--

CREATE INDEX ix_operator_action_logs__site_id ON operations.operator_action_logs USING btree (site_id);


--
-- Name: ix_override_approvals__correlation_id; Type: INDEX; Schema: operations; Owner: -
--

CREATE INDEX ix_override_approvals__correlation_id ON operations.override_approvals USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_override_approvals__decided_by_user_id; Type: INDEX; Schema: operations; Owner: -
--

CREATE INDEX ix_override_approvals__decided_by_user_id ON operations.override_approvals USING btree (decided_by_user_id);


--
-- Name: ix_override_approvals__override_request_id; Type: INDEX; Schema: operations; Owner: -
--

CREATE INDEX ix_override_approvals__override_request_id ON operations.override_approvals USING btree (override_request_id);


--
-- Name: ix_override_requests__correlation_id; Type: INDEX; Schema: operations; Owner: -
--

CREATE INDEX ix_override_requests__correlation_id ON operations.override_requests USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_override_requests__incident_record_id; Type: INDEX; Schema: operations; Owner: -
--

CREATE INDEX ix_override_requests__incident_record_id ON operations.override_requests USING btree (incident_record_id);


--
-- Name: ix_override_requests__lane_id; Type: INDEX; Schema: operations; Owner: -
--

CREATE INDEX ix_override_requests__lane_id ON operations.override_requests USING btree (lane_id);


--
-- Name: ix_override_requests__requested_by_user_id; Type: INDEX; Schema: operations; Owner: -
--

CREATE INDEX ix_override_requests__requested_by_user_id ON operations.override_requests USING btree (requested_by_user_id);


--
-- Name: ix_override_requests__site_id; Type: INDEX; Schema: operations; Owner: -
--

CREATE INDEX ix_override_requests__site_id ON operations.override_requests USING btree (site_id);


--
-- Name: ix_payment_provider_routing_policies__lookup; Type: INDEX; Schema: payments; Owner: -
--

CREATE INDEX ix_payment_provider_routing_policies__lookup ON payments.payment_provider_routing_policies USING btree (payment_method_code, currency_code, is_enabled, effective_from, effective_until);


--
-- Name: ix_payment_rails__rail_status; Type: INDEX; Schema: payments; Owner: -
--

CREATE INDEX ix_payment_rails__rail_status ON payments.payment_rails USING btree (rail_status);


--
-- Name: ix_provider_callbacks__correlation_id; Type: INDEX; Schema: payments; Owner: -
--

CREATE INDEX ix_provider_callbacks__correlation_id ON payments.provider_callbacks USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_provider_callbacks__payment_attempt_id; Type: INDEX; Schema: payments; Owner: -
--

CREATE INDEX ix_provider_callbacks__payment_attempt_id ON payments.provider_callbacks USING btree (payment_attempt_id);


--
-- Name: ix_provider_callbacks__payment_rail_id; Type: INDEX; Schema: payments; Owner: -
--

CREATE INDEX ix_provider_callbacks__payment_rail_id ON payments.provider_callbacks USING btree (payment_rail_id);


--
-- Name: ix_provider_callbacks__processing_status; Type: INDEX; Schema: payments; Owner: -
--

CREATE INDEX ix_provider_callbacks__processing_status ON payments.provider_callbacks USING btree (processing_status);


--
-- Name: ix_provider_callbacks__provider_session_id; Type: INDEX; Schema: payments; Owner: -
--

CREATE INDEX ix_provider_callbacks__provider_session_id ON payments.provider_callbacks USING btree (provider_session_id);


--
-- Name: ix_provider_callbacks__received_at; Type: INDEX; Schema: payments; Owner: -
--

CREATE INDEX ix_provider_callbacks__received_at ON payments.provider_callbacks USING btree (received_at);


--
-- Name: ix_provider_callbacks__verification_status; Type: INDEX; Schema: payments; Owner: -
--

CREATE INDEX ix_provider_callbacks__verification_status ON payments.provider_callbacks USING btree (verification_status);


--
-- Name: ix_provider_outcomes__correlation_id; Type: INDEX; Schema: payments; Owner: -
--

CREATE INDEX ix_provider_outcomes__correlation_id ON payments.provider_outcomes USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_provider_outcomes__payment_attempt_id; Type: INDEX; Schema: payments; Owner: -
--

CREATE INDEX ix_provider_outcomes__payment_attempt_id ON payments.provider_outcomes USING btree (payment_attempt_id);


--
-- Name: ix_provider_outcomes__payment_rail_id; Type: INDEX; Schema: payments; Owner: -
--

CREATE INDEX ix_provider_outcomes__payment_rail_id ON payments.provider_outcomes USING btree (payment_rail_id);


--
-- Name: ix_provider_outcomes__provider_callback_id; Type: INDEX; Schema: payments; Owner: -
--

CREATE INDEX ix_provider_outcomes__provider_callback_id ON payments.provider_outcomes USING btree (provider_callback_id);


--
-- Name: ix_provider_outcomes__provider_session_id; Type: INDEX; Schema: payments; Owner: -
--

CREATE INDEX ix_provider_outcomes__provider_session_id ON payments.provider_outcomes USING btree (provider_session_id);


--
-- Name: ix_provider_sessions__correlation_id; Type: INDEX; Schema: payments; Owner: -
--

CREATE INDEX ix_provider_sessions__correlation_id ON payments.provider_sessions USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_provider_sessions__expires_at; Type: INDEX; Schema: payments; Owner: -
--

CREATE INDEX ix_provider_sessions__expires_at ON payments.provider_sessions USING btree (expires_at);


--
-- Name: ix_provider_sessions__payment_attempt_id; Type: INDEX; Schema: payments; Owner: -
--

CREATE INDEX ix_provider_sessions__payment_attempt_id ON payments.provider_sessions USING btree (payment_attempt_id);


--
-- Name: ix_provider_sessions__payment_rail_id; Type: INDEX; Schema: payments; Owner: -
--

CREATE INDEX ix_provider_sessions__payment_rail_id ON payments.provider_sessions USING btree (payment_rail_id);


--
-- Name: ix_provider_sessions__session_status; Type: INDEX; Schema: payments; Owner: -
--

CREATE INDEX ix_provider_sessions__session_status ON payments.provider_sessions USING btree (session_status);


--
-- Name: ix_provider_status_queries__correlation_id; Type: INDEX; Schema: payments; Owner: -
--

CREATE INDEX ix_provider_status_queries__correlation_id ON payments.provider_status_queries USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_provider_status_queries__payment_attempt_id; Type: INDEX; Schema: payments; Owner: -
--

CREATE INDEX ix_provider_status_queries__payment_attempt_id ON payments.provider_status_queries USING btree (payment_attempt_id);


--
-- Name: ix_provider_status_queries__payment_rail_id; Type: INDEX; Schema: payments; Owner: -
--

CREATE INDEX ix_provider_status_queries__payment_rail_id ON payments.provider_status_queries USING btree (payment_rail_id);


--
-- Name: ix_provider_status_queries__provider_session_id; Type: INDEX; Schema: payments; Owner: -
--

CREATE INDEX ix_provider_status_queries__provider_session_id ON payments.provider_status_queries USING btree (provider_session_id);


--
-- Name: ix_provider_status_queries__query_status; Type: INDEX; Schema: payments; Owner: -
--

CREATE INDEX ix_provider_status_queries__query_status ON payments.provider_status_queries USING btree (query_status);


--
-- Name: uq_payment_provider_routing_policies__default_method_currency; Type: INDEX; Schema: payments; Owner: -
--

CREATE UNIQUE INDEX uq_payment_provider_routing_policies__default_method_currency ON payments.payment_provider_routing_policies USING btree (payment_method_code, currency_code) WHERE ((site_id IS NULL) AND (site_group_id IS NULL) AND (min_amount_minor_units IS NULL) AND (max_amount_minor_units IS NULL));


--
-- Name: ux_provider_callbacks__provider_event; Type: INDEX; Schema: payments; Owner: -
--

CREATE UNIQUE INDEX ux_provider_callbacks__provider_event ON payments.provider_callbacks USING btree (payment_rail_id, provider_event_ref) WHERE (provider_event_ref IS NOT NULL);


--
-- Name: ux_provider_outcomes__provider_callback; Type: INDEX; Schema: payments; Owner: -
--

CREATE UNIQUE INDEX ux_provider_outcomes__provider_callback ON payments.provider_outcomes USING btree (provider_callback_id) WHERE (provider_callback_id IS NOT NULL);


--
-- Name: ux_provider_outcomes__provider_status_query; Type: INDEX; Schema: payments; Owner: -
--

CREATE UNIQUE INDEX ux_provider_outcomes__provider_status_query ON payments.provider_outcomes USING btree (provider_status_query_id) WHERE (provider_status_query_id IS NOT NULL);


--
-- Name: ux_provider_outcomes__provider_transaction_ref; Type: INDEX; Schema: payments; Owner: -
--

CREATE UNIQUE INDEX ux_provider_outcomes__provider_transaction_ref ON payments.provider_outcomes USING btree (payment_rail_id, provider_transaction_ref) WHERE (provider_transaction_ref IS NOT NULL);


--
-- Name: ux_provider_sessions__active_by_attempt_rail; Type: INDEX; Schema: payments; Owner: -
--

CREATE UNIQUE INDEX ux_provider_sessions__active_by_attempt_rail ON payments.provider_sessions USING btree (payment_attempt_id, payment_rail_id) WHERE (session_status = ANY (ARRAY['CREATED'::payments.provider_session_status_enum, 'ACTIVE'::payments.provider_session_status_enum, 'PENDING'::payments.provider_session_status_enum]));


--
-- Name: ux_provider_sessions__provider_ref; Type: INDEX; Schema: payments; Owner: -
--

CREATE UNIQUE INDEX ux_provider_sessions__provider_ref ON payments.provider_sessions USING btree (payment_rail_id, provider_session_ref) WHERE (provider_session_ref IS NOT NULL);


--
-- Name: ix_mops_transaction_records__correlation_id; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_mops_transaction_records__correlation_id ON reconciliation.mops_transaction_records USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_mops_transaction_records__imported_by_service_identity_id; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_mops_transaction_records__imported_by_service_identity_id ON reconciliation.mops_transaction_records USING btree (imported_by_service_identity_id);


--
-- Name: ix_mops_transaction_records__incident_record_id; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_mops_transaction_records__incident_record_id ON reconciliation.mops_transaction_records USING btree (incident_record_id);


--
-- Name: ix_mops_transaction_records__lane_id; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_mops_transaction_records__lane_id ON reconciliation.mops_transaction_records USING btree (lane_id);


--
-- Name: ix_mops_transaction_records__manual_gate_log_id; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_mops_transaction_records__manual_gate_log_id ON reconciliation.mops_transaction_records USING btree (manual_gate_log_id);


--
-- Name: ix_mops_transaction_records__parking_session_id; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_mops_transaction_records__parking_session_id ON reconciliation.mops_transaction_records USING btree (parking_session_id);


--
-- Name: ix_mops_transaction_records__site_id; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_mops_transaction_records__site_id ON reconciliation.mops_transaction_records USING btree (site_id);


--
-- Name: ix_reconciliation_exceptions__assigned_to_user_id; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_reconciliation_exceptions__assigned_to_user_id ON reconciliation.reconciliation_exceptions USING btree (assigned_to_user_id);


--
-- Name: ix_reconciliation_exceptions__correlation_id; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_reconciliation_exceptions__correlation_id ON reconciliation.reconciliation_exceptions USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_reconciliation_exceptions__incident_record_id; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_reconciliation_exceptions__incident_record_id ON reconciliation.reconciliation_exceptions USING btree (incident_record_id);


--
-- Name: ix_reconciliation_exceptions__reconciliation_item_id; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_reconciliation_exceptions__reconciliation_item_id ON reconciliation.reconciliation_exceptions USING btree (reconciliation_item_id);


--
-- Name: ix_reconciliation_exceptions__reconciliation_run_id; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_reconciliation_exceptions__reconciliation_run_id ON reconciliation.reconciliation_exceptions USING btree (reconciliation_run_id);


--
-- Name: ix_reconciliation_items__correlation_id; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_reconciliation_items__correlation_id ON reconciliation.reconciliation_items USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_reconciliation_items__manual_gate_log_id; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_reconciliation_items__manual_gate_log_id ON reconciliation.reconciliation_items USING btree (manual_gate_log_id);


--
-- Name: ix_reconciliation_items__mops_transaction_record_id; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_reconciliation_items__mops_transaction_record_id ON reconciliation.reconciliation_items USING btree (mops_transaction_record_id);


--
-- Name: ix_reconciliation_items__payment_attempt_id; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_reconciliation_items__payment_attempt_id ON reconciliation.reconciliation_items USING btree (payment_attempt_id);


--
-- Name: ix_reconciliation_items__payment_confirmation_id; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_reconciliation_items__payment_confirmation_id ON reconciliation.reconciliation_items USING btree (payment_confirmation_id);


--
-- Name: ix_reconciliation_items__provider_outcome_id; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_reconciliation_items__provider_outcome_id ON reconciliation.reconciliation_items USING btree (provider_outcome_id);


--
-- Name: ix_reconciliation_items__reconciliation_run_id; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_reconciliation_items__reconciliation_run_id ON reconciliation.reconciliation_items USING btree (reconciliation_run_id);


--
-- Name: ix_reconciliation_runs__correlation_id; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_reconciliation_runs__correlation_id ON reconciliation.reconciliation_runs USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_reconciliation_runs__incident_record_id; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_reconciliation_runs__incident_record_id ON reconciliation.reconciliation_runs USING btree (incident_record_id);


--
-- Name: ix_reconciliation_runs__payment_rail_id; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_reconciliation_runs__payment_rail_id ON reconciliation.reconciliation_runs USING btree (payment_rail_id);


--
-- Name: ix_reconciliation_runs__site_group_id; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_reconciliation_runs__site_group_id ON reconciliation.reconciliation_runs USING btree (site_group_id);


--
-- Name: ix_reconciliation_runs__site_id; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_reconciliation_runs__site_id ON reconciliation.reconciliation_runs USING btree (site_id);


--
-- Name: ix_settlement_comparison_records__correlation_id; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_settlement_comparison_records__correlation_id ON reconciliation.settlement_comparison_records USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_settlement_comparison_records__mops_transaction_record_id; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_settlement_comparison_records__mops_transaction_record_id ON reconciliation.settlement_comparison_records USING btree (mops_transaction_record_id);


--
-- Name: ix_settlement_comparison_records__payment_confirmation_id; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_settlement_comparison_records__payment_confirmation_id ON reconciliation.settlement_comparison_records USING btree (payment_confirmation_id);


--
-- Name: ix_settlement_comparison_records__reconciliation_exception_i; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_settlement_comparison_records__reconciliation_exception_i ON reconciliation.settlement_comparison_records USING btree (reconciliation_exception_id);


--
-- Name: ix_settlement_comparison_records__reconciliation_item_id; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE INDEX ix_settlement_comparison_records__reconciliation_item_id ON reconciliation.settlement_comparison_records USING btree (reconciliation_item_id);


--
-- Name: ux_mops_transaction_records__source_batch_collection; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE UNIQUE INDEX ux_mops_transaction_records__source_batch_collection ON reconciliation.mops_transaction_records USING btree (source_system_code, source_batch_ref, collection_reference) WHERE ((source_batch_ref IS NOT NULL) AND (collection_reference IS NOT NULL));


--
-- Name: ux_mops_transaction_records__source_transaction_ref; Type: INDEX; Schema: reconciliation; Owner: -
--

CREATE UNIQUE INDEX ux_mops_transaction_records__source_transaction_ref ON reconciliation.mops_transaction_records USING btree (source_system_code, source_transaction_ref) WHERE (source_transaction_ref IS NOT NULL);


--
-- Name: ix_session_identifier_indexes__correlation_id; Type: INDEX; Schema: sessions; Owner: -
--

CREATE INDEX ix_session_identifier_indexes__correlation_id ON sessions.session_identifier_indexes USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_session_identifier_indexes__parking_session_id; Type: INDEX; Schema: sessions; Owner: -
--

CREATE INDEX ix_session_identifier_indexes__parking_session_id ON sessions.session_identifier_indexes USING btree (parking_session_id);


--
-- Name: ix_session_identifier_indexes__site_group_id; Type: INDEX; Schema: sessions; Owner: -
--

CREATE INDEX ix_session_identifier_indexes__site_group_id ON sessions.session_identifier_indexes USING btree (site_group_id);


--
-- Name: ix_session_identifier_indexes__site_id; Type: INDEX; Schema: sessions; Owner: -
--

CREATE INDEX ix_session_identifier_indexes__site_id ON sessions.session_identifier_indexes USING btree (site_id);


--
-- Name: ix_session_identifier_indexes__vendor_system_id; Type: INDEX; Schema: sessions; Owner: -
--

CREATE INDEX ix_session_identifier_indexes__vendor_system_id ON sessions.session_identifier_indexes USING btree (vendor_system_id);


--
-- Name: ix_session_lookup_cache__correlation_id; Type: INDEX; Schema: sessions; Owner: -
--

CREATE INDEX ix_session_lookup_cache__correlation_id ON sessions.session_lookup_cache USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_session_lookup_cache__parking_session_id; Type: INDEX; Schema: sessions; Owner: -
--

CREATE INDEX ix_session_lookup_cache__parking_session_id ON sessions.session_lookup_cache USING btree (parking_session_id);


--
-- Name: ix_session_lookup_cache__site_group_id; Type: INDEX; Schema: sessions; Owner: -
--

CREATE INDEX ix_session_lookup_cache__site_group_id ON sessions.session_lookup_cache USING btree (site_group_id);


--
-- Name: ix_session_lookup_cache__site_id; Type: INDEX; Schema: sessions; Owner: -
--

CREATE INDEX ix_session_lookup_cache__site_id ON sessions.session_lookup_cache USING btree (site_id);


--
-- Name: ix_session_lookup_cache__vendor_system_id; Type: INDEX; Schema: sessions; Owner: -
--

CREATE INDEX ix_session_lookup_cache__vendor_system_id ON sessions.session_lookup_cache USING btree (vendor_system_id);


--
-- Name: ix_session_resolution_requests__correlation_id; Type: INDEX; Schema: sessions; Owner: -
--

CREATE INDEX ix_session_resolution_requests__correlation_id ON sessions.session_resolution_requests USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_session_resolution_requests__request_status; Type: INDEX; Schema: sessions; Owner: -
--

CREATE INDEX ix_session_resolution_requests__request_status ON sessions.session_resolution_requests USING btree (request_status);


--
-- Name: ix_session_resolution_requests__requested_at; Type: INDEX; Schema: sessions; Owner: -
--

CREATE INDEX ix_session_resolution_requests__requested_at ON sessions.session_resolution_requests USING btree (requested_at);


--
-- Name: ix_session_resolution_requests__site_group_id; Type: INDEX; Schema: sessions; Owner: -
--

CREATE INDEX ix_session_resolution_requests__site_group_id ON sessions.session_resolution_requests USING btree (site_group_id);


--
-- Name: ix_session_resolution_requests__site_id; Type: INDEX; Schema: sessions; Owner: -
--

CREATE INDEX ix_session_resolution_requests__site_id ON sessions.session_resolution_requests USING btree (site_id);


--
-- Name: ix_session_resolution_results__correlation_id; Type: INDEX; Schema: sessions; Owner: -
--

CREATE INDEX ix_session_resolution_results__correlation_id ON sessions.session_resolution_results USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ix_session_resolution_results__parking_session_id; Type: INDEX; Schema: sessions; Owner: -
--

CREATE INDEX ix_session_resolution_results__parking_session_id ON sessions.session_resolution_results USING btree (parking_session_id);


--
-- Name: ix_session_resolution_results__session_resolution_request_id; Type: INDEX; Schema: sessions; Owner: -
--

CREATE INDEX ix_session_resolution_results__session_resolution_request_id ON sessions.session_resolution_results USING btree (session_resolution_request_id);


--
-- Name: ix_session_resolution_results__site_group_id; Type: INDEX; Schema: sessions; Owner: -
--

CREATE INDEX ix_session_resolution_results__site_group_id ON sessions.session_resolution_results USING btree (site_group_id);


--
-- Name: ix_session_resolution_results__site_id; Type: INDEX; Schema: sessions; Owner: -
--

CREATE INDEX ix_session_resolution_results__site_id ON sessions.session_resolution_results USING btree (site_id);


--
-- Name: ux_session_identifier_indexes__active_scope_with_site; Type: INDEX; Schema: sessions; Owner: -
--

CREATE UNIQUE INDEX ux_session_identifier_indexes__active_scope_with_site ON sessions.session_identifier_indexes USING btree (site_group_id, site_id, identifier_type, identifier_hash) WHERE ((identifier_status = 'ACTIVE'::sessions.session_identifier_status_enum) AND (site_id IS NOT NULL));


--
-- Name: ux_session_identifier_indexes__active_scope_without_site; Type: INDEX; Schema: sessions; Owner: -
--

CREATE UNIQUE INDEX ux_session_identifier_indexes__active_scope_without_site ON sessions.session_identifier_indexes USING btree (site_group_id, identifier_type, identifier_hash) WHERE ((identifier_status = 'ACTIVE'::sessions.session_identifier_status_enum) AND (site_id IS NULL));


--
-- Name: ux_session_lookup_cache__active_scope_with_site; Type: INDEX; Schema: sessions; Owner: -
--

CREATE UNIQUE INDEX ux_session_lookup_cache__active_scope_with_site ON sessions.session_lookup_cache USING btree (site_group_id, site_id, lookup_type, lookup_identifier_hash) WHERE ((cache_status = 'ACTIVE'::sessions.session_lookup_cache_status_enum) AND (site_id IS NOT NULL));


--
-- Name: ux_session_lookup_cache__active_scope_without_site; Type: INDEX; Schema: sessions; Owner: -
--

CREATE UNIQUE INDEX ux_session_lookup_cache__active_scope_without_site ON sessions.session_lookup_cache USING btree (site_group_id, lookup_type, lookup_identifier_hash) WHERE ((cache_status = 'ACTIVE'::sessions.session_lookup_cache_status_enum) AND (site_id IS NULL));


--
-- Name: ux_session_resolution_requests__idempotency_key; Type: INDEX; Schema: sessions; Owner: -
--

CREATE UNIQUE INDEX ux_session_resolution_requests__idempotency_key ON sessions.session_resolution_requests USING btree (idempotency_key) WHERE (idempotency_key IS NOT NULL);


--
-- Name: ix_device_assignments__gate_device_id; Type: INDEX; Schema: sites; Owner: -
--

CREATE INDEX ix_device_assignments__gate_device_id ON sites.device_assignments USING btree (gate_device_id);


--
-- Name: ix_device_assignments__lane_id; Type: INDEX; Schema: sites; Owner: -
--

CREATE INDEX ix_device_assignments__lane_id ON sites.device_assignments USING btree (lane_id);


--
-- Name: ix_device_assignments__site_id; Type: INDEX; Schema: sites; Owner: -
--

CREATE INDEX ix_device_assignments__site_id ON sites.device_assignments USING btree (site_id);


--
-- Name: ix_lanes__lane_status; Type: INDEX; Schema: sites; Owner: -
--

CREATE INDEX ix_lanes__lane_status ON sites.lanes USING btree (lane_status);


--
-- Name: ix_lanes__site_id; Type: INDEX; Schema: sites; Owner: -
--

CREATE INDEX ix_lanes__site_id ON sites.lanes USING btree (site_id);


--
-- Name: ix_site_groups__site_group_status; Type: INDEX; Schema: sites; Owner: -
--

CREATE INDEX ix_site_groups__site_group_status ON sites.site_groups USING btree (site_group_status);


--
-- Name: ix_sites__site_group_id; Type: INDEX; Schema: sites; Owner: -
--

CREATE INDEX ix_sites__site_group_id ON sites.sites USING btree (site_group_id);


--
-- Name: ix_sites__site_status; Type: INDEX; Schema: sites; Owner: -
--

CREATE INDEX ix_sites__site_status ON sites.sites USING btree (site_status);


--
-- Name: ux_device_assignments__active_gate_device; Type: INDEX; Schema: sites; Owner: -
--

CREATE UNIQUE INDEX ux_device_assignments__active_gate_device ON sites.device_assignments USING btree (gate_device_id) WHERE ((assignment_status = 'ACTIVE'::sites.device_assignment_status_enum) AND (gate_device_id IS NOT NULL));


--
-- Name: ux_device_assignments__active_lane_assignment_type; Type: INDEX; Schema: sites; Owner: -
--

CREATE UNIQUE INDEX ux_device_assignments__active_lane_assignment_type ON sites.device_assignments USING btree (site_id, lane_id, assignment_type) WHERE ((assignment_status = 'ACTIVE'::sites.device_assignment_status_enum) AND (lane_id IS NOT NULL));


--
-- Name: ux_device_assignments__active_service_identity; Type: INDEX; Schema: sites; Owner: -
--

CREATE UNIQUE INDEX ux_device_assignments__active_service_identity ON sites.device_assignments USING btree (service_identity_id) WHERE ((assignment_status = 'ACTIVE'::sites.device_assignment_status_enum) AND (service_identity_id IS NOT NULL));


--
-- Name: audit_events fk_audit_events__actor_service_identity_id; Type: FK CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.audit_events
    ADD CONSTRAINT fk_audit_events__actor_service_identity_id FOREIGN KEY (actor_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: audit_events fk_audit_events__actor_user_id; Type: FK CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.audit_events
    ADD CONSTRAINT fk_audit_events__actor_user_id FOREIGN KEY (actor_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: audit_events fk_audit_events__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.audit_events
    ADD CONSTRAINT fk_audit_events__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: audit_trail_entries fk_audit_trail_entries__audit_event_id; Type: FK CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.audit_trail_entries
    ADD CONSTRAINT fk_audit_trail_entries__audit_event_id FOREIGN KEY (audit_event_id) REFERENCES audit.audit_events(audit_event_id) DEFERRABLE;


--
-- Name: audit_trail_entries fk_audit_trail_entries__changed_by_service_identity_id; Type: FK CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.audit_trail_entries
    ADD CONSTRAINT fk_audit_trail_entries__changed_by_service_identity_id FOREIGN KEY (changed_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: audit_trail_entries fk_audit_trail_entries__changed_by_user_id; Type: FK CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.audit_trail_entries
    ADD CONSTRAINT fk_audit_trail_entries__changed_by_user_id FOREIGN KEY (changed_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: audit_trail_entries fk_audit_trail_entries__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.audit_trail_entries
    ADD CONSTRAINT fk_audit_trail_entries__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: evidence_links fk_evidence_links__audit_event_id; Type: FK CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.evidence_links
    ADD CONSTRAINT fk_evidence_links__audit_event_id FOREIGN KEY (audit_event_id) REFERENCES audit.audit_events(audit_event_id) DEFERRABLE;


--
-- Name: evidence_links fk_evidence_links__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.evidence_links
    ADD CONSTRAINT fk_evidence_links__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: evidence_links fk_evidence_links__created_by_user_id; Type: FK CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.evidence_links
    ADD CONSTRAINT fk_evidence_links__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: evidence_links fk_evidence_links__linked_by_service_identity_id; Type: FK CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.evidence_links
    ADD CONSTRAINT fk_evidence_links__linked_by_service_identity_id FOREIGN KEY (linked_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: evidence_links fk_evidence_links__linked_by_user_id; Type: FK CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.evidence_links
    ADD CONSTRAINT fk_evidence_links__linked_by_user_id FOREIGN KEY (linked_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: evidence_links fk_evidence_links__purged_by_service_identity_id; Type: FK CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.evidence_links
    ADD CONSTRAINT fk_evidence_links__purged_by_service_identity_id FOREIGN KEY (purged_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: evidence_links fk_evidence_links__purged_by_user_id; Type: FK CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.evidence_links
    ADD CONSTRAINT fk_evidence_links__purged_by_user_id FOREIGN KEY (purged_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: evidence_links fk_evidence_links__security_event_id; Type: FK CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.evidence_links
    ADD CONSTRAINT fk_evidence_links__security_event_id FOREIGN KEY (security_event_id) REFERENCES audit.security_events(security_event_id) DEFERRABLE;


--
-- Name: evidence_links fk_evidence_links__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.evidence_links
    ADD CONSTRAINT fk_evidence_links__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: evidence_links fk_evidence_links__updated_by_user_id; Type: FK CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.evidence_links
    ADD CONSTRAINT fk_evidence_links__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: security_events fk_security_events__actor_service_identity_id; Type: FK CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.security_events
    ADD CONSTRAINT fk_security_events__actor_service_identity_id FOREIGN KEY (actor_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: security_events fk_security_events__actor_user_id; Type: FK CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.security_events
    ADD CONSTRAINT fk_security_events__actor_user_id FOREIGN KEY (actor_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: security_events fk_security_events__audit_event_id; Type: FK CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.security_events
    ADD CONSTRAINT fk_security_events__audit_event_id FOREIGN KEY (audit_event_id) REFERENCES audit.audit_events(audit_event_id) DEFERRABLE;


--
-- Name: security_events fk_security_events__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.security_events
    ADD CONSTRAINT fk_security_events__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: security_events fk_security_events__incident_record_id; Type: FK CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.security_events
    ADD CONSTRAINT fk_security_events__incident_record_id FOREIGN KEY (incident_record_id) REFERENCES operations.incident_records(incident_record_id) DEFERRABLE;


--
-- Name: security_events fk_security_events__resolved_by_user_id; Type: FK CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.security_events
    ADD CONSTRAINT fk_security_events__resolved_by_user_id FOREIGN KEY (resolved_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: controlled_code_sets fk_controlled_code_sets__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.controlled_code_sets
    ADD CONSTRAINT fk_controlled_code_sets__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: controlled_code_sets fk_controlled_code_sets__created_by_user_id; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.controlled_code_sets
    ADD CONSTRAINT fk_controlled_code_sets__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: controlled_code_sets fk_controlled_code_sets__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.controlled_code_sets
    ADD CONSTRAINT fk_controlled_code_sets__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: controlled_code_sets fk_controlled_code_sets__updated_by_user_id; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.controlled_code_sets
    ADD CONSTRAINT fk_controlled_code_sets__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: feature_flags fk_feature_flags__approved_by_user_id; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.feature_flags
    ADD CONSTRAINT fk_feature_flags__approved_by_user_id FOREIGN KEY (approved_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: feature_flags fk_feature_flags__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.feature_flags
    ADD CONSTRAINT fk_feature_flags__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: feature_flags fk_feature_flags__created_by_user_id; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.feature_flags
    ADD CONSTRAINT fk_feature_flags__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: feature_flags fk_feature_flags__merchant_id; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.feature_flags
    ADD CONSTRAINT fk_feature_flags__merchant_id FOREIGN KEY (merchant_id) REFERENCES merchants.merchants(merchant_id) DEFERRABLE;


--
-- Name: feature_flags fk_feature_flags__payment_rail_id; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.feature_flags
    ADD CONSTRAINT fk_feature_flags__payment_rail_id FOREIGN KEY (payment_rail_id) REFERENCES payments.payment_rails(payment_rail_id) DEFERRABLE;


--
-- Name: feature_flags fk_feature_flags__service_identity_id; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.feature_flags
    ADD CONSTRAINT fk_feature_flags__service_identity_id FOREIGN KEY (service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: feature_flags fk_feature_flags__site_group_id; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.feature_flags
    ADD CONSTRAINT fk_feature_flags__site_group_id FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id) DEFERRABLE;


--
-- Name: feature_flags fk_feature_flags__site_id; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.feature_flags
    ADD CONSTRAINT fk_feature_flags__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE;


--
-- Name: feature_flags fk_feature_flags__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.feature_flags
    ADD CONSTRAINT fk_feature_flags__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: feature_flags fk_feature_flags__updated_by_user_id; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.feature_flags
    ADD CONSTRAINT fk_feature_flags__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: rate_limit_policies fk_rate_limit_policies__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.rate_limit_policies
    ADD CONSTRAINT fk_rate_limit_policies__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: rate_limit_policies fk_rate_limit_policies__created_by_user_id; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.rate_limit_policies
    ADD CONSTRAINT fk_rate_limit_policies__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: rate_limit_policies fk_rate_limit_policies__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.rate_limit_policies
    ADD CONSTRAINT fk_rate_limit_policies__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: rate_limit_policies fk_rate_limit_policies__updated_by_user_id; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.rate_limit_policies
    ADD CONSTRAINT fk_rate_limit_policies__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: system_parameters fk_system_parameters__approved_by_user_id; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.system_parameters
    ADD CONSTRAINT fk_system_parameters__approved_by_user_id FOREIGN KEY (approved_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: system_parameters fk_system_parameters__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.system_parameters
    ADD CONSTRAINT fk_system_parameters__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: system_parameters fk_system_parameters__created_by_user_id; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.system_parameters
    ADD CONSTRAINT fk_system_parameters__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: system_parameters fk_system_parameters__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.system_parameters
    ADD CONSTRAINT fk_system_parameters__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: system_parameters fk_system_parameters__updated_by_user_id; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.system_parameters
    ADD CONSTRAINT fk_system_parameters__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: ttl_policies fk_ttl_policies__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.ttl_policies
    ADD CONSTRAINT fk_ttl_policies__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: ttl_policies fk_ttl_policies__created_by_user_id; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.ttl_policies
    ADD CONSTRAINT fk_ttl_policies__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: ttl_policies fk_ttl_policies__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.ttl_policies
    ADD CONSTRAINT fk_ttl_policies__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: ttl_policies fk_ttl_policies__updated_by_user_id; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.ttl_policies
    ADD CONSTRAINT fk_ttl_policies__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: exit_authorizations fk_exit_authorizations__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.exit_authorizations
    ADD CONSTRAINT fk_exit_authorizations__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: exit_authorizations fk_exit_authorizations__parking_session_id; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.exit_authorizations
    ADD CONSTRAINT fk_exit_authorizations__parking_session_id FOREIGN KEY (parking_session_id) REFERENCES core.parking_sessions(parking_session_id) DEFERRABLE;


--
-- Name: exit_authorizations fk_exit_authorizations__payment_attempt_id; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.exit_authorizations
    ADD CONSTRAINT fk_exit_authorizations__payment_attempt_id FOREIGN KEY (payment_attempt_id) REFERENCES core.payment_attempts(payment_attempt_id) DEFERRABLE;


--
-- Name: exit_authorizations fk_exit_authorizations__payment_confirmation_id; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.exit_authorizations
    ADD CONSTRAINT fk_exit_authorizations__payment_confirmation_id FOREIGN KEY (payment_confirmation_id) REFERENCES core.payment_confirmations(payment_confirmation_id) DEFERRABLE;


--
-- Name: exit_authorizations fk_exit_authorizations__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.exit_authorizations
    ADD CONSTRAINT fk_exit_authorizations__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: parking_sessions fk_parking_sessions__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.parking_sessions
    ADD CONSTRAINT fk_parking_sessions__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: parking_sessions fk_parking_sessions__site_group_id; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.parking_sessions
    ADD CONSTRAINT fk_parking_sessions__site_group_id FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id) DEFERRABLE;


--
-- Name: parking_sessions fk_parking_sessions__site_id; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.parking_sessions
    ADD CONSTRAINT fk_parking_sessions__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE;


--
-- Name: parking_sessions fk_parking_sessions__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.parking_sessions
    ADD CONSTRAINT fk_parking_sessions__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: parking_sessions fk_parking_sessions__vendor_system_id; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.parking_sessions
    ADD CONSTRAINT fk_parking_sessions__vendor_system_id FOREIGN KEY (vendor_system_id) REFERENCES integration.vendor_systems(vendor_system_id) DEFERRABLE;


--
-- Name: payment_attempts fk_payment_attempts__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.payment_attempts
    ADD CONSTRAINT fk_payment_attempts__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: payment_attempts fk_payment_attempts__parking_session_id; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.payment_attempts
    ADD CONSTRAINT fk_payment_attempts__parking_session_id FOREIGN KEY (parking_session_id) REFERENCES core.parking_sessions(parking_session_id) DEFERRABLE;


--
-- Name: payment_attempts fk_payment_attempts__payment_rail_id; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.payment_attempts
    ADD CONSTRAINT fk_payment_attempts__payment_rail_id FOREIGN KEY (payment_rail_id) REFERENCES payments.payment_rails(payment_rail_id) DEFERRABLE;


--
-- Name: payment_attempts fk_payment_attempts__tariff_snapshot_id; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.payment_attempts
    ADD CONSTRAINT fk_payment_attempts__tariff_snapshot_id FOREIGN KEY (tariff_snapshot_id) REFERENCES core.tariff_snapshots(tariff_snapshot_id) DEFERRABLE;


--
-- Name: payment_attempts fk_payment_attempts__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.payment_attempts
    ADD CONSTRAINT fk_payment_attempts__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: payment_confirmations fk_payment_confirmations__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.payment_confirmations
    ADD CONSTRAINT fk_payment_confirmations__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: payment_confirmations fk_payment_confirmations__payment_attempt_id; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.payment_confirmations
    ADD CONSTRAINT fk_payment_confirmations__payment_attempt_id FOREIGN KEY (payment_attempt_id) REFERENCES core.payment_attempts(payment_attempt_id) DEFERRABLE;


--
-- Name: payment_confirmations fk_payment_confirmations__payment_rail_id; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.payment_confirmations
    ADD CONSTRAINT fk_payment_confirmations__payment_rail_id FOREIGN KEY (payment_rail_id) REFERENCES payments.payment_rails(payment_rail_id) DEFERRABLE;


--
-- Name: payment_confirmations fk_payment_confirmations__provider_outcome_id; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.payment_confirmations
    ADD CONSTRAINT fk_payment_confirmations__provider_outcome_id FOREIGN KEY (provider_outcome_id) REFERENCES payments.provider_outcomes(provider_outcome_id) DEFERRABLE;


--
-- Name: tariff_snapshots fk_tariff_snapshots__coupon_application_id; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.tariff_snapshots
    ADD CONSTRAINT fk_tariff_snapshots__coupon_application_id FOREIGN KEY (coupon_application_id) REFERENCES coupons.coupon_applications(coupon_application_id) DEFERRABLE;


--
-- Name: tariff_snapshots fk_tariff_snapshots__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.tariff_snapshots
    ADD CONSTRAINT fk_tariff_snapshots__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: tariff_snapshots fk_tariff_snapshots__parking_session_id; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.tariff_snapshots
    ADD CONSTRAINT fk_tariff_snapshots__parking_session_id FOREIGN KEY (parking_session_id) REFERENCES core.parking_sessions(parking_session_id) DEFERRABLE;


--
-- Name: tariff_snapshots fk_tariff_snapshots__statutory_discount_validation_id; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.tariff_snapshots
    ADD CONSTRAINT fk_tariff_snapshots__statutory_discount_validation_id FOREIGN KEY (statutory_discount_validation_id) REFERENCES discounts.statutory_discount_validations(statutory_discount_validation_id) DEFERRABLE;


--
-- Name: tariff_snapshots fk_tariff_snapshots__superseded_by_tariff_snapshot_id; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.tariff_snapshots
    ADD CONSTRAINT fk_tariff_snapshots__superseded_by_tariff_snapshot_id FOREIGN KEY (superseded_by_tariff_snapshot_id) REFERENCES core.tariff_snapshots(tariff_snapshot_id) DEFERRABLE;


--
-- Name: tariff_snapshots fk_tariff_snapshots__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.tariff_snapshots
    ADD CONSTRAINT fk_tariff_snapshots__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: tariff_snapshots fk_tariff_snapshots__vendor_system_id; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.tariff_snapshots
    ADD CONSTRAINT fk_tariff_snapshots__vendor_system_id FOREIGN KEY (vendor_system_id) REFERENCES integration.vendor_systems(vendor_system_id) DEFERRABLE;


--
-- Name: coupon_applications fk_coupon_applications__approved_by_user_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_applications
    ADD CONSTRAINT fk_coupon_applications__approved_by_user_id FOREIGN KEY (approved_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: coupon_applications fk_coupon_applications__coupon_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_applications
    ADD CONSTRAINT fk_coupon_applications__coupon_id FOREIGN KEY (coupon_id) REFERENCES coupons.coupons(coupon_id) DEFERRABLE;


--
-- Name: coupon_applications fk_coupon_applications__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_applications
    ADD CONSTRAINT fk_coupon_applications__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: coupon_applications fk_coupon_applications__created_by_user_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_applications
    ADD CONSTRAINT fk_coupon_applications__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: coupon_applications fk_coupon_applications__merchant_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_applications
    ADD CONSTRAINT fk_coupon_applications__merchant_id FOREIGN KEY (merchant_id) REFERENCES merchants.merchants(merchant_id) DEFERRABLE;


--
-- Name: coupon_applications fk_coupon_applications__merchant_wallet_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_applications
    ADD CONSTRAINT fk_coupon_applications__merchant_wallet_id FOREIGN KEY (merchant_wallet_id) REFERENCES merchants.merchant_wallets(merchant_wallet_id) DEFERRABLE;


--
-- Name: coupon_applications fk_coupon_applications__parking_session_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_applications
    ADD CONSTRAINT fk_coupon_applications__parking_session_id FOREIGN KEY (parking_session_id) REFERENCES core.parking_sessions(parking_session_id) DEFERRABLE;


--
-- Name: coupon_applications fk_coupon_applications__payment_attempt_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_applications
    ADD CONSTRAINT fk_coupon_applications__payment_attempt_id FOREIGN KEY (payment_attempt_id) REFERENCES core.payment_attempts(payment_attempt_id) DEFERRABLE;


--
-- Name: coupon_applications fk_coupon_applications__requested_by_service_identity_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_applications
    ADD CONSTRAINT fk_coupon_applications__requested_by_service_identity_id FOREIGN KEY (requested_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: coupon_applications fk_coupon_applications__requested_by_user_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_applications
    ADD CONSTRAINT fk_coupon_applications__requested_by_user_id FOREIGN KEY (requested_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: coupon_applications fk_coupon_applications__tariff_snapshot_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_applications
    ADD CONSTRAINT fk_coupon_applications__tariff_snapshot_id FOREIGN KEY (tariff_snapshot_id) REFERENCES core.tariff_snapshots(tariff_snapshot_id) DEFERRABLE;


--
-- Name: coupon_applications fk_coupon_applications__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_applications
    ADD CONSTRAINT fk_coupon_applications__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: coupon_applications fk_coupon_applications__updated_by_user_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_applications
    ADD CONSTRAINT fk_coupon_applications__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: coupon_rule_groups fk_coupon_rule_groups__coupon_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_rule_groups
    ADD CONSTRAINT fk_coupon_rule_groups__coupon_id FOREIGN KEY (coupon_id) REFERENCES coupons.coupons(coupon_id) DEFERRABLE;


--
-- Name: coupon_rule_groups fk_coupon_rule_groups__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_rule_groups
    ADD CONSTRAINT fk_coupon_rule_groups__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: coupon_rule_groups fk_coupon_rule_groups__created_by_user_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_rule_groups
    ADD CONSTRAINT fk_coupon_rule_groups__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: coupon_rule_groups fk_coupon_rule_groups__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_rule_groups
    ADD CONSTRAINT fk_coupon_rule_groups__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: coupon_rule_groups fk_coupon_rule_groups__updated_by_user_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_rule_groups
    ADD CONSTRAINT fk_coupon_rule_groups__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: coupon_rules fk_coupon_rules__coupon_rule_group_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_rules
    ADD CONSTRAINT fk_coupon_rules__coupon_rule_group_id FOREIGN KEY (coupon_rule_group_id) REFERENCES coupons.coupon_rule_groups(coupon_rule_group_id) DEFERRABLE;


--
-- Name: coupon_rules fk_coupon_rules__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_rules
    ADD CONSTRAINT fk_coupon_rules__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: coupon_rules fk_coupon_rules__created_by_user_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_rules
    ADD CONSTRAINT fk_coupon_rules__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: coupon_rules fk_coupon_rules__merchant_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_rules
    ADD CONSTRAINT fk_coupon_rules__merchant_id FOREIGN KEY (merchant_id) REFERENCES merchants.merchants(merchant_id) DEFERRABLE;


--
-- Name: coupon_rules fk_coupon_rules__site_group_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_rules
    ADD CONSTRAINT fk_coupon_rules__site_group_id FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id) DEFERRABLE;


--
-- Name: coupon_rules fk_coupon_rules__site_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_rules
    ADD CONSTRAINT fk_coupon_rules__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE;


--
-- Name: coupon_rules fk_coupon_rules__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_rules
    ADD CONSTRAINT fk_coupon_rules__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: coupon_rules fk_coupon_rules__updated_by_user_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupon_rules
    ADD CONSTRAINT fk_coupon_rules__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: coupons fk_coupons__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupons
    ADD CONSTRAINT fk_coupons__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: coupons fk_coupons__created_by_user_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupons
    ADD CONSTRAINT fk_coupons__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: coupons fk_coupons__merchant_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupons
    ADD CONSTRAINT fk_coupons__merchant_id FOREIGN KEY (merchant_id) REFERENCES merchants.merchants(merchant_id) DEFERRABLE;


--
-- Name: coupons fk_coupons__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupons
    ADD CONSTRAINT fk_coupons__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: coupons fk_coupons__updated_by_user_id; Type: FK CONSTRAINT; Schema: coupons; Owner: -
--

ALTER TABLE ONLY coupons.coupons
    ADD CONSTRAINT fk_coupons__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: discount_evidence_references fk_discount_evidence_references__captured_by_service_identit; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.discount_evidence_references
    ADD CONSTRAINT fk_discount_evidence_references__captured_by_service_identit FOREIGN KEY (captured_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: discount_evidence_references fk_discount_evidence_references__captured_by_user_id; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.discount_evidence_references
    ADD CONSTRAINT fk_discount_evidence_references__captured_by_user_id FOREIGN KEY (captured_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: discount_evidence_references fk_discount_evidence_references__created_by_service_identity; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.discount_evidence_references
    ADD CONSTRAINT fk_discount_evidence_references__created_by_service_identity FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: discount_evidence_references fk_discount_evidence_references__created_by_user_id; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.discount_evidence_references
    ADD CONSTRAINT fk_discount_evidence_references__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: discount_evidence_references fk_discount_evidence_references__purged_by_service_identity_; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.discount_evidence_references
    ADD CONSTRAINT fk_discount_evidence_references__purged_by_service_identity_ FOREIGN KEY (purged_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: discount_evidence_references fk_discount_evidence_references__purged_by_user_id; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.discount_evidence_references
    ADD CONSTRAINT fk_discount_evidence_references__purged_by_user_id FOREIGN KEY (purged_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: discount_evidence_references fk_discount_evidence_references__statutory_discount_validati; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.discount_evidence_references
    ADD CONSTRAINT fk_discount_evidence_references__statutory_discount_validati FOREIGN KEY (statutory_discount_validation_id) REFERENCES discounts.statutory_discount_validations(statutory_discount_validation_id) DEFERRABLE;


--
-- Name: discount_evidence_references fk_discount_evidence_references__updated_by_service_identity; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.discount_evidence_references
    ADD CONSTRAINT fk_discount_evidence_references__updated_by_service_identity FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: discount_evidence_references fk_discount_evidence_references__updated_by_user_id; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.discount_evidence_references
    ADD CONSTRAINT fk_discount_evidence_references__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: discount_policy_references fk_discount_policy_references__created_by_service_identity_i; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.discount_policy_references
    ADD CONSTRAINT fk_discount_policy_references__created_by_service_identity_i FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: discount_policy_references fk_discount_policy_references__created_by_user_id; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.discount_policy_references
    ADD CONSTRAINT fk_discount_policy_references__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: discount_policy_references fk_discount_policy_references__fallback_policy_reference_id; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.discount_policy_references
    ADD CONSTRAINT fk_discount_policy_references__fallback_policy_reference_id FOREIGN KEY (fallback_policy_reference_id) REFERENCES discounts.discount_policy_references(discount_policy_reference_id) DEFERRABLE;


--
-- Name: discount_policy_references fk_discount_policy_references__parent_policy_reference_id; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.discount_policy_references
    ADD CONSTRAINT fk_discount_policy_references__parent_policy_reference_id FOREIGN KEY (parent_policy_reference_id) REFERENCES discounts.discount_policy_references(discount_policy_reference_id) DEFERRABLE;


--
-- Name: discount_policy_references fk_discount_policy_references__site_group_id; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.discount_policy_references
    ADD CONSTRAINT fk_discount_policy_references__site_group_id FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id) DEFERRABLE;


--
-- Name: discount_policy_references fk_discount_policy_references__site_id; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.discount_policy_references
    ADD CONSTRAINT fk_discount_policy_references__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE;


--
-- Name: discount_policy_references fk_discount_policy_references__updated_by_service_identity_i; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.discount_policy_references
    ADD CONSTRAINT fk_discount_policy_references__updated_by_service_identity_i FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: discount_policy_references fk_discount_policy_references__updated_by_user_id; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.discount_policy_references
    ADD CONSTRAINT fk_discount_policy_references__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: statutory_discount_validations fk_statutory_discount_validations__applied_policy_reference_; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.statutory_discount_validations
    ADD CONSTRAINT fk_statutory_discount_validations__applied_policy_reference_ FOREIGN KEY (applied_policy_reference_id) REFERENCES discounts.discount_policy_references(discount_policy_reference_id) DEFERRABLE;


--
-- Name: statutory_discount_validations fk_statutory_discount_validations__created_by_service_identi; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.statutory_discount_validations
    ADD CONSTRAINT fk_statutory_discount_validations__created_by_service_identi FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: statutory_discount_validations fk_statutory_discount_validations__created_by_user_id; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.statutory_discount_validations
    ADD CONSTRAINT fk_statutory_discount_validations__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: statutory_discount_validations fk_statutory_discount_validations__evaluated_policy_referenc; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.statutory_discount_validations
    ADD CONSTRAINT fk_statutory_discount_validations__evaluated_policy_referenc FOREIGN KEY (evaluated_policy_reference_id) REFERENCES discounts.discount_policy_references(discount_policy_reference_id) DEFERRABLE;


--
-- Name: statutory_discount_validations fk_statutory_discount_validations__fallback_policy_reference; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.statutory_discount_validations
    ADD CONSTRAINT fk_statutory_discount_validations__fallback_policy_reference FOREIGN KEY (fallback_policy_reference_id) REFERENCES discounts.discount_policy_references(discount_policy_reference_id) DEFERRABLE;


--
-- Name: statutory_discount_validations fk_statutory_discount_validations__parking_session_id; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.statutory_discount_validations
    ADD CONSTRAINT fk_statutory_discount_validations__parking_session_id FOREIGN KEY (parking_session_id) REFERENCES core.parking_sessions(parking_session_id) DEFERRABLE;


--
-- Name: statutory_discount_validations fk_statutory_discount_validations__requested_by_service_iden; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.statutory_discount_validations
    ADD CONSTRAINT fk_statutory_discount_validations__requested_by_service_iden FOREIGN KEY (requested_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: statutory_discount_validations fk_statutory_discount_validations__requested_by_user_id; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.statutory_discount_validations
    ADD CONSTRAINT fk_statutory_discount_validations__requested_by_user_id FOREIGN KEY (requested_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: statutory_discount_validations fk_statutory_discount_validations__tariff_snapshot_id; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.statutory_discount_validations
    ADD CONSTRAINT fk_statutory_discount_validations__tariff_snapshot_id FOREIGN KEY (tariff_snapshot_id) REFERENCES core.tariff_snapshots(tariff_snapshot_id) DEFERRABLE;


--
-- Name: statutory_discount_validations fk_statutory_discount_validations__updated_by_service_identi; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.statutory_discount_validations
    ADD CONSTRAINT fk_statutory_discount_validations__updated_by_service_identi FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: statutory_discount_validations fk_statutory_discount_validations__updated_by_user_id; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.statutory_discount_validations
    ADD CONSTRAINT fk_statutory_discount_validations__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: statutory_discount_validations fk_statutory_discount_validations__validated_by_service_iden; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.statutory_discount_validations
    ADD CONSTRAINT fk_statutory_discount_validations__validated_by_service_iden FOREIGN KEY (validated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: statutory_discount_validations fk_statutory_discount_validations__validated_by_user_id; Type: FK CONSTRAINT; Schema: discounts; Owner: -
--

ALTER TABLE ONLY discounts.statutory_discount_validations
    ADD CONSTRAINT fk_statutory_discount_validations__validated_by_user_id FOREIGN KEY (validated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: consumer_checkpoints fk_consumer_checkpoints__last_domain_event_id; Type: FK CONSTRAINT; Schema: events; Owner: -
--

ALTER TABLE ONLY events.consumer_checkpoints
    ADD CONSTRAINT fk_consumer_checkpoints__last_domain_event_id FOREIGN KEY (last_domain_event_id) REFERENCES events.domain_events(domain_event_id) DEFERRABLE;


--
-- Name: consumer_checkpoints fk_consumer_checkpoints__last_outbox_event_id; Type: FK CONSTRAINT; Schema: events; Owner: -
--

ALTER TABLE ONLY events.consumer_checkpoints
    ADD CONSTRAINT fk_consumer_checkpoints__last_outbox_event_id FOREIGN KEY (last_outbox_event_id) REFERENCES events.outbox_events(outbox_event_id) DEFERRABLE;


--
-- Name: consumer_checkpoints fk_consumer_checkpoints__locked_by_service_identity_id; Type: FK CONSTRAINT; Schema: events; Owner: -
--

ALTER TABLE ONLY events.consumer_checkpoints
    ADD CONSTRAINT fk_consumer_checkpoints__locked_by_service_identity_id FOREIGN KEY (locked_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: consumer_checkpoints fk_consumer_checkpoints__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: events; Owner: -
--

ALTER TABLE ONLY events.consumer_checkpoints
    ADD CONSTRAINT fk_consumer_checkpoints__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: dead_letter_records fk_dead_letter_records__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: events; Owner: -
--

ALTER TABLE ONLY events.dead_letter_records
    ADD CONSTRAINT fk_dead_letter_records__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: dead_letter_records fk_dead_letter_records__event_publication_id; Type: FK CONSTRAINT; Schema: events; Owner: -
--

ALTER TABLE ONLY events.dead_letter_records
    ADD CONSTRAINT fk_dead_letter_records__event_publication_id FOREIGN KEY (event_publication_id) REFERENCES events.event_publications(event_publication_id) DEFERRABLE;


--
-- Name: dead_letter_records fk_dead_letter_records__outbox_event_id; Type: FK CONSTRAINT; Schema: events; Owner: -
--

ALTER TABLE ONLY events.dead_letter_records
    ADD CONSTRAINT fk_dead_letter_records__outbox_event_id FOREIGN KEY (outbox_event_id) REFERENCES events.outbox_events(outbox_event_id) DEFERRABLE;


--
-- Name: dead_letter_records fk_dead_letter_records__replay_requested_by_service_identity; Type: FK CONSTRAINT; Schema: events; Owner: -
--

ALTER TABLE ONLY events.dead_letter_records
    ADD CONSTRAINT fk_dead_letter_records__replay_requested_by_service_identity FOREIGN KEY (replay_requested_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: dead_letter_records fk_dead_letter_records__replay_requested_by_user_id; Type: FK CONSTRAINT; Schema: events; Owner: -
--

ALTER TABLE ONLY events.dead_letter_records
    ADD CONSTRAINT fk_dead_letter_records__replay_requested_by_user_id FOREIGN KEY (replay_requested_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: dead_letter_records fk_dead_letter_records__resolved_by_service_identity_id; Type: FK CONSTRAINT; Schema: events; Owner: -
--

ALTER TABLE ONLY events.dead_letter_records
    ADD CONSTRAINT fk_dead_letter_records__resolved_by_service_identity_id FOREIGN KEY (resolved_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: dead_letter_records fk_dead_letter_records__resolved_by_user_id; Type: FK CONSTRAINT; Schema: events; Owner: -
--

ALTER TABLE ONLY events.dead_letter_records
    ADD CONSTRAINT fk_dead_letter_records__resolved_by_user_id FOREIGN KEY (resolved_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: dead_letter_records fk_dead_letter_records__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: events; Owner: -
--

ALTER TABLE ONLY events.dead_letter_records
    ADD CONSTRAINT fk_dead_letter_records__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: dead_letter_records fk_dead_letter_records__updated_by_user_id; Type: FK CONSTRAINT; Schema: events; Owner: -
--

ALTER TABLE ONLY events.dead_letter_records
    ADD CONSTRAINT fk_dead_letter_records__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: domain_events fk_domain_events__actor_service_identity_id; Type: FK CONSTRAINT; Schema: events; Owner: -
--

ALTER TABLE ONLY events.domain_events
    ADD CONSTRAINT fk_domain_events__actor_service_identity_id FOREIGN KEY (actor_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: domain_events fk_domain_events__actor_user_id; Type: FK CONSTRAINT; Schema: events; Owner: -
--

ALTER TABLE ONLY events.domain_events
    ADD CONSTRAINT fk_domain_events__actor_user_id FOREIGN KEY (actor_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: domain_events fk_domain_events__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: events; Owner: -
--

ALTER TABLE ONLY events.domain_events
    ADD CONSTRAINT fk_domain_events__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: event_publications fk_event_publications__outbox_event_id; Type: FK CONSTRAINT; Schema: events; Owner: -
--

ALTER TABLE ONLY events.event_publications
    ADD CONSTRAINT fk_event_publications__outbox_event_id FOREIGN KEY (outbox_event_id) REFERENCES events.outbox_events(outbox_event_id) DEFERRABLE;


--
-- Name: event_publications fk_event_publications__publisher_service_identity_id; Type: FK CONSTRAINT; Schema: events; Owner: -
--

ALTER TABLE ONLY events.event_publications
    ADD CONSTRAINT fk_event_publications__publisher_service_identity_id FOREIGN KEY (publisher_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: outbox_events fk_outbox_events__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: events; Owner: -
--

ALTER TABLE ONLY events.outbox_events
    ADD CONSTRAINT fk_outbox_events__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: outbox_events fk_outbox_events__domain_event_id; Type: FK CONSTRAINT; Schema: events; Owner: -
--

ALTER TABLE ONLY events.outbox_events
    ADD CONSTRAINT fk_outbox_events__domain_event_id FOREIGN KEY (domain_event_id) REFERENCES events.domain_events(domain_event_id) DEFERRABLE;


--
-- Name: outbox_events fk_outbox_events__locked_by_service_identity_id; Type: FK CONSTRAINT; Schema: events; Owner: -
--

ALTER TABLE ONLY events.outbox_events
    ADD CONSTRAINT fk_outbox_events__locked_by_service_identity_id FOREIGN KEY (locked_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: outbox_events fk_outbox_events__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: events; Owner: -
--

ALTER TABLE ONLY events.outbox_events
    ADD CONSTRAINT fk_outbox_events__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: gate_authorization_consumptions fk_gate_authorization_consumptions__created_by_service_ident; Type: FK CONSTRAINT; Schema: gates; Owner: -
--

ALTER TABLE ONLY gates.gate_authorization_consumptions
    ADD CONSTRAINT fk_gate_authorization_consumptions__created_by_service_ident FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: gate_authorization_consumptions fk_gate_authorization_consumptions__exit_authorization_id; Type: FK CONSTRAINT; Schema: gates; Owner: -
--

ALTER TABLE ONLY gates.gate_authorization_consumptions
    ADD CONSTRAINT fk_gate_authorization_consumptions__exit_authorization_id FOREIGN KEY (exit_authorization_id) REFERENCES core.exit_authorizations(exit_authorization_id) DEFERRABLE;


--
-- Name: gate_authorization_consumptions fk_gate_authorization_consumptions__gate_device_id; Type: FK CONSTRAINT; Schema: gates; Owner: -
--

ALTER TABLE ONLY gates.gate_authorization_consumptions
    ADD CONSTRAINT fk_gate_authorization_consumptions__gate_device_id FOREIGN KEY (gate_device_id) REFERENCES gates.gate_devices(gate_device_id) DEFERRABLE;


--
-- Name: gate_authorization_consumptions fk_gate_authorization_consumptions__lane_id; Type: FK CONSTRAINT; Schema: gates; Owner: -
--

ALTER TABLE ONLY gates.gate_authorization_consumptions
    ADD CONSTRAINT fk_gate_authorization_consumptions__lane_id FOREIGN KEY (lane_id) REFERENCES sites.lanes(lane_id) DEFERRABLE;


--
-- Name: gate_authorization_consumptions fk_gate_authorization_consumptions__site_id; Type: FK CONSTRAINT; Schema: gates; Owner: -
--

ALTER TABLE ONLY gates.gate_authorization_consumptions
    ADD CONSTRAINT fk_gate_authorization_consumptions__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE;


--
-- Name: gate_authorization_consumptions fk_gate_authorization_consumptions__updated_by_service_ident; Type: FK CONSTRAINT; Schema: gates; Owner: -
--

ALTER TABLE ONLY gates.gate_authorization_consumptions
    ADD CONSTRAINT fk_gate_authorization_consumptions__updated_by_service_ident FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: gate_devices fk_gate_devices__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: gates; Owner: -
--

ALTER TABLE ONLY gates.gate_devices
    ADD CONSTRAINT fk_gate_devices__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: gate_devices fk_gate_devices__created_by_user_id; Type: FK CONSTRAINT; Schema: gates; Owner: -
--

ALTER TABLE ONLY gates.gate_devices
    ADD CONSTRAINT fk_gate_devices__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: gate_devices fk_gate_devices__lane_id; Type: FK CONSTRAINT; Schema: gates; Owner: -
--

ALTER TABLE ONLY gates.gate_devices
    ADD CONSTRAINT fk_gate_devices__lane_id FOREIGN KEY (lane_id) REFERENCES sites.lanes(lane_id) DEFERRABLE;


--
-- Name: gate_devices fk_gate_devices__service_identity_id; Type: FK CONSTRAINT; Schema: gates; Owner: -
--

ALTER TABLE ONLY gates.gate_devices
    ADD CONSTRAINT fk_gate_devices__service_identity_id FOREIGN KEY (service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: gate_devices fk_gate_devices__site_id; Type: FK CONSTRAINT; Schema: gates; Owner: -
--

ALTER TABLE ONLY gates.gate_devices
    ADD CONSTRAINT fk_gate_devices__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE;


--
-- Name: gate_devices fk_gate_devices__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: gates; Owner: -
--

ALTER TABLE ONLY gates.gate_devices
    ADD CONSTRAINT fk_gate_devices__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: gate_devices fk_gate_devices__updated_by_user_id; Type: FK CONSTRAINT; Schema: gates; Owner: -
--

ALTER TABLE ONLY gates.gate_devices
    ADD CONSTRAINT fk_gate_devices__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: gate_events fk_gate_events__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: gates; Owner: -
--

ALTER TABLE ONLY gates.gate_events
    ADD CONSTRAINT fk_gate_events__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: gate_events fk_gate_events__exit_authorization_id; Type: FK CONSTRAINT; Schema: gates; Owner: -
--

ALTER TABLE ONLY gates.gate_events
    ADD CONSTRAINT fk_gate_events__exit_authorization_id FOREIGN KEY (exit_authorization_id) REFERENCES core.exit_authorizations(exit_authorization_id) DEFERRABLE;


--
-- Name: gate_events fk_gate_events__gate_authorization_consumption_id; Type: FK CONSTRAINT; Schema: gates; Owner: -
--

ALTER TABLE ONLY gates.gate_events
    ADD CONSTRAINT fk_gate_events__gate_authorization_consumption_id FOREIGN KEY (gate_authorization_consumption_id) REFERENCES gates.gate_authorization_consumptions(gate_authorization_consumption_id) DEFERRABLE;


--
-- Name: gate_events fk_gate_events__gate_device_id; Type: FK CONSTRAINT; Schema: gates; Owner: -
--

ALTER TABLE ONLY gates.gate_events
    ADD CONSTRAINT fk_gate_events__gate_device_id FOREIGN KEY (gate_device_id) REFERENCES gates.gate_devices(gate_device_id) DEFERRABLE;


--
-- Name: gate_events fk_gate_events__lane_id; Type: FK CONSTRAINT; Schema: gates; Owner: -
--

ALTER TABLE ONLY gates.gate_events
    ADD CONSTRAINT fk_gate_events__lane_id FOREIGN KEY (lane_id) REFERENCES sites.lanes(lane_id) DEFERRABLE;


--
-- Name: gate_events fk_gate_events__site_id; Type: FK CONSTRAINT; Schema: gates; Owner: -
--

ALTER TABLE ONLY gates.gate_events
    ADD CONSTRAINT fk_gate_events__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE;


--
-- Name: gate_heartbeats fk_gate_heartbeats__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: gates; Owner: -
--

ALTER TABLE ONLY gates.gate_heartbeats
    ADD CONSTRAINT fk_gate_heartbeats__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: gate_heartbeats fk_gate_heartbeats__gate_device_id; Type: FK CONSTRAINT; Schema: gates; Owner: -
--

ALTER TABLE ONLY gates.gate_heartbeats
    ADD CONSTRAINT fk_gate_heartbeats__gate_device_id FOREIGN KEY (gate_device_id) REFERENCES gates.gate_devices(gate_device_id) DEFERRABLE;


--
-- Name: gate_heartbeats fk_gate_heartbeats__lane_id; Type: FK CONSTRAINT; Schema: gates; Owner: -
--

ALTER TABLE ONLY gates.gate_heartbeats
    ADD CONSTRAINT fk_gate_heartbeats__lane_id FOREIGN KEY (lane_id) REFERENCES sites.lanes(lane_id) DEFERRABLE;


--
-- Name: gate_heartbeats fk_gate_heartbeats__site_id; Type: FK CONSTRAINT; Schema: gates; Owner: -
--

ALTER TABLE ONLY gates.gate_heartbeats
    ADD CONSTRAINT fk_gate_heartbeats__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE;


--
-- Name: permissions fk_permissions__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.permissions
    ADD CONSTRAINT fk_permissions__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: permissions fk_permissions__created_by_user_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.permissions
    ADD CONSTRAINT fk_permissions__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: permissions fk_permissions__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.permissions
    ADD CONSTRAINT fk_permissions__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: permissions fk_permissions__updated_by_user_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.permissions
    ADD CONSTRAINT fk_permissions__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: role_permissions fk_role_permissions__assigned_by_service_identity_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.role_permissions
    ADD CONSTRAINT fk_role_permissions__assigned_by_service_identity_id FOREIGN KEY (assigned_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: role_permissions fk_role_permissions__assigned_by_user_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.role_permissions
    ADD CONSTRAINT fk_role_permissions__assigned_by_user_id FOREIGN KEY (assigned_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: role_permissions fk_role_permissions__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.role_permissions
    ADD CONSTRAINT fk_role_permissions__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: role_permissions fk_role_permissions__created_by_user_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.role_permissions
    ADD CONSTRAINT fk_role_permissions__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: role_permissions fk_role_permissions__permission_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.role_permissions
    ADD CONSTRAINT fk_role_permissions__permission_id FOREIGN KEY (permission_id) REFERENCES identity.permissions(permission_id) DEFERRABLE;


--
-- Name: role_permissions fk_role_permissions__revoked_by_service_identity_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.role_permissions
    ADD CONSTRAINT fk_role_permissions__revoked_by_service_identity_id FOREIGN KEY (revoked_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: role_permissions fk_role_permissions__revoked_by_user_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.role_permissions
    ADD CONSTRAINT fk_role_permissions__revoked_by_user_id FOREIGN KEY (revoked_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: role_permissions fk_role_permissions__role_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.role_permissions
    ADD CONSTRAINT fk_role_permissions__role_id FOREIGN KEY (role_id) REFERENCES identity.roles(role_id) DEFERRABLE;


--
-- Name: role_permissions fk_role_permissions__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.role_permissions
    ADD CONSTRAINT fk_role_permissions__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: role_permissions fk_role_permissions__updated_by_user_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.role_permissions
    ADD CONSTRAINT fk_role_permissions__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: roles fk_roles__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.roles
    ADD CONSTRAINT fk_roles__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: roles fk_roles__created_by_user_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.roles
    ADD CONSTRAINT fk_roles__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: roles fk_roles__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.roles
    ADD CONSTRAINT fk_roles__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: roles fk_roles__updated_by_user_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.roles
    ADD CONSTRAINT fk_roles__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: service_identities fk_service_identities__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.service_identities
    ADD CONSTRAINT fk_service_identities__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: service_identities fk_service_identities__created_by_user_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.service_identities
    ADD CONSTRAINT fk_service_identities__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: service_identities fk_service_identities__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.service_identities
    ADD CONSTRAINT fk_service_identities__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: service_identities fk_service_identities__updated_by_user_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.service_identities
    ADD CONSTRAINT fk_service_identities__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: user_roles fk_user_roles__assigned_by_service_identity_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.user_roles
    ADD CONSTRAINT fk_user_roles__assigned_by_service_identity_id FOREIGN KEY (assigned_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: user_roles fk_user_roles__assigned_by_user_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.user_roles
    ADD CONSTRAINT fk_user_roles__assigned_by_user_id FOREIGN KEY (assigned_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: user_roles fk_user_roles__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.user_roles
    ADD CONSTRAINT fk_user_roles__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: user_roles fk_user_roles__created_by_user_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.user_roles
    ADD CONSTRAINT fk_user_roles__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: user_roles fk_user_roles__last_reviewed_by_user_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.user_roles
    ADD CONSTRAINT fk_user_roles__last_reviewed_by_user_id FOREIGN KEY (last_reviewed_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: user_roles fk_user_roles__revoked_by_service_identity_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.user_roles
    ADD CONSTRAINT fk_user_roles__revoked_by_service_identity_id FOREIGN KEY (revoked_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: user_roles fk_user_roles__revoked_by_user_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.user_roles
    ADD CONSTRAINT fk_user_roles__revoked_by_user_id FOREIGN KEY (revoked_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: user_roles fk_user_roles__role_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.user_roles
    ADD CONSTRAINT fk_user_roles__role_id FOREIGN KEY (role_id) REFERENCES identity.roles(role_id) DEFERRABLE;


--
-- Name: user_roles fk_user_roles__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.user_roles
    ADD CONSTRAINT fk_user_roles__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: user_roles fk_user_roles__updated_by_user_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.user_roles
    ADD CONSTRAINT fk_user_roles__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: user_roles fk_user_roles__user_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.user_roles
    ADD CONSTRAINT fk_user_roles__user_id FOREIGN KEY (user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: users fk_users__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.users
    ADD CONSTRAINT fk_users__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: users fk_users__created_by_user_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.users
    ADD CONSTRAINT fk_users__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: users fk_users__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.users
    ADD CONSTRAINT fk_users__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: users fk_users__updated_by_user_id; Type: FK CONSTRAINT; Schema: identity; Owner: -
--

ALTER TABLE ONLY identity.users
    ADD CONSTRAINT fk_users__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: adapter_mappings fk_adapter_mappings__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.adapter_mappings
    ADD CONSTRAINT fk_adapter_mappings__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: adapter_mappings fk_adapter_mappings__created_by_user_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.adapter_mappings
    ADD CONSTRAINT fk_adapter_mappings__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: adapter_mappings fk_adapter_mappings__gate_device_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.adapter_mappings
    ADD CONSTRAINT fk_adapter_mappings__gate_device_id FOREIGN KEY (gate_device_id) REFERENCES gates.gate_devices(gate_device_id) DEFERRABLE;


--
-- Name: adapter_mappings fk_adapter_mappings__lane_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.adapter_mappings
    ADD CONSTRAINT fk_adapter_mappings__lane_id FOREIGN KEY (lane_id) REFERENCES sites.lanes(lane_id) DEFERRABLE;


--
-- Name: adapter_mappings fk_adapter_mappings__payment_rail_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.adapter_mappings
    ADD CONSTRAINT fk_adapter_mappings__payment_rail_id FOREIGN KEY (payment_rail_id) REFERENCES payments.payment_rails(payment_rail_id) DEFERRABLE;


--
-- Name: adapter_mappings fk_adapter_mappings__site_group_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.adapter_mappings
    ADD CONSTRAINT fk_adapter_mappings__site_group_id FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id) DEFERRABLE;


--
-- Name: adapter_mappings fk_adapter_mappings__site_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.adapter_mappings
    ADD CONSTRAINT fk_adapter_mappings__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE;


--
-- Name: adapter_mappings fk_adapter_mappings__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.adapter_mappings
    ADD CONSTRAINT fk_adapter_mappings__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: adapter_mappings fk_adapter_mappings__updated_by_user_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.adapter_mappings
    ADD CONSTRAINT fk_adapter_mappings__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: adapter_mappings fk_adapter_mappings__vendor_system_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.adapter_mappings
    ADD CONSTRAINT fk_adapter_mappings__vendor_system_id FOREIGN KEY (vendor_system_id) REFERENCES integration.vendor_systems(vendor_system_id) DEFERRABLE;


--
-- Name: integration_credential_references fk_integration_credential_references__created_by_service_ide; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.integration_credential_references
    ADD CONSTRAINT fk_integration_credential_references__created_by_service_ide FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: integration_credential_references fk_integration_credential_references__created_by_user_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.integration_credential_references
    ADD CONSTRAINT fk_integration_credential_references__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: integration_credential_references fk_integration_credential_references__service_identity_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.integration_credential_references
    ADD CONSTRAINT fk_integration_credential_references__service_identity_id FOREIGN KEY (service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: integration_credential_references fk_integration_credential_references__updated_by_service_ide; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.integration_credential_references
    ADD CONSTRAINT fk_integration_credential_references__updated_by_service_ide FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: integration_credential_references fk_integration_credential_references__updated_by_user_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.integration_credential_references
    ADD CONSTRAINT fk_integration_credential_references__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: integration_credential_references fk_integration_credential_references__vendor_system_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.integration_credential_references
    ADD CONSTRAINT fk_integration_credential_references__vendor_system_id FOREIGN KEY (vendor_system_id) REFERENCES integration.vendor_systems(vendor_system_id) DEFERRABLE;


--
-- Name: integration_health_records fk_integration_health_records__incident_record_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.integration_health_records
    ADD CONSTRAINT fk_integration_health_records__incident_record_id FOREIGN KEY (incident_record_id) REFERENCES operations.incident_records(incident_record_id) DEFERRABLE;


--
-- Name: integration_health_records fk_integration_health_records__observed_by_service_identity_; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.integration_health_records
    ADD CONSTRAINT fk_integration_health_records__observed_by_service_identity_ FOREIGN KEY (observed_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: integration_health_records fk_integration_health_records__site_group_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.integration_health_records
    ADD CONSTRAINT fk_integration_health_records__site_group_id FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id) DEFERRABLE;


--
-- Name: integration_health_records fk_integration_health_records__site_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.integration_health_records
    ADD CONSTRAINT fk_integration_health_records__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE;


--
-- Name: integration_health_records fk_integration_health_records__vendor_endpoint_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.integration_health_records
    ADD CONSTRAINT fk_integration_health_records__vendor_endpoint_id FOREIGN KEY (vendor_endpoint_id) REFERENCES integration.vendor_endpoints(vendor_endpoint_id) DEFERRABLE;


--
-- Name: integration_health_records fk_integration_health_records__vendor_system_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.integration_health_records
    ADD CONSTRAINT fk_integration_health_records__vendor_system_id FOREIGN KEY (vendor_system_id) REFERENCES integration.vendor_systems(vendor_system_id) DEFERRABLE;


--
-- Name: vendor_endpoints fk_vendor_endpoints__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.vendor_endpoints
    ADD CONSTRAINT fk_vendor_endpoints__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: vendor_endpoints fk_vendor_endpoints__created_by_user_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.vendor_endpoints
    ADD CONSTRAINT fk_vendor_endpoints__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: vendor_endpoints fk_vendor_endpoints__credential_reference_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.vendor_endpoints
    ADD CONSTRAINT fk_vendor_endpoints__credential_reference_id FOREIGN KEY (credential_reference_id) REFERENCES integration.integration_credential_references(integration_credential_reference_id) DEFERRABLE;


--
-- Name: vendor_endpoints fk_vendor_endpoints__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.vendor_endpoints
    ADD CONSTRAINT fk_vendor_endpoints__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: vendor_endpoints fk_vendor_endpoints__updated_by_user_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.vendor_endpoints
    ADD CONSTRAINT fk_vendor_endpoints__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: vendor_endpoints fk_vendor_endpoints__vendor_system_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.vendor_endpoints
    ADD CONSTRAINT fk_vendor_endpoints__vendor_system_id FOREIGN KEY (vendor_system_id) REFERENCES integration.vendor_systems(vendor_system_id) DEFERRABLE;


--
-- Name: vendor_systems fk_vendor_systems__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.vendor_systems
    ADD CONSTRAINT fk_vendor_systems__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: vendor_systems fk_vendor_systems__created_by_user_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.vendor_systems
    ADD CONSTRAINT fk_vendor_systems__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: vendor_systems fk_vendor_systems__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.vendor_systems
    ADD CONSTRAINT fk_vendor_systems__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: vendor_systems fk_vendor_systems__updated_by_user_id; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.vendor_systems
    ADD CONSTRAINT fk_vendor_systems__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: merchant_site_scopes fk_merchant_site_scopes__approved_by_user_id; Type: FK CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchant_site_scopes
    ADD CONSTRAINT fk_merchant_site_scopes__approved_by_user_id FOREIGN KEY (approved_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: merchant_site_scopes fk_merchant_site_scopes__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchant_site_scopes
    ADD CONSTRAINT fk_merchant_site_scopes__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: merchant_site_scopes fk_merchant_site_scopes__created_by_user_id; Type: FK CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchant_site_scopes
    ADD CONSTRAINT fk_merchant_site_scopes__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: merchant_site_scopes fk_merchant_site_scopes__merchant_id; Type: FK CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchant_site_scopes
    ADD CONSTRAINT fk_merchant_site_scopes__merchant_id FOREIGN KEY (merchant_id) REFERENCES merchants.merchants(merchant_id) DEFERRABLE;


--
-- Name: merchant_site_scopes fk_merchant_site_scopes__site_group_id; Type: FK CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchant_site_scopes
    ADD CONSTRAINT fk_merchant_site_scopes__site_group_id FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id) DEFERRABLE;


--
-- Name: merchant_site_scopes fk_merchant_site_scopes__site_id; Type: FK CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchant_site_scopes
    ADD CONSTRAINT fk_merchant_site_scopes__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE;


--
-- Name: merchant_site_scopes fk_merchant_site_scopes__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchant_site_scopes
    ADD CONSTRAINT fk_merchant_site_scopes__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: merchant_site_scopes fk_merchant_site_scopes__updated_by_user_id; Type: FK CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchant_site_scopes
    ADD CONSTRAINT fk_merchant_site_scopes__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: merchant_users fk_merchant_users__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchant_users
    ADD CONSTRAINT fk_merchant_users__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: merchant_users fk_merchant_users__created_by_user_id; Type: FK CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchant_users
    ADD CONSTRAINT fk_merchant_users__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: merchant_users fk_merchant_users__merchant_id; Type: FK CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchant_users
    ADD CONSTRAINT fk_merchant_users__merchant_id FOREIGN KEY (merchant_id) REFERENCES merchants.merchants(merchant_id) DEFERRABLE;


--
-- Name: merchant_users fk_merchant_users__revoked_by_user_id; Type: FK CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchant_users
    ADD CONSTRAINT fk_merchant_users__revoked_by_user_id FOREIGN KEY (revoked_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: merchant_users fk_merchant_users__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchant_users
    ADD CONSTRAINT fk_merchant_users__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: merchant_users fk_merchant_users__updated_by_user_id; Type: FK CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchant_users
    ADD CONSTRAINT fk_merchant_users__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: merchant_users fk_merchant_users__user_id; Type: FK CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchant_users
    ADD CONSTRAINT fk_merchant_users__user_id FOREIGN KEY (user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: merchant_wallets fk_merchant_wallets__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchant_wallets
    ADD CONSTRAINT fk_merchant_wallets__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: merchant_wallets fk_merchant_wallets__created_by_user_id; Type: FK CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchant_wallets
    ADD CONSTRAINT fk_merchant_wallets__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: merchant_wallets fk_merchant_wallets__merchant_id; Type: FK CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchant_wallets
    ADD CONSTRAINT fk_merchant_wallets__merchant_id FOREIGN KEY (merchant_id) REFERENCES merchants.merchants(merchant_id) DEFERRABLE;


--
-- Name: merchant_wallets fk_merchant_wallets__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchant_wallets
    ADD CONSTRAINT fk_merchant_wallets__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: merchant_wallets fk_merchant_wallets__updated_by_user_id; Type: FK CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchant_wallets
    ADD CONSTRAINT fk_merchant_wallets__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: merchants fk_merchants__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchants
    ADD CONSTRAINT fk_merchants__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: merchants fk_merchants__created_by_user_id; Type: FK CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchants
    ADD CONSTRAINT fk_merchants__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: merchants fk_merchants__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchants
    ADD CONSTRAINT fk_merchants__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: merchants fk_merchants__updated_by_user_id; Type: FK CONSTRAINT; Schema: merchants; Owner: -
--

ALTER TABLE ONLY merchants.merchants
    ADD CONSTRAINT fk_merchants__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: incident_records fk_incident_records__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.incident_records
    ADD CONSTRAINT fk_incident_records__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: incident_records fk_incident_records__created_by_user_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.incident_records
    ADD CONSTRAINT fk_incident_records__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: incident_records fk_incident_records__gate_device_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.incident_records
    ADD CONSTRAINT fk_incident_records__gate_device_id FOREIGN KEY (gate_device_id) REFERENCES gates.gate_devices(gate_device_id) DEFERRABLE;


--
-- Name: incident_records fk_incident_records__lane_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.incident_records
    ADD CONSTRAINT fk_incident_records__lane_id FOREIGN KEY (lane_id) REFERENCES sites.lanes(lane_id) DEFERRABLE;


--
-- Name: incident_records fk_incident_records__owner_service_identity_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.incident_records
    ADD CONSTRAINT fk_incident_records__owner_service_identity_id FOREIGN KEY (owner_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: incident_records fk_incident_records__owner_user_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.incident_records
    ADD CONSTRAINT fk_incident_records__owner_user_id FOREIGN KEY (owner_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: incident_records fk_incident_records__payment_rail_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.incident_records
    ADD CONSTRAINT fk_incident_records__payment_rail_id FOREIGN KEY (payment_rail_id) REFERENCES payments.payment_rails(payment_rail_id) DEFERRABLE;


--
-- Name: incident_records fk_incident_records__site_group_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.incident_records
    ADD CONSTRAINT fk_incident_records__site_group_id FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id) DEFERRABLE;


--
-- Name: incident_records fk_incident_records__site_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.incident_records
    ADD CONSTRAINT fk_incident_records__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE;


--
-- Name: incident_records fk_incident_records__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.incident_records
    ADD CONSTRAINT fk_incident_records__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: incident_records fk_incident_records__updated_by_user_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.incident_records
    ADD CONSTRAINT fk_incident_records__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: incident_records fk_incident_records__vendor_system_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.incident_records
    ADD CONSTRAINT fk_incident_records__vendor_system_id FOREIGN KEY (vendor_system_id) REFERENCES integration.vendor_systems(vendor_system_id) DEFERRABLE;


--
-- Name: manual_gate_logs fk_manual_gate_logs__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.manual_gate_logs
    ADD CONSTRAINT fk_manual_gate_logs__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: manual_gate_logs fk_manual_gate_logs__created_by_user_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.manual_gate_logs
    ADD CONSTRAINT fk_manual_gate_logs__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: manual_gate_logs fk_manual_gate_logs__exit_authorization_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.manual_gate_logs
    ADD CONSTRAINT fk_manual_gate_logs__exit_authorization_id FOREIGN KEY (exit_authorization_id) REFERENCES core.exit_authorizations(exit_authorization_id) DEFERRABLE;


--
-- Name: manual_gate_logs fk_manual_gate_logs__gate_authorization_consumption_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.manual_gate_logs
    ADD CONSTRAINT fk_manual_gate_logs__gate_authorization_consumption_id FOREIGN KEY (gate_authorization_consumption_id) REFERENCES gates.gate_authorization_consumptions(gate_authorization_consumption_id) DEFERRABLE;


--
-- Name: manual_gate_logs fk_manual_gate_logs__gate_device_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.manual_gate_logs
    ADD CONSTRAINT fk_manual_gate_logs__gate_device_id FOREIGN KEY (gate_device_id) REFERENCES gates.gate_devices(gate_device_id) DEFERRABLE;


--
-- Name: manual_gate_logs fk_manual_gate_logs__incident_record_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.manual_gate_logs
    ADD CONSTRAINT fk_manual_gate_logs__incident_record_id FOREIGN KEY (incident_record_id) REFERENCES operations.incident_records(incident_record_id) DEFERRABLE;


--
-- Name: manual_gate_logs fk_manual_gate_logs__lane_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.manual_gate_logs
    ADD CONSTRAINT fk_manual_gate_logs__lane_id FOREIGN KEY (lane_id) REFERENCES sites.lanes(lane_id) DEFERRABLE;


--
-- Name: manual_gate_logs fk_manual_gate_logs__override_approval_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.manual_gate_logs
    ADD CONSTRAINT fk_manual_gate_logs__override_approval_id FOREIGN KEY (override_approval_id) REFERENCES operations.override_approvals(override_approval_id) DEFERRABLE;


--
-- Name: manual_gate_logs fk_manual_gate_logs__parking_session_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.manual_gate_logs
    ADD CONSTRAINT fk_manual_gate_logs__parking_session_id FOREIGN KEY (parking_session_id) REFERENCES core.parking_sessions(parking_session_id) DEFERRABLE;


--
-- Name: manual_gate_logs fk_manual_gate_logs__performed_by_user_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.manual_gate_logs
    ADD CONSTRAINT fk_manual_gate_logs__performed_by_user_id FOREIGN KEY (performed_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: manual_gate_logs fk_manual_gate_logs__reconciliation_item_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.manual_gate_logs
    ADD CONSTRAINT fk_manual_gate_logs__reconciliation_item_id FOREIGN KEY (reconciliation_item_id) REFERENCES reconciliation.reconciliation_items(reconciliation_item_id) DEFERRABLE;


--
-- Name: manual_gate_logs fk_manual_gate_logs__recorded_by_service_identity_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.manual_gate_logs
    ADD CONSTRAINT fk_manual_gate_logs__recorded_by_service_identity_id FOREIGN KEY (recorded_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: manual_gate_logs fk_manual_gate_logs__recorded_by_user_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.manual_gate_logs
    ADD CONSTRAINT fk_manual_gate_logs__recorded_by_user_id FOREIGN KEY (recorded_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: manual_gate_logs fk_manual_gate_logs__site_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.manual_gate_logs
    ADD CONSTRAINT fk_manual_gate_logs__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE;


--
-- Name: manual_gate_logs fk_manual_gate_logs__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.manual_gate_logs
    ADD CONSTRAINT fk_manual_gate_logs__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: manual_gate_logs fk_manual_gate_logs__updated_by_user_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.manual_gate_logs
    ADD CONSTRAINT fk_manual_gate_logs__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: operator_action_logs fk_operator_action_logs__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.operator_action_logs
    ADD CONSTRAINT fk_operator_action_logs__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: operator_action_logs fk_operator_action_logs__created_by_user_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.operator_action_logs
    ADD CONSTRAINT fk_operator_action_logs__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: operator_action_logs fk_operator_action_logs__incident_record_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.operator_action_logs
    ADD CONSTRAINT fk_operator_action_logs__incident_record_id FOREIGN KEY (incident_record_id) REFERENCES operations.incident_records(incident_record_id) DEFERRABLE;


--
-- Name: operator_action_logs fk_operator_action_logs__operator_user_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.operator_action_logs
    ADD CONSTRAINT fk_operator_action_logs__operator_user_id FOREIGN KEY (operator_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: operator_action_logs fk_operator_action_logs__site_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.operator_action_logs
    ADD CONSTRAINT fk_operator_action_logs__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE;


--
-- Name: override_approvals fk_override_approvals__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.override_approvals
    ADD CONSTRAINT fk_override_approvals__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: override_approvals fk_override_approvals__created_by_user_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.override_approvals
    ADD CONSTRAINT fk_override_approvals__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: override_approvals fk_override_approvals__decided_by_user_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.override_approvals
    ADD CONSTRAINT fk_override_approvals__decided_by_user_id FOREIGN KEY (decided_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: override_approvals fk_override_approvals__override_request_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.override_approvals
    ADD CONSTRAINT fk_override_approvals__override_request_id FOREIGN KEY (override_request_id) REFERENCES operations.override_requests(override_request_id) DEFERRABLE;


--
-- Name: override_requests fk_override_requests__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.override_requests
    ADD CONSTRAINT fk_override_requests__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: override_requests fk_override_requests__created_by_user_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.override_requests
    ADD CONSTRAINT fk_override_requests__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: override_requests fk_override_requests__incident_record_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.override_requests
    ADD CONSTRAINT fk_override_requests__incident_record_id FOREIGN KEY (incident_record_id) REFERENCES operations.incident_records(incident_record_id) DEFERRABLE;


--
-- Name: override_requests fk_override_requests__lane_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.override_requests
    ADD CONSTRAINT fk_override_requests__lane_id FOREIGN KEY (lane_id) REFERENCES sites.lanes(lane_id) DEFERRABLE;


--
-- Name: override_requests fk_override_requests__requested_by_user_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.override_requests
    ADD CONSTRAINT fk_override_requests__requested_by_user_id FOREIGN KEY (requested_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: override_requests fk_override_requests__site_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.override_requests
    ADD CONSTRAINT fk_override_requests__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE;


--
-- Name: override_requests fk_override_requests__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.override_requests
    ADD CONSTRAINT fk_override_requests__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: override_requests fk_override_requests__updated_by_user_id; Type: FK CONSTRAINT; Schema: operations; Owner: -
--

ALTER TABLE ONLY operations.override_requests
    ADD CONSTRAINT fk_override_requests__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: payment_rails fk_payment_rails__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.payment_rails
    ADD CONSTRAINT fk_payment_rails__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: payment_rails fk_payment_rails__created_by_user_id; Type: FK CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.payment_rails
    ADD CONSTRAINT fk_payment_rails__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: payment_rails fk_payment_rails__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.payment_rails
    ADD CONSTRAINT fk_payment_rails__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: payment_rails fk_payment_rails__updated_by_user_id; Type: FK CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.payment_rails
    ADD CONSTRAINT fk_payment_rails__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: provider_callbacks fk_provider_callbacks__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.provider_callbacks
    ADD CONSTRAINT fk_provider_callbacks__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: provider_callbacks fk_provider_callbacks__payment_attempt_id; Type: FK CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.provider_callbacks
    ADD CONSTRAINT fk_provider_callbacks__payment_attempt_id FOREIGN KEY (payment_attempt_id) REFERENCES core.payment_attempts(payment_attempt_id) DEFERRABLE;


--
-- Name: provider_callbacks fk_provider_callbacks__payment_rail_id; Type: FK CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.provider_callbacks
    ADD CONSTRAINT fk_provider_callbacks__payment_rail_id FOREIGN KEY (payment_rail_id) REFERENCES payments.payment_rails(payment_rail_id) DEFERRABLE;


--
-- Name: provider_callbacks fk_provider_callbacks__provider_session_id; Type: FK CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.provider_callbacks
    ADD CONSTRAINT fk_provider_callbacks__provider_session_id FOREIGN KEY (provider_session_id) REFERENCES payments.provider_sessions(provider_session_id) DEFERRABLE;


--
-- Name: provider_outcomes fk_provider_outcomes__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.provider_outcomes
    ADD CONSTRAINT fk_provider_outcomes__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: provider_outcomes fk_provider_outcomes__payment_attempt_id; Type: FK CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.provider_outcomes
    ADD CONSTRAINT fk_provider_outcomes__payment_attempt_id FOREIGN KEY (payment_attempt_id) REFERENCES core.payment_attempts(payment_attempt_id) DEFERRABLE;


--
-- Name: provider_outcomes fk_provider_outcomes__payment_rail_id; Type: FK CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.provider_outcomes
    ADD CONSTRAINT fk_provider_outcomes__payment_rail_id FOREIGN KEY (payment_rail_id) REFERENCES payments.payment_rails(payment_rail_id) DEFERRABLE;


--
-- Name: provider_outcomes fk_provider_outcomes__provider_callback_id; Type: FK CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.provider_outcomes
    ADD CONSTRAINT fk_provider_outcomes__provider_callback_id FOREIGN KEY (provider_callback_id) REFERENCES payments.provider_callbacks(provider_callback_id) DEFERRABLE;


--
-- Name: provider_outcomes fk_provider_outcomes__provider_session_id; Type: FK CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.provider_outcomes
    ADD CONSTRAINT fk_provider_outcomes__provider_session_id FOREIGN KEY (provider_session_id) REFERENCES payments.provider_sessions(provider_session_id) DEFERRABLE;


--
-- Name: provider_outcomes fk_provider_outcomes__provider_status_query_id; Type: FK CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.provider_outcomes
    ADD CONSTRAINT fk_provider_outcomes__provider_status_query_id FOREIGN KEY (provider_status_query_id) REFERENCES payments.provider_status_queries(provider_status_query_id) DEFERRABLE;


--
-- Name: provider_outcomes fk_provider_outcomes__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.provider_outcomes
    ADD CONSTRAINT fk_provider_outcomes__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: provider_sessions fk_provider_sessions__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.provider_sessions
    ADD CONSTRAINT fk_provider_sessions__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: provider_sessions fk_provider_sessions__payment_attempt_id; Type: FK CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.provider_sessions
    ADD CONSTRAINT fk_provider_sessions__payment_attempt_id FOREIGN KEY (payment_attempt_id) REFERENCES core.payment_attempts(payment_attempt_id) DEFERRABLE;


--
-- Name: provider_sessions fk_provider_sessions__payment_rail_id; Type: FK CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.provider_sessions
    ADD CONSTRAINT fk_provider_sessions__payment_rail_id FOREIGN KEY (payment_rail_id) REFERENCES payments.payment_rails(payment_rail_id) DEFERRABLE;


--
-- Name: provider_sessions fk_provider_sessions__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.provider_sessions
    ADD CONSTRAINT fk_provider_sessions__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: provider_status_queries fk_provider_status_queries__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.provider_status_queries
    ADD CONSTRAINT fk_provider_status_queries__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: provider_status_queries fk_provider_status_queries__payment_attempt_id; Type: FK CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.provider_status_queries
    ADD CONSTRAINT fk_provider_status_queries__payment_attempt_id FOREIGN KEY (payment_attempt_id) REFERENCES core.payment_attempts(payment_attempt_id) DEFERRABLE;


--
-- Name: provider_status_queries fk_provider_status_queries__payment_rail_id; Type: FK CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.provider_status_queries
    ADD CONSTRAINT fk_provider_status_queries__payment_rail_id FOREIGN KEY (payment_rail_id) REFERENCES payments.payment_rails(payment_rail_id) DEFERRABLE;


--
-- Name: provider_status_queries fk_provider_status_queries__provider_session_id; Type: FK CONSTRAINT; Schema: payments; Owner: -
--

ALTER TABLE ONLY payments.provider_status_queries
    ADD CONSTRAINT fk_provider_status_queries__provider_session_id FOREIGN KEY (provider_session_id) REFERENCES payments.provider_sessions(provider_session_id) DEFERRABLE;


--
-- Name: mops_transaction_records fk_mops_transaction_records__captured_by_service_identity_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.mops_transaction_records
    ADD CONSTRAINT fk_mops_transaction_records__captured_by_service_identity_id FOREIGN KEY (captured_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: mops_transaction_records fk_mops_transaction_records__captured_by_user_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.mops_transaction_records
    ADD CONSTRAINT fk_mops_transaction_records__captured_by_user_id FOREIGN KEY (captured_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: mops_transaction_records fk_mops_transaction_records__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.mops_transaction_records
    ADD CONSTRAINT fk_mops_transaction_records__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: mops_transaction_records fk_mops_transaction_records__created_by_user_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.mops_transaction_records
    ADD CONSTRAINT fk_mops_transaction_records__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: mops_transaction_records fk_mops_transaction_records__imported_by_service_identity_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.mops_transaction_records
    ADD CONSTRAINT fk_mops_transaction_records__imported_by_service_identity_id FOREIGN KEY (imported_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: mops_transaction_records fk_mops_transaction_records__incident_record_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.mops_transaction_records
    ADD CONSTRAINT fk_mops_transaction_records__incident_record_id FOREIGN KEY (incident_record_id) REFERENCES operations.incident_records(incident_record_id) DEFERRABLE;


--
-- Name: mops_transaction_records fk_mops_transaction_records__lane_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.mops_transaction_records
    ADD CONSTRAINT fk_mops_transaction_records__lane_id FOREIGN KEY (lane_id) REFERENCES sites.lanes(lane_id) DEFERRABLE;


--
-- Name: mops_transaction_records fk_mops_transaction_records__manual_gate_log_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.mops_transaction_records
    ADD CONSTRAINT fk_mops_transaction_records__manual_gate_log_id FOREIGN KEY (manual_gate_log_id) REFERENCES operations.manual_gate_logs(manual_gate_log_id) DEFERRABLE;


--
-- Name: mops_transaction_records fk_mops_transaction_records__parking_session_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.mops_transaction_records
    ADD CONSTRAINT fk_mops_transaction_records__parking_session_id FOREIGN KEY (parking_session_id) REFERENCES core.parking_sessions(parking_session_id) DEFERRABLE;


--
-- Name: mops_transaction_records fk_mops_transaction_records__site_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.mops_transaction_records
    ADD CONSTRAINT fk_mops_transaction_records__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE;


--
-- Name: mops_transaction_records fk_mops_transaction_records__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.mops_transaction_records
    ADD CONSTRAINT fk_mops_transaction_records__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: mops_transaction_records fk_mops_transaction_records__updated_by_user_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.mops_transaction_records
    ADD CONSTRAINT fk_mops_transaction_records__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: reconciliation_exceptions fk_reconciliation_exceptions__assigned_to_service_identity_i; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_exceptions
    ADD CONSTRAINT fk_reconciliation_exceptions__assigned_to_service_identity_i FOREIGN KEY (assigned_to_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: reconciliation_exceptions fk_reconciliation_exceptions__assigned_to_user_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_exceptions
    ADD CONSTRAINT fk_reconciliation_exceptions__assigned_to_user_id FOREIGN KEY (assigned_to_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: reconciliation_exceptions fk_reconciliation_exceptions__closed_by_service_identity_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_exceptions
    ADD CONSTRAINT fk_reconciliation_exceptions__closed_by_service_identity_id FOREIGN KEY (closed_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: reconciliation_exceptions fk_reconciliation_exceptions__closed_by_user_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_exceptions
    ADD CONSTRAINT fk_reconciliation_exceptions__closed_by_user_id FOREIGN KEY (closed_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: reconciliation_exceptions fk_reconciliation_exceptions__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_exceptions
    ADD CONSTRAINT fk_reconciliation_exceptions__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: reconciliation_exceptions fk_reconciliation_exceptions__created_by_user_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_exceptions
    ADD CONSTRAINT fk_reconciliation_exceptions__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: reconciliation_exceptions fk_reconciliation_exceptions__incident_record_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_exceptions
    ADD CONSTRAINT fk_reconciliation_exceptions__incident_record_id FOREIGN KEY (incident_record_id) REFERENCES operations.incident_records(incident_record_id) DEFERRABLE;


--
-- Name: reconciliation_exceptions fk_reconciliation_exceptions__reconciliation_item_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_exceptions
    ADD CONSTRAINT fk_reconciliation_exceptions__reconciliation_item_id FOREIGN KEY (reconciliation_item_id) REFERENCES reconciliation.reconciliation_items(reconciliation_item_id) DEFERRABLE;


--
-- Name: reconciliation_exceptions fk_reconciliation_exceptions__reconciliation_run_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_exceptions
    ADD CONSTRAINT fk_reconciliation_exceptions__reconciliation_run_id FOREIGN KEY (reconciliation_run_id) REFERENCES reconciliation.reconciliation_runs(reconciliation_run_id) DEFERRABLE;


--
-- Name: reconciliation_exceptions fk_reconciliation_exceptions__resolved_by_service_identity_i; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_exceptions
    ADD CONSTRAINT fk_reconciliation_exceptions__resolved_by_service_identity_i FOREIGN KEY (resolved_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: reconciliation_exceptions fk_reconciliation_exceptions__resolved_by_user_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_exceptions
    ADD CONSTRAINT fk_reconciliation_exceptions__resolved_by_user_id FOREIGN KEY (resolved_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: reconciliation_exceptions fk_reconciliation_exceptions__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_exceptions
    ADD CONSTRAINT fk_reconciliation_exceptions__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: reconciliation_exceptions fk_reconciliation_exceptions__updated_by_user_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_exceptions
    ADD CONSTRAINT fk_reconciliation_exceptions__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: reconciliation_items fk_reconciliation_items__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_items
    ADD CONSTRAINT fk_reconciliation_items__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: reconciliation_items fk_reconciliation_items__created_by_user_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_items
    ADD CONSTRAINT fk_reconciliation_items__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: reconciliation_items fk_reconciliation_items__manual_gate_log_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_items
    ADD CONSTRAINT fk_reconciliation_items__manual_gate_log_id FOREIGN KEY (manual_gate_log_id) REFERENCES operations.manual_gate_logs(manual_gate_log_id) DEFERRABLE;


--
-- Name: reconciliation_items fk_reconciliation_items__mops_transaction_record_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_items
    ADD CONSTRAINT fk_reconciliation_items__mops_transaction_record_id FOREIGN KEY (mops_transaction_record_id) REFERENCES reconciliation.mops_transaction_records(mops_transaction_record_id) DEFERRABLE;


--
-- Name: reconciliation_items fk_reconciliation_items__payment_attempt_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_items
    ADD CONSTRAINT fk_reconciliation_items__payment_attempt_id FOREIGN KEY (payment_attempt_id) REFERENCES core.payment_attempts(payment_attempt_id) DEFERRABLE;


--
-- Name: reconciliation_items fk_reconciliation_items__payment_confirmation_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_items
    ADD CONSTRAINT fk_reconciliation_items__payment_confirmation_id FOREIGN KEY (payment_confirmation_id) REFERENCES core.payment_confirmations(payment_confirmation_id) DEFERRABLE;


--
-- Name: reconciliation_items fk_reconciliation_items__provider_outcome_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_items
    ADD CONSTRAINT fk_reconciliation_items__provider_outcome_id FOREIGN KEY (provider_outcome_id) REFERENCES payments.provider_outcomes(provider_outcome_id) DEFERRABLE;


--
-- Name: reconciliation_items fk_reconciliation_items__reconciliation_run_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_items
    ADD CONSTRAINT fk_reconciliation_items__reconciliation_run_id FOREIGN KEY (reconciliation_run_id) REFERENCES reconciliation.reconciliation_runs(reconciliation_run_id) DEFERRABLE;


--
-- Name: reconciliation_items fk_reconciliation_items__resolved_by_service_identity_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_items
    ADD CONSTRAINT fk_reconciliation_items__resolved_by_service_identity_id FOREIGN KEY (resolved_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: reconciliation_items fk_reconciliation_items__resolved_by_user_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_items
    ADD CONSTRAINT fk_reconciliation_items__resolved_by_user_id FOREIGN KEY (resolved_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: reconciliation_items fk_reconciliation_items__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_items
    ADD CONSTRAINT fk_reconciliation_items__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: reconciliation_items fk_reconciliation_items__updated_by_user_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_items
    ADD CONSTRAINT fk_reconciliation_items__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: reconciliation_runs fk_reconciliation_runs__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_runs
    ADD CONSTRAINT fk_reconciliation_runs__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: reconciliation_runs fk_reconciliation_runs__created_by_user_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_runs
    ADD CONSTRAINT fk_reconciliation_runs__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: reconciliation_runs fk_reconciliation_runs__incident_record_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_runs
    ADD CONSTRAINT fk_reconciliation_runs__incident_record_id FOREIGN KEY (incident_record_id) REFERENCES operations.incident_records(incident_record_id) DEFERRABLE;


--
-- Name: reconciliation_runs fk_reconciliation_runs__initiated_by_service_identity_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_runs
    ADD CONSTRAINT fk_reconciliation_runs__initiated_by_service_identity_id FOREIGN KEY (initiated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: reconciliation_runs fk_reconciliation_runs__initiated_by_user_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_runs
    ADD CONSTRAINT fk_reconciliation_runs__initiated_by_user_id FOREIGN KEY (initiated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: reconciliation_runs fk_reconciliation_runs__payment_rail_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_runs
    ADD CONSTRAINT fk_reconciliation_runs__payment_rail_id FOREIGN KEY (payment_rail_id) REFERENCES payments.payment_rails(payment_rail_id) DEFERRABLE;


--
-- Name: reconciliation_runs fk_reconciliation_runs__site_group_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_runs
    ADD CONSTRAINT fk_reconciliation_runs__site_group_id FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id) DEFERRABLE;


--
-- Name: reconciliation_runs fk_reconciliation_runs__site_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_runs
    ADD CONSTRAINT fk_reconciliation_runs__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE;


--
-- Name: reconciliation_runs fk_reconciliation_runs__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_runs
    ADD CONSTRAINT fk_reconciliation_runs__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: reconciliation_runs fk_reconciliation_runs__updated_by_user_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_runs
    ADD CONSTRAINT fk_reconciliation_runs__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: reconciliation_runs fk_reconciliation_runs__vendor_system_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.reconciliation_runs
    ADD CONSTRAINT fk_reconciliation_runs__vendor_system_id FOREIGN KEY (vendor_system_id) REFERENCES integration.vendor_systems(vendor_system_id) DEFERRABLE;


--
-- Name: settlement_comparison_records fk_settlement_comparison_records__compared_by_service_identi; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.settlement_comparison_records
    ADD CONSTRAINT fk_settlement_comparison_records__compared_by_service_identi FOREIGN KEY (compared_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: settlement_comparison_records fk_settlement_comparison_records__compared_by_user_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.settlement_comparison_records
    ADD CONSTRAINT fk_settlement_comparison_records__compared_by_user_id FOREIGN KEY (compared_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: settlement_comparison_records fk_settlement_comparison_records__created_by_service_identit; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.settlement_comparison_records
    ADD CONSTRAINT fk_settlement_comparison_records__created_by_service_identit FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: settlement_comparison_records fk_settlement_comparison_records__created_by_user_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.settlement_comparison_records
    ADD CONSTRAINT fk_settlement_comparison_records__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: settlement_comparison_records fk_settlement_comparison_records__mops_transaction_record_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.settlement_comparison_records
    ADD CONSTRAINT fk_settlement_comparison_records__mops_transaction_record_id FOREIGN KEY (mops_transaction_record_id) REFERENCES reconciliation.mops_transaction_records(mops_transaction_record_id) DEFERRABLE;


--
-- Name: settlement_comparison_records fk_settlement_comparison_records__payment_confirmation_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.settlement_comparison_records
    ADD CONSTRAINT fk_settlement_comparison_records__payment_confirmation_id FOREIGN KEY (payment_confirmation_id) REFERENCES core.payment_confirmations(payment_confirmation_id) DEFERRABLE;


--
-- Name: settlement_comparison_records fk_settlement_comparison_records__provider_outcome_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.settlement_comparison_records
    ADD CONSTRAINT fk_settlement_comparison_records__provider_outcome_id FOREIGN KEY (provider_outcome_id) REFERENCES payments.provider_outcomes(provider_outcome_id) DEFERRABLE;


--
-- Name: settlement_comparison_records fk_settlement_comparison_records__reconciliation_exception_i; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.settlement_comparison_records
    ADD CONSTRAINT fk_settlement_comparison_records__reconciliation_exception_i FOREIGN KEY (reconciliation_exception_id) REFERENCES reconciliation.reconciliation_exceptions(reconciliation_exception_id) DEFERRABLE;


--
-- Name: settlement_comparison_records fk_settlement_comparison_records__reconciliation_item_id; Type: FK CONSTRAINT; Schema: reconciliation; Owner: -
--

ALTER TABLE ONLY reconciliation.settlement_comparison_records
    ADD CONSTRAINT fk_settlement_comparison_records__reconciliation_item_id FOREIGN KEY (reconciliation_item_id) REFERENCES reconciliation.reconciliation_items(reconciliation_item_id) DEFERRABLE;


--
-- Name: session_identifier_indexes fk_session_identifier_indexes__created_by_service_identity_i; Type: FK CONSTRAINT; Schema: sessions; Owner: -
--

ALTER TABLE ONLY sessions.session_identifier_indexes
    ADD CONSTRAINT fk_session_identifier_indexes__created_by_service_identity_i FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: session_identifier_indexes fk_session_identifier_indexes__parking_session_id; Type: FK CONSTRAINT; Schema: sessions; Owner: -
--

ALTER TABLE ONLY sessions.session_identifier_indexes
    ADD CONSTRAINT fk_session_identifier_indexes__parking_session_id FOREIGN KEY (parking_session_id) REFERENCES core.parking_sessions(parking_session_id) DEFERRABLE;


--
-- Name: session_identifier_indexes fk_session_identifier_indexes__site_group_id; Type: FK CONSTRAINT; Schema: sessions; Owner: -
--

ALTER TABLE ONLY sessions.session_identifier_indexes
    ADD CONSTRAINT fk_session_identifier_indexes__site_group_id FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id) DEFERRABLE;


--
-- Name: session_identifier_indexes fk_session_identifier_indexes__site_id; Type: FK CONSTRAINT; Schema: sessions; Owner: -
--

ALTER TABLE ONLY sessions.session_identifier_indexes
    ADD CONSTRAINT fk_session_identifier_indexes__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE;


--
-- Name: session_identifier_indexes fk_session_identifier_indexes__updated_by_service_identity_i; Type: FK CONSTRAINT; Schema: sessions; Owner: -
--

ALTER TABLE ONLY sessions.session_identifier_indexes
    ADD CONSTRAINT fk_session_identifier_indexes__updated_by_service_identity_i FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: session_identifier_indexes fk_session_identifier_indexes__vendor_system_id; Type: FK CONSTRAINT; Schema: sessions; Owner: -
--

ALTER TABLE ONLY sessions.session_identifier_indexes
    ADD CONSTRAINT fk_session_identifier_indexes__vendor_system_id FOREIGN KEY (vendor_system_id) REFERENCES integration.vendor_systems(vendor_system_id) DEFERRABLE;


--
-- Name: session_lookup_cache fk_session_lookup_cache__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: sessions; Owner: -
--

ALTER TABLE ONLY sessions.session_lookup_cache
    ADD CONSTRAINT fk_session_lookup_cache__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: session_lookup_cache fk_session_lookup_cache__parking_session_id; Type: FK CONSTRAINT; Schema: sessions; Owner: -
--

ALTER TABLE ONLY sessions.session_lookup_cache
    ADD CONSTRAINT fk_session_lookup_cache__parking_session_id FOREIGN KEY (parking_session_id) REFERENCES core.parking_sessions(parking_session_id) DEFERRABLE;


--
-- Name: session_lookup_cache fk_session_lookup_cache__site_group_id; Type: FK CONSTRAINT; Schema: sessions; Owner: -
--

ALTER TABLE ONLY sessions.session_lookup_cache
    ADD CONSTRAINT fk_session_lookup_cache__site_group_id FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id) DEFERRABLE;


--
-- Name: session_lookup_cache fk_session_lookup_cache__site_id; Type: FK CONSTRAINT; Schema: sessions; Owner: -
--

ALTER TABLE ONLY sessions.session_lookup_cache
    ADD CONSTRAINT fk_session_lookup_cache__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE;


--
-- Name: session_lookup_cache fk_session_lookup_cache__vendor_system_id; Type: FK CONSTRAINT; Schema: sessions; Owner: -
--

ALTER TABLE ONLY sessions.session_lookup_cache
    ADD CONSTRAINT fk_session_lookup_cache__vendor_system_id FOREIGN KEY (vendor_system_id) REFERENCES integration.vendor_systems(vendor_system_id) DEFERRABLE;


--
-- Name: session_resolution_requests fk_session_resolution_requests__created_by_service_identity_; Type: FK CONSTRAINT; Schema: sessions; Owner: -
--

ALTER TABLE ONLY sessions.session_resolution_requests
    ADD CONSTRAINT fk_session_resolution_requests__created_by_service_identity_ FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: session_resolution_requests fk_session_resolution_requests__created_by_user_id; Type: FK CONSTRAINT; Schema: sessions; Owner: -
--

ALTER TABLE ONLY sessions.session_resolution_requests
    ADD CONSTRAINT fk_session_resolution_requests__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: session_resolution_requests fk_session_resolution_requests__site_group_id; Type: FK CONSTRAINT; Schema: sessions; Owner: -
--

ALTER TABLE ONLY sessions.session_resolution_requests
    ADD CONSTRAINT fk_session_resolution_requests__site_group_id FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id) DEFERRABLE;


--
-- Name: session_resolution_requests fk_session_resolution_requests__site_id; Type: FK CONSTRAINT; Schema: sessions; Owner: -
--

ALTER TABLE ONLY sessions.session_resolution_requests
    ADD CONSTRAINT fk_session_resolution_requests__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE;


--
-- Name: session_resolution_results fk_session_resolution_results__created_by_service_identity_i; Type: FK CONSTRAINT; Schema: sessions; Owner: -
--

ALTER TABLE ONLY sessions.session_resolution_results
    ADD CONSTRAINT fk_session_resolution_results__created_by_service_identity_i FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: session_resolution_results fk_session_resolution_results__parking_session_id; Type: FK CONSTRAINT; Schema: sessions; Owner: -
--

ALTER TABLE ONLY sessions.session_resolution_results
    ADD CONSTRAINT fk_session_resolution_results__parking_session_id FOREIGN KEY (parking_session_id) REFERENCES core.parking_sessions(parking_session_id) DEFERRABLE;


--
-- Name: session_resolution_results fk_session_resolution_results__session_resolution_request_id; Type: FK CONSTRAINT; Schema: sessions; Owner: -
--

ALTER TABLE ONLY sessions.session_resolution_results
    ADD CONSTRAINT fk_session_resolution_results__session_resolution_request_id FOREIGN KEY (session_resolution_request_id) REFERENCES sessions.session_resolution_requests(session_resolution_request_id) DEFERRABLE;


--
-- Name: session_resolution_results fk_session_resolution_results__site_group_id; Type: FK CONSTRAINT; Schema: sessions; Owner: -
--

ALTER TABLE ONLY sessions.session_resolution_results
    ADD CONSTRAINT fk_session_resolution_results__site_group_id FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id) DEFERRABLE;


--
-- Name: session_resolution_results fk_session_resolution_results__site_id; Type: FK CONSTRAINT; Schema: sessions; Owner: -
--

ALTER TABLE ONLY sessions.session_resolution_results
    ADD CONSTRAINT fk_session_resolution_results__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE;


--
-- Name: session_resolution_results fk_session_resolution_results__vendor_system_id; Type: FK CONSTRAINT; Schema: sessions; Owner: -
--

ALTER TABLE ONLY sessions.session_resolution_results
    ADD CONSTRAINT fk_session_resolution_results__vendor_system_id FOREIGN KEY (vendor_system_id) REFERENCES integration.vendor_systems(vendor_system_id) DEFERRABLE;


--
-- Name: device_assignments fk_device_assignments__assigned_by_service_identity_id; Type: FK CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.device_assignments
    ADD CONSTRAINT fk_device_assignments__assigned_by_service_identity_id FOREIGN KEY (assigned_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: device_assignments fk_device_assignments__assigned_by_user_id; Type: FK CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.device_assignments
    ADD CONSTRAINT fk_device_assignments__assigned_by_user_id FOREIGN KEY (assigned_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: device_assignments fk_device_assignments__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.device_assignments
    ADD CONSTRAINT fk_device_assignments__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: device_assignments fk_device_assignments__created_by_user_id; Type: FK CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.device_assignments
    ADD CONSTRAINT fk_device_assignments__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: device_assignments fk_device_assignments__gate_device_id; Type: FK CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.device_assignments
    ADD CONSTRAINT fk_device_assignments__gate_device_id FOREIGN KEY (gate_device_id) REFERENCES gates.gate_devices(gate_device_id) DEFERRABLE;


--
-- Name: device_assignments fk_device_assignments__lane_id; Type: FK CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.device_assignments
    ADD CONSTRAINT fk_device_assignments__lane_id FOREIGN KEY (lane_id) REFERENCES sites.lanes(lane_id) DEFERRABLE;


--
-- Name: device_assignments fk_device_assignments__service_identity_id; Type: FK CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.device_assignments
    ADD CONSTRAINT fk_device_assignments__service_identity_id FOREIGN KEY (service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: device_assignments fk_device_assignments__site_id; Type: FK CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.device_assignments
    ADD CONSTRAINT fk_device_assignments__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE;


--
-- Name: device_assignments fk_device_assignments__unassigned_by_service_identity_id; Type: FK CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.device_assignments
    ADD CONSTRAINT fk_device_assignments__unassigned_by_service_identity_id FOREIGN KEY (unassigned_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: device_assignments fk_device_assignments__unassigned_by_user_id; Type: FK CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.device_assignments
    ADD CONSTRAINT fk_device_assignments__unassigned_by_user_id FOREIGN KEY (unassigned_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: device_assignments fk_device_assignments__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.device_assignments
    ADD CONSTRAINT fk_device_assignments__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: device_assignments fk_device_assignments__updated_by_user_id; Type: FK CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.device_assignments
    ADD CONSTRAINT fk_device_assignments__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: lanes fk_lanes__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.lanes
    ADD CONSTRAINT fk_lanes__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: lanes fk_lanes__created_by_user_id; Type: FK CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.lanes
    ADD CONSTRAINT fk_lanes__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: lanes fk_lanes__site_id; Type: FK CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.lanes
    ADD CONSTRAINT fk_lanes__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE;


--
-- Name: lanes fk_lanes__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.lanes
    ADD CONSTRAINT fk_lanes__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: lanes fk_lanes__updated_by_user_id; Type: FK CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.lanes
    ADD CONSTRAINT fk_lanes__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: site_groups fk_site_groups__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.site_groups
    ADD CONSTRAINT fk_site_groups__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: site_groups fk_site_groups__created_by_user_id; Type: FK CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.site_groups
    ADD CONSTRAINT fk_site_groups__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: site_groups fk_site_groups__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.site_groups
    ADD CONSTRAINT fk_site_groups__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: site_groups fk_site_groups__updated_by_user_id; Type: FK CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.site_groups
    ADD CONSTRAINT fk_site_groups__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: sites fk_sites__created_by_service_identity_id; Type: FK CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.sites
    ADD CONSTRAINT fk_sites__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: sites fk_sites__created_by_user_id; Type: FK CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.sites
    ADD CONSTRAINT fk_sites__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- Name: sites fk_sites__site_group_id; Type: FK CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.sites
    ADD CONSTRAINT fk_sites__site_group_id FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id) DEFERRABLE;


--
-- Name: sites fk_sites__updated_by_service_identity_id; Type: FK CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.sites
    ADD CONSTRAINT fk_sites__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE;


--
-- Name: sites fk_sites__updated_by_user_id; Type: FK CONSTRAINT; Schema: sites; Owner: -
--

ALTER TABLE ONLY sites.sites
    ADD CONSTRAINT fk_sites__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE;


--
-- PostgreSQL database dump complete
--

\unrestrict FL1J3mh1xeSyeDAnYlS7TGPHZ4ul3cB7ogWfJZijWbxcphDF4zDuh7GrdftF6Tq

