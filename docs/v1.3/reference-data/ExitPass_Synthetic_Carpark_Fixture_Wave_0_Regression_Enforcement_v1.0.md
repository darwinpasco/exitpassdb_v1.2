# ExitPass Synthetic Carpark Fixture Wave 0 Regression Enforcement v1.0

## Purpose

Wave 0 adds reporting and regression enforcement for the approved synthetic carpark fixture reconciliation package. It does not migrate, retire, delete, rename, disable, reassign, or repurpose any fixture or historical reference.

The approved baseline is the reconciliation package merged by commit `e70dc7164ee8208ac6ff3f56ef06d646116775f5`. Its CSV inventories remain the source for fixture identities, classifications, dispositions, dependency boundaries, tracked-source occurrences, and realistic-target decisions.

## Enforcement

`scripts/validation/Invoke-SyntheticCarparkFixtureWave0Validation.ps1` performs these checks:

1. validates the reconciliation package and all negative cases;
2. rejects changes to seeds, migrations, generated database SQL, UAT fixtures, the approved inventory baseline, or HikCentral paths;
3. compares current repository fixture-token occurrences with the classified occurrence inventory;
4. regenerates canonical SQL and requires byte-stable generated output;
5. creates an isolated PostgreSQL 16 container, database, volume, and network with no host port;
6. applies the canonical database build;
7. runs the realistic catalog validator, dependency analyzer, and reconciliation SQL validator;
8. compares live fixture identities, parent relationships, names, types, lifecycle values, capability flags, assignments, effective dates, and jurisdiction identities with the approved inventories;
9. verifies every proposed realistic target exists without approving a mapping;
10. compares declared foreign keys and observed reference boundaries with the approved dependency inventory;
11. writes a deterministic normalized report under `build/reports`;
12. removes only invocation-owned disposable resources in guaranteed cleanup.

Any mismatch produces a non-zero exit code and identifies the offending path, identity, mapping, or dependency boundary. The report contains no credentials, connection strings, business payloads, or task-specific resource identifiers.

## Local invocation

Run from the repository root in Windows PowerShell 5.1 or PowerShell 7:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\validation\Invoke-SyntheticCarparkFixtureWave0Validation.ps1 -BaselineRef origin/develop
```

Prerequisites are Git and Docker with the `postgres:16-alpine` image available. The runner does not use a host database and does not publish a PostgreSQL port.

## CI integration

The existing `.github/workflows/db-object-source-validation.yml` workflow invokes the runner in its PostgreSQL validation job after the standard object-source check. Checkout uses full history so the runner can enforce the diff against `origin/develop`. The existing report artifact upload includes the Wave 0 report.

## Output interpretation

A successful report starts with `WAVE0_SYNTHETIC_CARPARK_FIXTURE_REPORT_V1`, records `STATUS=PASS`, and gives fixture, mapping, dependency, foreign-key, observed-reference, and tracked-occurrence counts. It also records a SHA-256 of normalized analyzer output and `PITX_ACTIVATION=CONFIRMED_UNCHANGED`.

On failure, the report records `STATUS=FAIL` and a sanitized diagnostic. Cleanup failure is also a validation failure; the runner never removes a resource whose invocation label and immutable identity cannot be revalidated.

## Identity and history protection

The canonical Test Site retains its explicit governance disposition. Parking Lot Index Code `1` is not identity evidence and cannot establish equivalence with PITX Level 3. No synthetic-to-realistic mapping is approved by Wave 0.

Historical payment, fiscal, session, gate, audit, event, reconciliation, and transaction references remain immutable. Wave 0 rejects rewritable-history classifications, direct deletion approval, primary-key repurposing, and changes to fixture seed or migration sources.

## PITX Level 3

PITX Level 3 is activated. The applicable Paranaque Senior Citizen free-parking privilege is confirmed and operational. The unavailable LGU ordinance copy is a documentation gap only.

This validation task does not configure, activate, start, contact, or modify any HikCentral target. That task boundary leaves the confirmed PITX Level 3 operational posture unchanged.

## Non-goals

Wave 0 does not change fixture rows, statuses, assignments, public lookup, payment, fiscal issuance, exit authorization, statutory-benefit coverage, runtime configuration, or integration configuration. It does not access an existing local, shared, UAT, or production database.

## Next authorized wave

After Wave 0 is reviewed and merged, product and fixture owners may review whether Wave 1 test-scope isolation is necessary. Wave 1 requires separate authorization and must not begin from this change.
