# ExitPass Realistic Carpark Catalog Canonical Seed v1.0

## Purpose

This implementation promotes the completed realistic carpark manifest into canonical ExitPass database reference data. The authority is ExitPass merge commit `ee7bc7545054f8277301a8bf66cdf4ee8628afb7` (PR #632, source commit `f844c29fd62cd8100b9746774d596c54771071ff`), which builds on the original approved manifest at `83f5b9b76d7174f28280b93f77f811f4d186d7b1`.

The catalog is identity and jurisdiction reference data only. It does not activate operations, migrate synthetic fixtures, publish statutory-discount policies, configure HikCentral, or rewrite historical transaction identities.

## Frozen source artifacts

| Artifact | SHA-256 |
|---|---|
| `ExitPass_Realistic_Carpark_Catalog_and_Jurisdiction_Seed_Manifest_v1.0.md` | `CB819D80890F975236CDB1A85990786B717D4CC4447C2D6D0F84E6B0FCB1AE2C` |
| `ExitPass_Realistic_Carpark_Fixture_Identity_Reconciliation_v1.0.md` | `536F528FCBBA2A76C6E501505B78C6DC81A3BE703F73AF3D8D9AB55634FAE769` |
| `ExitPass_Realistic_Carpark_Site_Groups_v1.0.csv` | `8645EBC837311D9E9A393D593F158E7C846275AB5EE7FDF1F50F03E5624AE168` |
| `ExitPass_Realistic_Carpark_Sites_v1.0.csv` | `682C415D9E3C64670542F2936D44ADAB5433A7C4D68BF6FB9E07E148DED2FCFD` |
| `ExitPass_Realistic_Carpark_Site_Jurisdiction_Assignments_v1.0.csv` | `B2345B8F85940DB1104DDCAD96667BB33C9EC1CC152C9B47881B25930ACDE9CA` |
| `ExitPass_Realistic_Carpark_Statutory_Discount_Coverage_v1.0.csv` | `3B31C495305C103FB654D8A1A0064F2A3FE33BBFE6BB03A8332C86835034C07C` |
| `ExitPass_Realistic_Carpark_Source_Register_v1.0.csv` | `1042C45644ABD40B1D708CB9E7C6D30F8D29D911BDAE46C491FC1D4CA149B1F7` |
| `Test-RealisticCarparkCatalogSeedManifest.ps1` | `2FC7FD68A7C2214627D0CB2A4027FD17CCCA3BE167DF12948149239EDBCA1829` |

## Versioning and sources

The repository is hybrid. `objects/reference-data/sites.realistic-carpark-catalog.seed.sql` is the authoritative state source for clean construction. `migrations/20260813120000_realistic_carpark_catalog_canonical_seed.sql` is the minimum additive forward path for existing databases. `objects/exitpass-full-object-apply-order.txt` drives `scripts/build/Build-ExitPassFullObjectSql.ps1`, which regenerates `build/generated/exitpass-full-object.generated.sql`.

Both paths fail on semantic UUID/code collisions. An exact row is an idempotent no-op; no broad conflict update may repurpose an identity.

## Source mapping

| Manifest field | Canonical field | Rule |
|---|---|---|
| `site_group_id` | `sites.site_groups.site_group_id` | Exact approved UUID |
| Site Group code/name | `site_group_code` / `site_group_name` | Exact approved value |
| Group timezone/currency | `timezone_name` / `default_currency_code` | `Asia/Manila` / `PHP` |
| Group `effective_from` | `effective_from` | `2026-08-13T00:00:00+08:00` (stored instant `2026-08-12T16:00:00Z`) |
| `site_id` / parent | `sites.sites.site_id` / `site_group_id` | Exact approved UUIDs |
| Site code/name/type | `site_code` / `site_name` / `site_type` | Exact approved values |
| Site jurisdiction | `local_government_unit_id` / `lgu_code` | Existing jurisdiction UUID / canonical PSGC |
| Assignment UUID / links | `site_jurisdiction_assignment_id` / `site_id` / `jurisdiction_id` | Exact approved UUIDs |
| Assignment `effective_from` | `effective_from` | Approved timestamp; never migration time or `now()` |
| `APPROVED_CANONICAL_SEED_INPUT` | no lifecycle field | Provenance marker represented in bounded `source_reference` only |
| Assignment lifecycle | `assignment_status` | `PENDING_APPROVAL` |
| All `effective_to` values | corresponding `effective_to` | `NULL` |

The approved effective timestamp starts catalog identity and jurisdiction-mapping validity. Operational posture remains independently fail-closed: groups and Sites are `DRAFT`; public lookup and payment are false; assignments remain `PENDING_APPROVAL`. The schema has no catalog-level fiscal or exit toggle; DRAFT/disabled Sites are not configured with lanes, devices, tariffs, adapters, Vendor Systems, projection targets, or credentials.

## Results

The seed adds 39 Site Groups, 46 Sites, and 46 one-to-one pending jurisdiction assignments while reusing 13 active jurisdictions. Site types are `OPEN_LOT` 5, `STRUCTURED_PARKING` 2, `MALL_PARKING` 9, `MIXED_USE_PROPERTY` 1, and `OTHER` 29. The intentional `OTHER` classifications are preserved rather than reinterpreted.

City of Lapu-Lapu remains UUID `23104fc9-a144-381c-4347-ccb2aa1a2998`, PSGC `0731100000`, jurisdiction code `PH-PSGC-0731100000`, and correspondence code `072226000`. All six Mactan New Town Sites reuse that identity. Both Bridgetowne Sites use City of Pasig. PITX Level 3 remains a manifest-only `PROPOSED_NOT_ACTIVATED` candidate; no canonical activation record is created.

The 26 statutory research rows remain documentation inputs only and are not inserted into executable policy tables.

## Site Group inventory

| Site Group UUID | Code | Name | Status | Effective from |
|---|---|---|---|---|
| `d54e01eb-b802-571e-9a47-ab328181a52f` | `ALABANG-TOWN-CENTER` | Alabang Town Center | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `15247658-8f68-5be4-9468-413d6f6f5b20` | `ARYA-RESIDENCES` | Arya Residences | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `f91d131d-bb72-5232-a172-2d1219ce212e` | `AYALA-OPEN-LOT` | Ayala Open Lot | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `387560fc-f0ec-5772-92a6-67efd93a1524` | `BRIDGETOWNE` | Bridgetowne | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `5b87cf69-23db-5c10-94f7-96ff0a3f9f50` | `CYBER-BETA` | Cyber Beta | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `dd752741-9b2c-55dc-bcaa-f942db4779a9` | `CYBER-EXXA-TOWER` | Cyber Exxa Tower | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `25df41c5-ef63-5e24-8b0c-a31cf14029d6` | `CYBER-SIGMA` | Cyber Sigma | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `c93cacc2-a937-5760-9f01-c26ed992aeae` | `CYBER-TERA-CYBER-GIGA` | Cyber Tera / Cyber Giga | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `1952fd7f-0e14-5a3b-b406-a431c8c4245f` | `DELOS-SANTOS-HOSPITAL` | Delos Santos Hospital | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `f4d07383-fd36-576f-9ce4-f0b99fb41443` | `ESCOLTA` | Escolta | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `554980d2-6f8f-59e5-a04c-b6d1a663149a` | `F-ORTIGAS-AVE` | F. Ortigas Ave. | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `3faeb9ad-a8d1-5478-94f8-31e78adb8567` | `GRAND-CENTRAL-RESIDENCES` | Grand Central Residences | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `9632dab0-5f16-551f-836e-58def469d889` | `INSULAR-VALRO` | Insular Valro | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `5d31d8c2-ce1c-55ad-90cf-db4b8c6ed68d` | `LANDMARK-ALABANG` | Landmark Alabang | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `1c40a4b4-a607-5942-91b2-a7f8af80671a` | `MACTAN-NEW-TOWN` | Mactan New Town | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `38478f75-36c9-58bb-9e40-aafcbf40ea1d` | `MAKATI-CINEMA-SQUARE` | Makati Cinema Square | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `ebfee7f7-b814-52bb-a93a-2249f46b9e59` | `MANILA-HOTEL` | Manila Hotel | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `030b448e-be2d-5eed-83f1-357e43943217` | `MARCO-POLO-HOTEL` | Marco Polo Hotel | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `5c768693-ab14-58cc-b678-684ce85280ad` | `MERALCO-AVE` | Meralco Ave. | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `79430d3d-78ee-50ee-9384-809d203a883a` | `NATIONAL-BOOKSTORE` | National Bookstore | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `c5c43b8d-c8dd-570d-91c7-ed5cec205f21` | `PEARL-DRIVE` | Pearl Drive | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `a6dbadf6-68b5-5bed-a7e0-a75faee70841` | `PITX` | PITX | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `70d63a5e-928d-5281-8915-f5d9ce765451` | `ROBINSONS-CYBERGATE` | Robinsons Cybergate | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `4be2b550-7735-50ac-8759-029f2e4a013d` | `ROBINSONS-DAVAO-CITY-DELTA` | Robinsons Davao City - Delta | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `65c40fb7-0129-5195-948e-46474c97197d` | `ROBINSONS-MALABON` | Robinsons Malabon | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `ff05aaf0-080f-5648-acf0-0c5ca41a1d5b` | `ROBINSONS-OTIS` | Robinsons Otis | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `96a2bc59-f907-581e-9204-7b5996dfa9d8` | `ROBINSONS-PIONEER` | Robinsons Pioneer | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `e2d55745-c646-563b-98a7-95c20eea184d` | `ROCKWELL-PPM` | Rockwell PPM | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `fa4a30e5-9e30-5735-8d41-e2a0c81dddf9` | `ROCKWELL-SANTOLAN` | Rockwell Santolan | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `59be83b6-a0ca-5813-9d7d-8fd0aa02f2a0` | `ROCKWELL-SHERIDAN` | Rockwell Sheridan | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `d873f195-7920-5dff-bf8e-adafac53bfe0` | `SM-GRACE-MALL` | SM Grace Mall | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `6ae061a4-85ae-59db-af90-ba114df6fada` | `SM-GREEN-MALL` | SM Green Mall | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `cfcea976-e1f3-55e4-a18e-15d1f4b5da64` | `SM-MPLACE-BASEMENT` | SM MPlace Basement | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `d63c02d7-4a9f-59b2-9085-20475914cfae` | `SM-MPLACE-STREET` | SM MPlace Street | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `4ba4d8e3-ecd8-5aea-abdd-5d2ce894dc83` | `TALAMBAN-TIMES-SQUARE` | Talamban Times Square | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `735b0faa-b930-5fb4-a8da-d8bd9c544691` | `TEKTITE-TOWERS` | Tektite Towers | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `6a42a0d4-17c6-56c4-84b7-df396def1e42` | `TORDESILLAS` | Tordesillas | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `1618f7bd-f2dd-5bd1-9256-d7ac8b5b4e6a` | `UN-SQUARE-MALL` | UN Square Mall | `DRAFT` | `2026-08-13T00:00:00+08:00` |
| `bb356bde-a59e-5244-afad-2b8bfc816d78` | `WOODLAND` | Woodland | `DRAFT` | `2026-08-13T00:00:00+08:00` |

## Site inventory

| Site UUID | Code | Name | Site Group | Site type | Jurisdiction UUID | Status |
|---|---|---|---|---|---|---|
| `270aaaff-6e3a-5b22-acb1-144ea95d5e20` | `ALABANG-TOWN-CENTER` | Alabang Town Center | `ALABANG-TOWN-CENTER` | `MALL_PARKING` | `d7ef112d-06ee-b57c-34b6-fae8c457a0c6` | `DRAFT` |
| `e2792ce4-29e8-513d-b08d-b43ae4a212ac` | `ARYA-RESIDENCES` | Arya Residences | `ARYA-RESIDENCES` | `OTHER` | `c7514a40-c898-f3a2-0bfa-530b26daa273` | `DRAFT` |
| `5360fb17-35f4-5200-b407-22515191e88d` | `AYALA-OPEN-LOT` | Ayala Open Lot | `AYALA-OPEN-LOT` | `OPEN_LOT` | `557b0a76-8ffe-0818-d342-5b86dba06705` | `DRAFT` |
| `4d138cea-f7f4-54a7-8f30-de1873153683` | `BRIDGETOWNE-OPEN-LOT-BLK-09` | Bridgetowne Open Lot Block 09 | `BRIDGETOWNE` | `OPEN_LOT` | `20650612-8f91-3b4a-bba8-5d8afe29ef5a` | `DRAFT` |
| `b4158151-e61b-5410-94ff-7715bffbf62e` | `BRIDGETOWNE-OPEN-LOT-BLK-15` | Bridgetowne Open Lot Block 15 | `BRIDGETOWNE` | `OPEN_LOT` | `20650612-8f91-3b4a-bba8-5d8afe29ef5a` | `DRAFT` |
| `1cef054e-4254-58bd-b0b7-060cca9418d6` | `CYBER-BETA` | Cyber Beta | `CYBER-BETA` | `OTHER` | `20650612-8f91-3b4a-bba8-5d8afe29ef5a` | `DRAFT` |
| `26189a6a-1f29-5591-8467-0e40085bce2f` | `CYBER-EXXA-TOWER` | Cyber Exxa Tower | `CYBER-EXXA-TOWER` | `OTHER` | `79893901-65d3-7c29-0099-25e937a7c8c9` | `DRAFT` |
| `f13fbbdb-d707-519b-bf76-eefb79233005` | `CYBER-SIGMA` | Cyber Sigma | `CYBER-SIGMA` | `OTHER` | `c7514a40-c898-f3a2-0bfa-530b26daa273` | `DRAFT` |
| `995fdc44-b216-5f5c-8760-5c942da3cb40` | `CYBER-TERA-CYBER-GIGA` | Cyber Tera / Cyber Giga | `CYBER-TERA-CYBER-GIGA` | `OTHER` | `79893901-65d3-7c29-0099-25e937a7c8c9` | `DRAFT` |
| `36cb6781-2372-5629-bff1-18c2ebf8897d` | `DELOS-SANTOS-HOSPITAL` | Delos Santos Hospital | `DELOS-SANTOS-HOSPITAL` | `OTHER` | `79893901-65d3-7c29-0099-25e937a7c8c9` | `DRAFT` |
| `b2885dd9-0424-5251-9769-ebe06c500daa` | `ESCOLTA` | Escolta | `ESCOLTA` | `OTHER` | `e5959354-04af-4540-9889-6e040b6cd399` | `DRAFT` |
| `1b5b2105-dc5f-5294-a241-01f05de2dcdc` | `F-ORTIGAS-AVE` | F. Ortigas Ave. | `F-ORTIGAS-AVE` | `OTHER` | `20650612-8f91-3b4a-bba8-5d8afe29ef5a` | `DRAFT` |
| `1f3057bf-ccc3-5322-87ae-21c6be307d79` | `GRAND-CENTRAL-RESIDENCES` | Grand Central Residences | `GRAND-CENTRAL-RESIDENCES` | `OTHER` | `c7514a40-c898-f3a2-0bfa-530b26daa273` | `DRAFT` |
| `72ca5540-31dc-5a08-bced-e95a986f2902` | `INSULAR-VALRO` | Insular Valro | `INSULAR-VALRO` | `OTHER` | `557b0a76-8ffe-0818-d342-5b86dba06705` | `DRAFT` |
| `52936ca1-7e08-5ac7-aa53-68245330580d` | `LANDMARK-ALABANG` | Landmark Alabang | `LANDMARK-ALABANG` | `MALL_PARKING` | `d7ef112d-06ee-b57c-34b6-fae8c457a0c6` | `DRAFT` |
| `8cd1a8db-4fdc-5509-929d-4d9c2141ce9d` | `MACTAN-NEW-TOWN-AL-FRESCO` | Mactan New Town Al Fresco | `MACTAN-NEW-TOWN` | `MIXED_USE_PROPERTY` | `23104fc9-a144-381c-4347-ccb2aa1a2998` | `DRAFT` |
| `615ca612-68d7-546d-9851-71acc6949b41` | `MACTAN-NEW-TOWN-BEACH-PARKING` | Mactan New Town Beach Parking | `MACTAN-NEW-TOWN` | `OTHER` | `23104fc9-a144-381c-4347-ccb2aa1a2998` | `DRAFT` |
| `fb95fc53-3b2c-5920-9304-bbc3f3a51f5b` | `MACTAN-NEW-TOWN-MCDONALDS` | Mactan New Town McDonald's | `MACTAN-NEW-TOWN` | `OTHER` | `23104fc9-a144-381c-4347-ccb2aa1a2998` | `DRAFT` |
| `0e5e13bb-f2fb-59ae-9ae7-dc5df820a9b9` | `MACTAN-NEW-TOWN-MUSEUM` | Mactan New Town Museum | `MACTAN-NEW-TOWN` | `OTHER` | `23104fc9-a144-381c-4347-ccb2aa1a2998` | `DRAFT` |
| `4d6bbe58-fad5-5068-9000-f5aa843ccf58` | `MACTAN-NEW-TOWN-OPEN-LOT-GRAVEL` | Mactan New Town Open Lot Gravel | `MACTAN-NEW-TOWN` | `OPEN_LOT` | `23104fc9-a144-381c-4347-ccb2aa1a2998` | `DRAFT` |
| `be420081-ed0a-5dbf-8721-71eb20312346` | `MACTAN-NEW-TOWN-OPR` | Mactan New Town OPR | `MACTAN-NEW-TOWN` | `OTHER` | `23104fc9-a144-381c-4347-ccb2aa1a2998` | `DRAFT` |
| `eef20dd3-20fc-572b-9574-939517abbd95` | `MAKATI-CINEMA-SQUARE` | Makati Cinema Square | `MAKATI-CINEMA-SQUARE` | `MALL_PARKING` | `557b0a76-8ffe-0818-d342-5b86dba06705` | `DRAFT` |
| `53f6f0f6-4341-59e7-85f5-b526b1bdcbd0` | `MANILA-HOTEL` | Manila Hotel | `MANILA-HOTEL` | `OTHER` | `e5959354-04af-4540-9889-6e040b6cd399` | `DRAFT` |
| `e850eaad-6903-5cf7-aeb1-e0bb2e2d5a1c` | `MARCO-POLO-HOTEL` | Marco Polo Hotel | `MARCO-POLO-HOTEL` | `OTHER` | `20650612-8f91-3b4a-bba8-5d8afe29ef5a` | `DRAFT` |
| `d1ccd074-2fe9-570f-b9d7-03970bbc6e8e` | `MERALCO-AVE` | Meralco Ave. | `MERALCO-AVE` | `OTHER` | `20650612-8f91-3b4a-bba8-5d8afe29ef5a` | `DRAFT` |
| `eb98130b-edb7-5a3f-90d5-8d474809e936` | `NATIONAL-BOOKSTORE` | National Bookstore | `NATIONAL-BOOKSTORE` | `OTHER` | `79893901-65d3-7c29-0099-25e937a7c8c9` | `DRAFT` |
| `07d89135-6777-597c-9523-0b29756a9086` | `PEARL-DRIVE` | Pearl Drive | `PEARL-DRIVE` | `OTHER` | `20650612-8f91-3b4a-bba8-5d8afe29ef5a` | `DRAFT` |
| `2d1dcdf8-f563-537c-8542-0bde7cc9da97` | `PITX-LEVEL-3` | PITX Level 3 | `PITX` | `STRUCTURED_PARKING` | `f7a1b4b9-17a9-89de-5059-f72779616f23` | `DRAFT` |
| `b336964f-3b84-5404-8690-97ead0929b1f` | `PITX-OPEN-LOT` | PITX Open Lot | `PITX` | `OPEN_LOT` | `f7a1b4b9-17a9-89de-5059-f72779616f23` | `DRAFT` |
| `37b1a6f0-1e9c-507a-b967-81e30e95ea05` | `ROBINSONS-CYBERGATE` | Robinsons Cybergate | `ROBINSONS-CYBERGATE` | `OTHER` | `20dcf68a-511f-8208-7dfa-1688425d4d66` | `DRAFT` |
| `0217b14a-5837-5599-99e1-356bcf5ea2cc` | `ROBINSONS-DAVAO-CITY-DELTA` | Robinsons Davao City - Delta | `ROBINSONS-DAVAO-CITY-DELTA` | `OTHER` | `2ebef844-416b-c827-357c-742d2c8d56aa` | `DRAFT` |
| `a37daf7e-b812-53dd-a3dd-b3889c375fb2` | `ROBINSONS-MALABON` | Robinsons Malabon | `ROBINSONS-MALABON` | `MALL_PARKING` | `46a4b330-a065-daad-5de5-16654b67164f` | `DRAFT` |
| `f5d0af07-2790-588f-b83c-c1c63f740582` | `ROBINSONS-OTIS` | Robinsons Otis | `ROBINSONS-OTIS` | `MALL_PARKING` | `e5959354-04af-4540-9889-6e040b6cd399` | `DRAFT` |
| `6042e5ee-d7da-5b4c-bcab-5815ef3591eb` | `ROBINSONS-PIONEER` | Robinsons Pioneer | `ROBINSONS-PIONEER` | `MALL_PARKING` | `20dcf68a-511f-8208-7dfa-1688425d4d66` | `DRAFT` |
| `877d773f-b07c-5c0a-bef3-6983ddc2c767` | `ROCKWELL-PPM` | Rockwell PPM | `ROCKWELL-PPM` | `OTHER` | `557b0a76-8ffe-0818-d342-5b86dba06705` | `DRAFT` |
| `b1bed6db-61b5-5936-9e5b-780c4eaa0464` | `ROCKWELL-SANTOLAN` | Rockwell Santolan | `ROCKWELL-SANTOLAN` | `OTHER` | `d20727ab-9024-d233-ab75-3d49245b452c` | `DRAFT` |
| `7bc9ed78-ee43-52ca-997e-f4de6d92d572` | `ROCKWELL-SHERIDAN` | Rockwell Sheridan | `ROCKWELL-SHERIDAN` | `OTHER` | `20dcf68a-511f-8208-7dfa-1688425d4d66` | `DRAFT` |
| `cf15f183-5a4d-5257-9e6a-d167aafec86b` | `SM-GRACE-MALL` | SM Grace Mall | `SM-GRACE-MALL` | `MALL_PARKING` | `c7514a40-c898-f3a2-0bfa-530b26daa273` | `DRAFT` |
| `99999e0d-8edf-525b-99ac-a4722ca83e21` | `SM-GREEN-MALL` | SM Green Mall | `SM-GREEN-MALL` | `MALL_PARKING` | `e5959354-04af-4540-9889-6e040b6cd399` | `DRAFT` |
| `922704c2-3bab-5b16-9a92-43868cec7950` | `SM-MPLACE-BASEMENT` | SM MPlace Basement | `SM-MPLACE-BASEMENT` | `STRUCTURED_PARKING` | `79893901-65d3-7c29-0099-25e937a7c8c9` | `DRAFT` |
| `bc791bf8-6a3e-5618-82f6-ee15daf78db3` | `SM-MPLACE-STREET` | SM MPlace Street | `SM-MPLACE-STREET` | `OTHER` | `79893901-65d3-7c29-0099-25e937a7c8c9` | `DRAFT` |
| `92611558-2c89-53ff-9ac7-9fb39c83df79` | `TALAMBAN-TIMES-SQUARE` | Talamban Times Square | `TALAMBAN-TIMES-SQUARE` | `OTHER` | `42689eb0-66a8-04bb-96fd-c8d32caad475` | `DRAFT` |
| `0d5b8df7-f4e3-58bf-a768-e6c3378f6b92` | `TEKTITE-TOWERS` | Tektite Towers | `TEKTITE-TOWERS` | `OTHER` | `20650612-8f91-3b4a-bba8-5d8afe29ef5a` | `DRAFT` |
| `7c80cf1d-a3fc-5f36-9b53-d06cd093b628` | `TORDESILLAS` | Tordesillas | `TORDESILLAS` | `OTHER` | `557b0a76-8ffe-0818-d342-5b86dba06705` | `DRAFT` |
| `75674321-c7d9-51de-9c17-c59c116c6d62` | `UN-SQUARE-MALL` | UN Square Mall | `UN-SQUARE-MALL` | `MALL_PARKING` | `e5959354-04af-4540-9889-6e040b6cd399` | `DRAFT` |
| `d6a7c750-0b44-540e-acf4-9d4aa2f2c7af` | `WOODLAND` | Woodland | `WOODLAND` | `OTHER` | `20dcf68a-511f-8208-7dfa-1688425d4d66` | `DRAFT` |

## Assignment inventory

| Assignment UUID | Site code | Jurisdiction UUID | Effective from | Status |
|---|---|---|---|---|
| `d57528b6-0135-529d-8c99-7830fabb82fc` | `ALABANG-TOWN-CENTER` | `d7ef112d-06ee-b57c-34b6-fae8c457a0c6` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `20e28490-4607-5615-9674-c29e45fcfa07` | `ARYA-RESIDENCES` | `c7514a40-c898-f3a2-0bfa-530b26daa273` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `fe112476-454c-576f-a490-713d64651312` | `AYALA-OPEN-LOT` | `557b0a76-8ffe-0818-d342-5b86dba06705` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `40c96505-4c51-50b4-b950-2ea3589e519f` | `BRIDGETOWNE-OPEN-LOT-BLK-09` | `20650612-8f91-3b4a-bba8-5d8afe29ef5a` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `50ebd43f-3259-5238-8c9c-938838785f32` | `BRIDGETOWNE-OPEN-LOT-BLK-15` | `20650612-8f91-3b4a-bba8-5d8afe29ef5a` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `b56453a6-da0a-5548-88f6-2fe14fa6793c` | `CYBER-BETA` | `20650612-8f91-3b4a-bba8-5d8afe29ef5a` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `4deac6ec-65db-5666-b328-3195682b2b44` | `CYBER-EXXA-TOWER` | `79893901-65d3-7c29-0099-25e937a7c8c9` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `5ffa9ae2-c728-5de2-8e05-63318001cf35` | `CYBER-SIGMA` | `c7514a40-c898-f3a2-0bfa-530b26daa273` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `3f1021a6-9566-5c05-adb4-d55928c443f2` | `CYBER-TERA-CYBER-GIGA` | `79893901-65d3-7c29-0099-25e937a7c8c9` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `54cf1f4f-f3c3-5599-8ea1-4fc7801f9f22` | `DELOS-SANTOS-HOSPITAL` | `79893901-65d3-7c29-0099-25e937a7c8c9` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `38883ef7-dac1-536b-b42d-7029d9c78f95` | `ESCOLTA` | `e5959354-04af-4540-9889-6e040b6cd399` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `37e060d1-3df0-5059-a021-416c4442a5c3` | `F-ORTIGAS-AVE` | `20650612-8f91-3b4a-bba8-5d8afe29ef5a` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `cf58a9be-983d-561e-9fc1-1fe6cd9787c8` | `GRAND-CENTRAL-RESIDENCES` | `c7514a40-c898-f3a2-0bfa-530b26daa273` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `a8aee24f-3d25-55de-97d4-4c0cfb921beb` | `INSULAR-VALRO` | `557b0a76-8ffe-0818-d342-5b86dba06705` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `b9ef6902-118f-5726-a460-16de8eb93cc2` | `LANDMARK-ALABANG` | `d7ef112d-06ee-b57c-34b6-fae8c457a0c6` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `f54025df-0fe5-5a9b-9edf-ad3585c01c48` | `MACTAN-NEW-TOWN-AL-FRESCO` | `23104fc9-a144-381c-4347-ccb2aa1a2998` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `8d5920a2-1467-5572-9536-0f9bcddd0246` | `MACTAN-NEW-TOWN-BEACH-PARKING` | `23104fc9-a144-381c-4347-ccb2aa1a2998` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `8e7a9251-d0be-5972-9fea-6dc233aa6b44` | `MACTAN-NEW-TOWN-MCDONALDS` | `23104fc9-a144-381c-4347-ccb2aa1a2998` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `27e2d19e-c160-5953-9a8f-620e7451af45` | `MACTAN-NEW-TOWN-MUSEUM` | `23104fc9-a144-381c-4347-ccb2aa1a2998` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `6a44873e-f609-5df2-863b-e7ec224338f7` | `MACTAN-NEW-TOWN-OPEN-LOT-GRAVEL` | `23104fc9-a144-381c-4347-ccb2aa1a2998` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `230a6003-52df-5e33-a606-adbd8fc632b1` | `MACTAN-NEW-TOWN-OPR` | `23104fc9-a144-381c-4347-ccb2aa1a2998` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `d4b4a106-6021-5626-9347-2bf2da9a6366` | `MAKATI-CINEMA-SQUARE` | `557b0a76-8ffe-0818-d342-5b86dba06705` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `17273a18-1619-5d6e-af76-e45460bd1aba` | `MANILA-HOTEL` | `e5959354-04af-4540-9889-6e040b6cd399` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `da2aced6-e999-582b-833d-cb0be1724b88` | `MARCO-POLO-HOTEL` | `20650612-8f91-3b4a-bba8-5d8afe29ef5a` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `c6d00b0c-b3d9-5480-be6a-5a80563e73f1` | `MERALCO-AVE` | `20650612-8f91-3b4a-bba8-5d8afe29ef5a` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `ddf249f1-0183-5237-850a-3d97ecd3ef70` | `NATIONAL-BOOKSTORE` | `79893901-65d3-7c29-0099-25e937a7c8c9` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `bcfd54b6-c233-5491-b961-14c1b3b3c161` | `PEARL-DRIVE` | `20650612-8f91-3b4a-bba8-5d8afe29ef5a` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `2574804d-e93c-52f9-a917-81c08e44c30f` | `PITX-LEVEL-3` | `f7a1b4b9-17a9-89de-5059-f72779616f23` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `e078aec8-7a00-57eb-a377-2d31067e2d8f` | `PITX-OPEN-LOT` | `f7a1b4b9-17a9-89de-5059-f72779616f23` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `5a2d904e-6baf-5b30-8090-ab85d8bbf424` | `ROBINSONS-CYBERGATE` | `20dcf68a-511f-8208-7dfa-1688425d4d66` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `9987081a-eaa3-59d1-ac75-22ac3cb9c0c5` | `ROBINSONS-DAVAO-CITY-DELTA` | `2ebef844-416b-c827-357c-742d2c8d56aa` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `116c046b-2799-5e03-a047-4b7a7e61139f` | `ROBINSONS-MALABON` | `46a4b330-a065-daad-5de5-16654b67164f` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `39493573-2f1c-5df3-bc9e-e445b0012a47` | `ROBINSONS-OTIS` | `e5959354-04af-4540-9889-6e040b6cd399` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `144c4e09-9479-5569-98c7-28044b81e352` | `ROBINSONS-PIONEER` | `20dcf68a-511f-8208-7dfa-1688425d4d66` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `b73704de-bf2c-504a-b5ee-a408c6c9312c` | `ROCKWELL-PPM` | `557b0a76-8ffe-0818-d342-5b86dba06705` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `7e43b258-aeed-501a-bdca-d7a50c260310` | `ROCKWELL-SANTOLAN` | `d20727ab-9024-d233-ab75-3d49245b452c` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `d46b47c1-ee38-5cb2-9327-3284ddd5a94c` | `ROCKWELL-SHERIDAN` | `20dcf68a-511f-8208-7dfa-1688425d4d66` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `9d8bad16-07f0-592d-be86-2be76d4eef68` | `SM-GRACE-MALL` | `c7514a40-c898-f3a2-0bfa-530b26daa273` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `2f027e45-e9a6-5f31-8a72-985bbaf59a04` | `SM-GREEN-MALL` | `e5959354-04af-4540-9889-6e040b6cd399` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `56788a61-83a6-5e87-a6dd-7f807c7fbedb` | `SM-MPLACE-BASEMENT` | `79893901-65d3-7c29-0099-25e937a7c8c9` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `b3151dc4-7f2a-5eb5-8d9f-577d15e230aa` | `SM-MPLACE-STREET` | `79893901-65d3-7c29-0099-25e937a7c8c9` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `29d3fd35-4f69-5aaa-b0a3-d31d01efd30c` | `TALAMBAN-TIMES-SQUARE` | `42689eb0-66a8-04bb-96fd-c8d32caad475` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `2da1f031-0799-59f1-8ae4-6d5a36cd4e78` | `TEKTITE-TOWERS` | `20650612-8f91-3b4a-bba8-5d8afe29ef5a` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `173eab83-e3d3-56ac-82b1-57c75b625fad` | `TORDESILLAS` | `557b0a76-8ffe-0818-d342-5b86dba06705` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `871de9c5-9ca6-59c4-9a75-e11b2e8942f5` | `UN-SQUARE-MALL` | `e5959354-04af-4540-9889-6e040b6cd399` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |
| `e5123b24-b10b-5c9a-8593-4507d856b0eb` | `WOODLAND` | `20dcf68a-511f-8208-7dfa-1688425d4d66` | `2026-08-13T00:00:00+08:00` | `PENDING_APPROVAL` |

## Jurisdiction reuse

| Jurisdiction UUID | Manifest code | Display name | PSGC | Site count |
|---|---|---|---|---:|
| `42689eb0-66a8-04bb-96fd-c8d32caad475` | `CEBU_CITY` | City of Cebu | `0730600000` | 1 |
| `2ebef844-416b-c827-357c-742d2c8d56aa` | `DAVAO_CITY` | Davao City | `1130700000` | 1 |
| `23104fc9-a144-381c-4347-ccb2aa1a2998` | `LAPU_LAPU` | City of Lapu-Lapu | `0731100000` | 6 |
| `557b0a76-8ffe-0818-d342-5b86dba06705` | `MAKATI` | City of Makati | `1380300000` | 5 |
| `46a4b330-a065-daad-5de5-16654b67164f` | `MALABON` | City of Malabon | `1380400000` | 1 |
| `20dcf68a-511f-8208-7dfa-1688425d4d66` | `MANDALUYONG` | City of Mandaluyong | `1380500000` | 4 |
| `e5959354-04af-4540-9889-6e040b6cd399` | `MANILA` | City of Manila | `1380600000` | 5 |
| `d7ef112d-06ee-b57c-34b6-fae8c457a0c6` | `MUNTINLUPA` | City of Muntinlupa | `1380800000` | 2 |
| `f7a1b4b9-17a9-89de-5059-f72779616f23` | `PARANAQUE` | City of ParaÃ±aque | `1381000000` | 2 |
| `20650612-8f91-3b4a-bba8-5d8afe29ef5a` | `PASIG` | City of Pasig | `1381200000` | 8 |
| `79893901-65d3-7c29-0099-25e937a7c8c9` | `QUEZON_CITY` | Quezon City | `1381300000` | 6 |
| `d20727ab-9024-d233-ab75-3d49245b452c` | `SAN_JUAN` | City of San Juan | `1381400000` | 1 |
| `c7514a40-c898-f3a2-0bfa-530b26daa273` | `TAGUIG` | City of Taguig | `1381500000` | 4 |

## Fixture coexistence and dependencies

The exact `origin/develop` baseline contains four existing Site Groups, 92 existing Sites, and 90 existing assignments. Their stable governed-field hashes before this change are:

- Site Groups: `cb10b90dae01325d951e860932a70373`
- Sites: `f0380c3b7ec122e0bce46173c266f8e4`
- assignments: `9e3a409c5d2cc26c8a1d04279a582b07`

These hashes exclude legacy execution-time effective dates because the pre-existing v1.2 MNT fixture uses `now()` for those fields. The approved realistic rows remain validated against their exact fixed effective timestamp.

The existing inventory consists of the active `MNT` development group with two operational development Sites plus three disabled `SAMPLE-METRO-*` groups, 90 disabled synthetic metropolitan Sites, and 90 synthetic active jurisdiction assignments. The realistic UUID and code scan found no collision. The focused validator recomputes the pre-existing governed-field hashes after excluding the approved realistic rows.

Foreign keys into Site Groups or Sites exist in core fiscal references; statutory payable-basis commands, policy versions, evidence tables and scope grants; human scope grants and privileged-access requests; Operator Console access, device, shift, takeover, revocation, and statutory review tables; and Site jurisdiction assignments. Baseline dependent counts are zero except the 90 pre-existing assignments. The additive seed creates no dependent operational row.

## Validation and replay

Validation covers exact manifest identities and codes, all one-to-one relationships, 13 existing active jurisdictions, Site type distribution, the approved effective instant, null end dates, DRAFT/PENDING_APPROVAL lifecycle, disabled public/payment controls, fixture hashes, Mactan and Bridgetowne reconciliation, and absence of integration mappings or executable Site policy versions.

Clean construction applies the generated full-object SQL. Upgrade applies the forward migration to the exact baseline. Reapplying the declarative seed and migration is an exact no-op. Clean-build and upgraded catalog hashes must converge, while fixture hashes and dependent counts remain unchanged.

Validated catalog hashes are `88fedb66061db521949a10ed3d240567` for Site Groups, `c265e1c36cfaea7a9ddf02c9986130e0` for Sites, and `d3fc86f85c0d1878f89af6e59b2f6619` for assignments. Clean-build and baseline-upgrade databases produced the same three hashes. Stable Vendor System and endpoint hashes also remained unchanged (`f6a0ee5a37f2fadc896dacc474b26382` and `c5342f6c0132efba5940ef743c27dbd9`), with zero adapter mappings and zero executable policy versions.

The repository object-source CI passed with 2,699 full apply-order sources and 334 v1.3 alignment sources. The focused positive validator passed on clean-build and upgraded databases. Negative tests proved rejection of UUID/code drift, duplicate UUIDs and codes, cross-entity UUID reuse, missing or duplicate assignments, inactive jurisdictions, incorrect Mactan ownership, changed effective windows, operational flags, active assignments, integration mappings, policy-version rows, and modified pre-existing fixtures.

## Rollback

Uncommitted source changes or an unapplied candidate may be reverted at source-control level. A deployed additive catalog must not be unconditionally deleted after dependent operational records can exist. Any future retirement requires a governed forward change that first inventories references, preserves Site and assignment identities needed by history, disables rather than repurposes records, and leaves transaction snapshots untouched. Synthetic fixtures coexist and are not part of this rollback.

## Residual risks and approvals

The catalog remains non-operational until separate product, jurisdiction-assignment, public lookup, payment, fiscal, exit, and integration approvals occur. PITX HikCentral candidacy requires a separate activation contract and configuration. Merge review must confirm source/generated equivalence, clean-build and upgrade convergence, replay, fixture preservation, and focused regression results. Deployment requires normal database change approval and must not be combined with synthetic-fixture migration.
