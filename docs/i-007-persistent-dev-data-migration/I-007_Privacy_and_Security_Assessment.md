# I-007 Privacy and Security Assessment

## Data Classes

| Class | Examples | Migration posture |
|---|---|---|
| Public/reference | canonical regions, provinces, LGUs, controlled public names | rebuild from source-controlled seed |
| Internal operational | Sites, Site Groups, lanes, gate devices, sessions | migrate only with deterministic mapping or archive |
| Financial | payment attempts, confirmations, tariffs, fiscal references | migrate only after monetary and fiscal reconciliation |
| Authentication/authorization | users, roles, service identities, permissions | rebuild or migrate only with Security approval |
| Personal data | user/account/session identifiers, possible plate/ticket data | mask in reports; migrate only when required |
| Sensitive personal/statutory | statutory discount validations, decisions, reviews, evidence-adjacent refs | archive or migrate only under statutory privacy contracts |
| Secrets/credentials | credential references, provider config | never print or commit; rotate/recreate preferred |

## Prohibitions

Documentation and future migration artifacts must not include raw credentials, connection strings with secrets, private keys, bearer tokens, raw statutory ID values, raw customer names, raw plate numbers, raw payment provider payloads, evidence images or bytes, Base64 evidence, object-storage locators, or protected reviewer notes.

## Masking and Reporting

Use counts, date ranges, status classifications, keyed hashes, and owner-reviewed samples only. Any row-level sample must be synthetic or redacted.

## Archive Access

Archived database access must be restricted to approved maintainers. Human access should be logged. Archive access does not imply permission to browse personal or statutory data.

## Retention and Deletion

I-007 does not set legal retention periods. Retention requires legal/privacy approval. Until approved, preserve the source archive and backup. Do not delete or shorten retention silently.

## Security Findings

- The persistent database contains service identities and user data; automatic identity migration is blocked.
- Integration credential reference tables are empty, but vendor/service identity adjacency means migration reports must avoid connection details.
- Statutory review and validation rows are sensitive-personal adjacent; protected evidence bytes are not present in the assessed row-count inventory, but future evidence contracts still apply.
- Event and audit rows may include personal or operational context; archive-first posture is required.

## Future Controls

Use a read-only source role if available, disposable target databases for rehearsal, encrypted extraction artifacts outside Git, security/privacy scans on all committed docs and scripts, and Security approval for any user/service identity migration.
