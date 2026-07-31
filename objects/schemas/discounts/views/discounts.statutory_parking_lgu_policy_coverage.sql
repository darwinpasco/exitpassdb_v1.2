-- Create view "statutory_parking_lgu_policy_coverage"
CREATE VIEW "discounts"."statutory_parking_lgu_policy_coverage" AS
SELECT
  s.local_government_unit_id,
  j.jurisdiction_code AS local_government_unit_code,
  j.psgc_code,
  j.display_name AS local_government_unit_name,
  r.statutory_discount_policy_registry_id,
  r.policy_code,
  r.policy_name,
  r.entitlement_type,
  r.verification_status,
  r.policy_status,
  r.benefit_type,
  r.beneficiary_residency_scope,
  r.ordinance_reference,
  r.source_reference,
  r.coverage_available,
  r.auto_application_allowed,
  r.source_scan_date,
  r.effective_from,
  r.effective_to,
  CASE
    WHEN r.auto_application_allowed = true AND r.coverage_available = true AND r.policy_status = 'ACTIVE'::discounts.discount_policy_status_enum THEN 'AUTO_APPLICATION_ALLOWED'
    WHEN r.coverage_available = true THEN 'RESEARCH_COVERAGE_IDENTIFIED'
    ELSE 'NO_ACTIVE_LOCAL_COVERAGE'
  END AS coverage_resolution_status
FROM discounts.statutory_discount_policy_registry r
JOIN discounts.statutory_discount_policy_registry_lgu_scopes s ON s.statutory_discount_policy_registry_id = r.statutory_discount_policy_registry_id
JOIN sites.jurisdictions j ON j.jurisdiction_id = s.local_government_unit_id;;
