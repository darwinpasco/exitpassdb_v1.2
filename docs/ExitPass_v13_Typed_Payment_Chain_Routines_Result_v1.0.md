# ExitPass v1.3 Typed Payment-Chain Routines Result v1.0

## Result
PASSED. Typed Central PMS payment-chain routines were promoted from ExitPass app-local patches into the canonical `exitpassdb_v1.2` object-source layout and full generated SQL output.

## Source Inspected
- `D:\SourceCodes\ExitPass\infra\db\patches\ExitPass_Core_CreateOrReusePaymentAttempt_v1.2.sql`
- `D:\SourceCodes\ExitPass\infra\db\patches\ExitPass_Core_FinalizePaymentAttempt_v1.2.sql`
- `D:\SourceCodes\ExitPass\infra\db\patches\ExitPass_Core_RecordPaymentConfirmation_v1.2.sql`
- `D:\SourceCodes\ExitPass\infra\db\patches\ExitPass_Core_IssueExitAuthorization_v1.2.sql`
- `D:\SourceCodes\ExitPass\infra\db\patches\ExitPass_Core_ConsumeExitAuthorization_v1.2.sql`
- Central PMS typed routine gateways for payment attempt creation, payment finality, payment confirmation, exit authorization issuance, and exit authorization consumption.

## Routines Promoted
| Routine | Signature | Object source |
| --- | --- | --- |
| `core.create_or_reuse_payment_attempt` | `(uuid, uuid, text, text, text, uuid, timestamptz)` | `objects/schemas/core/functions/core.create_or_reuse_payment_attempt.sql` |
| `core.finalize_payment_attempt` | `(uuid, text, text, uuid, timestamptz)` | `objects/schemas/core/functions/core.finalize_payment_attempt.sql` |
| `core.record_payment_confirmation` | `(uuid, text, text, text, uuid, timestamptz)` | `objects/schemas/core/functions/core.record_payment_confirmation.sql` |
| `core.issue_exit_authorization` | `(uuid, uuid, uuid, uuid, timestamptz)` | `objects/schemas/core/functions/core.issue_exit_authorization.sql` |
| `core.consume_exit_authorization` | `(uuid, uuid, uuid, timestamptz)` | `objects/schemas/core/functions/core.consume_exit_authorization.sql` |

## Placeholder Compatibility Decision
The core zero-argument placeholders were replaced by the typed routines because the canonical Central PMS output must satisfy the current Central PMS typed gateway calls. The existing `gates.consume_exit_authorization()` placeholder remains in place as a backward-compatible baseline object because current Central PMS source calls `core.consume_exit_authorization(...)`, and no source requirement was found to remove the `gates` placeholder.

## Generated Output and Migration
- Updated `objects/exitpass-full-object-apply-order.txt` so typed core routines are applied after dependent core tables/patch-aligned objects.
- Refreshed `build/generated/exitpass-full-object.generated.sql`.
- Added additive migration `migrations/20260713183000_v13_typed_payment_chain_routines.sql` for deployment history.
- Updated `scripts/validation/Validate-V13CentralPmsAlignment.sql` to assert the typed routine signatures.

## Validation
| Command | Result |
| --- | --- |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\build\Build-ExitPassFullObjectSql.ps1` | PASSED |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\build\Build-V13CentralPmsObjectSql.ps1` | PASSED |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\validation\Validate-ExitPassFullObjectSourceLayout.ps1` | PASSED |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\validation\Validate-V13CentralPmsObjectSourceLayout.ps1` | PASSED |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\validation\Invoke-DbObjectSourceCoverageReport.ps1 -SkipDbApply` | PASSED |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\validation\Invoke-DbObjectSourceCoverageReport.ps1 -RunDbApply -DockerContainer exitpass-postgres -DbName exitpass_object_source_coverage_validation` | PASSED; clean disposable apply and `Validate-V13CentralPmsAlignment.sql` passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\validation\Invoke-DbObjectSourceCoverageReport.ps1 -RunDbApply -DockerContainer exitpass-postgres -DbName centralpms_aligned_exitpassdb_validation_local` | PASSED; Central PMS validation DB rebuilt from canonical generated SQL |

## Central PMS Cross-Repo Validation
Using `EXITPASS_TEST_MAIN_DB=Host=localhost;Port=5433;Database=centralpms_aligned_exitpassdb_validation_local;Username=exitpass;Password=change_me;Include Error Detail=true`:

| Command | Result |
| --- | --- |
| `dotnet test src\Services\CentralPms\tests\ExitPass.CentralPms.IntegrationTests\ExitPass.CentralPms.IntegrationTests.csproj --no-restore --filter "FullyQualifiedName~CreateOrReusePaymentAttemptDbRoutineGatewayTests|FullyQualifiedName~CreateOrReusePaymentAttemptDbRoutineGatewayConcurrencyTests|FullyQualifiedName~FinalizePaymentAttemptIntegrationTests|FullyQualifiedName~RecordPaymentConfirmationIntegrationTests|FullyQualifiedName~IssueExitAuthorizationIntegrationTests|FullyQualifiedName~ConsumeExitAuthorizationIntegrationTests"` | PASSED |
| `dotnet test src\Services\CentralPms\tests\ExitPass.CentralPms.IntegrationTests\ExitPass.CentralPms.IntegrationTests.csproj --no-restore --filter "FullyQualifiedName~FiscalIssuanceReferenceRepositoryTests"` | PASSED, 14 tests |
| `dotnet build src\Services\CentralPms\src\ExitPass.CentralPms.Api\ExitPass.CentralPms.Api.csproj --no-restore` | PASSED |

## Remaining Gaps
- Historical app-local patch files remain in the ExitPass app repo for now; canonical validation no longer needs the promoted typed payment-chain routine patches.
- `schema/07_functions.generated.sql` still represents the older generated baseline convention. The object-source full generated SQL is the validated canonical output for this alignment path.

## Files Changed
- `build/generated/exitpass-full-object.generated.sql`
- `objects/exitpass-full-object-apply-order.txt`
- `objects/schemas/core/functions/core.create_or_reuse_payment_attempt.sql`
- `objects/schemas/core/functions/core.finalize_payment_attempt.sql`
- `objects/schemas/core/functions/core.record_payment_confirmation.sql`
- `objects/schemas/core/functions/core.issue_exit_authorization.sql`
- `objects/schemas/core/functions/core.consume_exit_authorization.sql`
- `migrations/20260713183000_v13_typed_payment_chain_routines.sql`
- `scripts/validation/Validate-V13CentralPmsAlignment.sql`
- `docs/ExitPass_v13_Typed_Payment_Chain_Routines_Result_v1.0.md`
