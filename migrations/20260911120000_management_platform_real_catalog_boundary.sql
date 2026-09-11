-- Additive database-owned boundary for the approved Professional Parking real carpark catalog.
-- This migration classifies existing canonical rows only; it does not change lifecycle or delete history.
BEGIN;

CREATE TABLE sites.real_carpark_catalog_site_groups (
  site_group_id uuid NOT NULL,
  catalog_code character varying(64) NOT NULL,
  source_reference text NOT NULL,
  source_sha256 character(64) NOT NULL,
  registered_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT pk_real_carpark_catalog_site_groups PRIMARY KEY (site_group_id),
  CONSTRAINT fk_real_carpark_catalog_site_groups__site_group FOREIGN KEY (site_group_id) REFERENCES sites.site_groups (site_group_id),
  CONSTRAINT ck_real_carpark_catalog_site_groups__catalog_code CHECK (catalog_code = 'PROFESSIONAL_PARKING_REAL_CARPARK_V1'),
  CONSTRAINT ck_real_carpark_catalog_site_groups__source_sha256 CHECK (source_sha256 ~ '^[A-F0-9]{64}$')
);

CREATE TABLE sites.real_carpark_catalog_sites (
  site_id uuid NOT NULL,
  site_group_id uuid NOT NULL,
  catalog_code character varying(64) NOT NULL,
  source_reference text NOT NULL,
  source_sha256 character(64) NOT NULL,
  registered_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT pk_real_carpark_catalog_sites PRIMARY KEY (site_id),
  CONSTRAINT fk_real_carpark_catalog_sites__site FOREIGN KEY (site_id) REFERENCES sites.sites (site_id),
  CONSTRAINT fk_real_carpark_catalog_sites__site_group FOREIGN KEY (site_group_id) REFERENCES sites.site_groups (site_group_id),
  CONSTRAINT ck_real_carpark_catalog_sites__catalog_code CHECK (catalog_code = 'PROFESSIONAL_PARKING_REAL_CARPARK_V1'),
  CONSTRAINT ck_real_carpark_catalog_sites__source_sha256 CHECK (source_sha256 ~ '^[A-F0-9]{64}$')
);

WITH approved(site_group_id) AS (
  VALUES
  ('d54e01eb-b802-571e-9a47-ab328181a52f'::uuid),
  ('15247658-8f68-5be4-9468-413d6f6f5b20'::uuid),
  ('f91d131d-bb72-5232-a172-2d1219ce212e'::uuid),
  ('387560fc-f0ec-5772-92a6-67efd93a1524'::uuid),
  ('5b87cf69-23db-5c10-94f7-96ff0a3f9f50'::uuid),
  ('dd752741-9b2c-55dc-bcaa-f942db4779a9'::uuid),
  ('25df41c5-ef63-5e24-8b0c-a31cf14029d6'::uuid),
  ('c93cacc2-a937-5760-9f01-c26ed992aeae'::uuid),
  ('1952fd7f-0e14-5a3b-b406-a431c8c4245f'::uuid),
  ('f4d07383-fd36-576f-9ce4-f0b99fb41443'::uuid),
  ('554980d2-6f8f-59e5-a04c-b6d1a663149a'::uuid),
  ('3faeb9ad-a8d1-5478-94f8-31e78adb8567'::uuid),
  ('9632dab0-5f16-551f-836e-58def469d889'::uuid),
  ('5d31d8c2-ce1c-55ad-90cf-db4b8c6ed68d'::uuid),
  ('1c40a4b4-a607-5942-91b2-a7f8af80671a'::uuid),
  ('38478f75-36c9-58bb-9e40-aafcbf40ea1d'::uuid),
  ('ebfee7f7-b814-52bb-a93a-2249f46b9e59'::uuid),
  ('030b448e-be2d-5eed-83f1-357e43943217'::uuid),
  ('5c768693-ab14-58cc-b678-684ce85280ad'::uuid),
  ('79430d3d-78ee-50ee-9384-809d203a883a'::uuid),
  ('c5c43b8d-c8dd-570d-91c7-ed5cec205f21'::uuid),
  ('a6dbadf6-68b5-5bed-a7e0-a75faee70841'::uuid),
  ('70d63a5e-928d-5281-8915-f5d9ce765451'::uuid),
  ('4be2b550-7735-50ac-8759-029f2e4a013d'::uuid),
  ('65c40fb7-0129-5195-948e-46474c97197d'::uuid),
  ('ff05aaf0-080f-5648-acf0-0c5ca41a1d5b'::uuid),
  ('96a2bc59-f907-581e-9204-7b5996dfa9d8'::uuid),
  ('e2d55745-c646-563b-98a7-95c20eea184d'::uuid),
  ('fa4a30e5-9e30-5735-8d41-e2a0c81dddf9'::uuid),
  ('59be83b6-a0ca-5813-9d7d-8fd0aa02f2a0'::uuid),
  ('d873f195-7920-5dff-bf8e-adafac53bfe0'::uuid),
  ('6ae061a4-85ae-59db-af90-ba114df6fada'::uuid),
  ('cfcea976-e1f3-55e4-a18e-15d1f4b5da64'::uuid),
  ('d63c02d7-4a9f-59b2-9085-20475914cfae'::uuid),
  ('4ba4d8e3-ecd8-5aea-abdd-5d2ce894dc83'::uuid),
  ('735b0faa-b930-5fb4-a8da-d8bd9c544691'::uuid),
  ('6a42a0d4-17c6-56c4-84b7-df396def1e42'::uuid),
  ('1618f7bd-f2dd-5bd1-9256-d7ac8b5b4e6a'::uuid),
  ('bb356bde-a59e-5244-afad-2b8bfc816d78'::uuid)
)
INSERT INTO sites.real_carpark_catalog_site_groups (site_group_id, catalog_code, source_reference, source_sha256)
SELECT site_group_id, 'PROFESSIONAL_PARKING_REAL_CARPARK_V1', 'D:\Docs\Carparks.xlsx',
       '63C20CD3ABA3E13D6F9FC022083507C0BC43A2AB9C751E9084DD19C59969359A'
