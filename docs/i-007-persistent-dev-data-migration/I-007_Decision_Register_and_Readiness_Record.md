# I-007 Decision Register and Readiness Record

## Current Decision Summary

| Decision | Status | Rationale | Owner |
|---|---|---|---|
| Use `D:\SourceCodes\exitpassdb_v1.2` as canonical repo | Accepted | Current canonical database repository | Database owner |
| Do not use retired `D:\SourceCodes\ExitPass_DBv1.2` | Accepted | Retired path explicitly prohibited | Database owner |
| Treat I-007 as design-only | Accepted | No execution authorized | Engineering lead |
| Preserve `exitpass_v12_dev` untouched | Accepted | Contains meaningful operational development data | DBA |
| Prefer side-by-side hybrid migration | Recommended | Safest balance of preservation and canonical alignment | Engineering lead/DBA |
| Do not migrate identity/service identities automatically | Blocked | Security and credential lifecycle decision required | Security |
| Do not replay stale outbox events | Accepted | Replay could duplicate side effects | Platform |
| Do not downgrade Paranaque Senior Citizen coverage | Accepted | Existing product authority says verified active operational with source text gap | Product/Policy |
| No fixed backup retention duration | Blocked | Legal/privacy approval required | Legal/Privacy |
| No migration execution | Accepted | Out of scope | Engineering lead |

## Human Decisions Required

1. Which existing Sites and Site Groups are meaningful configuration versus generated development data.
2. Whether to migrate any historical parking sessions, payments, confirmations, tariffs, and exit authorizations into the canonical target or archive only.
3. Whether fiscal references must remain queryable in the target or only the archive.
4. Whether stale statutory validations, decisions, reviews, and payable-basis applications should migrate or be archive-only.
5. Whether existing users should be recreated, anonymized, migrated, or archived only.
6. Whether service identities should be rotated/reissued instead of migrated.
7. Whether vendor systems and device assignments are retained configuration or generated test data.
8. Legal/privacy retention period for the archived database and backups.
9. Whether an archive query/reporting tool is required before cutover.
10. Approved rollback window and rollback decision owner.

## Readiness Gates Before Execution

- retention matrix approved
- blocked mappings resolved
- backup verified and restore rehearsed
- canonical target built and validated
- migration scripts reviewed and dry-run clean
- privacy/security sign-off complete
- application smoke plan ready
- rollback plan approved

## I-007 Readiness Verdict

I-007 provides the assessment and design package needed to plan a future execution task. It does not authorize execution. The migration remains blocked pending human decisions and a separately approved implementation/runbook execution task.
