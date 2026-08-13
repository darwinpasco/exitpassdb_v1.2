-- Add the approved realistic carpark catalog to existing canonical databases.
-- This forward migration is additive, idempotent for exact matches, and fail-closed on identity drift.
-- Canonical non-operational realistic carpark catalog from ExitPass manifest merge ee7bc7545054f8277301a8bf66cdf4ee8628afb7.
-- The approved effective timestamp establishes catalog validity; it does not activate operations.
BEGIN;

CREATE TEMP TABLE ep_realistic_catalog_groups (
  site_group_id uuid PRIMARY KEY,
  site_group_code text NOT NULL UNIQUE,
  site_group_name text NOT NULL,
  timezone_name text NOT NULL,
  currency_code text NOT NULL,
  effective_from timestamptz NOT NULL
) ON COMMIT DROP;
INSERT INTO ep_realistic_catalog_groups VALUES
  ('d54e01eb-b802-571e-9a47-ab328181a52f'::uuid, 'ALABANG-TOWN-CENTER', 'Alabang Town Center', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('15247658-8f68-5be4-9468-413d6f6f5b20'::uuid, 'ARYA-RESIDENCES', 'Arya Residences', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('f91d131d-bb72-5232-a172-2d1219ce212e'::uuid, 'AYALA-OPEN-LOT', 'Ayala Open Lot', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('387560fc-f0ec-5772-92a6-67efd93a1524'::uuid, 'BRIDGETOWNE', 'Bridgetowne', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('5b87cf69-23db-5c10-94f7-96ff0a3f9f50'::uuid, 'CYBER-BETA', 'Cyber Beta', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('dd752741-9b2c-55dc-bcaa-f942db4779a9'::uuid, 'CYBER-EXXA-TOWER', 'Cyber Exxa Tower', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('25df41c5-ef63-5e24-8b0c-a31cf14029d6'::uuid, 'CYBER-SIGMA', 'Cyber Sigma', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('c93cacc2-a937-5760-9f01-c26ed992aeae'::uuid, 'CYBER-TERA-CYBER-GIGA', 'Cyber Tera / Cyber Giga', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('1952fd7f-0e14-5a3b-b406-a431c8c4245f'::uuid, 'DELOS-SANTOS-HOSPITAL', 'Delos Santos Hospital', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('f4d07383-fd36-576f-9ce4-f0b99fb41443'::uuid, 'ESCOLTA', 'Escolta', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('554980d2-6f8f-59e5-a04c-b6d1a663149a'::uuid, 'F-ORTIGAS-AVE', 'F. Ortigas Ave.', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('3faeb9ad-a8d1-5478-94f8-31e78adb8567'::uuid, 'GRAND-CENTRAL-RESIDENCES', 'Grand Central Residences', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('9632dab0-5f16-551f-836e-58def469d889'::uuid, 'INSULAR-VALRO', 'Insular Valro', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('5d31d8c2-ce1c-55ad-90cf-db4b8c6ed68d'::uuid, 'LANDMARK-ALABANG', 'Landmark Alabang', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('1c40a4b4-a607-5942-91b2-a7f8af80671a'::uuid, 'MACTAN-NEW-TOWN', 'Mactan New Town', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('38478f75-36c9-58bb-9e40-aafcbf40ea1d'::uuid, 'MAKATI-CINEMA-SQUARE', 'Makati Cinema Square', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('ebfee7f7-b814-52bb-a93a-2249f46b9e59'::uuid, 'MANILA-HOTEL', 'Manila Hotel', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('030b448e-be2d-5eed-83f1-357e43943217'::uuid, 'MARCO-POLO-HOTEL', 'Marco Polo Hotel', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('5c768693-ab14-58cc-b678-684ce85280ad'::uuid, 'MERALCO-AVE', 'Meralco Ave.', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('79430d3d-78ee-50ee-9384-809d203a883a'::uuid, 'NATIONAL-BOOKSTORE', 'National Bookstore', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('c5c43b8d-c8dd-570d-91c7-ed5cec205f21'::uuid, 'PEARL-DRIVE', 'Pearl Drive', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('a6dbadf6-68b5-5bed-a7e0-a75faee70841'::uuid, 'PITX', 'PITX', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('70d63a5e-928d-5281-8915-f5d9ce765451'::uuid, 'ROBINSONS-CYBERGATE', 'Robinsons Cybergate', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('4be2b550-7735-50ac-8759-029f2e4a013d'::uuid, 'ROBINSONS-DAVAO-CITY-DELTA', 'Robinsons Davao City - Delta', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('65c40fb7-0129-5195-948e-46474c97197d'::uuid, 'ROBINSONS-MALABON', 'Robinsons Malabon', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('ff05aaf0-080f-5648-acf0-0c5ca41a1d5b'::uuid, 'ROBINSONS-OTIS', 'Robinsons Otis', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('96a2bc59-f907-581e-9204-7b5996dfa9d8'::uuid, 'ROBINSONS-PIONEER', 'Robinsons Pioneer', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('e2d55745-c646-563b-98a7-95c20eea184d'::uuid, 'ROCKWELL-PPM', 'Rockwell PPM', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('fa4a30e5-9e30-5735-8d41-e2a0c81dddf9'::uuid, 'ROCKWELL-SANTOLAN', 'Rockwell Santolan', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('59be83b6-a0ca-5813-9d7d-8fd0aa02f2a0'::uuid, 'ROCKWELL-SHERIDAN', 'Rockwell Sheridan', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('d873f195-7920-5dff-bf8e-adafac53bfe0'::uuid, 'SM-GRACE-MALL', 'SM Grace Mall', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('6ae061a4-85ae-59db-af90-ba114df6fada'::uuid, 'SM-GREEN-MALL', 'SM Green Mall', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('cfcea976-e1f3-55e4-a18e-15d1f4b5da64'::uuid, 'SM-MPLACE-BASEMENT', 'SM MPlace Basement', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('d63c02d7-4a9f-59b2-9085-20475914cfae'::uuid, 'SM-MPLACE-STREET', 'SM MPlace Street', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('4ba4d8e3-ecd8-5aea-abdd-5d2ce894dc83'::uuid, 'TALAMBAN-TIMES-SQUARE', 'Talamban Times Square', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('735b0faa-b930-5fb4-a8da-d8bd9c544691'::uuid, 'TEKTITE-TOWERS', 'Tektite Towers', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('6a42a0d4-17c6-56c4-84b7-df396def1e42'::uuid, 'TORDESILLAS', 'Tordesillas', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('1618f7bd-f2dd-5bd1-9256-d7ac8b5b4e6a'::uuid, 'UN-SQUARE-MALL', 'UN Square Mall', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('bb356bde-a59e-5244-afad-2b8bfc816d78'::uuid, 'WOODLAND', 'Woodland', 'Asia/Manila', 'PHP', '2026-08-13T00:00:00+08:00'::timestamptz);

CREATE TEMP TABLE ep_realistic_catalog_sites (
  site_id uuid PRIMARY KEY,
  site_group_id uuid NOT NULL,
  site_code text NOT NULL UNIQUE,
  site_name text NOT NULL,
  site_type text NOT NULL,
  timezone_name text NOT NULL,
  jurisdiction_id uuid NOT NULL,
  psgc_code text NOT NULL,
  effective_from timestamptz NOT NULL
) ON COMMIT DROP;
INSERT INTO ep_realistic_catalog_sites VALUES
  ('2d1dcdf8-f563-537c-8542-0bde7cc9da97'::uuid, 'a6dbadf6-68b5-5bed-a7e0-a75faee70841'::uuid, 'PITX-LEVEL-3', 'PITX Level 3', 'STRUCTURED_PARKING', 'Asia/Manila', 'f7a1b4b9-17a9-89de-5059-f72779616f23'::uuid, '1381000000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('b336964f-3b84-5404-8690-97ead0929b1f'::uuid, 'a6dbadf6-68b5-5bed-a7e0-a75faee70841'::uuid, 'PITX-OPEN-LOT', 'PITX Open Lot', 'OPEN_LOT', 'Asia/Manila', 'f7a1b4b9-17a9-89de-5059-f72779616f23'::uuid, '1381000000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('26189a6a-1f29-5591-8467-0e40085bce2f'::uuid, 'dd752741-9b2c-55dc-bcaa-f942db4779a9'::uuid, 'CYBER-EXXA-TOWER', 'Cyber Exxa Tower', 'OTHER', 'Asia/Manila', '79893901-65d3-7c29-0099-25e937a7c8c9'::uuid, '1381300000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('a37daf7e-b812-53dd-a3dd-b3889c375fb2'::uuid, '65c40fb7-0129-5195-948e-46474c97197d'::uuid, 'ROBINSONS-MALABON', 'Robinsons Malabon', 'MALL_PARKING', 'Asia/Manila', '46a4b330-a065-daad-5de5-16654b67164f'::uuid, '1380400000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('0d5b8df7-f4e3-58bf-a768-e6c3378f6b92'::uuid, '735b0faa-b930-5fb4-a8da-d8bd9c544691'::uuid, 'TEKTITE-TOWERS', 'Tektite Towers', 'OTHER', 'Asia/Manila', '20650612-8f91-3b4a-bba8-5d8afe29ef5a'::uuid, '1381200000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('1b5b2105-dc5f-5294-a241-01f05de2dcdc'::uuid, '554980d2-6f8f-59e5-a04c-b6d1a663149a'::uuid, 'F-ORTIGAS-AVE', 'F. Ortigas Ave.', 'OTHER', 'Asia/Manila', '20650612-8f91-3b4a-bba8-5d8afe29ef5a'::uuid, '1381200000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('d1ccd074-2fe9-570f-b9d7-03970bbc6e8e'::uuid, '5c768693-ab14-58cc-b678-684ce85280ad'::uuid, 'MERALCO-AVE', 'Meralco Ave.', 'OTHER', 'Asia/Manila', '20650612-8f91-3b4a-bba8-5d8afe29ef5a'::uuid, '1381200000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('e2792ce4-29e8-513d-b08d-b43ae4a212ac'::uuid, '15247658-8f68-5be4-9468-413d6f6f5b20'::uuid, 'ARYA-RESIDENCES', 'Arya Residences', 'OTHER', 'Asia/Manila', 'c7514a40-c898-f3a2-0bfa-530b26daa273'::uuid, '1381500000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('f13fbbdb-d707-519b-bf76-eefb79233005'::uuid, '25df41c5-ef63-5e24-8b0c-a31cf14029d6'::uuid, 'CYBER-SIGMA', 'Cyber Sigma', 'OTHER', 'Asia/Manila', 'c7514a40-c898-f3a2-0bfa-530b26daa273'::uuid, '1381500000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('1f3057bf-ccc3-5322-87ae-21c6be307d79'::uuid, '3faeb9ad-a8d1-5478-94f8-31e78adb8567'::uuid, 'GRAND-CENTRAL-RESIDENCES', 'Grand Central Residences', 'OTHER', 'Asia/Manila', 'c7514a40-c898-f3a2-0bfa-530b26daa273'::uuid, '1381500000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('877d773f-b07c-5c0a-bef3-6983ddc2c767'::uuid, 'e2d55745-c646-563b-98a7-95c20eea184d'::uuid, 'ROCKWELL-PPM', 'Rockwell PPM', 'OTHER', 'Asia/Manila', '557b0a76-8ffe-0818-d342-5b86dba06705'::uuid, '1380300000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('b1bed6db-61b5-5936-9e5b-780c4eaa0464'::uuid, 'fa4a30e5-9e30-5735-8d41-e2a0c81dddf9'::uuid, 'ROCKWELL-SANTOLAN', 'Rockwell Santolan', 'OTHER', 'Asia/Manila', 'd20727ab-9024-d233-ab75-3d49245b452c'::uuid, '1381400000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('7bc9ed78-ee43-52ca-997e-f4de6d92d572'::uuid, '59be83b6-a0ca-5813-9d7d-8fd0aa02f2a0'::uuid, 'ROCKWELL-SHERIDAN', 'Rockwell Sheridan', 'OTHER', 'Asia/Manila', '20dcf68a-511f-8208-7dfa-1688425d4d66'::uuid, '1380500000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('36cb6781-2372-5629-bff1-18c2ebf8897d'::uuid, '1952fd7f-0e14-5a3b-b406-a431c8c4245f'::uuid, 'DELOS-SANTOS-HOSPITAL', 'Delos Santos Hospital', 'OTHER', 'Asia/Manila', '79893901-65d3-7c29-0099-25e937a7c8c9'::uuid, '1381300000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('eb98130b-edb7-5a3f-90d5-8d474809e936'::uuid, '79430d3d-78ee-50ee-9384-809d203a883a'::uuid, 'NATIONAL-BOOKSTORE', 'National Bookstore', 'OTHER', 'Asia/Manila', '79893901-65d3-7c29-0099-25e937a7c8c9'::uuid, '1381300000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('eef20dd3-20fc-572b-9574-939517abbd95'::uuid, '38478f75-36c9-58bb-9e40-aafcbf40ea1d'::uuid, 'MAKATI-CINEMA-SQUARE', 'Makati Cinema Square', 'MALL_PARKING', 'Asia/Manila', '557b0a76-8ffe-0818-d342-5b86dba06705'::uuid, '1380300000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('52936ca1-7e08-5ac7-aa53-68245330580d'::uuid, '5d31d8c2-ce1c-55ad-90cf-db4b8c6ed68d'::uuid, 'LANDMARK-ALABANG', 'Landmark Alabang', 'MALL_PARKING', 'Asia/Manila', 'd7ef112d-06ee-b57c-34b6-fae8c457a0c6'::uuid, '1380800000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('72ca5540-31dc-5a08-bced-e95a986f2902'::uuid, '9632dab0-5f16-551f-836e-58def469d889'::uuid, 'INSULAR-VALRO', 'Insular Valro', 'OTHER', 'Asia/Manila', '557b0a76-8ffe-0818-d342-5b86dba06705'::uuid, '1380300000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('f5d0af07-2790-588f-b83c-c1c63f740582'::uuid, 'ff05aaf0-080f-5648-acf0-0c5ca41a1d5b'::uuid, 'ROBINSONS-OTIS', 'Robinsons Otis', 'MALL_PARKING', 'Asia/Manila', 'e5959354-04af-4540-9889-6e040b6cd399'::uuid, '1380600000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('6042e5ee-d7da-5b4c-bcab-5815ef3591eb'::uuid, '96a2bc59-f907-581e-9204-7b5996dfa9d8'::uuid, 'ROBINSONS-PIONEER', 'Robinsons Pioneer', 'MALL_PARKING', 'Asia/Manila', '20dcf68a-511f-8208-7dfa-1688425d4d66'::uuid, '1380500000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('d6a7c750-0b44-540e-acf4-9d4aa2f2c7af'::uuid, 'bb356bde-a59e-5244-afad-2b8bfc816d78'::uuid, 'WOODLAND', 'Woodland', 'OTHER', 'Asia/Manila', '20dcf68a-511f-8208-7dfa-1688425d4d66'::uuid, '1380500000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('37b1a6f0-1e9c-507a-b967-81e30e95ea05'::uuid, '70d63a5e-928d-5281-8915-f5d9ce765451'::uuid, 'ROBINSONS-CYBERGATE', 'Robinsons Cybergate', 'OTHER', 'Asia/Manila', '20dcf68a-511f-8208-7dfa-1688425d4d66'::uuid, '1380500000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('53f6f0f6-4341-59e7-85f5-b526b1bdcbd0'::uuid, 'ebfee7f7-b814-52bb-a93a-2249f46b9e59'::uuid, 'MANILA-HOTEL', 'Manila Hotel', 'OTHER', 'Asia/Manila', 'e5959354-04af-4540-9889-6e040b6cd399'::uuid, '1380600000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('1cef054e-4254-58bd-b0b7-060cca9418d6'::uuid, '5b87cf69-23db-5c10-94f7-96ff0a3f9f50'::uuid, 'CYBER-BETA', 'Cyber Beta', 'OTHER', 'Asia/Manila', '20650612-8f91-3b4a-bba8-5d8afe29ef5a'::uuid, '1381200000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('995fdc44-b216-5f5c-8760-5c942da3cb40'::uuid, 'c93cacc2-a937-5760-9f01-c26ed992aeae'::uuid, 'CYBER-TERA-CYBER-GIGA', 'Cyber Tera / Cyber Giga', 'OTHER', 'Asia/Manila', '79893901-65d3-7c29-0099-25e937a7c8c9'::uuid, '1381300000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('e850eaad-6903-5cf7-aeb1-e0bb2e2d5a1c'::uuid, '030b448e-be2d-5eed-83f1-357e43943217'::uuid, 'MARCO-POLO-HOTEL', 'Marco Polo Hotel', 'OTHER', 'Asia/Manila', '20650612-8f91-3b4a-bba8-5d8afe29ef5a'::uuid, '1381200000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('cf15f183-5a4d-5257-9e6a-d167aafec86b'::uuid, 'd873f195-7920-5dff-bf8e-adafac53bfe0'::uuid, 'SM-GRACE-MALL', 'SM Grace Mall', 'MALL_PARKING', 'Asia/Manila', 'c7514a40-c898-f3a2-0bfa-530b26daa273'::uuid, '1381500000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('07d89135-6777-597c-9523-0b29756a9086'::uuid, 'c5c43b8d-c8dd-570d-91c7-ed5cec205f21'::uuid, 'PEARL-DRIVE', 'Pearl Drive', 'OTHER', 'Asia/Manila', '20650612-8f91-3b4a-bba8-5d8afe29ef5a'::uuid, '1381200000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('922704c2-3bab-5b16-9a92-43868cec7950'::uuid, 'cfcea976-e1f3-55e4-a18e-15d1f4b5da64'::uuid, 'SM-MPLACE-BASEMENT', 'SM MPlace Basement', 'STRUCTURED_PARKING', 'Asia/Manila', '79893901-65d3-7c29-0099-25e937a7c8c9'::uuid, '1381300000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('bc791bf8-6a3e-5618-82f6-ee15daf78db3'::uuid, 'd63c02d7-4a9f-59b2-9085-20475914cfae'::uuid, 'SM-MPLACE-STREET', 'SM MPlace Street', 'OTHER', 'Asia/Manila', '79893901-65d3-7c29-0099-25e937a7c8c9'::uuid, '1381300000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('7c80cf1d-a3fc-5f36-9b53-d06cd093b628'::uuid, '6a42a0d4-17c6-56c4-84b7-df396def1e42'::uuid, 'TORDESILLAS', 'Tordesillas', 'OTHER', 'Asia/Manila', '557b0a76-8ffe-0818-d342-5b86dba06705'::uuid, '1380300000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('99999e0d-8edf-525b-99ac-a4722ca83e21'::uuid, '6ae061a4-85ae-59db-af90-ba114df6fada'::uuid, 'SM-GREEN-MALL', 'SM Green Mall', 'MALL_PARKING', 'Asia/Manila', 'e5959354-04af-4540-9889-6e040b6cd399'::uuid, '1380600000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('b2885dd9-0424-5251-9769-ebe06c500daa'::uuid, 'f4d07383-fd36-576f-9ce4-f0b99fb41443'::uuid, 'ESCOLTA', 'Escolta', 'OTHER', 'Asia/Manila', 'e5959354-04af-4540-9889-6e040b6cd399'::uuid, '1380600000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('75674321-c7d9-51de-9c17-c59c116c6d62'::uuid, '1618f7bd-f2dd-5bd1-9256-d7ac8b5b4e6a'::uuid, 'UN-SQUARE-MALL', 'UN Square Mall', 'MALL_PARKING', 'Asia/Manila', 'e5959354-04af-4540-9889-6e040b6cd399'::uuid, '1380600000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('b4158151-e61b-5410-94ff-7715bffbf62e'::uuid, '387560fc-f0ec-5772-92a6-67efd93a1524'::uuid, 'BRIDGETOWNE-OPEN-LOT-BLK-15', 'Bridgetowne Open Lot Block 15', 'OPEN_LOT', 'Asia/Manila', '20650612-8f91-3b4a-bba8-5d8afe29ef5a'::uuid, '1381200000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('4d138cea-f7f4-54a7-8f30-de1873153683'::uuid, '387560fc-f0ec-5772-92a6-67efd93a1524'::uuid, 'BRIDGETOWNE-OPEN-LOT-BLK-09', 'Bridgetowne Open Lot Block 09', 'OPEN_LOT', 'Asia/Manila', '20650612-8f91-3b4a-bba8-5d8afe29ef5a'::uuid, '1381200000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('fb95fc53-3b2c-5920-9304-bbc3f3a51f5b'::uuid, '1c40a4b4-a607-5942-91b2-a7f8af80671a'::uuid, 'MACTAN-NEW-TOWN-MCDONALDS', 'Mactan New Town McDonald''s', 'OTHER', 'Asia/Manila', '23104fc9-a144-381c-4347-ccb2aa1a2998'::uuid, '0731100000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('8cd1a8db-4fdc-5509-929d-4d9c2141ce9d'::uuid, '1c40a4b4-a607-5942-91b2-a7f8af80671a'::uuid, 'MACTAN-NEW-TOWN-AL-FRESCO', 'Mactan New Town Al Fresco', 'MIXED_USE_PROPERTY', 'Asia/Manila', '23104fc9-a144-381c-4347-ccb2aa1a2998'::uuid, '0731100000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('4d6bbe58-fad5-5068-9000-f5aa843ccf58'::uuid, '1c40a4b4-a607-5942-91b2-a7f8af80671a'::uuid, 'MACTAN-NEW-TOWN-OPEN-LOT-GRAVEL', 'Mactan New Town Open Lot Gravel', 'OPEN_LOT', 'Asia/Manila', '23104fc9-a144-381c-4347-ccb2aa1a2998'::uuid, '0731100000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('be420081-ed0a-5dbf-8721-71eb20312346'::uuid, '1c40a4b4-a607-5942-91b2-a7f8af80671a'::uuid, 'MACTAN-NEW-TOWN-OPR', 'Mactan New Town OPR', 'OTHER', 'Asia/Manila', '23104fc9-a144-381c-4347-ccb2aa1a2998'::uuid, '0731100000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('615ca612-68d7-546d-9851-71acc6949b41'::uuid, '1c40a4b4-a607-5942-91b2-a7f8af80671a'::uuid, 'MACTAN-NEW-TOWN-BEACH-PARKING', 'Mactan New Town Beach Parking', 'OTHER', 'Asia/Manila', '23104fc9-a144-381c-4347-ccb2aa1a2998'::uuid, '0731100000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('0e5e13bb-f2fb-59ae-9ae7-dc5df820a9b9'::uuid, '1c40a4b4-a607-5942-91b2-a7f8af80671a'::uuid, 'MACTAN-NEW-TOWN-MUSEUM', 'Mactan New Town Museum', 'OTHER', 'Asia/Manila', '23104fc9-a144-381c-4347-ccb2aa1a2998'::uuid, '0731100000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('270aaaff-6e3a-5b22-acb1-144ea95d5e20'::uuid, 'd54e01eb-b802-571e-9a47-ab328181a52f'::uuid, 'ALABANG-TOWN-CENTER', 'Alabang Town Center', 'MALL_PARKING', 'Asia/Manila', 'd7ef112d-06ee-b57c-34b6-fae8c457a0c6'::uuid, '1380800000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('92611558-2c89-53ff-9ac7-9fb39c83df79'::uuid, '4ba4d8e3-ecd8-5aea-abdd-5d2ce894dc83'::uuid, 'TALAMBAN-TIMES-SQUARE', 'Talamban Times Square', 'OTHER', 'Asia/Manila', '42689eb0-66a8-04bb-96fd-c8d32caad475'::uuid, '0730600000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('0217b14a-5837-5599-99e1-356bcf5ea2cc'::uuid, '4be2b550-7735-50ac-8759-029f2e4a013d'::uuid, 'ROBINSONS-DAVAO-CITY-DELTA', 'Robinsons Davao City - Delta', 'OTHER', 'Asia/Manila', '2ebef844-416b-c827-357c-742d2c8d56aa'::uuid, '1130700000', '2026-08-13T00:00:00+08:00'::timestamptz),
  ('5360fb17-35f4-5200-b407-22515191e88d'::uuid, 'f91d131d-bb72-5232-a172-2d1219ce212e'::uuid, 'AYALA-OPEN-LOT', 'Ayala Open Lot', 'OPEN_LOT', 'Asia/Manila', '557b0a76-8ffe-0818-d342-5b86dba06705'::uuid, '1380300000', '2026-08-13T00:00:00+08:00'::timestamptz);

CREATE TEMP TABLE ep_realistic_catalog_assignments (
  assignment_id uuid PRIMARY KEY,
  site_id uuid NOT NULL UNIQUE,
  site_code text NOT NULL UNIQUE,
  jurisdiction_id uuid NOT NULL,
  effective_from timestamptz NOT NULL,
  source_reference text NOT NULL
) ON COMMIT DROP;
INSERT INTO ep_realistic_catalog_assignments VALUES
  ('d57528b6-0135-529d-8c99-7830fabb82fc'::uuid, '270aaaff-6e3a-5b22-acb1-144ea95d5e20'::uuid, 'ALABANG-TOWN-CENTER', 'd7ef112d-06ee-b57c-34b6-fae8c457a0c6'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; ALABANG-TOWN-CENTER; APPROVED_CANONICAL_SEED_INPUT.'),
  ('20e28490-4607-5615-9674-c29e45fcfa07'::uuid, 'e2792ce4-29e8-513d-b08d-b43ae4a212ac'::uuid, 'ARYA-RESIDENCES', 'c7514a40-c898-f3a2-0bfa-530b26daa273'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; ARYA-RESIDENCES; APPROVED_CANONICAL_SEED_INPUT.'),
  ('fe112476-454c-576f-a490-713d64651312'::uuid, '5360fb17-35f4-5200-b407-22515191e88d'::uuid, 'AYALA-OPEN-LOT', '557b0a76-8ffe-0818-d342-5b86dba06705'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; AYALA-OPEN-LOT; APPROVED_CANONICAL_SEED_INPUT.'),
  ('40c96505-4c51-50b4-b950-2ea3589e519f'::uuid, '4d138cea-f7f4-54a7-8f30-de1873153683'::uuid, 'BRIDGETOWNE-OPEN-LOT-BLK-09', '20650612-8f91-3b4a-bba8-5d8afe29ef5a'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; BRIDGETOWNE-OPEN-LOT-BLK-09; APPROVED_CANONICAL_SEED_INPUT.'),
  ('50ebd43f-3259-5238-8c9c-938838785f32'::uuid, 'b4158151-e61b-5410-94ff-7715bffbf62e'::uuid, 'BRIDGETOWNE-OPEN-LOT-BLK-15', '20650612-8f91-3b4a-bba8-5d8afe29ef5a'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; BRIDGETOWNE-OPEN-LOT-BLK-15; APPROVED_CANONICAL_SEED_INPUT.'),
  ('b56453a6-da0a-5548-88f6-2fe14fa6793c'::uuid, '1cef054e-4254-58bd-b0b7-060cca9418d6'::uuid, 'CYBER-BETA', '20650612-8f91-3b4a-bba8-5d8afe29ef5a'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; CYBER-BETA; APPROVED_CANONICAL_SEED_INPUT.'),
  ('4deac6ec-65db-5666-b328-3195682b2b44'::uuid, '26189a6a-1f29-5591-8467-0e40085bce2f'::uuid, 'CYBER-EXXA-TOWER', '79893901-65d3-7c29-0099-25e937a7c8c9'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; CYBER-EXXA-TOWER; APPROVED_CANONICAL_SEED_INPUT.'),
  ('5ffa9ae2-c728-5de2-8e05-63318001cf35'::uuid, 'f13fbbdb-d707-519b-bf76-eefb79233005'::uuid, 'CYBER-SIGMA', 'c7514a40-c898-f3a2-0bfa-530b26daa273'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; CYBER-SIGMA; APPROVED_CANONICAL_SEED_INPUT.'),
  ('3f1021a6-9566-5c05-adb4-d55928c443f2'::uuid, '995fdc44-b216-5f5c-8760-5c942da3cb40'::uuid, 'CYBER-TERA-CYBER-GIGA', '79893901-65d3-7c29-0099-25e937a7c8c9'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; CYBER-TERA-CYBER-GIGA; APPROVED_CANONICAL_SEED_INPUT.'),
  ('54cf1f4f-f3c3-5599-8ea1-4fc7801f9f22'::uuid, '36cb6781-2372-5629-bff1-18c2ebf8897d'::uuid, 'DELOS-SANTOS-HOSPITAL', '79893901-65d3-7c29-0099-25e937a7c8c9'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; DELOS-SANTOS-HOSPITAL; APPROVED_CANONICAL_SEED_INPUT.'),
  ('38883ef7-dac1-536b-b42d-7029d9c78f95'::uuid, 'b2885dd9-0424-5251-9769-ebe06c500daa'::uuid, 'ESCOLTA', 'e5959354-04af-4540-9889-6e040b6cd399'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; ESCOLTA; APPROVED_CANONICAL_SEED_INPUT.'),
  ('37e060d1-3df0-5059-a021-416c4442a5c3'::uuid, '1b5b2105-dc5f-5294-a241-01f05de2dcdc'::uuid, 'F-ORTIGAS-AVE', '20650612-8f91-3b4a-bba8-5d8afe29ef5a'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; F-ORTIGAS-AVE; APPROVED_CANONICAL_SEED_INPUT.'),
  ('cf58a9be-983d-561e-9fc1-1fe6cd9787c8'::uuid, '1f3057bf-ccc3-5322-87ae-21c6be307d79'::uuid, 'GRAND-CENTRAL-RESIDENCES', 'c7514a40-c898-f3a2-0bfa-530b26daa273'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; GRAND-CENTRAL-RESIDENCES; APPROVED_CANONICAL_SEED_INPUT.'),
  ('a8aee24f-3d25-55de-97d4-4c0cfb921beb'::uuid, '72ca5540-31dc-5a08-bced-e95a986f2902'::uuid, 'INSULAR-VALRO', '557b0a76-8ffe-0818-d342-5b86dba06705'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; INSULAR-VALRO; APPROVED_CANONICAL_SEED_INPUT.'),
  ('b9ef6902-118f-5726-a460-16de8eb93cc2'::uuid, '52936ca1-7e08-5ac7-aa53-68245330580d'::uuid, 'LANDMARK-ALABANG', 'd7ef112d-06ee-b57c-34b6-fae8c457a0c6'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; LANDMARK-ALABANG; APPROVED_CANONICAL_SEED_INPUT.'),
  ('f54025df-0fe5-5a9b-9edf-ad3585c01c48'::uuid, '8cd1a8db-4fdc-5509-929d-4d9c2141ce9d'::uuid, 'MACTAN-NEW-TOWN-AL-FRESCO', '23104fc9-a144-381c-4347-ccb2aa1a2998'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; MACTAN-NEW-TOWN-AL-FRESCO; APPROVED_CANONICAL_SEED_INPUT.'),
  ('8d5920a2-1467-5572-9536-0f9bcddd0246'::uuid, '615ca612-68d7-546d-9851-71acc6949b41'::uuid, 'MACTAN-NEW-TOWN-BEACH-PARKING', '23104fc9-a144-381c-4347-ccb2aa1a2998'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; MACTAN-NEW-TOWN-BEACH-PARKING; APPROVED_CANONICAL_SEED_INPUT.'),
  ('8e7a9251-d0be-5972-9fea-6dc233aa6b44'::uuid, 'fb95fc53-3b2c-5920-9304-bbc3f3a51f5b'::uuid, 'MACTAN-NEW-TOWN-MCDONALDS', '23104fc9-a144-381c-4347-ccb2aa1a2998'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; MACTAN-NEW-TOWN-MCDONALDS; APPROVED_CANONICAL_SEED_INPUT.'),
  ('27e2d19e-c160-5953-9a8f-620e7451af45'::uuid, '0e5e13bb-f2fb-59ae-9ae7-dc5df820a9b9'::uuid, 'MACTAN-NEW-TOWN-MUSEUM', '23104fc9-a144-381c-4347-ccb2aa1a2998'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; MACTAN-NEW-TOWN-MUSEUM; APPROVED_CANONICAL_SEED_INPUT.'),
  ('6a44873e-f609-5df2-863b-e7ec224338f7'::uuid, '4d6bbe58-fad5-5068-9000-f5aa843ccf58'::uuid, 'MACTAN-NEW-TOWN-OPEN-LOT-GRAVEL', '23104fc9-a144-381c-4347-ccb2aa1a2998'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; MACTAN-NEW-TOWN-OPEN-LOT-GRAVEL; APPROVED_CANONICAL_SEED_INPUT.'),
  ('230a6003-52df-5e33-a606-adbd8fc632b1'::uuid, 'be420081-ed0a-5dbf-8721-71eb20312346'::uuid, 'MACTAN-NEW-TOWN-OPR', '23104fc9-a144-381c-4347-ccb2aa1a2998'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; MACTAN-NEW-TOWN-OPR; APPROVED_CANONICAL_SEED_INPUT.'),
  ('d4b4a106-6021-5626-9347-2bf2da9a6366'::uuid, 'eef20dd3-20fc-572b-9574-939517abbd95'::uuid, 'MAKATI-CINEMA-SQUARE', '557b0a76-8ffe-0818-d342-5b86dba06705'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; MAKATI-CINEMA-SQUARE; APPROVED_CANONICAL_SEED_INPUT.'),
  ('17273a18-1619-5d6e-af76-e45460bd1aba'::uuid, '53f6f0f6-4341-59e7-85f5-b526b1bdcbd0'::uuid, 'MANILA-HOTEL', 'e5959354-04af-4540-9889-6e040b6cd399'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; MANILA-HOTEL; APPROVED_CANONICAL_SEED_INPUT.'),
  ('da2aced6-e999-582b-833d-cb0be1724b88'::uuid, 'e850eaad-6903-5cf7-aeb1-e0bb2e2d5a1c'::uuid, 'MARCO-POLO-HOTEL', '20650612-8f91-3b4a-bba8-5d8afe29ef5a'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; MARCO-POLO-HOTEL; APPROVED_CANONICAL_SEED_INPUT.'),
  ('c6d00b0c-b3d9-5480-be6a-5a80563e73f1'::uuid, 'd1ccd074-2fe9-570f-b9d7-03970bbc6e8e'::uuid, 'MERALCO-AVE', '20650612-8f91-3b4a-bba8-5d8afe29ef5a'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; MERALCO-AVE; APPROVED_CANONICAL_SEED_INPUT.'),
  ('ddf249f1-0183-5237-850a-3d97ecd3ef70'::uuid, 'eb98130b-edb7-5a3f-90d5-8d474809e936'::uuid, 'NATIONAL-BOOKSTORE', '79893901-65d3-7c29-0099-25e937a7c8c9'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; NATIONAL-BOOKSTORE; APPROVED_CANONICAL_SEED_INPUT.'),
  ('bcfd54b6-c233-5491-b961-14c1b3b3c161'::uuid, '07d89135-6777-597c-9523-0b29756a9086'::uuid, 'PEARL-DRIVE', '20650612-8f91-3b4a-bba8-5d8afe29ef5a'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; PEARL-DRIVE; APPROVED_CANONICAL_SEED_INPUT.'),
  ('2574804d-e93c-52f9-a917-81c08e44c30f'::uuid, '2d1dcdf8-f563-537c-8542-0bde7cc9da97'::uuid, 'PITX-LEVEL-3', 'f7a1b4b9-17a9-89de-5059-f72779616f23'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; PITX-LEVEL-3; APPROVED_CANONICAL_SEED_INPUT.'),
  ('e078aec8-7a00-57eb-a377-2d31067e2d8f'::uuid, 'b336964f-3b84-5404-8690-97ead0929b1f'::uuid, 'PITX-OPEN-LOT', 'f7a1b4b9-17a9-89de-5059-f72779616f23'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; PITX-OPEN-LOT; APPROVED_CANONICAL_SEED_INPUT.'),
  ('5a2d904e-6baf-5b30-8090-ab85d8bbf424'::uuid, '37b1a6f0-1e9c-507a-b967-81e30e95ea05'::uuid, 'ROBINSONS-CYBERGATE', '20dcf68a-511f-8208-7dfa-1688425d4d66'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; ROBINSONS-CYBERGATE; APPROVED_CANONICAL_SEED_INPUT.'),
  ('9987081a-eaa3-59d1-ac75-22ac3cb9c0c5'::uuid, '0217b14a-5837-5599-99e1-356bcf5ea2cc'::uuid, 'ROBINSONS-DAVAO-CITY-DELTA', '2ebef844-416b-c827-357c-742d2c8d56aa'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; ROBINSONS-DAVAO-CITY-DELTA; APPROVED_CANONICAL_SEED_INPUT.'),
  ('116c046b-2799-5e03-a047-4b7a7e61139f'::uuid, 'a37daf7e-b812-53dd-a3dd-b3889c375fb2'::uuid, 'ROBINSONS-MALABON', '46a4b330-a065-daad-5de5-16654b67164f'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; ROBINSONS-MALABON; APPROVED_CANONICAL_SEED_INPUT.'),
  ('39493573-2f1c-5df3-bc9e-e445b0012a47'::uuid, 'f5d0af07-2790-588f-b83c-c1c63f740582'::uuid, 'ROBINSONS-OTIS', 'e5959354-04af-4540-9889-6e040b6cd399'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; ROBINSONS-OTIS; APPROVED_CANONICAL_SEED_INPUT.'),
  ('144c4e09-9479-5569-98c7-28044b81e352'::uuid, '6042e5ee-d7da-5b4c-bcab-5815ef3591eb'::uuid, 'ROBINSONS-PIONEER', '20dcf68a-511f-8208-7dfa-1688425d4d66'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; ROBINSONS-PIONEER; APPROVED_CANONICAL_SEED_INPUT.'),
  ('b73704de-bf2c-504a-b5ee-a408c6c9312c'::uuid, '877d773f-b07c-5c0a-bef3-6983ddc2c767'::uuid, 'ROCKWELL-PPM', '557b0a76-8ffe-0818-d342-5b86dba06705'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; ROCKWELL-PPM; APPROVED_CANONICAL_SEED_INPUT.'),
  ('7e43b258-aeed-501a-bdca-d7a50c260310'::uuid, 'b1bed6db-61b5-5936-9e5b-780c4eaa0464'::uuid, 'ROCKWELL-SANTOLAN', 'd20727ab-9024-d233-ab75-3d49245b452c'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; ROCKWELL-SANTOLAN; APPROVED_CANONICAL_SEED_INPUT.'),
  ('d46b47c1-ee38-5cb2-9327-3284ddd5a94c'::uuid, '7bc9ed78-ee43-52ca-997e-f4de6d92d572'::uuid, 'ROCKWELL-SHERIDAN', '20dcf68a-511f-8208-7dfa-1688425d4d66'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; ROCKWELL-SHERIDAN; APPROVED_CANONICAL_SEED_INPUT.'),
  ('9d8bad16-07f0-592d-be86-2be76d4eef68'::uuid, 'cf15f183-5a4d-5257-9e6a-d167aafec86b'::uuid, 'SM-GRACE-MALL', 'c7514a40-c898-f3a2-0bfa-530b26daa273'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; SM-GRACE-MALL; APPROVED_CANONICAL_SEED_INPUT.'),
  ('2f027e45-e9a6-5f31-8a72-985bbaf59a04'::uuid, '99999e0d-8edf-525b-99ac-a4722ca83e21'::uuid, 'SM-GREEN-MALL', 'e5959354-04af-4540-9889-6e040b6cd399'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; SM-GREEN-MALL; APPROVED_CANONICAL_SEED_INPUT.'),
  ('56788a61-83a6-5e87-a6dd-7f807c7fbedb'::uuid, '922704c2-3bab-5b16-9a92-43868cec7950'::uuid, 'SM-MPLACE-BASEMENT', '79893901-65d3-7c29-0099-25e937a7c8c9'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; SM-MPLACE-BASEMENT; APPROVED_CANONICAL_SEED_INPUT.'),
  ('b3151dc4-7f2a-5eb5-8d9f-577d15e230aa'::uuid, 'bc791bf8-6a3e-5618-82f6-ee15daf78db3'::uuid, 'SM-MPLACE-STREET', '79893901-65d3-7c29-0099-25e937a7c8c9'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; SM-MPLACE-STREET; APPROVED_CANONICAL_SEED_INPUT.'),
  ('29d3fd35-4f69-5aaa-b0a3-d31d01efd30c'::uuid, '92611558-2c89-53ff-9ac7-9fb39c83df79'::uuid, 'TALAMBAN-TIMES-SQUARE', '42689eb0-66a8-04bb-96fd-c8d32caad475'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; TALAMBAN-TIMES-SQUARE; APPROVED_CANONICAL_SEED_INPUT.'),
  ('2da1f031-0799-59f1-8ae4-6d5a36cd4e78'::uuid, '0d5b8df7-f4e3-58bf-a768-e6c3378f6b92'::uuid, 'TEKTITE-TOWERS', '20650612-8f91-3b4a-bba8-5d8afe29ef5a'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; TEKTITE-TOWERS; APPROVED_CANONICAL_SEED_INPUT.'),
  ('173eab83-e3d3-56ac-82b1-57c75b625fad'::uuid, '7c80cf1d-a3fc-5f36-9b53-d06cd093b628'::uuid, 'TORDESILLAS', '557b0a76-8ffe-0818-d342-5b86dba06705'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; TORDESILLAS; APPROVED_CANONICAL_SEED_INPUT.'),
  ('871de9c5-9ca6-59c4-9a75-e11b2e8942f5'::uuid, '75674321-c7d9-51de-9c17-c59c116c6d62'::uuid, 'UN-SQUARE-MALL', 'e5959354-04af-4540-9889-6e040b6cd399'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; UN-SQUARE-MALL; APPROVED_CANONICAL_SEED_INPUT.'),
  ('e5123b24-b10b-5c9a-8593-4507d856b0eb'::uuid, 'd6a7c750-0b44-540e-acf4-9d4aa2f2c7af'::uuid, 'WOODLAND', '20dcf68a-511f-8208-7dfa-1688425d4d66'::uuid, '2026-08-13T00:00:00+08:00'::timestamptz, 'ExitPass realistic carpark manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7; WOODLAND; APPROVED_CANONICAL_SEED_INPUT.');

DO $$
BEGIN
  IF (SELECT count(*) FROM ep_realistic_catalog_groups) <> 39
     OR (SELECT count(*) FROM ep_realistic_catalog_sites) <> 46
     OR (SELECT count(*) FROM ep_realistic_catalog_assignments) <> 46 THEN
    RAISE EXCEPTION 'Realistic carpark catalog seed refused: approved manifest cardinality changed.';
  END IF;

  IF EXISTS (
    SELECT 1 FROM ep_realistic_catalog_sites s
    LEFT JOIN ep_realistic_catalog_groups g ON g.site_group_id = s.site_group_id
    WHERE g.site_group_id IS NULL
  ) OR EXISTS (
    SELECT 1 FROM ep_realistic_catalog_assignments a
    LEFT JOIN ep_realistic_catalog_sites s ON s.site_id = a.site_id
    WHERE s.site_id IS NULL OR s.site_code <> a.site_code OR s.jurisdiction_id <> a.jurisdiction_id
  ) THEN
    RAISE EXCEPTION 'Realistic carpark catalog seed refused: manifest parent or assignment relationship is inconsistent.';
  END IF;

  IF (SELECT count(DISTINCT jurisdiction_id) FROM ep_realistic_catalog_sites) <> 13
     OR EXISTS (
       SELECT 1 FROM ep_realistic_catalog_sites e
       LEFT JOIN sites.jurisdictions j ON j.jurisdiction_id = e.jurisdiction_id
       WHERE j.jurisdiction_id IS NULL OR j.jurisdiction_status <> 'ACTIVE' OR j.psgc_code <> e.psgc_code
     ) THEN
    RAISE EXCEPTION 'Realistic carpark catalog seed refused: an approved canonical jurisdiction is missing or inconsistent.';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM sites.jurisdictions j
    JOIN sites.philippine_regions r ON r.philippine_region_id = j.philippine_region_id
    WHERE j.jurisdiction_id = '23104fc9-a144-381c-4347-ccb2aa1a2998'
      AND j.jurisdiction_code = 'PH-PSGC-0731100000'
      AND j.psgc_code = '0731100000'
      AND j.correspondence_code = '072226000'
      AND j.jurisdiction_type = 'CITY'
      AND j.city_classification = 'HIGHLY_URBANIZED'
      AND j.jurisdiction_status = 'ACTIVE'
      AND r.region_code = 'REGION_VII'
  ) OR EXISTS (
    SELECT 1 FROM sites.jurisdictions
    WHERE psgc_code = '0730110000' OR jurisdiction_code = 'PH-PSGC-0730110000'
  ) THEN
    RAISE EXCEPTION 'Realistic carpark catalog seed refused: canonical City of Lapu-Lapu prerequisite failed.';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM ep_realistic_catalog_groups e
    JOIN sites.site_groups g ON g.site_group_id = e.site_group_id OR g.site_group_code = e.site_group_code
    WHERE NOT (
      g.site_group_id = e.site_group_id
      AND g.site_group_code = e.site_group_code
      AND g.site_group_name = e.site_group_name
      AND g.business_label IS NULL
      AND g.description = 'Non-operational canonical realistic carpark catalog entry from approved ExitPass manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7.'
      AND g.operator_entity_name IS NULL
      AND g.timezone_name = e.timezone_name
      AND g.default_currency_code = e.currency_code
      AND g.site_group_status = 'DRAFT'
      AND NOT g.public_lookup_enabled
      AND NOT g.default_payment_enabled
      AND g.effective_from = e.effective_from
      AND g.effective_to IS NULL
    )
  ) THEN
    RAISE EXCEPTION 'Realistic carpark catalog seed refused: Site Group UUID or code collision has different semantics.';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM ep_realistic_catalog_sites e
    JOIN sites.sites s ON s.site_id = e.site_id OR s.site_code = e.site_code
    JOIN sites.jurisdictions j ON j.jurisdiction_id = e.jurisdiction_id
    WHERE NOT (
      s.site_id = e.site_id
      AND s.site_group_id = e.site_group_id
      AND s.site_code = e.site_code
      AND s.site_name = e.site_name
      AND s.site_description = 'Non-operational canonical realistic carpark catalog entry from approved ExitPass manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7.'
      AND s.site_type::text = e.site_type
      AND s.timezone_name = e.timezone_name
      AND s.address_line1 IS NULL
      AND s.address_line2 IS NULL
      AND s.city IS NOT DISTINCT FROM j.display_name
      AND s.province IS NOT DISTINCT FROM j.province_name
      AND s.country_code = 'PH'
      AND s.lgu_code = e.psgc_code
      AND s.local_government_unit_id = e.jurisdiction_id
      AND s.site_status = 'DRAFT'
      AND NOT s.public_lookup_enabled
      AND NOT s.payment_enabled
      AND s.effective_from = e.effective_from
      AND s.effective_to IS NULL
    )
  ) THEN
    RAISE EXCEPTION 'Realistic carpark catalog seed refused: Site UUID or code collision has different semantics.';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM ep_realistic_catalog_assignments e
    JOIN sites.site_jurisdiction_assignments a
      ON a.site_jurisdiction_assignment_id = e.assignment_id OR a.site_id = e.site_id
    WHERE NOT (
      a.site_jurisdiction_assignment_id = e.assignment_id
      AND a.site_id = e.site_id
      AND a.jurisdiction_id = e.jurisdiction_id
      AND a.assignment_status = 'PENDING_APPROVAL'
      AND a.effective_from = e.effective_from
      AND a.effective_to IS NULL
      AND a.source_reference = e.source_reference
      AND a.approval_reference IS NULL
      AND a.correction_reason IS NULL
    )
  ) THEN
    RAISE EXCEPTION 'Realistic carpark catalog seed refused: assignment UUID or Site ownership collision has different semantics.';
  END IF;

  IF EXISTS (SELECT 1 FROM ep_realistic_catalog_groups e JOIN sites.sites s ON s.site_id = e.site_group_id)
     OR EXISTS (SELECT 1 FROM ep_realistic_catalog_groups e JOIN sites.site_jurisdiction_assignments a ON a.site_jurisdiction_assignment_id = e.site_group_id)
     OR EXISTS (SELECT 1 FROM ep_realistic_catalog_sites e JOIN sites.site_groups g ON g.site_group_id = e.site_id)
     OR EXISTS (SELECT 1 FROM ep_realistic_catalog_sites e JOIN sites.site_jurisdiction_assignments a ON a.site_jurisdiction_assignment_id = e.site_id)
     OR EXISTS (SELECT 1 FROM ep_realistic_catalog_assignments e JOIN sites.site_groups g ON g.site_group_id = e.assignment_id)
     OR EXISTS (SELECT 1 FROM ep_realistic_catalog_assignments e JOIN sites.sites s ON s.site_id = e.assignment_id) THEN
    RAISE EXCEPTION 'Realistic carpark catalog seed refused: approved UUID is reused across canonical entity types.';
  END IF;
END $$;
INSERT INTO sites.site_groups (
  site_group_id, site_group_code, site_group_name, business_label, description,
  operator_entity_name, timezone_name, default_currency_code, site_group_status,
  public_lookup_enabled, default_payment_enabled, effective_from, effective_to
)
SELECT e.site_group_id, e.site_group_code, e.site_group_name, NULL,
       'Non-operational canonical realistic carpark catalog entry from approved ExitPass manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7.',
       NULL, e.timezone_name, e.currency_code, 'DRAFT', false, false, e.effective_from, NULL
FROM ep_realistic_catalog_groups e
WHERE NOT EXISTS (
  SELECT 1 FROM sites.site_groups g
  WHERE g.site_group_id = e.site_group_id OR g.site_group_code = e.site_group_code
);

INSERT INTO sites.sites (
  site_id, site_group_id, site_code, site_name, site_description, site_type,
  timezone_name, address_line1, address_line2, city, province, country_code,
  lgu_code, local_government_unit_id, site_status, public_lookup_enabled,
  payment_enabled, effective_from, effective_to
)
SELECT e.site_id, e.site_group_id, e.site_code, e.site_name,
       'Non-operational canonical realistic carpark catalog entry from approved ExitPass manifest ee7bc7545054f8277301a8bf66cdf4ee8628afb7.',
       e.site_type::sites.site_type_enum, e.timezone_name, NULL, NULL,
       j.display_name, j.province_name, 'PH', e.psgc_code, e.jurisdiction_id,
       'DRAFT', false, false, e.effective_from, NULL
FROM ep_realistic_catalog_sites e
JOIN sites.jurisdictions j ON j.jurisdiction_id = e.jurisdiction_id
WHERE NOT EXISTS (
  SELECT 1 FROM sites.sites s
  WHERE s.site_id = e.site_id OR s.site_code = e.site_code
);

INSERT INTO sites.site_jurisdiction_assignments (
  site_jurisdiction_assignment_id, site_id, jurisdiction_id, assignment_status,
  effective_from, effective_to, source_reference, approval_reference, correction_reason
)
SELECT e.assignment_id, e.site_id, e.jurisdiction_id, 'PENDING_APPROVAL',
       e.effective_from, NULL, e.source_reference, NULL, NULL
FROM ep_realistic_catalog_assignments e
WHERE NOT EXISTS (
  SELECT 1 FROM sites.site_jurisdiction_assignments a
  WHERE a.site_jurisdiction_assignment_id = e.assignment_id OR a.site_id = e.site_id
);
DO $$
BEGIN
  IF (SELECT count(*) FROM sites.site_groups g JOIN ep_realistic_catalog_groups e ON e.site_group_id = g.site_group_id) <> 39
     OR (SELECT count(*) FROM sites.sites s JOIN ep_realistic_catalog_sites e ON e.site_id = s.site_id) <> 46
     OR (SELECT count(*) FROM sites.site_jurisdiction_assignments a JOIN ep_realistic_catalog_assignments e ON e.assignment_id = a.site_jurisdiction_assignment_id) <> 46 THEN
    RAISE EXCEPTION 'Realistic carpark catalog seed failed post-insert cardinality validation.';
  END IF;

  IF EXISTS (
    SELECT 1 FROM sites.site_groups g JOIN ep_realistic_catalog_groups e USING (site_group_id)
    WHERE g.site_group_code <> e.site_group_code OR g.site_group_name <> e.site_group_name
       OR g.site_group_status <> 'DRAFT' OR g.public_lookup_enabled OR g.default_payment_enabled
       OR g.effective_from <> e.effective_from OR g.effective_to IS NOT NULL
  ) OR EXISTS (
    SELECT 1 FROM sites.sites s JOIN ep_realistic_catalog_sites e USING (site_id)
    WHERE s.site_group_id <> e.site_group_id OR s.site_code <> e.site_code OR s.site_name <> e.site_name
       OR s.site_type::text <> e.site_type OR s.site_status <> 'DRAFT'
       OR s.public_lookup_enabled OR s.payment_enabled OR s.effective_from <> e.effective_from
       OR s.effective_to IS NOT NULL OR s.local_government_unit_id <> e.jurisdiction_id
  ) OR EXISTS (
    SELECT 1 FROM sites.site_jurisdiction_assignments a
    JOIN ep_realistic_catalog_assignments e ON e.assignment_id = a.site_jurisdiction_assignment_id
    WHERE a.site_id <> e.site_id OR a.jurisdiction_id <> e.jurisdiction_id
       OR a.assignment_status <> 'PENDING_APPROVAL' OR a.effective_from <> e.effective_from
       OR a.effective_to IS NOT NULL OR a.approval_reference IS NOT NULL
  ) THEN
    RAISE EXCEPTION 'Realistic carpark catalog seed failed post-insert semantic validation.';
  END IF;
END $$;
COMMIT;
