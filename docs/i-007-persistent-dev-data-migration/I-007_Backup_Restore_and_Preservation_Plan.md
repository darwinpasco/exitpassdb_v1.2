# I-007 Backup, Restore, and Preservation Plan

## Existing Backup Metadata

Existing backup location discovered read-only:

`D:\DatabaseBackups\ExitPass\I-006\20260731`

Files observed:

- `exitpass_v12_dev_pre_i006.full.dump`
- `exitpass_v12_dev_pre_i006.schema.sql`
- `exitpass_v12_dev_pre_i006.inventory.txt`
- `exitpass_v12_dev_pre_i006.metadata.txt`
- `exitpass_v12_dev_pre_i006.dump-list.txt`
- `exitpass_v12_dev_pre_i006.sha256`

Metadata observed:

- timestamp UTC: `2026-07-31T02:43:14.9904663Z`
- container: `exitpass-postgres`
- image: `postgres:16-alpine`
- host port: `5433`
- database: `exitpass_v12_dev`
- backup type: custom full dump and schema-only dump
- credentials printed: `false`

Checksum manifest entries were present. I-007 did not modify or overwrite the backup files.

## Required Future Preservation Package

Before any execution task, create or verify a preservation package outside Git repositories:

- custom-format full database dump
- schema-only dump
- data-only dump for migration extraction when appropriate
- global objects/roles inventory where safe
- extension inventory
- ownership inventory
- table row-count manifest
- table semantic-hash manifest
- object inventory
- constraint and index inventory
- backup metadata with PostgreSQL version and timestamp
- checksum manifest
- restore rehearsal report
- chain-of-custody record

## Backup Security

Store outside source repositories, encrypt at rest where supported, restrict access to DBA/Security-approved operators, and never include credentials in filenames, logs, or reports. Do not commit backup files, dump lists, row extracts, or logs containing sensitive values.

## Restore Rehearsal

A future execution task must restore the full dump to a disposable database and validate object count parity, row count parity, schema version/object inventory, extensions, primary keys, foreign keys, representative semantic hashes, and no application writes during rehearsal.

## Rollback Usage

The backup and archived source database are rollback inputs. Rollback must not depend on generated DDL alone because the stale database contains meaningful operational data and extra objects not represented in the current generated-DDL comparison.

## Retention

No fixed retention duration is established by this design. Retention duration requires legal/privacy approval. Until approved, preserve the archive and backup. Do not shorten retention silently.
