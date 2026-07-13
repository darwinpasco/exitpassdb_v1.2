/*
 * ExitPass v1.2 durable SQL patch.
 *
 * Operator Console schema migration draft.
 *
 * References:
 * - docs/operator-console/operator-console-schema-extension-design.md
 * - docs/operator-console/proposals/operator-console-ddl-proposal.sql
 * - docs/operator-console/proposals/operator-console-ddl-proposal-notes.md
 *
 * This patch creates Operator Console access, HR/Timekeeping shift import,
 * browser/device binding, takeover, access evaluation evidence, and statutory
 * entitlement fingerprint storage.
 *
 * Non-payment boundary:
 * The objects below must not create, mutate, route, configure, or invoke payment
 * attempts, payment confirmations, payment provider outcomes, exit
 * authorizations, gate authorization consumptions, coupon applications,
 * settlement truth records, provider routing, or payment finality.
 */

CREATE SCHEMA IF NOT EXISTS operator_console;;

