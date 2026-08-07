\set ON_ERROR_STOP on

BEGIN;

DO $$
DECLARE
    service_id uuid := '19000000-0000-0000-0000-000000000001';
    user_a uuid := '19000000-0000-0000-0000-000000000002';
    user_b uuid := '19000000-0000-0000-0000-000000000003';
    user_c uuid := '19000000-0000-0000-0000-000000000004';
    role_id uuid := '19000000-0000-0000-0000-000000000005';
    user_role_id uuid := '19000000-0000-0000-0000-000000000006';
    v_site_group_id uuid := '19000000-0000-0000-0000-000000000007';
    site_id uuid := '19000000-0000-0000-0000-000000000008';
    credential_a uuid := '19000000-0000-0000-0000-000000000009';
    credential_c uuid := '19000000-0000-0000-0000-000000000010';
    provider_id uuid := '19000000-0000-0000-0000-000000000011';
    mfa_id uuid := '19000000-0000-0000-0000-000000000012';
    decider_session_id uuid := '19000000-0000-0000-0000-000000000013';
    site_grant_id uuid := '19000000-0000-0000-0000-000000000014';
    request_id uuid := '19000000-0000-0000-0000-000000000015';
    site_group_grant_id uuid := '19000000-0000-0000-0000-000000000023';
    collision_blocked boolean := false;
    credential_lifecycle_blocked boolean := false;
    external_duplicate_blocked boolean := false;
    mfa_duplicate_blocked boolean := false;
    mfa_lifecycle_blocked boolean := false;
    mfa_reset_lifecycle_blocked boolean := false;
    session_expiry_blocked boolean := false;
    challenge_duplicate_blocked boolean := false;
    challenge_expiry_blocked boolean := false;
    invalid_scope_blocked boolean := false;
    duplicate_scope_blocked boolean := false;
    invalid_site_group_blocked boolean := false;
    duplicate_site_group_blocked boolean := false;
    invalid_global_blocked boolean := false;
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'identity'
          AND table_name IN ('local_credentials', 'external_identity_bindings', 'user_mfa_authenticators', 'human_sessions', 'authentication_attempts', 'credential_challenges')
          AND (
              lower(column_name) IN ('password', 'plaintext_password', 'raw_password', 'recoverable_password')
              OR lower(column_name) LIKE '%password_hint%'
              OR lower(column_name) LIKE '%raw_session_secret%'
              OR lower(column_name) LIKE '%raw_bearer%'
              OR lower(column_name) LIKE '%raw_refresh%'
              OR lower(column_name) LIKE '%totp_seed%'
              OR lower(column_name) LIKE '%totp_code%'
              OR lower(column_name) LIKE '%provisioning_uri%'
              OR lower(column_name) LIKE '%qr_payload%'
              OR lower(column_name) LIKE '%id_token%'
              OR lower(column_name) LIKE '%access_token%'
              OR lower(column_name) LIKE '%refresh_token%'
          )
    ) THEN
        RAISE EXCEPTION 'Prohibited secret-bearing identity column found.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'identity'
          AND table_name IN ('local_credentials', 'external_identity_providers', 'external_identity_bindings', 'user_mfa_authenticators', 'human_sessions', 'authentication_attempts', 'credential_challenges', 'user_role_scope_grants', 'privileged_access_requests', 'privileged_access_decisions')
          AND data_type IN ('json', 'jsonb')
    ) THEN
        RAISE EXCEPTION 'Generic JSON authority found in I-019 identity tables.';
    END IF;

    IF EXISTS (SELECT 1 FROM identity.external_identity_providers) THEN
        RAISE EXCEPTION 'I-019 must seed no external identity provider.';
    END IF;
    IF EXISTS (SELECT 1 FROM identity.user_role_scope_grants WHERE scope_type = 'GLOBAL') THEN
        RAISE EXCEPTION 'I-019 must seed no GLOBAL scope grant.';
    END IF;

    INSERT INTO identity.service_identities (
        service_identity_id, service_identity_code, service_identity_name, identity_type, identity_status, effective_from
    ) VALUES (service_id, 'i019-validation-service', 'I-019 Validation Service', 'INTERNAL_SERVICE', 'ACTIVE', now());

    INSERT INTO identity.users (user_id, username, display_name, user_type, user_status, effective_from)
    VALUES
        (user_a, 'Cashier01', 'I-019 User A', 'SITE_OPERATOR', 'ACTIVE', now()),
        (user_b, 'Reviewer02', 'I-019 User B', 'OPERATIONS_USER', 'ACTIVE', now()),
        (user_c, 'Admin03', 'I-019 User C', 'INTERNAL_ADMIN', 'ACTIVE', now());

    IF (SELECT username_normalized FROM identity.users WHERE user_id = user_a) <> 'cashier01' THEN
        RAISE EXCEPTION 'Normalized username was not deterministically generated.';
    END IF;

    BEGIN
        INSERT INTO identity.users (username, display_name, user_type, user_status, effective_from)
        VALUES (' cashier01 ', 'Collision', 'SITE_OPERATOR', 'ACTIVE', now());
    EXCEPTION WHEN unique_violation THEN
        collision_blocked := true;
    END;
    IF NOT collision_blocked THEN RAISE EXCEPTION 'Normalized username collision was not blocked.'; END IF;

    INSERT INTO identity.roles (role_id, role_code, role_name, role_type, role_status, effective_from)
    VALUES (role_id, 'I019_VALIDATION_ROLE', 'I-019 Validation Role', 'OPERATIONS', 'ACTIVE', now());
    INSERT INTO identity.user_roles (user_role_id, user_id, role_id, assignment_status, effective_from)
    VALUES (user_role_id, user_a, role_id, 'ACTIVE', now());

    INSERT INTO sites.site_groups (site_group_id, site_group_code, site_group_name, timezone_name, default_currency_code, site_group_status, effective_from)
    VALUES (v_site_group_id, 'I019-GROUP', 'I-019 Group', 'Asia/Manila', 'PHP', 'ACTIVE', now());
    INSERT INTO sites.sites (site_id, site_group_id, site_code, site_name, site_type, timezone_name, country_code, site_status, effective_from)
    VALUES (site_id, v_site_group_id, 'I019-SITE', 'I-019 Site', 'OTHER', 'Asia/Manila', 'PH', 'ACTIVE', now());

    INSERT INTO identity.local_credentials (
        local_credential_id, user_id, credential_status, password_verifier, verifier_salt,
        verifier_algorithm_code, verifier_algorithm_version, verifier_work_factor,
        verifier_memory_kib, verifier_parallelism, activated_at
    ) VALUES
        (credential_a, user_a, 'ACTIVE', decode(repeat('a1', 32), 'hex'), decode(repeat('b2', 16), 'hex'), 'ARGON2ID', 1, 3, 65536, 1, now()),
        (credential_c, user_c, 'ACTIVE', decode(repeat('c3', 32), 'hex'), decode(repeat('d4', 16), 'hex'), 'ARGON2ID', 1, 3, 65536, 1, now());
    BEGIN
        INSERT INTO identity.local_credentials (
            user_id, credential_status, password_verifier, verifier_salt,
            verifier_algorithm_code, verifier_algorithm_version, verifier_work_factor
        ) VALUES (user_b, 'ACTIVE', decode(repeat('11', 32), 'hex'), decode(repeat('22', 16), 'hex'), 'ARGON2ID', 1, 3);
    EXCEPTION WHEN check_violation THEN
        credential_lifecycle_blocked := true;
    END;
    IF NOT credential_lifecycle_blocked THEN RAISE EXCEPTION 'Invalid active local credential lifecycle was not blocked.'; END IF;

    INSERT INTO identity.external_identity_providers (
        external_identity_provider_id, provider_code, provider_name, issuer_identifier_hash, provider_status, effective_from
    ) VALUES (provider_id, 'I019_DISABLED_OIDC', 'I-019 Disabled OIDC', repeat('1', 64), 'DISABLED', now());
    INSERT INTO identity.external_identity_bindings (
        user_id, external_identity_provider_id, external_subject_hash, binding_status, effective_from
    ) VALUES (user_a, provider_id, repeat('2', 64), 'ACTIVE', now());
    BEGIN
        INSERT INTO identity.external_identity_bindings (
            user_id, external_identity_provider_id, external_subject_hash, binding_status, effective_from
        ) VALUES (user_b, provider_id, repeat('2', 64), 'ACTIVE', now());
    EXCEPTION WHEN unique_violation THEN
        external_duplicate_blocked := true;
    END;
    IF NOT external_duplicate_blocked THEN RAISE EXCEPTION 'External issuer/subject duplicate was not blocked.'; END IF;

    INSERT INTO identity.user_mfa_authenticators (
        user_mfa_authenticator_id, user_id, authenticator_type, authenticator_status,
        protected_secret_envelope, protection_key_reference, protection_key_version,
        envelope_format_version, activated_at
    ) VALUES (mfa_id, user_c, 'TOTP', 'ACTIVE', decode(repeat('e5', 32), 'hex'), 'key://i019-synthetic', 'v1', 1, now());
    BEGIN
        INSERT INTO identity.user_mfa_authenticators (
            user_id, authenticator_type, authenticator_status, protected_secret_envelope,
            protection_key_reference, protection_key_version, envelope_format_version, activated_at
        ) VALUES (user_c, 'TOTP', 'ACTIVE', decode(repeat('f6', 32), 'hex'), 'key://i019-other', 'v1', 1, now());
    EXCEPTION WHEN unique_violation THEN
        mfa_duplicate_blocked := true;
    END;
    IF NOT mfa_duplicate_blocked THEN RAISE EXCEPTION 'Duplicate current TOTP authenticator was not blocked.'; END IF;
    BEGIN
        INSERT INTO identity.user_mfa_authenticators (
            user_id, authenticator_type, authenticator_status, protected_secret_envelope,
            protection_key_reference, protection_key_version, envelope_format_version
        ) VALUES (user_b, 'TOTP', 'ACTIVE', decode(repeat('33', 32), 'hex'), 'key://i019-invalid', 'v1', 1);
    EXCEPTION WHEN check_violation THEN
        mfa_lifecycle_blocked := true;
    END;
    IF NOT mfa_lifecycle_blocked THEN RAISE EXCEPTION 'Invalid active TOTP lifecycle was not blocked.'; END IF;
    BEGIN
        INSERT INTO identity.user_mfa_authenticators (
            user_id, authenticator_type, authenticator_status, protected_secret_envelope,
            protection_key_reference, protection_key_version, envelope_format_version, activated_at
        ) VALUES (user_b, 'TOTP', 'RESET_REQUIRED', decode(repeat('44', 32), 'hex'), 'key://i019-invalid-reset', 'v1', 1, now());
    EXCEPTION WHEN check_violation THEN
        mfa_reset_lifecycle_blocked := true;
    END;
    IF NOT mfa_reset_lifecycle_blocked THEN RAISE EXCEPTION 'TOTP reset-required state without governed reset metadata was not blocked.'; END IF;

    INSERT INTO identity.human_sessions (
        human_session_id, session_secret_hash, user_id, authentication_provider, local_credential_id,
        session_audience, session_status, assurance_context_code, mfa_requirement_satisfied,
        mfa_authenticator_id, mfa_verified_at, authenticated_at, last_seen_at, idle_expires_at,
        absolute_expires_at, credential_version_snapshot, authorization_epoch_snapshot, correlation_id
    ) VALUES (
        decider_session_id, repeat('3', 64), user_c, 'LOCAL', credential_c,
        'MANAGEMENT_PLATFORM', 'ACTIVE', 'PASSWORD_TOTP', true,
        mfa_id, now(), now(), now(), now() + interval '30 minutes',
        now() + interval '8 hours', 1, 1, '19000000-0000-0000-0000-000000000016'
    );
    BEGIN
        INSERT INTO identity.human_sessions (
            session_secret_hash, user_id, authentication_provider, local_credential_id,
            session_audience, session_status, assurance_context_code, authenticated_at,
            last_seen_at, idle_expires_at, absolute_expires_at, credential_version_snapshot,
            authorization_epoch_snapshot, correlation_id
        ) VALUES (
            repeat('9', 64), user_a, 'LOCAL', credential_a, 'APT', 'ACTIVE', 'PASSWORD',
            '2026-01-01T00:00:00Z', '2026-01-01T00:01:00Z', '2026-01-01T00:00:30Z',
            '2026-01-01T08:00:00Z', 1, 1, '19000000-0000-0000-0000-000000000024'
        );
    EXCEPTION WHEN check_violation THEN
        session_expiry_blocked := true;
    END;
    IF NOT session_expiry_blocked THEN RAISE EXCEPTION 'Invalid human-session expiry ordering was not blocked.'; END IF;

    INSERT INTO identity.authentication_attempts (
        user_id, login_identifier_hash, attempt_type, attempt_result, session_audience,
        source_ip_hash, observed_at, correlation_id, recorded_by_service_identity_id
    ) VALUES
        (user_a, repeat('4', 64), 'PASSWORD', 'SUCCESS', 'APT', repeat('5', 64), now(), '19000000-0000-0000-0000-000000000017', service_id),
        (user_c, repeat('6', 64), 'TOTP', 'INVALID', 'MANAGEMENT_PLATFORM', repeat('5', 64), now(), '19000000-0000-0000-0000-000000000018', service_id);

    INSERT INTO identity.credential_challenges (
        user_id, challenge_purpose, challenge_status, challenge_secret_hash,
        issued_at, expires_at, requested_by_service_identity_id, correlation_id
    ) VALUES (user_a, 'PASSWORD_RESET', 'ISSUED', repeat('7', 64), now(), now() + interval '15 minutes', service_id, '19000000-0000-0000-0000-000000000019');
    BEGIN
        INSERT INTO identity.credential_challenges (
            user_id, challenge_purpose, challenge_status, challenge_secret_hash,
            issued_at, expires_at, requested_by_service_identity_id, correlation_id
        ) VALUES (user_a, 'PASSWORD_RESET', 'ISSUED', repeat('8', 64), now(), now() + interval '15 minutes', service_id, '19000000-0000-0000-0000-000000000020');
    EXCEPTION WHEN unique_violation THEN
        challenge_duplicate_blocked := true;
    END;
    IF NOT challenge_duplicate_blocked THEN RAISE EXCEPTION 'Concurrent issued challenge was not blocked.'; END IF;
    BEGIN
        INSERT INTO identity.credential_challenges (
            user_id, challenge_purpose, challenge_status, challenge_secret_hash,
            issued_at, expires_at, requested_by_service_identity_id, correlation_id
        ) VALUES (
            user_b, 'ACCOUNT_ACTIVATION', 'ISSUED', repeat('a', 64),
            '2026-01-01T00:01:00Z', '2026-01-01T00:00:00Z', service_id,
            '19000000-0000-0000-0000-000000000025'
        );
    EXCEPTION WHEN check_violation THEN
        challenge_expiry_blocked := true;
    END;
    IF NOT challenge_expiry_blocked THEN RAISE EXCEPTION 'Invalid credential-challenge expiry was not blocked.'; END IF;
    UPDATE identity.credential_challenges
    SET challenge_status = 'CONSUMED', consumed_at = now(), row_version = row_version + 1
    WHERE challenge_secret_hash = repeat('7', 64);

    INSERT INTO identity.user_role_scope_grants (
        user_role_scope_grant_id, user_role_id, scope_type, site_id, grant_status,
        grant_reason_code, effective_from, granted_by_service_identity_id
    ) VALUES (site_grant_id, user_role_id, 'SITE', site_id, 'ACTIVE', 'I019_VALIDATION', now(), service_id);
    INSERT INTO identity.user_role_scope_grants (
        user_role_scope_grant_id, user_role_id, scope_type, site_group_id, grant_status,
        grant_reason_code, effective_from, granted_by_service_identity_id
    ) VALUES (site_group_grant_id, user_role_id, 'SITE_GROUP', v_site_group_id, 'ACTIVE', 'I019_VALIDATION', now(), service_id);
    INSERT INTO identity.user_role_scope_grants (
        user_role_id, scope_type, grant_status, grant_reason_code, effective_from, granted_by_service_identity_id
    ) VALUES (user_role_id, 'GLOBAL', 'PENDING', 'I019_VALIDATION_ONLY', now(), service_id);
    BEGIN
        INSERT INTO identity.user_role_scope_grants (
            user_role_id, scope_type, grant_status, grant_reason_code, effective_from, granted_by_service_identity_id
        ) VALUES (user_role_id, 'SITE', 'ACTIVE', 'INVALID_NULL_SITE', now(), service_id);
    EXCEPTION WHEN check_violation THEN
        invalid_scope_blocked := true;
    END;
    IF NOT invalid_scope_blocked THEN RAISE EXCEPTION 'Null SITE scope was not blocked.'; END IF;
    BEGIN
        INSERT INTO identity.user_role_scope_grants (
            user_role_id, scope_type, site_id, grant_status, grant_reason_code, effective_from, granted_by_service_identity_id
        ) VALUES (user_role_id, 'SITE', site_id, 'ACTIVE', 'DUPLICATE', now(), service_id);
    EXCEPTION WHEN unique_violation THEN
        duplicate_scope_blocked := true;
    END;
    IF NOT duplicate_scope_blocked THEN RAISE EXCEPTION 'Duplicate current Site scope was not blocked.'; END IF;
    BEGIN
        INSERT INTO identity.user_role_scope_grants (
            user_role_id, scope_type, grant_status, grant_reason_code, effective_from, granted_by_service_identity_id
        ) VALUES (user_role_id, 'SITE_GROUP', 'ACTIVE', 'INVALID_NULL_SITE_GROUP', now(), service_id);
    EXCEPTION WHEN check_violation THEN
        invalid_site_group_blocked := true;
    END;
    IF NOT invalid_site_group_blocked THEN RAISE EXCEPTION 'Null Site Group scope was not blocked.'; END IF;
    BEGIN
        INSERT INTO identity.user_role_scope_grants (
            user_role_id, scope_type, site_group_id, grant_status, grant_reason_code, effective_from, granted_by_service_identity_id
        ) VALUES (user_role_id, 'SITE_GROUP', v_site_group_id, 'ACTIVE', 'DUPLICATE_GROUP', now(), service_id);
    EXCEPTION WHEN unique_violation THEN
        duplicate_site_group_blocked := true;
    END;
    IF NOT duplicate_site_group_blocked THEN RAISE EXCEPTION 'Duplicate current Site Group scope was not blocked.'; END IF;
    BEGIN
        INSERT INTO identity.user_role_scope_grants (
            user_role_id, scope_type, site_id, grant_status, grant_reason_code, effective_from, granted_by_service_identity_id
        ) VALUES (user_role_id, 'GLOBAL', site_id, 'ACTIVE', 'INVALID_GLOBAL_SITE', now(), service_id);
    EXCEPTION WHEN check_violation THEN
        invalid_global_blocked := true;
    END;
    IF NOT invalid_global_blocked THEN RAISE EXCEPTION 'GLOBAL scope carrying a Site was not blocked.'; END IF;

    IF NOT EXISTS (
        SELECT 1 FROM identity.user_role_scope_grants g
        WHERE g.grant_reason_code = 'I019_VALIDATION_ONLY'
          AND g.scope_type = 'GLOBAL'
          AND g.site_id IS NULL
          AND g.site_group_id IS NULL
          AND g.grant_status = 'PENDING'
    ) THEN
        RAISE EXCEPTION 'Explicit pending GLOBAL scope shape was not persisted.';
    END IF;

    INSERT INTO identity.privileged_access_requests (
        privileged_access_request_id, target_user_id, requested_role_id, requested_scope_type,
        requested_site_id, request_status, request_reason_code, requested_effective_from,
        requested_at, requested_by_user_id, correlation_id
    ) VALUES (
        request_id, user_b, role_id, 'SITE', site_id, 'PENDING_DECISION', 'I019_VALIDATION', now(),
        now(), user_a, '19000000-0000-0000-0000-000000000021'
    );
    IF (SELECT request_status FROM identity.privileged_access_requests WHERE privileged_access_request_id = request_id) <> 'PENDING_DECISION' THEN
        RAISE EXCEPTION 'Privileged request defaulted to approval.';
    END IF;
    INSERT INTO identity.privileged_access_decisions (
        privileged_access_request_id, decision_sequence, decision, decision_reason_code,
        decided_at, decided_by_user_id, decider_human_session_id, correlation_id, created_by_service_identity_id
    ) VALUES (
        request_id, 1, 'APPROVE', 'I019_VALIDATION', now(), user_c, decider_session_id,
        '19000000-0000-0000-0000-000000000022', service_id
    );

    IF NOT EXISTS (
        SELECT 1
        FROM identity.user_role_scope_grants g
        JOIN identity.user_roles ur ON ur.user_role_id = g.user_role_id
        JOIN identity.users u ON u.user_id = ur.user_id
        JOIN sites.sites s ON s.site_id = g.site_id
        WHERE g.user_role_scope_grant_id = site_grant_id
          AND g.scope_type = 'SITE'
          AND ur.assignment_status = 'ACTIVE'
          AND u.user_id = user_a
          AND s.site_group_id = v_site_group_id
    ) THEN
        RAISE EXCEPTION 'Canonical user-role-Site scope join failed.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM identity.user_role_scope_grants g
        JOIN identity.user_roles ur ON ur.user_role_id = g.user_role_id
        JOIN sites.site_groups sg ON sg.site_group_id = g.site_group_id
        WHERE g.user_role_scope_grant_id = site_group_grant_id
          AND g.scope_type = 'SITE_GROUP'
          AND ur.assignment_status = 'ACTIVE'
          AND sg.site_group_id = v_site_group_id
    ) THEN
        RAISE EXCEPTION 'Canonical user-role-Site Group scope join failed.';
    END IF;

    UPDATE identity.user_roles
    SET assignment_status = 'REVOKED',
        revoked_at = now(),
        revoked_by_service_identity_id = service_id,
        row_version = row_version + 1
    WHERE identity.user_roles.user_role_id = '19000000-0000-0000-0000-000000000006';
    IF EXISTS (
        SELECT 1
        FROM identity.user_role_scope_grants g
        JOIN identity.user_roles ur ON ur.user_role_id = g.user_role_id
        WHERE g.user_role_scope_grant_id = site_grant_id
          AND g.grant_status = 'ACTIVE'
          AND ur.assignment_status = 'ACTIVE'
          AND ur.effective_from <= now()
          AND (ur.effective_to IS NULL OR ur.effective_to > now())
    ) THEN
        RAISE EXCEPTION 'A scope grant retained authority after parent role assignment revocation.';
    END IF;

    IF (SELECT count(*) FROM identity.permissions WHERE permission_code LIKE 'human-authentication.%' OR permission_code LIKE 'identity.%assignment.%' OR permission_code IN ('identity.privileged-access.decide', 'identity.access-review.manage')) < 12 THEN
        RAISE EXCEPTION 'I-019 permission catalog entries missing.';
    END IF;
    IF (SELECT count(*) FROM config.controlled_code_sets WHERE code_set_name = 'HUMAN_IDENTITY_EVENT_TYPE' AND code_domain = 'IDENTITY' AND code_status = 'ACTIVE') < 33 THEN
        RAISE EXCEPTION 'I-019 controlled identity event catalog entries missing.';
    END IF;
END $$;

ROLLBACK;

SELECT 'I-019 human authentication/session/scope foundation validation passed.' AS validation_result;
