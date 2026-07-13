# ExitPass DB Branch Protection Required Checks v1.0

## Result
Branch protection guidance documented for `exitpassdb_v1.2`. No GitHub repository settings were changed by this document-only slice.

## Purpose
Protect the canonical database repository so object-source files, committed generated SQL, migrations, and disposable database apply validation cannot drift before merge.

## Protected branches
Immediate target:

| Branch | Required now | Notes |
| --- | --- | --- |
| `develop` | Yes | Current default branch and primary integration branch. |
| `main` | Recommended if present | Protect once the repository uses `main` for stable releases. |
| `release/*` | Recommended later | Apply when release branches are introduced. |

## Required status checks
Workflow name: `DB Object Source Validation`

| Required check | GitHub workflow/job display | Purpose |
| --- | --- | --- |
| `db-object-source-validation` | `DB Object Source Validation / db-object-source-validation` | Fast non-DB check. Runs generators, layout validators, coverage/equivalence reporting with `-SkipDbApply`, `git diff --check`, and uploads `build/reports/*`. |
| `db-object-source-postgres-apply` | `DB Object Source Validation / db-object-source-postgres-apply` | Full database proof. Starts `postgres:16`, applies `build/generated/exitpass-full-object.generated.sql` to a clean disposable database, runs `Validate-V13CentralPmsAlignment.sql`, runs `git diff --check`, and uploads `build/reports/*`. |

Both checks should be required before merging into `develop`.

## Recommended GitHub branch protection settings
Recommended settings for `develop`:

- Require a pull request before merging.
- Require at least 1 approval.
- Dismiss stale approvals when new commits are pushed.
- Require review from code owners if `CODEOWNERS` is later added.
- Require status checks to pass before merging.
- Require branches to be up to date before merging.
- Require conversation resolution before merging.
- Require the two DB object-source checks listed above.
- Block force pushes.
- Block deletions.
- Restrict who can push to protected branches if the repository owner wants tighter release control.
- Do not allow bypass for normal contributors.
- Allow admin bypass only for documented emergency/break-glass cases if Darwin chooses to keep admin bypass.

These are recommended GitHub settings. Configure them in GitHub repository settings; do not encode production branch-protection authority in database scripts.

## Required review settings
Reviewers should check:

- Object files under `objects/**` match the intended database change.
- Generated SQL under `build/generated/**` is regenerated when object-source output changes.
- Migrations remain deployment/change-history artifacts and are not deleted.
- `schema/schema.sql` and `schema/*.generated.sql` are not changed unless explicitly part of a baseline maintenance task.
- No production secrets, passwords, tokens, private keys, certificates, raw statutory evidence, or customer data are committed.

## Required generated artifact policy
- Object files under `objects/**` are the source decomposition.
- Generated SQL under `build/generated/**` is committed build output.
- Migrations remain deployment/change-history artifacts.
- PRs changing object files must include regenerated generated SQL when generation output changes.
- CI fails if generated SQL changes after regeneration during validation.
- `build/reports/**` are generated run artifacts and must not be committed.

## Required database validation policy
PRs changing any of these paths should pass both required checks:

- `objects/**`
- `build/generated/**`
- `migrations/**`
- `schema/**`
- `reference-data/**`
- `scripts/build/**`
- `scripts/validation/**`
- `.github/workflows/db-object-source-validation.yml`

The PostgreSQL full apply check must validate:

- clean disposable database creation
- application of `build/generated/exitpass-full-object.generated.sql`
- successful execution of `scripts/validation/Validate-V13CentralPmsAlignment.sql`

Manual browser testing is not required for database source-control changes. Central PMS application tests may be requested separately when DB behavior changes affect runtime code.

## Merge rules
- Merge only through pull requests into protected branches.
- Do not merge with stale generated SQL.
- Do not merge if either required check is failing.
- Do not squash away migration/history context in a way that makes DB deployment review harder.
- Keep database behavior changes separate from app and POS Server repository changes unless an approved cross-repo release plan requires otherwise.

## Emergency/break-glass rule
Break-glass bypass should be rare and documented in the pull request or release note. At minimum record:

- reason for bypass
- impacted branch
- skipped required check, if any
- manual validation performed
- follow-up issue or corrective PR
- approver

Normal contributors should not have bypass rights. Admin bypass is a repository-owner decision, not a database script behavior.

## Local pre-push commands
Fast local check:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\validation\Invoke-DbObjectSourceCiCheck.ps1 -SkipDbApply
```

Local Docker-compatible DB apply check:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\validation\Invoke-DbObjectSourceCoverageReport.ps1 -RunDbApply
```

Direct PostgreSQL / non-Docker apply check:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\validation\Invoke-DbObjectSourceCoverageReport.ps1 -RunDbApply -DbHost localhost -DbPort 5432 -DbUser exitpass -DbPassword change_me -AdminDatabase postgres -ValidationDatabase exitpass_object_source_coverage_validation
```

Repository hygiene checks:

```powershell
git diff --check
git status --short --branch --untracked-files=all
```

## CI troubleshooting
| Symptom | Likely cause | Fix |
| --- | --- | --- |
| Generated SQL freshness failure | `objects/**` changed but `build/generated/**` was not regenerated. | Run the CI wrapper locally and commit regenerated SQL. |
| Missing apply-order entry | New object file was added but not listed in the relevant apply-order file. | Add the object file to the correct deterministic apply-order file. |
| Duplicate apply-order entry | Same object file appears more than once. | Remove the duplicate and rerun validation. |
| PostgreSQL service not ready | Service container health check or startup delay. | Re-run job; if persistent, inspect service logs and readiness step. |
| `Validate-V13CentralPmsAlignment.sql` failure | Generated SQL applied but required v1.3 object/constraint/reference-data expectation is missing. | Compare the failing validation assertion against object files and generated SQL. |
| Report artifacts missing | Coverage script failed before writing `build/reports/*` or artifact path changed. | Inspect the failing step logs and restore report output paths. |
| `git diff --check` line-ending warning | Git reports LF/CRLF normalization. | Warning only is acceptable; whitespace errors or blank EOF lines must be fixed. |

## Files changed
- `docs/ExitPass_DB_Branch_Protection_Required_Checks_v1.0.md`

## Validation
Run for this doc-only slice:

```powershell
git diff --check
git status --short --branch --untracked-files=all
```
