# ExitPass Canonical Human Authentication, Session, and Scope DB Foundation v1.0

## Purpose

I-019 supplies the canonical PostgreSQL persistence required by the I-018 human identity contract. It is database-only. It does not implement login, password or TOTP verification, OIDC activation, cookies or tokens, authorization middleware, user-administration APIs, or staff-application UI.

## Canonical Source

The object-per-file sources under `objects/` are authoritative. `objects/exitpass-full-object-apply-order.txt` defines the full rebuild order and `objects/v13-central-pms-object-apply-order.txt` defines the Central PMS alignment slice. The two SQL files under `build/generated/` are regenerated review artifacts, not independently authored migrations.

The canonical integration branch is `develop`. The repository has no `dev` branch. I-019 is based on `origin/develop` commit `f140dbb75c450c43056082a3cedcf4cf89df1536`.

## Existing Objects Retained

I-019 retains and extends the existing `identity.users`, `identity.roles`, `identity.permissions`, `identity.user_roles`, `identity.role_permissions`, and `identity.service_identities` authorities. It reuses `audit.audit_events` and `audit.security_events`; it does not create a shadow audit store. Site and Site Group authority remains in `sites.sites` and `sites.site_groups`.

## User Login Authority

`identity.users.username_normalized` is a generated `lower(btrim(username))` value with an unconditional unique index. The normalized value is server-owned by construction, two current or historical identities cannot share it, and retired usernames are not reused. Email remains a profile attribute and is not made a mandatory login alias by I-019.

`credential_version` supports invalidating sessions after credential changes. `authorization_epoch` supports invalidating sessions after user, role, permission, or scope changes. Lockout expiry and a controlled lockout reason augment the existing user lock state without hard-coding throttle values.

## Local Credentials

`identity.local_credentials` stores one-way password verifier bytes, verifier salt, algorithm/version/work metadata, lifecycle, credential version, and audit actors. It contains no plaintext password, reversible password, hint, reset token, browser token, or provider password. Argon2id remains the recommended I-020 runtime algorithm, but no algorithm is executed or forced by this persistence slice.

## Optional External Identity

`identity.external_identity_providers` stores a disabled-by-default provider identity using a controlled provider code and issuer identifier hash. `identity.external_identity_bindings` binds one ExitPass user to one provider and immutable external-subject hash. No provider is seeded and no endpoint, client secret, password, group-to-role mapping, assertion, ID token, access token, or refresh token is stored.

## TOTP Authenticator Authority

`identity.user_mfa_authenticators` supports the approved v1.3 TOTP authenticator only. It stores an opaque application-encrypted secret envelope, non-secret protection-key reference/version metadata, lifecycle, activation, bounded last-use replay metadata, and governed reset or revocation attribution.

The encryption key remains outside ordinary database data access. The database contains no plaintext TOTP seed, submitted OTP code, provisioning URI, QR payload, authenticator export, WebAuthn credential, passkey, or plaintext recovery code. Recovery codes and WebAuthn/FIDO2/passkey persistence are deferred.

## Human Sessions

`identity.human_sessions` supports opaque server-side sessions for `MANAGEMENT_PLATFORM`, `OPERATOR_CONSOLE`, and `APT`. It stores only a unique session-secret hash and an opaque public session reference. It binds the human user to the authentication provider, optional local credential or external binding, audience, optional APT device/service identity, authentication and activity times, idle and absolute expiries, assurance/MFA state, credential-version snapshot, authorization-epoch snapshot, revocation attribution, and correlation.

No raw session secret, bearer token, refresh token, OIDC access token, or OIDC refresh token is stored. Timeout durations, concurrent-session limits, and application cookie/token mechanics remain I-020 configuration and policy.

## Authentication Attempts And Challenges

`identity.authentication_attempts` is a privacy-bounded ledger for password, TOTP, activation, reset, and recovery outcomes. It supports user and normalized-principal hashes plus bounded network/client hashes without storing a password, verifier submission, OTP code, raw IP address, request body, or token.

`identity.credential_challenges` stores purpose-bound activation/reset/recovery challenge hashes with issue, expiry, consume, revoke, actor, reason, and correlation state. The delivery channel is intentionally not selected because DR-05 remains unresolved. Raw activation and reset values are prohibited.

## Role-Bound Scope Grants

`identity.user_role_scope_grants` attaches scope to exactly one `identity.user_roles` assignment. Scope is explicitly one of `SITE`, `SITE_GROUP`, or `GLOBAL`:

- `SITE` requires one `sites.sites` row.
- `SITE_GROUP` requires one `sites.site_groups` row.
- `GLOBAL` requires both foreign keys to be absent and the explicit `GLOBAL` discriminator.

Null Site fields never imply global authority. No global grant is seeded. Exact current duplicate grants are rejected while revoked and expired history remains queryable. Runtime authorization must also require an active/effective parent user-role assignment and active/effective role-permission binding; the database does not treat a scope row as independent authority.

