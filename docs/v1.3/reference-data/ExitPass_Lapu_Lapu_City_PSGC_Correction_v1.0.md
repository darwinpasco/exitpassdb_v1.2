# City of Lapu-Lapu PSGC canonical reference correction

## Purpose and authority

This change corrects the current Philippine Standard Geographic Code (PSGC) attached to the existing canonical City of Lapu-Lapu jurisdiction. The Philippine Statistics Authority (PSA) sources were accessed on 2026-08-12:

- City record: <https://psa.gov.ph/classification/psgc/barangays/0731100000>
- Highly urbanized cities: <https://psa.gov.ph/classification/psgc/hucs>
- Region VII cities: <https://psa.gov.ph/classification/psgc/cities/0700000000>

The PSA pages identify the publication as **Philippine Standard Geographic Code as of 30 June 2026**. They distinguish:

- current 10-digit PSGC: `0731100000`;
- correspondence code: `072226000`;
- official name: `City of Lapu-Lapu`;
- classification: highly urbanized city;
- region: Region VII (Central Visayas).

The correspondence code is stored only in the existing `correspondence_code` column. It is not substituted into the 10-digit `psgc_code` column.

## Before and after

| Field | Before | Corrected |
|---|---|---|
| `jurisdiction_id` | `23104fc9-a144-381c-4347-ccb2aa1a2998` | unchanged |
| `jurisdiction_code` | `PH-PSGC-0730110000` | `PH-PSGC-0731100000` |
| `psgc_code` | `0730110000` | `0731100000` |
| `correspondence_code` | null | `072226000` |
| `display_name` | `City of Lapu-Lapu` | unchanged |
| type/classification | `CITY` / `HIGHLY_URBANIZED` | unchanged |
| region | `REGION_VII` | unchanged |
| province | null | unchanged |

No official evidence was found that supports `0730110000` as a current or historical PSGC for City of Lapu-Lapu. Repository history shows it entered with the initial I-006 jurisdiction seed, so this change treats it as a canonical data-entry error rather than an approved historical alias.

## Identity-preservation decision

The jurisdiction UUID is deterministically allocated from the stable seed input `exitpass:i006:lgu:LAPU_LAPU`, not from the PSGC. Database comments describe `jurisdiction_id` as the stable canonical identity. The existing row unambiguously represents City of Lapu-Lapu, and no separate canonical row uses the corrected PSGC or jurisdiction code.

The existing UUID is therefore preserved. This avoids replacing the real-world entity, preserves all foreign keys, and keeps historical transaction and policy references attached to the same city.

Two related seed allocators previously included the external code. Their already-issued identifiers are preserved explicitly:

- Metro Cebu membership: `fb97785d-eed4-39b4-eb89-52bb20265fdd`;
- Senior Citizen policy registry: `a216d952-6bf6-e518-c91c-08cbcb608e1c`;
- PWD policy registry: `42c440a6-a93c-7ac5-e6e6-3096e41808fc`;
- Senior Citizen policy scope: `c336d25f-e95d-bb35-6c79-42b7f4b68e19`;
- PWD policy scope: `11e203f6-6a63-0174-086d-d2d6ce0b7e8a`.

These literals preserve issued identities; they do not introduce new identities.

## Relationships and dependents

City of Lapu-Lapu remains an independent highly urbanized city in Region VII. Under the canonical model, its `philippine_province_id` and province display value remain null. Its active Expanded Metro Cebu membership remains valid and keeps the same membership UUID.

Direct jurisdiction foreign-key paths exist from:

- Site rows and site-jurisdiction assignments;
- metropolitan-area memberships;
- statutory policy registry rows and LGU scopes;
- statutory policy versions;
- statutory decision policy-authority snapshots;
- jurisdiction replacement relationships.

The baseline reference-data build contains two Site rows, two current Site assignments, two policy registry rows, two policy-scope rows, and one metropolitan-area membership referencing the jurisdiction UUID. Those references remain unchanged.

Current policy registry codes and current jurisdiction-code fields are corrected while preserving registry UUIDs. Historical policy-version and decision-authority records may contain an external-code snapshot. The migration intentionally does not rewrite those snapshots because their UUID reference continues to identify the same city and historical snapshots must not be restated silently.

## Implementation mechanism

The repository is hybrid for this reference data:

1. Object-per-file declarative seeds define the canonical clean-build state.
2. The generated full-object artifact is rebuilt from the approved apply order.
3. A forward migration corrects existing seeded databases in place.

The migration fails closed on identity, topology, corrected-code, or policy-ownership conflicts. It is idempotent and is a no-op when the jurisdiction reference seed has not yet been applied. Deployment order for an existing database is the forward migration followed by the normal canonical reference-data application. Clean builds obtain the corrected state directly from the declarative seeds.

The focused validator and the v1.3 alignment validator require:

- exactly one active City of Lapu-Lapu canonical row;
- the unchanged jurisdiction UUID;
- PSGC `0731100000` and jurisdiction code `PH-PSGC-0731100000`;
- correspondence code `072226000` in its separate field;
- Region VII, highly urbanized city, and null-province semantics;
- no current canonical use of `0730110000`;
- unique current PSGC and jurisdiction codes;
- preserved metropolitan and policy identities.

## Rollback posture

Before deployment, rollback is source-control reversion. After deployment, reversing the reference correction requires a separately reviewed forward operation; restoring the unsupported external code is not an ordinary operational rollback. Any reversal must preserve jurisdiction and dependent foreign keys and must not rewrite historical transaction identities or snapshots.

## Residual risks and approvals

- Other Philippine jurisdiction records were not refreshed or revalidated in this focused correction.
- Historical snapshots containing the prior external code remain historical evidence and require a broader, approved external-code versioning design if aliases or code history become necessary.
- Database deployment requires normal database-owner review and validation of both the clean-build and supported upgrade paths.
- The blocked realistic carpark catalog must re-read the merged canonical source before assigning its Mactan New Town Sites.

## Scope boundaries

This correction does not create a new jurisdiction identity. It does not create a Site Group or Site, seed the realistic carpark catalog, activate HikCentral, publish a statutory-discount policy, or rewrite historical transaction identities. It does not modify the ExitPass application repository. It does not access or modify `D:\Docs\Carparks.xlsx`. The blocked realistic-carpark manifest branch and worktree remain unchanged.
