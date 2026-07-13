/*
 * ExitPass v1.2 durable SQL patch.
 *
 * Operator Console production policy import review queue persistence.
 *
 * System invariants:
 * - This patch creates only review queue persistence objects.
 * - Approval means APPROVED_FOR_DB_REPO_ALIGNMENT only.
 * - This patch does not import, seed, activate, or approve production policy registry rows.
 * - This patch does not create production policy import execution jobs.
 */

CREATE SCHEMA IF NOT EXISTS operator_console;;

