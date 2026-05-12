DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_service_identities__service_identity_code') THEN
        ALTER TABLE identity.service_identities
        ADD CONSTRAINT uq_service_identities__service_identity_code UNIQUE (service_identity_code);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_roles__role_code') THEN
        ALTER TABLE identity.roles
        ADD CONSTRAINT uq_roles__role_code UNIQUE (role_code);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_permissions__permission_code') THEN
        ALTER TABLE identity.permissions
        ADD CONSTRAINT uq_permissions__permission_code UNIQUE (permission_code);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_controlled_code_sets__set_value_domain') THEN
        ALTER TABLE config.controlled_code_sets
        ADD CONSTRAINT uq_controlled_code_sets__set_value_domain UNIQUE (code_set_name, code_value, code_domain);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_ttl_policies__policy_code') THEN
        ALTER TABLE config.ttl_policies
        ADD CONSTRAINT uq_ttl_policies__policy_code UNIQUE (policy_code);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_rate_limit_policies__policy_code') THEN
        ALTER TABLE config.rate_limit_policies
        ADD CONSTRAINT uq_rate_limit_policies__policy_code UNIQUE (policy_code);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_vendor_systems__vendor_code_environment') THEN
        ALTER TABLE integration.vendor_systems
        ADD CONSTRAINT uq_vendor_systems__vendor_code_environment UNIQUE (vendor_code, environment_code);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_vendor_endpoints__vendor_endpoint_code') THEN
        ALTER TABLE integration.vendor_endpoints
        ADD CONSTRAINT uq_vendor_endpoints__vendor_endpoint_code UNIQUE (vendor_system_id, endpoint_code);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_payment_rails__rail_code') THEN
        ALTER TABLE payments.payment_rails
        ADD CONSTRAINT uq_payment_rails__rail_code UNIQUE (rail_code);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_site_groups__site_group_code') THEN
        ALTER TABLE sites.site_groups
        ADD CONSTRAINT uq_site_groups__site_group_code UNIQUE (site_group_code);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_sites__site_group_site_code') THEN
        ALTER TABLE sites.sites
        ADD CONSTRAINT uq_sites__site_group_site_code UNIQUE (site_group_id, site_code);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_lanes__site_lane_code') THEN
        ALTER TABLE sites.lanes
        ADD CONSTRAINT uq_lanes__site_lane_code UNIQUE (site_id, lane_code);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_gate_devices__site_device_code') THEN
        ALTER TABLE gates.gate_devices
        ADD CONSTRAINT uq_gate_devices__site_device_code UNIQUE (site_id, device_code);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_discount_policy_references__policy_code_version') THEN
        ALTER TABLE discounts.discount_policy_references
        ADD CONSTRAINT uq_discount_policy_references__policy_code_version UNIQUE (policy_code, policy_version);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_merchants__merchant_code') THEN
        ALTER TABLE merchants.merchants
        ADD CONSTRAINT uq_merchants__merchant_code UNIQUE (merchant_code);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_merchant_wallets__merchant_wallet_code') THEN
        ALTER TABLE merchants.merchant_wallets
        ADD CONSTRAINT uq_merchant_wallets__merchant_wallet_code UNIQUE (merchant_id, wallet_code);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_coupons__merchant_coupon_code') THEN
        ALTER TABLE coupons.coupons
        ADD CONSTRAINT uq_coupons__merchant_coupon_code UNIQUE (merchant_id, coupon_code);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_coupon_rule_groups__coupon_rule_group_code') THEN
        ALTER TABLE coupons.coupon_rule_groups
        ADD CONSTRAINT uq_coupon_rule_groups__coupon_rule_group_code UNIQUE (coupon_id, rule_group_code);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_coupon_rules__group_rule_code') THEN
        ALTER TABLE coupons.coupon_rules
        ADD CONSTRAINT uq_coupon_rules__group_rule_code UNIQUE (coupon_rule_group_id, rule_code);
    END IF;
END $$;