-- Create view "site_group_lgu_scopes"
CREATE VIEW "sites"."site_group_lgu_scopes" AS
SELECT
  sg.site_group_id,
  sg.site_group_code,
  sg.site_group_name,
  j.jurisdiction_id AS local_government_unit_id,
  j.jurisdiction_code AS local_government_unit_code,
  j.psgc_code,
  j.display_name AS local_government_unit_name,
  ma.metropolitan_area_id,
  ma.metropolitan_area_code,
  ma.metropolitan_area_name,
  count(DISTINCT s.site_id) AS site_count
FROM sites.site_groups sg
JOIN sites.sites s ON s.site_group_id = sg.site_group_id
JOIN sites.jurisdictions j ON j.jurisdiction_id = s.local_government_unit_id
LEFT JOIN sites.metropolitan_area_jurisdictions maj
  ON maj.jurisdiction_id = j.jurisdiction_id
 AND maj.membership_status = 'ACTIVE'::sites.jurisdiction_status_enum
 AND maj.effective_from <= now()
 AND (maj.effective_to IS NULL OR maj.effective_to > now())
LEFT JOIN sites.metropolitan_areas ma ON ma.metropolitan_area_id = maj.metropolitan_area_id
GROUP BY sg.site_group_id, sg.site_group_code, sg.site_group_name, j.jurisdiction_id, j.jurisdiction_code, j.psgc_code, j.display_name, ma.metropolitan_area_id, ma.metropolitan_area_code, ma.metropolitan_area_name;;