FROM approved;

WITH approved(site_id, site_group_id) AS (
  VALUES
  ('2d1dcdf8-f563-537c-8542-0bde7cc9da97'::uuid, 'a6dbadf6-68b5-5bed-a7e0-a75faee70841'::uuid),
  ('b336964f-3b84-5404-8690-97ead0929b1f'::uuid, 'a6dbadf6-68b5-5bed-a7e0-a75faee70841'::uuid),
  ('26189a6a-1f29-5591-8467-0e40085bce2f'::uuid, 'dd752741-9b2c-55dc-bcaa-f942db4779a9'::uuid),
  ('a37daf7e-b812-53dd-a3dd-b3889c375fb2'::uuid, '65c40fb7-0129-5195-948e-46474c97197d'::uuid),
  ('0d5b8df7-f4e3-58bf-a768-e6c3378f6b92'::uuid, '735b0faa-b930-5fb4-a8da-d8bd9c544691'::uuid),
  ('1b5b2105-dc5f-5294-a241-01f05de2dcdc'::uuid, '554980d2-6f8f-59e5-a04c-b6d1a663149a'::uuid),
  ('d1ccd074-2fe9-570f-b9d7-03970bbc6e8e'::uuid, '5c768693-ab14-58cc-b678-684ce85280ad'::uuid),
  ('e2792ce4-29e8-513d-b08d-b43ae4a212ac'::uuid, '15247658-8f68-5be4-9468-413d6f6f5b20'::uuid),
  ('f13fbbdb-d707-519b-bf76-eefb79233005'::uuid, '25df41c5-ef63-5e24-8b0c-a31cf14029d6'::uuid),
  ('1f3057bf-ccc3-5322-87ae-21c6be307d79'::uuid, '3faeb9ad-a8d1-5478-94f8-31e78adb8567'::uuid),
  ('877d773f-b07c-5c0a-bef3-6983ddc2c767'::uuid, 'e2d55745-c646-563b-98a7-95c20eea184d'::uuid),
  ('b1bed6db-61b5-5936-9e5b-780c4eaa0464'::uuid, 'fa4a30e5-9e30-5735-8d41-e2a0c81dddf9'::uuid),
  ('7bc9ed78-ee43-52ca-997e-f4de6d92d572'::uuid, '59be83b6-a0ca-5813-9d7d-8fd0aa02f2a0'::uuid),
  ('36cb6781-2372-5629-bff1-18c2ebf8897d'::uuid, '1952fd7f-0e14-5a3b-b406-a431c8c4245f'::uuid),
  ('eb98130b-edb7-5a3f-90d5-8d474809e936'::uuid, '79430d3d-78ee-50ee-9384-809d203a883a'::uuid),
  ('eef20dd3-20fc-572b-9574-939517abbd95'::uuid, '38478f75-36c9-58bb-9e40-aafcbf40ea1d'::uuid),
  ('52936ca1-7e08-5ac7-aa53-68245330580d'::uuid, '5d31d8c2-ce1c-55ad-90cf-db4b8c6ed68d'::uuid),
  ('72ca5540-31dc-5a08-bced-e95a986f2902'::uuid, '9632dab0-5f16-551f-836e-58def469d889'::uuid),
  ('f5d0af07-2790-588f-b83c-c1c63f740582'::uuid, 'ff05aaf0-080f-5648-acf0-0c5ca41a1d5b'::uuid),
  ('6042e5ee-d7da-5b4c-bcab-5815ef3591eb'::uuid, '96a2bc59-f907-581e-9204-7b5996dfa9d8'::uuid),
  ('d6a7c750-0b44-540e-acf4-9d4aa2f2c7af'::uuid, 'bb356bde-a59e-5244-afad-2b8bfc816d78'::uuid),
  ('37b1a6f0-1e9c-507a-b967-81e30e95ea05'::uuid, '70d63a5e-928d-5281-8915-f5d9ce765451'::uuid),
  ('53f6f0f6-4341-59e7-85f5-b526b1bdcbd0'::uuid, 'ebfee7f7-b814-52bb-a93a-2249f46b9e59'::uuid),
  ('1cef054e-4254-58bd-b0b7-060cca9418d6'::uuid, '5b87cf69-23db-5c10-94f7-96ff0a3f9f50'::uuid),
  ('995fdc44-b216-5f5c-8760-5c942da3cb40'::uuid, 'c93cacc2-a937-5760-9f01-c26ed992aeae'::uuid),
  ('e850eaad-6903-5cf7-aeb1-e0bb2e2d5a1c'::uuid, '030b448e-be2d-5eed-83f1-357e43943217'::uuid),
  ('cf15f183-5a4d-5257-9e6a-d167aafec86b'::uuid, 'd873f195-7920-5dff-bf8e-adafac53bfe0'::uuid),
  ('07d89135-6777-597c-9523-0b29756a9086'::uuid, 'c5c43b8d-c8dd-570d-91c7-ed5cec205f21'::uuid),
  ('922704c2-3bab-5b16-9a92-43868cec7950'::uuid, 'cfcea976-e1f3-55e4-a18e-15d1f4b5da64'::uuid),
  ('bc791bf8-6a3e-5618-82f6-ee15daf78db3'::uuid, 'd63c02d7-4a9f-59b2-9085-20475914cfae'::uuid),
  ('7c80cf1d-a3fc-5f36-9b53-d06cd093b628'::uuid, '6a42a0d4-17c6-56c4-84b7-df396def1e42'::uuid),
  ('99999e0d-8edf-525b-99ac-a4722ca83e21'::uuid, '6ae061a4-85ae-59db-af90-ba114df6fada'::uuid),
  ('b2885dd9-0424-5251-9769-ebe06c500daa'::uuid, 'f4d07383-fd36-576f-9ce4-f0b99fb41443'::uuid),
  ('75674321-c7d9-51de-9c17-c59c116c6d62'::uuid, '1618f7bd-f2dd-5bd1-9256-d7ac8b5b4e6a'::uuid),
  ('b4158151-e61b-5410-94ff-7715bffbf62e'::uuid, '387560fc-f0ec-5772-92a6-67efd93a1524'::uuid),
  ('4d138cea-f7f4-54a7-8f30-de1873153683'::uuid, '387560fc-f0ec-5772-92a6-67efd93a1524'::uuid),
  ('fb95fc53-3b2c-5920-9304-bbc3f3a51f5b'::uuid, '1c40a4b4-a607-5942-91b2-a7f8af80671a'::uuid),
  ('8cd1a8db-4fdc-5509-929d-4d9c2141ce9d'::uuid, '1c40a4b4-a607-5942-91b2-a7f8af80671a'::uuid),
  ('4d6bbe58-fad5-5068-9000-f5aa843ccf58'::uuid, '1c40a4b4-a607-5942-91b2-a7f8af80671a'::uuid),
  ('be420081-ed0a-5dbf-8721-71eb20312346'::uuid, '1c40a4b4-a607-5942-91b2-a7f8af80671a'::uuid),
  ('615ca612-68d7-546d-9851-71acc6949b41'::uuid, '1c40a4b4-a607-5942-91b2-a7f8af80671a'::uuid),
  ('0e5e13bb-f2fb-59ae-9ae7-dc5df820a9b9'::uuid, '1c40a4b4-a607-5942-91b2-a7f8af80671a'::uuid),
  ('270aaaff-6e3a-5b22-acb1-144ea95d5e20'::uuid, 'd54e01eb-b802-571e-9a47-ab328181a52f'::uuid),
  ('92611558-2c89-53ff-9ac7-9fb39c83df79'::uuid, '4ba4d8e3-ecd8-5aea-abdd-5d2ce894dc83'::uuid),
  ('0217b14a-5837-5599-99e1-356bcf5ea2cc'::uuid, '4be2b550-7735-50ac-8759-029f2e4a013d'::uuid),
  ('5360fb17-35f4-5200-b407-22515191e88d'::uuid, 'f91d131d-bb72-5232-a172-2d1219ce212e'::uuid)
)
INSERT INTO sites.real_carpark_catalog_sites (site_id, site_group_id, catalog_code, source_reference, source_sha256)
SELECT site_id, site_group_id, 'PROFESSIONAL_PARKING_REAL_CARPARK_V1', 'D:\Docs\Carparks.xlsx',
       '63C20CD3ABA3E13D6F9FC022083507C0BC43A2AB9C751E9084DD19C59969359A'
FROM approved;

DO $$ BEGIN
  IF (SELECT count(*) FROM sites.real_carpark_catalog_site_groups) <> 39
     OR (SELECT count(*) FROM sites.real_carpark_catalog_sites) <> 46 THEN
    RAISE EXCEPTION 'Real carpark catalog classification refused: expected exactly 39 Site Groups and 46 Sites.';
  END IF;
  IF EXISTS (
    SELECT 1
    FROM sites.real_carpark_catalog_sites c
    JOIN sites.sites s ON s.site_id = c.site_id
    WHERE s.site_group_id <> c.site_group_id
  ) THEN
    RAISE EXCEPTION 'Real carpark catalog classification refused: Site parent mismatch.';
  END IF;
END $$;

COMMIT;

