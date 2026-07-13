/*
 * ExitPass v1.2 durable SQL patch.
 *
 * Statutory discount final APPLIED tariff snapshot lifecycle support.
 *
 * References:
 * - docs/operator-console/statutory-discount-applied-tariff-snapshot-lifecycle-design.md
 * - docs/operator-console/statutory-discount-payable-basis-application-design.md
 *
 * System invariants:
 * - The original tariff snapshot amount fields are not mutated by this routine.
 * - The original tariff snapshot may transition from ACTIVE to SUPERSEDED as lifecycle metadata only.
 * - The applied statutory discount payable basis is represented by one new ACTIVE tariff snapshot.
 * - The payable-basis application row is the durable idempotency/audit anchor.
 * - This patch does not create payment attempts, payment confirmations, provider outcomes, exit authorizations,
 *   gate consumptions, coupon applications, settlement truth, reconciliation records, or AUB objects.
 */

CREATE UNIQUE INDEX IF NOT EXISTS ux_tariff_snapshots__statutory_discount_validation_applied
    ON core.tariff_snapshots (statutory_discount_validation_id)
    WHERE statutory_discount_validation_id IS NOT NULL;;

