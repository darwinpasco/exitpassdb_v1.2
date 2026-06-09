# ExitPass v1.2 Reconciliation Readiness Report

Date: 2026-05-24

Branch: `chore/live-db-reconciliation-readiness-sync`

## Scope

This report documents reconciliation readiness in the live ExitPass v1.2 PostgreSQL schema and the synchronized database repository baseline. It focuses on the validated WebPay PayMongo QRPH/PHP payment-to-exit control chain.

This is a baseline-readiness report only. No settlement, payout, or new reconciliation tables were created.

## Source of Truth

The live database `exitpass_v12_dev` was inspected before repository SQL artifacts were updated. The repository was then synchronized from live schema-only extraction.

## Provider Routing Readiness

Live `payments.payment_provider_routing_policies` has the current QRPH/PHP WebPay routing expectation:

| payment_method_code | currency_code | primary_provider_code | fallback_provider_code | is_enabled | primary_provider_enabled | fallback_provider_enabled |
| --- | --- | --- | --- | --- | --- | --- |
| QRPH | PHP | PAYMONGO | null | true | true | false |

Conclusion:

- QRPH/PHP routes to `PAYMONGO`.
- No fallback provider is enabled for QRPH/PHP.
- No AUB route/configuration/invocation was introduced by this repository sync.

The live `payments.payment_rails` table contains historical/development rail metadata, but the active QRPH/PHP routing policy for this slice is PAYMONGO-only.

## Payment-to-Exit Evidence Tables

The live schema contains durable business-control and operational evidence for the validated chain:

| Concern | Live evidence table |
| --- | --- |
| WebPay ticket/session | `core.parking_sessions` |
| Payment attempt | `core.payment_attempts` |
| PayMongo provider session | `payments.provider_sessions` |
| PayMongo webhook/callback evidence | `payments.provider_callbacks` |
| Provider outcome evidence | `payments.provider_outcomes` |
| ExitPass payment finality | `core.payment_confirmations` |
| Exit authorization issuance | `core.exit_authorizations` |
| Gate consume finality | `gates.gate_authorization_consumptions` |
| Gate operational event evidence | `gates.gate_events` |
| Durable audit evidence | `audit.audit_events` |
| Domain event evidence | `events.domain_events` |
| Outbox evidence | `events.outbox_events` |

Note: there is no live `payments.provider_webhook_events` table. PayMongo webhook evidence is represented by `payments.provider_callbacks` plus `payments.provider_outcomes` where an outcome has been derived.

## Reconciliation Schema Readiness

The live database already contains reconciliation baseline tables:

- `reconciliation.reconciliation_runs`
- `reconciliation.reconciliation_items`
- `reconciliation.reconciliation_exceptions`
- `reconciliation.mops_transaction_records`
- `reconciliation.settlement_comparison_records`

Relevant reconciliation enum values are present:

- `reconciliation_comparison_basis_enum` includes `PROVIDER_TO_CORE`.
- `reconciliation_item_status_enum` includes `MATCHED`, `MISMATCHED`, `EXCEPTION`.
- `reconciliation_match_status_enum` includes `MATCH`, `AMOUNT_MISMATCH`, `MISSING_SOURCE`, `MISSING_TARGET`, `DUPLICATE`, `INCONCLUSIVE`.
- `reconciliation_exception_type_enum` includes `AMOUNT_MISMATCH`, `MISSING_PAYMENT_CONFIRMATION`, `MISSING_PROVIDER_OUTCOME`, `DUPLICATE_RECORD`, `MANUAL_GATE_WITHOUT_PAYMENT`.
- `reconciliation_run_type_enum` includes `PAYMENT_PROVIDER_RECONCILIATION`.

Conclusion:

- The schema is ready for read-only PayMongo provider-to-core reconciliation diagnostics.
- The schema also has durable persistence targets for future reconciliation runs/items if a later slice explicitly implements persisted reconciliation processing.
- No new reconciliation tables are needed for the current baseline.

## Control-Chain Matching Model

The current live schema supports the following baseline reconciliation classifications using existing tables:

