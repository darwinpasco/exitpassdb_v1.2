# I-007 Migration and Archival Strategy

## Cutover Options

| Option | Data preservation | Determinism | Rollback safety | Downtime | Effort | Validation complexity | Auditability | Privacy risk | Operational risk | App compatibility | Development suitability |
|---|---|---|---|---|---|---|---|---|---|---|---|
| A. In-place schema migration | medium | low | low | medium | high | high | medium | high | high | risky | poor |
| B. Side-by-side canonical replacement with transformed data load | high | high | high | medium | high | high | high | medium | medium | good after validation | good |
| C. Archive old database and start clean canonical database | low for active use, high for archive | high | high | low | low | medium | high | low | low | good | acceptable if data not needed |
| D. Hybrid: migrate reference/configuration and selected operational data, archive remainder | high for selected data | medium-high | high | medium | medium-high | high | high | medium | medium | good | recommended |

## Recommendation

Use Option D: side-by-side canonical target with selective transformed migration and full archive retention of `exitpass_v12_dev`.

Reasons:

- The stale database contains meaningful operational data but is missing I-006 canonical objects.
- Some stale tables are absent from the current generated-DDL comparison, so full in-place migration would mix incompatible histories.
- Identity, service identity, fiscal, and statutory evidence-adjacent data require owner decisions.
- A canonical target allows seed replay, drift validation, and rollback without touching the source.
- Archive retention preserves stale data for forensic and development reference without forcing unsafe runtime compatibility.

## Migration Phases

1. Phase 0: approvals and freeze prerequisites. Entry criteria: owner approval, maintenance window, source freeze, privacy/security sign-off. Stop on unapproved identity/fiscal/statutory decisions.
2. Phase 1: verified backup and restore rehearsal. Produce full/schema/data dumps, checksums, restore rehearsal, inventory report. Stop on backup or restore failure.
3. Phase 2: build canonical target database from `build/generated/exitpass-full-object.generated.sql`. Stop on DDL drift or apply failure.
4. Phase 3: load canonical seeds and controlled codes. Validate I-006 counts and seed idempotency. Stop on duplicate seed rows or enabled synthetic Sites.
5. Phase 4: migrate retainable reference/configuration data. Validate code uniqueness, Site/Site Group uniqueness, no secrets copied.
6. Phase 5: migrate operational data by dependency order: Sites/groups, lanes/devices, sessions, tariffs, payments, confirmations, exit authorizations, statutory validations/decisions/reviews, fiscal references, gate consumptions, reconciliation references.
7. Phase 6: apply transformations and mappings. Produce crosswalks and rejected-row reports.
8. Phase 7: integrity and reconciliation validation. Validate FK closure, monetary totals, statutory lifecycle consistency, Site/LGU coverage, generated-DDL drift.
9. Phase 8: application smoke validation. Validate Central PMS, WebPay, Operator Console, Management Platform coverage reads, and APT read paths where available.
10. Phase 9: cutover rehearsal on disposable clones only.
11. Phase 10: guarded cutover. Not authorized by I-007.
12. Phase 11: post-cutover verification.
13. Phase 12: rollback window and archive retention.

## Non-Goals

I-007 authorizes no execution, source DB writes, backup creation or overwrite, credential migration, UAT, or production rollout.