## Privileged Access Persistence

`identity.privileged_access_requests` records a target user, role, optional relational Site/Site Group/GLOBAL scope proposal, requested effectivity, reason, policy reference, requester, lifecycle, and the role/scope rows eventually activated. `identity.privileged_access_decisions` records immutable sequenced decisions bound to a deciding user and human session.

Draft or pending state is never approval, and no decision is created by default. The schema supports independent decisions without hard-coding the unresolved DR-10 approver-count policy. Runtime must evaluate the configured policy, decision independence, role privilege classification, current actor permission/scope, and request state transactionally before activation.

## Permission And Event Catalog

I-019 adds narrow permission catalog entries for self-session access, session administration, credential reset, MFA status/reset/removal, role assignment, scope assignment, privileged-access decisions, and access review. It assigns none of them to a role.

The controlled `HUMAN_IDENTITY_EVENT_TYPE` vocabulary covers login, lockout, sessions, credentials, external bindings, TOTP, role/scope changes, privileged access, denied authorization, and suspicious authentication. Audit and security event payloads must remain secret-free.

## Policies Deliberately Not Hard-Coded

I-019 represents but does not decide DR-01 through DR-03 and DR-05 through DR-11. In particular, it does not activate OIDC, require local credentials for every identity, select reset delivery, fix timeout or concurrency values, alter APT custody behavior, require an exact privileged approver count, or grant/allowlist global scope. DR-04 is represented by TOTP capability, but role classification and enforcement remain server-side runtime responsibilities.

## Validation Contract

`scripts/validation/Validate-HumanAuthenticationFoundation.sql` runs transactional positive and negative proofs and rolls back all synthetic rows. The object-source CI path executes it after the canonical generated DDL and Central PMS alignment validator.

Validation covers normalized username collision, local verifier shape, external subject uniqueness, protected TOTP envelope/current-authenticator uniqueness, session hashing/audience/expiry/assurance, privacy-safe authentication attempts, challenge replay/lifecycle, Site/Site Group/GLOBAL scope shape and duplicate protection, privileged request/decision linkage, controlled vocabulary, permission catalog, prohibited columns, and absence of active external-provider or global-scope seed rows.

The pre-I-019 transition proof starts from the exact `origin/develop` generated full DDL and applies the additive I-019 object slice in dependency order. This follows the current repository model used by the recent canonical I-012 through I-015 foundations; it does not reinterpret the generated v13 source slice as an idempotent migration.

## Validation Result

Validation ran against a disposable PostgreSQL 16 container with no persistent volume. The repository CI entry point regenerated both committed SQL artifacts, validated the full and v13 source layouts, created a fresh database, applied the full generated DDL, and passed the Central PMS alignment and focused I-019 validators.

Two independent clean rebuilds produced byte-identical deterministic schema-only dumps. The pre-I-019 upgrade database was built directly from the exact `origin/develop` generated DDL, populated with two synthetic pre-existing users, and advanced with the additive I-019 source slice. Both users survived with deterministic normalized usernames and initial credential/authorization versions. A normalized catalog comparison of every I-019 column, enum, constraint, and index matched the clean rebuild.

The final I-019 inventory contains 16 identity enum families and 10 new identity tables. All 43 new foreign keys are validated, 67 checks are present, 50 indexes including primary/unique indexes are present, and no duplicate index shape was found. Permission and controlled-event seed replay retained exactly 12 permissions and 33 event codes, with zero active external providers and zero GLOBAL grants.

The focused transaction proved positive and negative lifecycle paths for usernames, credentials, external bindings, TOTP, sessions, authentication attempts, challenges, Site/Site Group/GLOBAL scopes, parent role revocation, and privileged decisions. It also confirmed that no prohibited plaintext/token column or generic JSON authority exists.

The optional legacy local-ordinance validator is not part of the repository CI entry point and remains byte-identical to `origin/develop`. Its existing 9-digit PSGC fixture conflicts with the existing 10-digit canonical PSGC constraint. I-019 does not change that unrelated validator or jurisdiction model.

## I-020 Boundary

I-020 may implement normalized username/password login, Argon2id verification and upgrade, TOTP enrollment/confirmation/verification, privileged Management Platform TOTP challenge, session issue/continue/revoke, secure web and APT device-bound sessions, throttling/lockout, activation/reset, optional OIDC adapter, authentication freshness, and current-session readback. It must use these canonical objects and must not create an application shadow store.

## I-021 Boundary

I-021 may implement governed user lifecycle, role and scope assignment/revocation, privileged request/decision processing, MFA status/reset/removal administration, access review, session administration, and audit history. It must preserve actor independence, explicit scope, no-default-global access, and fail-closed activation.

## Authorization

Controlled UAT and production rollout remain unauthorized. I-019 establishes persistence only; real human authentication, sessions, authorization/scope reevaluation, and governed administration must merge before authentication readiness can be assessed.
