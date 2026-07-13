# ExitPass DB Object Source Layout Result v1.0

## Result
PASSED.

This branch now introduces an object-per-file source-control layout for all ExitPass-owned schemas, while preserving the existing v1.2 generated schema baseline and migration history. Object files are the preferred source decomposition for future database changes; generated SQL remains build output; migrations remain deployment/change-history artifacts.

## Object-per-file principle
One database object is represented by one source-controlled file where practical:

- Schemas: `objects/schemas/<schema>/schema/<schema>.schema.sql`
- Types/enums: `objects/schemas/<schema>/types/<schema>.<type>.sql`
- Tables: `objects/schemas/<schema>/tables/<schema>.<table>.sql`
- Constraints: `objects/schemas/<schema>/constraints/<schema>.<constraint>.sql`
- Indexes: `objects/schemas/<schema>/indexes/<schema>.<index>.sql`
- Functions: `objects/schemas/<schema>/functions/<schema>.<function>.sql`
- Triggers: `objects/schemas/<schema>/triggers/<schema>.<trigger>.sql`
- Views: `objects/schemas/<schema>/views/<schema>.<view>.sql`
- Comments: `objects/schemas/<schema>/comments/<schema>.<object>.comments.sql`
- Reference data: `objects/reference-data/*.sql`
- Local/UAT support: `objects/uat/*.sql`

## Folders added
The layout now covers these ExitPass-owned schemas:

- `audit`
- `config`
- `core`
- `coupons`
- `discounts`
- `events`
- `gates`
- `identity`
- `integration`
- `merchants`
- `operations`
- `operator_console`
- `payments`
- `reconciliation`
- `sessions`
- `sites`

The layout also includes:

- `objects/extensions`
- `objects/reference-data`
- `objects/uat`
- `build/generated`
- `scripts/build`
- `scripts/validation`

## Schemas converted
All ExitPass-owned schemas listed above are represented under `objects/schemas`.

Excluded schemas:

- `public`, except for the required `pgcrypto` extension object under `objects/extensions`
- `pagila`
- PostgreSQL/system/internal schemas

## Objects converted
Converted from the canonical database source and current v1.3 alignment work:

- Full v1.2 canonical schema source from `schema/schema.sql`
- Existing v1.2 reference data from `reference-data/ExitPass_Reference_Data_v1.2.sql`
- v1.3 Central PMS alignment objects from `migrations/20260713090000_v13_central_pms_alignment.sql`
- v1.3 Management Platform role/permission reference-data object
- Local/UAT seed and verification scripts mirrored under `objects/uat` with a separate UAT apply-order

Object counts from validation:

| Type | Count |
| --- | ---: |
| Schema files | 17 |
| Type files | 157 |
| Table files | 99 |
| Constraint files | 44 |
| Index files | 438 |
| Function files | 14 |
| Trigger files | 2 |
| View files | 0 |
| Comment files | 1632 |
| Reference-data files | 3 |
| UAT files | 4 |
| Extension files | 1 |
| Total SQL object files | 2411 |
| Full apply-order entries | 2407 |
| v1.3 apply-order entries | 197 |

## Generator scripts
- `scripts/build/Build-ExitPassFullObjectSql.ps1`
- `scripts/build/Build-V13CentralPmsObjectSql.ps1`

Generated outputs:

- `build/generated/exitpass-full-object.generated.sql`
- `build/generated/v13-central-pms-alignment.generated.sql`

## Apply-order files
- `objects/exitpass-full-object-apply-order.txt`
- `objects/v13-central-pms-object-apply-order.txt`
- `objects/v13-central-pms-uat-object-apply-order.txt`

## Generated output policy
Generated SQL artifacts are committed because this repository already commits generated SQL artifacts under `schema/`. The generated files are reviewable build output only. Future database edits should update `objects/**` first, then regenerate the appropriate generated artifact and migration/rebuild output.

## Validation performed
Commands run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\build\Build-V13CentralPmsObjectSql.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\validation\Validate-V13CentralPmsObjectSourceLayout.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\build\Build-ExitPassFullObjectSql.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\validation\Validate-ExitPassFullObjectSourceLayout.ps1

docker exec exitpass-postgres psql -U exitpass -d postgres -c "DROP DATABASE IF EXISTS exitpass_full_object_layout_validation WITH (FORCE);"
docker exec exitpass-postgres psql -U exitpass -d postgres -c "CREATE DATABASE exitpass_full_object_layout_validation;"
docker cp D:\SourceCodes\exitpassdb_v1.2\build\generated\exitpass-full-object.generated.sql exitpass-postgres:/tmp/exitpass-full-object.generated.sql
docker exec exitpass-postgres psql -v ON_ERROR_STOP=1 -U exitpass -d exitpass_full_object_layout_validation -f /tmp/exitpass-full-object.generated.sql
docker cp D:\SourceCodes\exitpassdb_v1.2\scripts\validation\Validate-V13CentralPmsAlignment.sql exitpass-postgres:/tmp/Validate-V13CentralPmsAlignment.sql
docker exec exitpass-postgres psql -v ON_ERROR_STOP=1 -U exitpass -d exitpass_full_object_layout_validation -f /tmp/Validate-V13CentralPmsAlignment.sql
```

Results:

- v1.3 Central PMS object generator passed.
- v1.3 Central PMS object layout validation passed for 197 object files.
- Full object generator passed for 2407 apply-order entries.
- Full object layout validation passed.
- Full generated SQL applied cleanly to an empty disposable PostgreSQL database.
- Existing `Validate-V13CentralPmsAlignment.sql` passed against the full generated database state.

## Intentionally not converted
- Existing `schema/*.generated.sql` files were not deleted or replaced.
- Existing `schema/schema.sql` was not deleted or replaced.
- Existing migrations were not deleted or rewritten.
- `public`, `pagila`, and PostgreSQL/system/internal schemas were not converted into ExitPass-owned object source folders.
- No ExitPass application repo, Operator Console UI, or POS Server source was changed.
- No schema behavior, canonical object names, business logic, POS Server `pos.*` objects, mutation APIs, or UI were introduced.

## Next recommended slice
Use the full object layout as the source decomposition for the next database change. The next high-value slice is to add a formal source-to-generated equivalence report that compares object files, `schema/schema.sql`, and migrations by object identity, then decide whether future migration generation should be driven directly from `objects/exitpass-full-object-apply-order.txt`.
