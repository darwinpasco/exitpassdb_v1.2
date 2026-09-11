# Management Platform real catalog boundary

## Continuous validation after Wave 1/2

The Wave 0 changed-path freeze remains historical evidence of the documentation-only phase.
It is superseded in active CI by
`scripts/validation/Invoke-RealCarparkCatalogBoundaryValidation.ps1`. The current validator
regenerates normal SQL from object source, compares it byte-for-byte with the committed
artifact, applies the normal and explicit test-fixture paths to disposable PostgreSQL
databases, and verifies the 39/46 canonical boundary and 43/138 explicit-fixture topology.
It also retains the useful Wave 0 inventory, immutable-history, cleanup-safety, tracked-source,
and PITX consistency checks without prohibiting authorized seed or migration evolution.

The database classifies the approved Professional Parking catalog through
`sites.real_carpark_catalog_site_groups` and `sites.real_carpark_catalog_sites`.
Membership is registered only from the canonical 39-group/46-site seed sourced
from `D:\Docs\Carparks.xlsx` with SHA-256
`63C20CD3ABA3E13D6F9FC022083507C0BC43A2AB9C751E9084DD19C59969359A`.

Central PMS uses membership as the business-data trust boundary, then applies
ACTIVE/effective lifecycle predicates and the authenticated actor's effective
scope grants. Parking integration readiness is deliberately not joined into
identity assignment eligibility.

The legacy v1.2 local-development topology and I-006 metropolitan samples were
moved under `objects/test/` and removed from the normal full-object apply order.
They are available only through the explicit
`objects/test/synthetic-carpark-fixture-apply-order.txt` test fragment.

The DarwinPasco25 39-group reconciliation script is review-only and guarded.
It was prepared for a separately authorized persistent-data change and is not
part of any normal build, migration, or apply order.
