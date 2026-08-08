# ExitPass APT Operational Permissions Canonical DB Result v1.0

## Contract Dependency

I-021B promotes the merged I-021A APT operational RBAC contract into canonical database reference data. It does not change the frozen permission semantics or implement APT runtime behavior.

## Canonical Permissions

| Permission | Canonical ID | Purpose |
| --- | --- | --- |
| `apt.access` | `6bcab461-3595-145e-5807-c8449228cdb6` | Enter and use APT after human authentication, device binding, and Site authorization. |
| `cashier-shifts.operate` | `307d7772-6b84-d76f-0e7e-980fab9a1e5c` | Open, resume, and close the authenticated cashier's own shift. |
| `cash-custody.operate` | `cd0e161b-3010-f559-1486-fbcd65dc9434` | Open, resume, and close the authenticated cashier's own custody session. |
| `terminal-cash.receive` | `93989b4d-6be8-27c8-8053-1cc128cbcc20` | Supply the human-permission dimension immediately before physical cash finality. |

All four records are `ACTIVE`, require audit, and use deterministic canonical identifiers. `apt.access` is not marked sensitive because it grants application entry only; shift, custody, and cash receipt operation permissions are sensitive.

## SITE_OPERATOR Binding

The canonical `SITE_OPERATOR` role (`d187851f-88fd-5974-b595-07367ad1a3b4`) receives one `ACTIVE` binding for each permission:

| Permission | Role-permission ID |
| --- | --- |
| `apt.access` | `fd1580da-c069-5250-e49f-697d767af8a1` |
| `cashier-shifts.operate` | `45b48318-f583-7fd1-d048-d1e753f4057a` |
| `cash-custody.operate` | `06730455-c02f-4f7f-d89a-c822f76ab2f0` |
| `terminal-cash.receive` | `e1504522-9e04-571d-d507-9b9441012ee4` |

Existing `SITE_OPERATOR` permissions remain unchanged. `OPERATIONS_SUPERVISOR` receives no automatic cashier authority; a supervisor who performs cashier duties must separately hold `SITE_OPERATOR`.

## Scope And Deferred Authority

The permissions become effective only through an active user-role assignment and an active, effective Site or Site Group grant. I-021B seeds no user assignments, Site grants, Site Group grants, or GLOBAL grants. Null Site fields do not imply global authority.

No supervisor custody-handover permission is introduced. Handover remains deferred pending DR-08 and DR-09.

`terminal-cash.payable-basis.read` remains a separate read-only Central PMS application contract. It is not added or bound by I-021B and cannot substitute for any of the four operational permissions.

## CASH_RECEIVED Boundary

The role binding supplies only the human permission dimension. CASH_RECEIVED still requires the current human session, active account, current device binding, current Site or Site Group scope, the authenticated cashier's own active shift and custody, `terminal-cash.receive`, payable-basis revalidation, POS and fiscal readiness, and every other terminal-cash safeguard.

## Validation

`scripts/validation/Validate-AptOperationalRbacFoundation.sql` verifies the exact permission and binding identifiers, metadata, preserved SITE_OPERATOR baseline, supervisor non-binding, handover and GLOBAL prohibitions, and payable-basis separation. Its transactional fixture proves the canonical effective-authorization join returns all four permissions for a Site-scoped SITE_OPERATOR and that revoking one role-permission binding immediately removes that permission; all fixture changes roll back.

The repository CI path regenerates both object-source SQL artifacts, validates both source layouts, rebuilds an empty disposable PostgreSQL 16 database, runs the v1.3 Central PMS alignment and I-019 human-authentication validators, then runs the I-021B focused validator.

Validation used the disposable `exitpass-i021b-postgres` PostgreSQL 16 container and `exitpass_i021b_validation` database. The aggregate CI check and each of the three SQL validators passed. Canonical queries returned four required ACTIVE permission rows, four ACTIVE SITE_OPERATOR bindings, zero OPERATIONS_SUPERVISOR bindings for those permissions, zero handover permissions, and zero GLOBAL grants supplying APT operational authority. SITE_OPERATOR retained its four prior bindings and now has eight ACTIVE permissions in total.

Replaying the I-021B seed retained exactly four permission rows and four SITE_OPERATOR bindings. Regenerating the full and v1.3 SQL artifacts produced byte-identical SHA-256 results before and after regeneration. The transactional focused validator resolved all four permissions through user, role assignment, role, role-permission, permission, and Site-scope rows; after revoking the `apt.access` binding inside the transaction, only three remained effective. The transaction then rolled back.

The aggregate validator now checks native `psql` and Docker command exit codes. This prevents a failed SQL validator from being reported as a successful database apply.

## J-008 Follow-up

After I-021B merges, J-008 must use `apt.access` for APT entry, `cashier-shifts.operate` for own-shift operations, `cash-custody.operate` for own-custody operations, and `terminal-cash.receive` immediately before physical cash finality. It must retain `terminal-cash.payable-basis.read` only for payable-basis resolve and revalidate calls.
