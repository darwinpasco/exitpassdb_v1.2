-- ============================================================
-- 04. Foreign Key Constraints
-- Generated from ExitPass v1.2 DDL
-- ============================================================
ALTER TABLE core.parking_sessions ADD CONSTRAINT fk_parking_sessions__site_group_id FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.parking_sessions ADD CONSTRAINT fk_parking_sessions__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.parking_sessions ADD CONSTRAINT fk_parking_sessions__vendor_system_id FOREIGN KEY (vendor_system_id) REFERENCES integration.vendor_systems(vendor_system_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.parking_sessions ADD CONSTRAINT fk_parking_sessions__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.parking_sessions ADD CONSTRAINT fk_parking_sessions__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.tariff_snapshots ADD CONSTRAINT fk_tariff_snapshots__parking_session_id FOREIGN KEY (parking_session_id) REFERENCES core.parking_sessions(parking_session_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.tariff_snapshots ADD CONSTRAINT fk_tariff_snapshots__superseded_by_tariff_snapshot_id FOREIGN KEY (superseded_by_tariff_snapshot_id) REFERENCES core.tariff_snapshots(tariff_snapshot_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.tariff_snapshots ADD CONSTRAINT fk_tariff_snapshots__vendor_system_id FOREIGN KEY (vendor_system_id) REFERENCES integration.vendor_systems(vendor_system_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.tariff_snapshots ADD CONSTRAINT fk_tariff_snapshots__statutory_discount_validation_id FOREIGN KEY (statutory_discount_validation_id) REFERENCES discounts.statutory_discount_validations(statutory_discount_validation_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.tariff_snapshots ADD CONSTRAINT fk_tariff_snapshots__coupon_application_id FOREIGN KEY (coupon_application_id) REFERENCES coupons.coupon_applications(coupon_application_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.tariff_snapshots ADD CONSTRAINT fk_tariff_snapshots__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.tariff_snapshots ADD CONSTRAINT fk_tariff_snapshots__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.payment_attempts ADD CONSTRAINT fk_payment_attempts__parking_session_id FOREIGN KEY (parking_session_id) REFERENCES core.parking_sessions(parking_session_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.payment_attempts ADD CONSTRAINT fk_payment_attempts__tariff_snapshot_id FOREIGN KEY (tariff_snapshot_id) REFERENCES core.tariff_snapshots(tariff_snapshot_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.payment_attempts ADD CONSTRAINT fk_payment_attempts__payment_rail_id FOREIGN KEY (payment_rail_id) REFERENCES payments.payment_rails(payment_rail_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.payment_attempts ADD CONSTRAINT fk_payment_attempts__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.payment_attempts ADD CONSTRAINT fk_payment_attempts__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.payment_confirmations ADD CONSTRAINT fk_payment_confirmations__payment_attempt_id FOREIGN KEY (payment_attempt_id) REFERENCES core.payment_attempts(payment_attempt_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.payment_confirmations ADD CONSTRAINT fk_payment_confirmations__provider_outcome_id FOREIGN KEY (provider_outcome_id) REFERENCES payments.provider_outcomes(provider_outcome_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.payment_confirmations ADD CONSTRAINT fk_payment_confirmations__payment_rail_id FOREIGN KEY (payment_rail_id) REFERENCES payments.payment_rails(payment_rail_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.payment_confirmations ADD CONSTRAINT fk_payment_confirmations__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.exit_authorizations ADD CONSTRAINT fk_exit_authorizations__parking_session_id FOREIGN KEY (parking_session_id) REFERENCES core.parking_sessions(parking_session_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.exit_authorizations ADD CONSTRAINT fk_exit_authorizations__payment_attempt_id FOREIGN KEY (payment_attempt_id) REFERENCES core.payment_attempts(payment_attempt_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.exit_authorizations ADD CONSTRAINT fk_exit_authorizations__payment_confirmation_id FOREIGN KEY (payment_confirmation_id) REFERENCES core.payment_confirmations(payment_confirmation_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.exit_authorizations ADD CONSTRAINT fk_exit_authorizations__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.exit_authorizations ADD CONSTRAINT fk_exit_authorizations__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE payments.payment_rails ADD CONSTRAINT fk_payment_rails__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE payments.payment_rails ADD CONSTRAINT fk_payment_rails__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE payments.payment_rails ADD CONSTRAINT fk_payment_rails__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE payments.payment_rails ADD CONSTRAINT fk_payment_rails__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE payments.provider_sessions ADD CONSTRAINT fk_provider_sessions__payment_attempt_id FOREIGN KEY (payment_attempt_id) REFERENCES core.payment_attempts(payment_attempt_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE payments.provider_sessions ADD CONSTRAINT fk_provider_sessions__payment_rail_id FOREIGN KEY (payment_rail_id) REFERENCES payments.payment_rails(payment_rail_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE payments.provider_sessions ADD CONSTRAINT fk_provider_sessions__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE payments.provider_sessions ADD CONSTRAINT fk_provider_sessions__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE payments.provider_callbacks ADD CONSTRAINT fk_provider_callbacks__payment_rail_id FOREIGN KEY (payment_rail_id) REFERENCES payments.payment_rails(payment_rail_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE payments.provider_callbacks ADD CONSTRAINT fk_provider_callbacks__provider_session_id FOREIGN KEY (provider_session_id) REFERENCES payments.provider_sessions(provider_session_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE payments.provider_callbacks ADD CONSTRAINT fk_provider_callbacks__payment_attempt_id FOREIGN KEY (payment_attempt_id) REFERENCES core.payment_attempts(payment_attempt_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE payments.provider_callbacks ADD CONSTRAINT fk_provider_callbacks__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE payments.provider_status_queries ADD CONSTRAINT fk_provider_status_queries__payment_attempt_id FOREIGN KEY (payment_attempt_id) REFERENCES core.payment_attempts(payment_attempt_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE payments.provider_status_queries ADD CONSTRAINT fk_provider_status_queries__provider_session_id FOREIGN KEY (provider_session_id) REFERENCES payments.provider_sessions(provider_session_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE payments.provider_status_queries ADD CONSTRAINT fk_provider_status_queries__payment_rail_id FOREIGN KEY (payment_rail_id) REFERENCES payments.payment_rails(payment_rail_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE payments.provider_status_queries ADD CONSTRAINT fk_provider_status_queries__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE payments.provider_outcomes ADD CONSTRAINT fk_provider_outcomes__payment_attempt_id FOREIGN KEY (payment_attempt_id) REFERENCES core.payment_attempts(payment_attempt_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE payments.provider_outcomes ADD CONSTRAINT fk_provider_outcomes__provider_session_id FOREIGN KEY (provider_session_id) REFERENCES payments.provider_sessions(provider_session_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE payments.provider_outcomes ADD CONSTRAINT fk_provider_outcomes__provider_callback_id FOREIGN KEY (provider_callback_id) REFERENCES payments.provider_callbacks(provider_callback_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE payments.provider_outcomes ADD CONSTRAINT fk_provider_outcomes__provider_status_query_id FOREIGN KEY (provider_status_query_id) REFERENCES payments.provider_status_queries(provider_status_query_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE payments.provider_outcomes ADD CONSTRAINT fk_provider_outcomes__payment_rail_id FOREIGN KEY (payment_rail_id) REFERENCES payments.payment_rails(payment_rail_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE payments.provider_outcomes ADD CONSTRAINT fk_provider_outcomes__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE payments.provider_outcomes ADD CONSTRAINT fk_provider_outcomes__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sessions.session_resolution_requests ADD CONSTRAINT fk_session_resolution_requests__site_group_id FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sessions.session_resolution_requests ADD CONSTRAINT fk_session_resolution_requests__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sessions.session_resolution_requests ADD CONSTRAINT fk_session_resolution_requests__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sessions.session_resolution_requests ADD CONSTRAINT fk_session_resolution_requests__created_by_service_identity_ FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sessions.session_resolution_results ADD CONSTRAINT fk_session_resolution_results__session_resolution_request_id FOREIGN KEY (session_resolution_request_id) REFERENCES sessions.session_resolution_requests(session_resolution_request_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sessions.session_resolution_results ADD CONSTRAINT fk_session_resolution_results__parking_session_id FOREIGN KEY (parking_session_id) REFERENCES core.parking_sessions(parking_session_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sessions.session_resolution_results ADD CONSTRAINT fk_session_resolution_results__site_group_id FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sessions.session_resolution_results ADD CONSTRAINT fk_session_resolution_results__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sessions.session_resolution_results ADD CONSTRAINT fk_session_resolution_results__vendor_system_id FOREIGN KEY (vendor_system_id) REFERENCES integration.vendor_systems(vendor_system_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sessions.session_resolution_results ADD CONSTRAINT fk_session_resolution_results__created_by_service_identity_i FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sessions.session_lookup_cache ADD CONSTRAINT fk_session_lookup_cache__site_group_id FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sessions.session_lookup_cache ADD CONSTRAINT fk_session_lookup_cache__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sessions.session_lookup_cache ADD CONSTRAINT fk_session_lookup_cache__parking_session_id FOREIGN KEY (parking_session_id) REFERENCES core.parking_sessions(parking_session_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sessions.session_lookup_cache ADD CONSTRAINT fk_session_lookup_cache__vendor_system_id FOREIGN KEY (vendor_system_id) REFERENCES integration.vendor_systems(vendor_system_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sessions.session_lookup_cache ADD CONSTRAINT fk_session_lookup_cache__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sessions.session_identifier_indexes ADD CONSTRAINT fk_session_identifier_indexes__parking_session_id FOREIGN KEY (parking_session_id) REFERENCES core.parking_sessions(parking_session_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sessions.session_identifier_indexes ADD CONSTRAINT fk_session_identifier_indexes__site_group_id FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sessions.session_identifier_indexes ADD CONSTRAINT fk_session_identifier_indexes__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sessions.session_identifier_indexes ADD CONSTRAINT fk_session_identifier_indexes__vendor_system_id FOREIGN KEY (vendor_system_id) REFERENCES integration.vendor_systems(vendor_system_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sessions.session_identifier_indexes ADD CONSTRAINT fk_session_identifier_indexes__created_by_service_identity_i FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sessions.session_identifier_indexes ADD CONSTRAINT fk_session_identifier_indexes__updated_by_service_identity_i FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupons ADD CONSTRAINT fk_coupons__merchant_id FOREIGN KEY (merchant_id) REFERENCES merchants.merchants(merchant_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupons ADD CONSTRAINT fk_coupons__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupons ADD CONSTRAINT fk_coupons__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupons ADD CONSTRAINT fk_coupons__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupons ADD CONSTRAINT fk_coupons__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupon_rule_groups ADD CONSTRAINT fk_coupon_rule_groups__coupon_id FOREIGN KEY (coupon_id) REFERENCES coupons.coupons(coupon_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupon_rule_groups ADD CONSTRAINT fk_coupon_rule_groups__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupon_rule_groups ADD CONSTRAINT fk_coupon_rule_groups__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupon_rule_groups ADD CONSTRAINT fk_coupon_rule_groups__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupon_rule_groups ADD CONSTRAINT fk_coupon_rule_groups__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupon_rules ADD CONSTRAINT fk_coupon_rules__coupon_rule_group_id FOREIGN KEY (coupon_rule_group_id) REFERENCES coupons.coupon_rule_groups(coupon_rule_group_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupon_rules ADD CONSTRAINT fk_coupon_rules__site_group_id FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupon_rules ADD CONSTRAINT fk_coupon_rules__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupon_rules ADD CONSTRAINT fk_coupon_rules__merchant_id FOREIGN KEY (merchant_id) REFERENCES merchants.merchants(merchant_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupon_rules ADD CONSTRAINT fk_coupon_rules__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupon_rules ADD CONSTRAINT fk_coupon_rules__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupon_rules ADD CONSTRAINT fk_coupon_rules__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupon_rules ADD CONSTRAINT fk_coupon_rules__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupon_applications ADD CONSTRAINT fk_coupon_applications__coupon_id FOREIGN KEY (coupon_id) REFERENCES coupons.coupons(coupon_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupon_applications ADD CONSTRAINT fk_coupon_applications__merchant_id FOREIGN KEY (merchant_id) REFERENCES merchants.merchants(merchant_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupon_applications ADD CONSTRAINT fk_coupon_applications__merchant_wallet_id FOREIGN KEY (merchant_wallet_id) REFERENCES merchants.merchant_wallets(merchant_wallet_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupon_applications ADD CONSTRAINT fk_coupon_applications__parking_session_id FOREIGN KEY (parking_session_id) REFERENCES core.parking_sessions(parking_session_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupon_applications ADD CONSTRAINT fk_coupon_applications__tariff_snapshot_id FOREIGN KEY (tariff_snapshot_id) REFERENCES core.tariff_snapshots(tariff_snapshot_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupon_applications ADD CONSTRAINT fk_coupon_applications__payment_attempt_id FOREIGN KEY (payment_attempt_id) REFERENCES core.payment_attempts(payment_attempt_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupon_applications ADD CONSTRAINT fk_coupon_applications__requested_by_user_id FOREIGN KEY (requested_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupon_applications ADD CONSTRAINT fk_coupon_applications__requested_by_service_identity_id FOREIGN KEY (requested_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupon_applications ADD CONSTRAINT fk_coupon_applications__approved_by_user_id FOREIGN KEY (approved_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupon_applications ADD CONSTRAINT fk_coupon_applications__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupon_applications ADD CONSTRAINT fk_coupon_applications__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupon_applications ADD CONSTRAINT fk_coupon_applications__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE coupons.coupon_applications ADD CONSTRAINT fk_coupon_applications__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.discount_policy_references ADD CONSTRAINT fk_discount_policy_references__site_group_id FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.discount_policy_references ADD CONSTRAINT fk_discount_policy_references__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.discount_policy_references ADD CONSTRAINT fk_discount_policy_references__parent_policy_reference_id FOREIGN KEY (parent_policy_reference_id) REFERENCES discounts.discount_policy_references(discount_policy_reference_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.discount_policy_references ADD CONSTRAINT fk_discount_policy_references__fallback_policy_reference_id FOREIGN KEY (fallback_policy_reference_id) REFERENCES discounts.discount_policy_references(discount_policy_reference_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.discount_policy_references ADD CONSTRAINT fk_discount_policy_references__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.discount_policy_references ADD CONSTRAINT fk_discount_policy_references__created_by_service_identity_i FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.discount_policy_references ADD CONSTRAINT fk_discount_policy_references__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.discount_policy_references ADD CONSTRAINT fk_discount_policy_references__updated_by_service_identity_i FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.statutory_discount_validations ADD CONSTRAINT fk_statutory_discount_validations__parking_session_id FOREIGN KEY (parking_session_id) REFERENCES core.parking_sessions(parking_session_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.statutory_discount_validations ADD CONSTRAINT fk_statutory_discount_validations__tariff_snapshot_id FOREIGN KEY (tariff_snapshot_id) REFERENCES core.tariff_snapshots(tariff_snapshot_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.statutory_discount_validations ADD CONSTRAINT fk_statutory_discount_validations__evaluated_policy_referenc FOREIGN KEY (evaluated_policy_reference_id) REFERENCES discounts.discount_policy_references(discount_policy_reference_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.statutory_discount_validations ADD CONSTRAINT fk_statutory_discount_validations__applied_policy_reference_ FOREIGN KEY (applied_policy_reference_id) REFERENCES discounts.discount_policy_references(discount_policy_reference_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.statutory_discount_validations ADD CONSTRAINT fk_statutory_discount_validations__fallback_policy_reference FOREIGN KEY (fallback_policy_reference_id) REFERENCES discounts.discount_policy_references(discount_policy_reference_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.statutory_discount_validations ADD CONSTRAINT fk_statutory_discount_validations__validated_by_user_id FOREIGN KEY (validated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.statutory_discount_validations ADD CONSTRAINT fk_statutory_discount_validations__validated_by_service_iden FOREIGN KEY (validated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.statutory_discount_validations ADD CONSTRAINT fk_statutory_discount_validations__requested_by_user_id FOREIGN KEY (requested_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.statutory_discount_validations ADD CONSTRAINT fk_statutory_discount_validations__requested_by_service_iden FOREIGN KEY (requested_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.statutory_discount_validations ADD CONSTRAINT fk_statutory_discount_validations__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.statutory_discount_validations ADD CONSTRAINT fk_statutory_discount_validations__created_by_service_identi FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.statutory_discount_validations ADD CONSTRAINT fk_statutory_discount_validations__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.statutory_discount_validations ADD CONSTRAINT fk_statutory_discount_validations__updated_by_service_identi FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.discount_evidence_references ADD CONSTRAINT fk_discount_evidence_references__statutory_discount_validati FOREIGN KEY (statutory_discount_validation_id) REFERENCES discounts.statutory_discount_validations(statutory_discount_validation_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.discount_evidence_references ADD CONSTRAINT fk_discount_evidence_references__captured_by_user_id FOREIGN KEY (captured_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.discount_evidence_references ADD CONSTRAINT fk_discount_evidence_references__captured_by_service_identit FOREIGN KEY (captured_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.discount_evidence_references ADD CONSTRAINT fk_discount_evidence_references__purged_by_user_id FOREIGN KEY (purged_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.discount_evidence_references ADD CONSTRAINT fk_discount_evidence_references__purged_by_service_identity_ FOREIGN KEY (purged_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.discount_evidence_references ADD CONSTRAINT fk_discount_evidence_references__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.discount_evidence_references ADD CONSTRAINT fk_discount_evidence_references__created_by_service_identity FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.discount_evidence_references ADD CONSTRAINT fk_discount_evidence_references__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE discounts.discount_evidence_references ADD CONSTRAINT fk_discount_evidence_references__updated_by_service_identity FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE gates.gate_devices ADD CONSTRAINT fk_gate_devices__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE gates.gate_devices ADD CONSTRAINT fk_gate_devices__lane_id FOREIGN KEY (lane_id) REFERENCES sites.lanes(lane_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE gates.gate_devices ADD CONSTRAINT fk_gate_devices__service_identity_id FOREIGN KEY (service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE gates.gate_devices ADD CONSTRAINT fk_gate_devices__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE gates.gate_devices ADD CONSTRAINT fk_gate_devices__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE gates.gate_devices ADD CONSTRAINT fk_gate_devices__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE gates.gate_devices ADD CONSTRAINT fk_gate_devices__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE gates.gate_authorization_consumptions ADD CONSTRAINT fk_gate_authorization_consumptions__exit_authorization_id FOREIGN KEY (exit_authorization_id) REFERENCES core.exit_authorizations(exit_authorization_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE gates.gate_authorization_consumptions ADD CONSTRAINT fk_gate_authorization_consumptions__gate_device_id FOREIGN KEY (gate_device_id) REFERENCES gates.gate_devices(gate_device_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE gates.gate_authorization_consumptions ADD CONSTRAINT fk_gate_authorization_consumptions__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE gates.gate_authorization_consumptions ADD CONSTRAINT fk_gate_authorization_consumptions__lane_id FOREIGN KEY (lane_id) REFERENCES sites.lanes(lane_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE gates.gate_authorization_consumptions ADD CONSTRAINT fk_gate_authorization_consumptions__created_by_service_ident FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE gates.gate_authorization_consumptions ADD CONSTRAINT fk_gate_authorization_consumptions__updated_by_service_ident FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE gates.gate_events ADD CONSTRAINT fk_gate_events__gate_device_id FOREIGN KEY (gate_device_id) REFERENCES gates.gate_devices(gate_device_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE gates.gate_events ADD CONSTRAINT fk_gate_events__gate_authorization_consumption_id FOREIGN KEY (gate_authorization_consumption_id) REFERENCES gates.gate_authorization_consumptions(gate_authorization_consumption_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE gates.gate_events ADD CONSTRAINT fk_gate_events__exit_authorization_id FOREIGN KEY (exit_authorization_id) REFERENCES core.exit_authorizations(exit_authorization_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE gates.gate_events ADD CONSTRAINT fk_gate_events__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE gates.gate_events ADD CONSTRAINT fk_gate_events__lane_id FOREIGN KEY (lane_id) REFERENCES sites.lanes(lane_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE gates.gate_events ADD CONSTRAINT fk_gate_events__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE gates.gate_heartbeats ADD CONSTRAINT fk_gate_heartbeats__gate_device_id FOREIGN KEY (gate_device_id) REFERENCES gates.gate_devices(gate_device_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE gates.gate_heartbeats ADD CONSTRAINT fk_gate_heartbeats__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE gates.gate_heartbeats ADD CONSTRAINT fk_gate_heartbeats__lane_id FOREIGN KEY (lane_id) REFERENCES sites.lanes(lane_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE gates.gate_heartbeats ADD CONSTRAINT fk_gate_heartbeats__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.manual_gate_logs ADD CONSTRAINT fk_manual_gate_logs__parking_session_id FOREIGN KEY (parking_session_id) REFERENCES core.parking_sessions(parking_session_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.manual_gate_logs ADD CONSTRAINT fk_manual_gate_logs__exit_authorization_id FOREIGN KEY (exit_authorization_id) REFERENCES core.exit_authorizations(exit_authorization_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.manual_gate_logs ADD CONSTRAINT fk_manual_gate_logs__gate_authorization_consumption_id FOREIGN KEY (gate_authorization_consumption_id) REFERENCES gates.gate_authorization_consumptions(gate_authorization_consumption_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.manual_gate_logs ADD CONSTRAINT fk_manual_gate_logs__incident_record_id FOREIGN KEY (incident_record_id) REFERENCES operations.incident_records(incident_record_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.manual_gate_logs ADD CONSTRAINT fk_manual_gate_logs__override_approval_id FOREIGN KEY (override_approval_id) REFERENCES operations.override_approvals(override_approval_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.manual_gate_logs ADD CONSTRAINT fk_manual_gate_logs__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.manual_gate_logs ADD CONSTRAINT fk_manual_gate_logs__lane_id FOREIGN KEY (lane_id) REFERENCES sites.lanes(lane_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.manual_gate_logs ADD CONSTRAINT fk_manual_gate_logs__gate_device_id FOREIGN KEY (gate_device_id) REFERENCES gates.gate_devices(gate_device_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.manual_gate_logs ADD CONSTRAINT fk_manual_gate_logs__reconciliation_item_id FOREIGN KEY (reconciliation_item_id) REFERENCES reconciliation.reconciliation_items(reconciliation_item_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.manual_gate_logs ADD CONSTRAINT fk_manual_gate_logs__performed_by_user_id FOREIGN KEY (performed_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.manual_gate_logs ADD CONSTRAINT fk_manual_gate_logs__recorded_by_user_id FOREIGN KEY (recorded_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.manual_gate_logs ADD CONSTRAINT fk_manual_gate_logs__recorded_by_service_identity_id FOREIGN KEY (recorded_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.manual_gate_logs ADD CONSTRAINT fk_manual_gate_logs__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.manual_gate_logs ADD CONSTRAINT fk_manual_gate_logs__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.manual_gate_logs ADD CONSTRAINT fk_manual_gate_logs__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.manual_gate_logs ADD CONSTRAINT fk_manual_gate_logs__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.override_requests ADD CONSTRAINT fk_override_requests__incident_record_id FOREIGN KEY (incident_record_id) REFERENCES operations.incident_records(incident_record_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.override_requests ADD CONSTRAINT fk_override_requests__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.override_requests ADD CONSTRAINT fk_override_requests__lane_id FOREIGN KEY (lane_id) REFERENCES sites.lanes(lane_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.override_requests ADD CONSTRAINT fk_override_requests__requested_by_user_id FOREIGN KEY (requested_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.override_requests ADD CONSTRAINT fk_override_requests__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.override_requests ADD CONSTRAINT fk_override_requests__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.override_requests ADD CONSTRAINT fk_override_requests__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.override_requests ADD CONSTRAINT fk_override_requests__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.override_approvals ADD CONSTRAINT fk_override_approvals__override_request_id FOREIGN KEY (override_request_id) REFERENCES operations.override_requests(override_request_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.override_approvals ADD CONSTRAINT fk_override_approvals__decided_by_user_id FOREIGN KEY (decided_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.override_approvals ADD CONSTRAINT fk_override_approvals__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.override_approvals ADD CONSTRAINT fk_override_approvals__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.incident_records ADD CONSTRAINT fk_incident_records__site_group_id FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.incident_records ADD CONSTRAINT fk_incident_records__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.incident_records ADD CONSTRAINT fk_incident_records__lane_id FOREIGN KEY (lane_id) REFERENCES sites.lanes(lane_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.incident_records ADD CONSTRAINT fk_incident_records__gate_device_id FOREIGN KEY (gate_device_id) REFERENCES gates.gate_devices(gate_device_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.incident_records ADD CONSTRAINT fk_incident_records__vendor_system_id FOREIGN KEY (vendor_system_id) REFERENCES integration.vendor_systems(vendor_system_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.incident_records ADD CONSTRAINT fk_incident_records__payment_rail_id FOREIGN KEY (payment_rail_id) REFERENCES payments.payment_rails(payment_rail_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.incident_records ADD CONSTRAINT fk_incident_records__owner_user_id FOREIGN KEY (owner_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.incident_records ADD CONSTRAINT fk_incident_records__owner_service_identity_id FOREIGN KEY (owner_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.incident_records ADD CONSTRAINT fk_incident_records__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.incident_records ADD CONSTRAINT fk_incident_records__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.incident_records ADD CONSTRAINT fk_incident_records__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.incident_records ADD CONSTRAINT fk_incident_records__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.operator_action_logs ADD CONSTRAINT fk_operator_action_logs__operator_user_id FOREIGN KEY (operator_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.operator_action_logs ADD CONSTRAINT fk_operator_action_logs__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.operator_action_logs ADD CONSTRAINT fk_operator_action_logs__incident_record_id FOREIGN KEY (incident_record_id) REFERENCES operations.incident_records(incident_record_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.operator_action_logs ADD CONSTRAINT fk_operator_action_logs__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE operations.operator_action_logs ADD CONSTRAINT fk_operator_action_logs__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.mops_transaction_records ADD CONSTRAINT fk_mops_transaction_records__parking_session_id FOREIGN KEY (parking_session_id) REFERENCES core.parking_sessions(parking_session_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.mops_transaction_records ADD CONSTRAINT fk_mops_transaction_records__manual_gate_log_id FOREIGN KEY (manual_gate_log_id) REFERENCES operations.manual_gate_logs(manual_gate_log_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.mops_transaction_records ADD CONSTRAINT fk_mops_transaction_records__incident_record_id FOREIGN KEY (incident_record_id) REFERENCES operations.incident_records(incident_record_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.mops_transaction_records ADD CONSTRAINT fk_mops_transaction_records__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.mops_transaction_records ADD CONSTRAINT fk_mops_transaction_records__lane_id FOREIGN KEY (lane_id) REFERENCES sites.lanes(lane_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.mops_transaction_records ADD CONSTRAINT fk_mops_transaction_records__captured_by_user_id FOREIGN KEY (captured_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.mops_transaction_records ADD CONSTRAINT fk_mops_transaction_records__captured_by_service_identity_id FOREIGN KEY (captured_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.mops_transaction_records ADD CONSTRAINT fk_mops_transaction_records__imported_by_service_identity_id FOREIGN KEY (imported_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.mops_transaction_records ADD CONSTRAINT fk_mops_transaction_records__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.mops_transaction_records ADD CONSTRAINT fk_mops_transaction_records__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.mops_transaction_records ADD CONSTRAINT fk_mops_transaction_records__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.mops_transaction_records ADD CONSTRAINT fk_mops_transaction_records__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_runs ADD CONSTRAINT fk_reconciliation_runs__site_group_id FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_runs ADD CONSTRAINT fk_reconciliation_runs__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_runs ADD CONSTRAINT fk_reconciliation_runs__incident_record_id FOREIGN KEY (incident_record_id) REFERENCES operations.incident_records(incident_record_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_runs ADD CONSTRAINT fk_reconciliation_runs__payment_rail_id FOREIGN KEY (payment_rail_id) REFERENCES payments.payment_rails(payment_rail_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_runs ADD CONSTRAINT fk_reconciliation_runs__vendor_system_id FOREIGN KEY (vendor_system_id) REFERENCES integration.vendor_systems(vendor_system_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_runs ADD CONSTRAINT fk_reconciliation_runs__initiated_by_user_id FOREIGN KEY (initiated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_runs ADD CONSTRAINT fk_reconciliation_runs__initiated_by_service_identity_id FOREIGN KEY (initiated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_runs ADD CONSTRAINT fk_reconciliation_runs__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_runs ADD CONSTRAINT fk_reconciliation_runs__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_runs ADD CONSTRAINT fk_reconciliation_runs__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_runs ADD CONSTRAINT fk_reconciliation_runs__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_items ADD CONSTRAINT fk_reconciliation_items__reconciliation_run_id FOREIGN KEY (reconciliation_run_id) REFERENCES reconciliation.reconciliation_runs(reconciliation_run_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_items ADD CONSTRAINT fk_reconciliation_items__mops_transaction_record_id FOREIGN KEY (mops_transaction_record_id) REFERENCES reconciliation.mops_transaction_records(mops_transaction_record_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_items ADD CONSTRAINT fk_reconciliation_items__manual_gate_log_id FOREIGN KEY (manual_gate_log_id) REFERENCES operations.manual_gate_logs(manual_gate_log_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_items ADD CONSTRAINT fk_reconciliation_items__payment_attempt_id FOREIGN KEY (payment_attempt_id) REFERENCES core.payment_attempts(payment_attempt_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_items ADD CONSTRAINT fk_reconciliation_items__payment_confirmation_id FOREIGN KEY (payment_confirmation_id) REFERENCES core.payment_confirmations(payment_confirmation_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_items ADD CONSTRAINT fk_reconciliation_items__provider_outcome_id FOREIGN KEY (provider_outcome_id) REFERENCES payments.provider_outcomes(provider_outcome_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_items ADD CONSTRAINT fk_reconciliation_items__resolved_by_user_id FOREIGN KEY (resolved_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_items ADD CONSTRAINT fk_reconciliation_items__resolved_by_service_identity_id FOREIGN KEY (resolved_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_items ADD CONSTRAINT fk_reconciliation_items__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_items ADD CONSTRAINT fk_reconciliation_items__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_items ADD CONSTRAINT fk_reconciliation_items__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_items ADD CONSTRAINT fk_reconciliation_items__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_exceptions ADD CONSTRAINT fk_reconciliation_exceptions__reconciliation_run_id FOREIGN KEY (reconciliation_run_id) REFERENCES reconciliation.reconciliation_runs(reconciliation_run_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_exceptions ADD CONSTRAINT fk_reconciliation_exceptions__reconciliation_item_id FOREIGN KEY (reconciliation_item_id) REFERENCES reconciliation.reconciliation_items(reconciliation_item_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_exceptions ADD CONSTRAINT fk_reconciliation_exceptions__incident_record_id FOREIGN KEY (incident_record_id) REFERENCES operations.incident_records(incident_record_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_exceptions ADD CONSTRAINT fk_reconciliation_exceptions__assigned_to_user_id FOREIGN KEY (assigned_to_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_exceptions ADD CONSTRAINT fk_reconciliation_exceptions__assigned_to_service_identity_i FOREIGN KEY (assigned_to_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_exceptions ADD CONSTRAINT fk_reconciliation_exceptions__resolved_by_user_id FOREIGN KEY (resolved_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_exceptions ADD CONSTRAINT fk_reconciliation_exceptions__resolved_by_service_identity_i FOREIGN KEY (resolved_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_exceptions ADD CONSTRAINT fk_reconciliation_exceptions__closed_by_user_id FOREIGN KEY (closed_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_exceptions ADD CONSTRAINT fk_reconciliation_exceptions__closed_by_service_identity_id FOREIGN KEY (closed_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_exceptions ADD CONSTRAINT fk_reconciliation_exceptions__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_exceptions ADD CONSTRAINT fk_reconciliation_exceptions__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_exceptions ADD CONSTRAINT fk_reconciliation_exceptions__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.reconciliation_exceptions ADD CONSTRAINT fk_reconciliation_exceptions__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.settlement_comparison_records ADD CONSTRAINT fk_settlement_comparison_records__reconciliation_item_id FOREIGN KEY (reconciliation_item_id) REFERENCES reconciliation.reconciliation_items(reconciliation_item_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.settlement_comparison_records ADD CONSTRAINT fk_settlement_comparison_records__mops_transaction_record_id FOREIGN KEY (mops_transaction_record_id) REFERENCES reconciliation.mops_transaction_records(mops_transaction_record_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.settlement_comparison_records ADD CONSTRAINT fk_settlement_comparison_records__reconciliation_exception_i FOREIGN KEY (reconciliation_exception_id) REFERENCES reconciliation.reconciliation_exceptions(reconciliation_exception_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.settlement_comparison_records ADD CONSTRAINT fk_settlement_comparison_records__payment_confirmation_id FOREIGN KEY (payment_confirmation_id) REFERENCES core.payment_confirmations(payment_confirmation_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.settlement_comparison_records ADD CONSTRAINT fk_settlement_comparison_records__provider_outcome_id FOREIGN KEY (provider_outcome_id) REFERENCES payments.provider_outcomes(provider_outcome_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.settlement_comparison_records ADD CONSTRAINT fk_settlement_comparison_records__compared_by_user_id FOREIGN KEY (compared_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.settlement_comparison_records ADD CONSTRAINT fk_settlement_comparison_records__compared_by_service_identi FOREIGN KEY (compared_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.settlement_comparison_records ADD CONSTRAINT fk_settlement_comparison_records__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE reconciliation.settlement_comparison_records ADD CONSTRAINT fk_settlement_comparison_records__created_by_service_identit FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sites.site_groups ADD CONSTRAINT fk_site_groups__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sites.site_groups ADD CONSTRAINT fk_site_groups__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sites.site_groups ADD CONSTRAINT fk_site_groups__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sites.site_groups ADD CONSTRAINT fk_site_groups__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sites.sites ADD CONSTRAINT fk_sites__site_group_id FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sites.sites ADD CONSTRAINT fk_sites__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sites.sites ADD CONSTRAINT fk_sites__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sites.sites ADD CONSTRAINT fk_sites__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sites.sites ADD CONSTRAINT fk_sites__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sites.lanes ADD CONSTRAINT fk_lanes__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sites.lanes ADD CONSTRAINT fk_lanes__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sites.lanes ADD CONSTRAINT fk_lanes__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sites.lanes ADD CONSTRAINT fk_lanes__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sites.lanes ADD CONSTRAINT fk_lanes__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sites.device_assignments ADD CONSTRAINT fk_device_assignments__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sites.device_assignments ADD CONSTRAINT fk_device_assignments__lane_id FOREIGN KEY (lane_id) REFERENCES sites.lanes(lane_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sites.device_assignments ADD CONSTRAINT fk_device_assignments__gate_device_id FOREIGN KEY (gate_device_id) REFERENCES gates.gate_devices(gate_device_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sites.device_assignments ADD CONSTRAINT fk_device_assignments__service_identity_id FOREIGN KEY (service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sites.device_assignments ADD CONSTRAINT fk_device_assignments__assigned_by_user_id FOREIGN KEY (assigned_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sites.device_assignments ADD CONSTRAINT fk_device_assignments__assigned_by_service_identity_id FOREIGN KEY (assigned_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sites.device_assignments ADD CONSTRAINT fk_device_assignments__unassigned_by_user_id FOREIGN KEY (unassigned_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sites.device_assignments ADD CONSTRAINT fk_device_assignments__unassigned_by_service_identity_id FOREIGN KEY (unassigned_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sites.device_assignments ADD CONSTRAINT fk_device_assignments__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sites.device_assignments ADD CONSTRAINT fk_device_assignments__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sites.device_assignments ADD CONSTRAINT fk_device_assignments__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE sites.device_assignments ADD CONSTRAINT fk_device_assignments__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE merchants.merchants ADD CONSTRAINT fk_merchants__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE merchants.merchants ADD CONSTRAINT fk_merchants__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE merchants.merchants ADD CONSTRAINT fk_merchants__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE merchants.merchants ADD CONSTRAINT fk_merchants__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE merchants.merchant_site_scopes ADD CONSTRAINT fk_merchant_site_scopes__merchant_id FOREIGN KEY (merchant_id) REFERENCES merchants.merchants(merchant_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE merchants.merchant_site_scopes ADD CONSTRAINT fk_merchant_site_scopes__site_group_id FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE merchants.merchant_site_scopes ADD CONSTRAINT fk_merchant_site_scopes__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE merchants.merchant_site_scopes ADD CONSTRAINT fk_merchant_site_scopes__approved_by_user_id FOREIGN KEY (approved_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE merchants.merchant_site_scopes ADD CONSTRAINT fk_merchant_site_scopes__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE merchants.merchant_site_scopes ADD CONSTRAINT fk_merchant_site_scopes__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE merchants.merchant_site_scopes ADD CONSTRAINT fk_merchant_site_scopes__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE merchants.merchant_site_scopes ADD CONSTRAINT fk_merchant_site_scopes__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE merchants.merchant_wallets ADD CONSTRAINT fk_merchant_wallets__merchant_id FOREIGN KEY (merchant_id) REFERENCES merchants.merchants(merchant_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE merchants.merchant_wallets ADD CONSTRAINT fk_merchant_wallets__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE merchants.merchant_wallets ADD CONSTRAINT fk_merchant_wallets__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE merchants.merchant_wallets ADD CONSTRAINT fk_merchant_wallets__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE merchants.merchant_wallets ADD CONSTRAINT fk_merchant_wallets__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE merchants.merchant_users ADD CONSTRAINT fk_merchant_users__merchant_id FOREIGN KEY (merchant_id) REFERENCES merchants.merchants(merchant_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE merchants.merchant_users ADD CONSTRAINT fk_merchant_users__user_id FOREIGN KEY (user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE merchants.merchant_users ADD CONSTRAINT fk_merchant_users__revoked_by_user_id FOREIGN KEY (revoked_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE merchants.merchant_users ADD CONSTRAINT fk_merchant_users__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE merchants.merchant_users ADD CONSTRAINT fk_merchant_users__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE merchants.merchant_users ADD CONSTRAINT fk_merchant_users__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE merchants.merchant_users ADD CONSTRAINT fk_merchant_users__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.users ADD CONSTRAINT fk_users__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.users ADD CONSTRAINT fk_users__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.users ADD CONSTRAINT fk_users__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.users ADD CONSTRAINT fk_users__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.roles ADD CONSTRAINT fk_roles__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.roles ADD CONSTRAINT fk_roles__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.roles ADD CONSTRAINT fk_roles__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.roles ADD CONSTRAINT fk_roles__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.permissions ADD CONSTRAINT fk_permissions__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.permissions ADD CONSTRAINT fk_permissions__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.permissions ADD CONSTRAINT fk_permissions__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.permissions ADD CONSTRAINT fk_permissions__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.user_roles ADD CONSTRAINT fk_user_roles__user_id FOREIGN KEY (user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.user_roles ADD CONSTRAINT fk_user_roles__role_id FOREIGN KEY (role_id) REFERENCES identity.roles(role_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.user_roles ADD CONSTRAINT fk_user_roles__assigned_by_user_id FOREIGN KEY (assigned_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.user_roles ADD CONSTRAINT fk_user_roles__assigned_by_service_identity_id FOREIGN KEY (assigned_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.user_roles ADD CONSTRAINT fk_user_roles__revoked_by_user_id FOREIGN KEY (revoked_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.user_roles ADD CONSTRAINT fk_user_roles__revoked_by_service_identity_id FOREIGN KEY (revoked_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.user_roles ADD CONSTRAINT fk_user_roles__last_reviewed_by_user_id FOREIGN KEY (last_reviewed_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.user_roles ADD CONSTRAINT fk_user_roles__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.user_roles ADD CONSTRAINT fk_user_roles__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.user_roles ADD CONSTRAINT fk_user_roles__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.user_roles ADD CONSTRAINT fk_user_roles__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.role_permissions ADD CONSTRAINT fk_role_permissions__role_id FOREIGN KEY (role_id) REFERENCES identity.roles(role_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.role_permissions ADD CONSTRAINT fk_role_permissions__permission_id FOREIGN KEY (permission_id) REFERENCES identity.permissions(permission_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.role_permissions ADD CONSTRAINT fk_role_permissions__assigned_by_user_id FOREIGN KEY (assigned_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.role_permissions ADD CONSTRAINT fk_role_permissions__assigned_by_service_identity_id FOREIGN KEY (assigned_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.role_permissions ADD CONSTRAINT fk_role_permissions__revoked_by_user_id FOREIGN KEY (revoked_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.role_permissions ADD CONSTRAINT fk_role_permissions__revoked_by_service_identity_id FOREIGN KEY (revoked_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.role_permissions ADD CONSTRAINT fk_role_permissions__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.role_permissions ADD CONSTRAINT fk_role_permissions__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.role_permissions ADD CONSTRAINT fk_role_permissions__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.role_permissions ADD CONSTRAINT fk_role_permissions__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.service_identities ADD CONSTRAINT fk_service_identities__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.service_identities ADD CONSTRAINT fk_service_identities__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.service_identities ADD CONSTRAINT fk_service_identities__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE identity.service_identities ADD CONSTRAINT fk_service_identities__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE audit.audit_events ADD CONSTRAINT fk_audit_events__actor_user_id FOREIGN KEY (actor_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE audit.audit_events ADD CONSTRAINT fk_audit_events__actor_service_identity_id FOREIGN KEY (actor_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE audit.audit_events ADD CONSTRAINT fk_audit_events__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE audit.audit_trail_entries ADD CONSTRAINT fk_audit_trail_entries__audit_event_id FOREIGN KEY (audit_event_id) REFERENCES audit.audit_events(audit_event_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE audit.audit_trail_entries ADD CONSTRAINT fk_audit_trail_entries__changed_by_user_id FOREIGN KEY (changed_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE audit.audit_trail_entries ADD CONSTRAINT fk_audit_trail_entries__changed_by_service_identity_id FOREIGN KEY (changed_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE audit.audit_trail_entries ADD CONSTRAINT fk_audit_trail_entries__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE audit.security_events ADD CONSTRAINT fk_security_events__audit_event_id FOREIGN KEY (audit_event_id) REFERENCES audit.audit_events(audit_event_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE audit.security_events ADD CONSTRAINT fk_security_events__actor_user_id FOREIGN KEY (actor_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE audit.security_events ADD CONSTRAINT fk_security_events__actor_service_identity_id FOREIGN KEY (actor_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE audit.security_events ADD CONSTRAINT fk_security_events__incident_record_id FOREIGN KEY (incident_record_id) REFERENCES operations.incident_records(incident_record_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE audit.security_events ADD CONSTRAINT fk_security_events__resolved_by_user_id FOREIGN KEY (resolved_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE audit.security_events ADD CONSTRAINT fk_security_events__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE audit.evidence_links ADD CONSTRAINT fk_evidence_links__audit_event_id FOREIGN KEY (audit_event_id) REFERENCES audit.audit_events(audit_event_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE audit.evidence_links ADD CONSTRAINT fk_evidence_links__security_event_id FOREIGN KEY (security_event_id) REFERENCES audit.security_events(security_event_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE audit.evidence_links ADD CONSTRAINT fk_evidence_links__linked_by_user_id FOREIGN KEY (linked_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE audit.evidence_links ADD CONSTRAINT fk_evidence_links__linked_by_service_identity_id FOREIGN KEY (linked_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE audit.evidence_links ADD CONSTRAINT fk_evidence_links__purged_by_user_id FOREIGN KEY (purged_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE audit.evidence_links ADD CONSTRAINT fk_evidence_links__purged_by_service_identity_id FOREIGN KEY (purged_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE audit.evidence_links ADD CONSTRAINT fk_evidence_links__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE audit.evidence_links ADD CONSTRAINT fk_evidence_links__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE audit.evidence_links ADD CONSTRAINT fk_evidence_links__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE audit.evidence_links ADD CONSTRAINT fk_evidence_links__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.vendor_systems ADD CONSTRAINT fk_vendor_systems__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.vendor_systems ADD CONSTRAINT fk_vendor_systems__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.vendor_systems ADD CONSTRAINT fk_vendor_systems__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.vendor_systems ADD CONSTRAINT fk_vendor_systems__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.vendor_endpoints ADD CONSTRAINT fk_vendor_endpoints__vendor_system_id FOREIGN KEY (vendor_system_id) REFERENCES integration.vendor_systems(vendor_system_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.vendor_endpoints ADD CONSTRAINT fk_vendor_endpoints__credential_reference_id FOREIGN KEY (credential_reference_id) REFERENCES integration.integration_credential_references(integration_credential_reference_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.vendor_endpoints ADD CONSTRAINT fk_vendor_endpoints__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.vendor_endpoints ADD CONSTRAINT fk_vendor_endpoints__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.vendor_endpoints ADD CONSTRAINT fk_vendor_endpoints__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.vendor_endpoints ADD CONSTRAINT fk_vendor_endpoints__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.adapter_mappings ADD CONSTRAINT fk_adapter_mappings__vendor_system_id FOREIGN KEY (vendor_system_id) REFERENCES integration.vendor_systems(vendor_system_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.adapter_mappings ADD CONSTRAINT fk_adapter_mappings__site_group_id FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.adapter_mappings ADD CONSTRAINT fk_adapter_mappings__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.adapter_mappings ADD CONSTRAINT fk_adapter_mappings__lane_id FOREIGN KEY (lane_id) REFERENCES sites.lanes(lane_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.adapter_mappings ADD CONSTRAINT fk_adapter_mappings__gate_device_id FOREIGN KEY (gate_device_id) REFERENCES gates.gate_devices(gate_device_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.adapter_mappings ADD CONSTRAINT fk_adapter_mappings__payment_rail_id FOREIGN KEY (payment_rail_id) REFERENCES payments.payment_rails(payment_rail_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.adapter_mappings ADD CONSTRAINT fk_adapter_mappings__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.adapter_mappings ADD CONSTRAINT fk_adapter_mappings__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.adapter_mappings ADD CONSTRAINT fk_adapter_mappings__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.adapter_mappings ADD CONSTRAINT fk_adapter_mappings__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.integration_credential_references ADD CONSTRAINT fk_integration_credential_references__vendor_system_id FOREIGN KEY (vendor_system_id) REFERENCES integration.vendor_systems(vendor_system_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.integration_credential_references ADD CONSTRAINT fk_integration_credential_references__service_identity_id FOREIGN KEY (service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.integration_credential_references ADD CONSTRAINT fk_integration_credential_references__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.integration_credential_references ADD CONSTRAINT fk_integration_credential_references__created_by_service_ide FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.integration_credential_references ADD CONSTRAINT fk_integration_credential_references__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.integration_credential_references ADD CONSTRAINT fk_integration_credential_references__updated_by_service_ide FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.integration_health_records ADD CONSTRAINT fk_integration_health_records__vendor_system_id FOREIGN KEY (vendor_system_id) REFERENCES integration.vendor_systems(vendor_system_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.integration_health_records ADD CONSTRAINT fk_integration_health_records__vendor_endpoint_id FOREIGN KEY (vendor_endpoint_id) REFERENCES integration.vendor_endpoints(vendor_endpoint_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.integration_health_records ADD CONSTRAINT fk_integration_health_records__site_group_id FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.integration_health_records ADD CONSTRAINT fk_integration_health_records__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.integration_health_records ADD CONSTRAINT fk_integration_health_records__incident_record_id FOREIGN KEY (incident_record_id) REFERENCES operations.incident_records(incident_record_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE integration.integration_health_records ADD CONSTRAINT fk_integration_health_records__observed_by_service_identity_ FOREIGN KEY (observed_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE config.system_parameters ADD CONSTRAINT fk_system_parameters__approved_by_user_id FOREIGN KEY (approved_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE config.system_parameters ADD CONSTRAINT fk_system_parameters__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE config.system_parameters ADD CONSTRAINT fk_system_parameters__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE config.system_parameters ADD CONSTRAINT fk_system_parameters__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE config.system_parameters ADD CONSTRAINT fk_system_parameters__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE config.feature_flags ADD CONSTRAINT fk_feature_flags__site_group_id FOREIGN KEY (site_group_id) REFERENCES sites.site_groups(site_group_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE config.feature_flags ADD CONSTRAINT fk_feature_flags__site_id FOREIGN KEY (site_id) REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE config.feature_flags ADD CONSTRAINT fk_feature_flags__merchant_id FOREIGN KEY (merchant_id) REFERENCES merchants.merchants(merchant_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE config.feature_flags ADD CONSTRAINT fk_feature_flags__payment_rail_id FOREIGN KEY (payment_rail_id) REFERENCES payments.payment_rails(payment_rail_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE config.feature_flags ADD CONSTRAINT fk_feature_flags__service_identity_id FOREIGN KEY (service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE config.feature_flags ADD CONSTRAINT fk_feature_flags__approved_by_user_id FOREIGN KEY (approved_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE config.feature_flags ADD CONSTRAINT fk_feature_flags__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE config.feature_flags ADD CONSTRAINT fk_feature_flags__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE config.feature_flags ADD CONSTRAINT fk_feature_flags__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE config.feature_flags ADD CONSTRAINT fk_feature_flags__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE config.rate_limit_policies ADD CONSTRAINT fk_rate_limit_policies__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE config.rate_limit_policies ADD CONSTRAINT fk_rate_limit_policies__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE config.rate_limit_policies ADD CONSTRAINT fk_rate_limit_policies__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE config.rate_limit_policies ADD CONSTRAINT fk_rate_limit_policies__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE config.ttl_policies ADD CONSTRAINT fk_ttl_policies__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE config.ttl_policies ADD CONSTRAINT fk_ttl_policies__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE config.ttl_policies ADD CONSTRAINT fk_ttl_policies__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE config.ttl_policies ADD CONSTRAINT fk_ttl_policies__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE config.controlled_code_sets ADD CONSTRAINT fk_controlled_code_sets__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE config.controlled_code_sets ADD CONSTRAINT fk_controlled_code_sets__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE config.controlled_code_sets ADD CONSTRAINT fk_controlled_code_sets__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE config.controlled_code_sets ADD CONSTRAINT fk_controlled_code_sets__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE events.domain_events ADD CONSTRAINT fk_domain_events__actor_user_id FOREIGN KEY (actor_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE events.domain_events ADD CONSTRAINT fk_domain_events__actor_service_identity_id FOREIGN KEY (actor_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE events.domain_events ADD CONSTRAINT fk_domain_events__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE events.outbox_events ADD CONSTRAINT fk_outbox_events__domain_event_id FOREIGN KEY (domain_event_id) REFERENCES events.domain_events(domain_event_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE events.outbox_events ADD CONSTRAINT fk_outbox_events__locked_by_service_identity_id FOREIGN KEY (locked_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE events.outbox_events ADD CONSTRAINT fk_outbox_events__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE events.outbox_events ADD CONSTRAINT fk_outbox_events__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE events.event_publications ADD CONSTRAINT fk_event_publications__outbox_event_id FOREIGN KEY (outbox_event_id) REFERENCES events.outbox_events(outbox_event_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE events.event_publications ADD CONSTRAINT fk_event_publications__publisher_service_identity_id FOREIGN KEY (publisher_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE events.dead_letter_records ADD CONSTRAINT fk_dead_letter_records__outbox_event_id FOREIGN KEY (outbox_event_id) REFERENCES events.outbox_events(outbox_event_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE events.dead_letter_records ADD CONSTRAINT fk_dead_letter_records__event_publication_id FOREIGN KEY (event_publication_id) REFERENCES events.event_publications(event_publication_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE events.dead_letter_records ADD CONSTRAINT fk_dead_letter_records__resolved_by_user_id FOREIGN KEY (resolved_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE events.dead_letter_records ADD CONSTRAINT fk_dead_letter_records__resolved_by_service_identity_id FOREIGN KEY (resolved_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE events.dead_letter_records ADD CONSTRAINT fk_dead_letter_records__replay_requested_by_user_id FOREIGN KEY (replay_requested_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE events.dead_letter_records ADD CONSTRAINT fk_dead_letter_records__replay_requested_by_service_identity FOREIGN KEY (replay_requested_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE events.dead_letter_records ADD CONSTRAINT fk_dead_letter_records__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE events.dead_letter_records ADD CONSTRAINT fk_dead_letter_records__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE events.dead_letter_records ADD CONSTRAINT fk_dead_letter_records__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE events.consumer_checkpoints ADD CONSTRAINT fk_consumer_checkpoints__last_outbox_event_id FOREIGN KEY (last_outbox_event_id) REFERENCES events.outbox_events(outbox_event_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE events.consumer_checkpoints ADD CONSTRAINT fk_consumer_checkpoints__last_domain_event_id FOREIGN KEY (last_domain_event_id) REFERENCES events.domain_events(domain_event_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE events.consumer_checkpoints ADD CONSTRAINT fk_consumer_checkpoints__locked_by_service_identity_id FOREIGN KEY (locked_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE events.consumer_checkpoints ADD CONSTRAINT fk_consumer_checkpoints__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE;