| Classification | Schema evidence |
| --- | --- |
| `MATCHED` | `core.payment_attempts.CONFIRMED`, `payments.provider_sessions.PAID`, one `core.payment_confirmations`, provider callback evidence, and linked exit authorization |
| `EXITPASS_CONFIRMED_PROVIDER_MISSING` | ExitPass confirmation exists but no provider paid/session/callback evidence is linked |
| `PROVIDER_PAID_EXITPASS_MISSING` | Provider paid/session/outcome evidence exists but no ExitPass payment confirmation exists |
| `AMOUNT_MISMATCH` | ExitPass confirmed amount differs from provider amount after PayMongo minor-unit normalization |
| `CURRENCY_MISMATCH` | ExitPass currency differs from provider currency |
| `DUPLICATE_PROVIDER_EVENT` | Duplicate `provider_event_ref` evidence under `payments.provider_callbacks` |
| `DUPLICATE_PAYMENT_CONFIRMATION` | More than one confirmation linked to the same WebPay payment chain |
| `STALE_PENDING_ATTEMPT` | Pending attempt is past `expires_at` |
| `CONFIRMED_WITHOUT_EXIT_AUTHORIZATION` | Confirmed payment lacks linked `core.exit_authorizations` row |
| `EXIT_AUTHORIZATION_WITHOUT_CONFIRMATION` | Exit authorization exists without linked confirmation |
| `GATE_CONSUMED_WITHOUT_CONFIRMATION` | Gate consumption exists without linked confirmation |

PayMongo amount note:

- `core.payment_attempts.amount` and `core.payment_confirmations.confirmed_amount` are stored as currency units.
- PayMongo-derived provider session/outcome amounts can be stored in minor units.
- Reconciliation diagnostics should normalize PayMongo provider amounts before comparing to ExitPass amounts.

## Constraints and Index Readiness

The live schema includes the key uniqueness and lookup controls needed by reconciliation:

- `core.payment_attempts`
  - primary key on `payment_attempt_id`
  - unique idempotency key
  - unique tariff snapshot
  - active-by-session partial unique index
  - indexes on status, parking session, payment rail, tariff snapshot, and correlation id
- `payments.provider_sessions`
  - primary key on `provider_session_id`
  - indexes for payment attempt, provider reference, provider status, and correlation fields
- `payments.provider_callbacks`
  - primary key on `provider_callback_id`
  - provider callback replay/evidence indexes
- `payments.provider_outcomes`
  - primary key on `provider_outcome_id`
  - links to payment attempt, provider session, callback, and payment rail
- `core.payment_confirmations`
  - primary key on `payment_confirmation_id`
  - unique provider transaction reference constraint/index
  - one-confirmation-per-attempt constraint
- `core.exit_authorizations`
  - primary key on `exit_authorization_id`
  - one authorization per payment attempt and payment confirmation
  - active-by-session partial unique index
- `gates.gate_authorization_consumptions`
  - primary key on `gate_authorization_consumption_id`
  - consume evidence linked to exit authorization
- `audit.audit_events`, `events.domain_events`, `events.outbox_events`, `gates.gate_events`
  - event/audit persistence tables with correlation and target identifiers

## Sync Outcome

Repository schema-only artifacts were regenerated/aligned from live DB:

- `snapshots/ExitPass_Full_Database_Creation_DDL_v1.2.live_schema.sql`
- `snapshots/ExitPass_Full_Database_Creation_DDL_v1.2.sql`
- `migrations/20260512012142_baseline_v1_2.sql`

No patch script was needed because the live DB already contains the reconciliation-ready schema and the task target was repository synchronization.

## Validation Summary

Validated from live database inspection:

- Reconciliation schema exists.
- Provider-to-core enum values exist.
- Payment-to-exit control-chain tables exist.
- Provider callback/outcome evidence tables exist.
- Durable audit/domain/outbox/gate-event tables exist.
- QRPH/PHP routing policy points to PAYMONGO only with fallback disabled.
- Schema-only DDL contains no runtime WebPay ticket data, no PayMongo secrets, and no AUB text.

## Conclusion

The live ExitPass v1.2 database is reconciliation-ready for the PayMongo WebPay QRPH/PHP baseline. The DB repository has been synchronized to the live schema without mutating business data, without introducing settlement/payout scope, and without adding or changing AUB routing.
