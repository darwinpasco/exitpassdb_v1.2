# I-007 Cutover and Rollback Runbook

## Status

This runbook is a design artifact only. It must not be executed without a separately authorized execution task.

## Cutover Entry Criteria

- source backup verified
- restore rehearsal passed
- canonical target built from current generated DDL
- canonical seeds applied and replayed
- table disposition matrix approved
- blocked mappings resolved or explicitly archived
- identity/service identity migration decision approved
- Site/LGU mappings approved
- payment/fiscal reconciliation passed
- source database frozen or write-disabled by approved operations
- rollback owner and deadline named

## Deterministic Rollback Triggers

Rollback or abort is mandatory for row-count mismatch, primary-key duplicate or loss, foreign-key validation failure, controlled-code mismatch, Site/LGU mapping ambiguity, application startup failure, payment/session reconciliation mismatch, fiscal-reference mismatch, statutory-policy mismatch, migration checksum mismatch, unexpected write to source database, backup verification failure, restore rehearsal failure, connection-string target mismatch, public/payment flag enabled on synthetic sample Sites, or statutory `auto_application_allowed=true` for research-derived seed rows.

## Rollback Decision Owner

The future execution plan must name a single rollback decision owner and alternates. Recommended owner: Engineering lead with DBA and domain-owner concurrence.

## Cutover Sequence Design

1. Confirm source archive and backup.
2. Confirm source connection list.
3. Confirm target validation results.
4. Freeze application writes.
5. Change application connection to canonical target through approved configuration only.
6. Start applications.
7. Run smoke tests.
8. Run post-cutover reconciliation.
9. Leave source database archived and accessible under a protected name.
10. Record final manifest.

Do not drop the source database during cutover.

## Rollback Sequence Design

1. Stop application writes to target.
2. Preserve target database for forensic comparison.
3. Repoint applications to archived source database or restore target from source backup as approved.
4. Validate application startup.
5. Record rollback reason, trigger, timestamp, and owner.

## Target Quarantine

Any failed target must be quarantined, not reused for production-like validation. Quarantine means no application points to it, no migrations continue against it, and owner approval is required before removal.

## Evidence Retention

No statutory evidence bytes are in scope. If future evidence metadata is encountered, preserve only governed metadata and do not copy protected objects without the statutory evidence contract and privacy approval.
