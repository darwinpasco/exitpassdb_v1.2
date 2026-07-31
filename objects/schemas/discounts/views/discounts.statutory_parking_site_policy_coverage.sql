-- Create view "statutory_parking_site_policy_coverage"
CREATE VIEW "discounts"."statutory_parking_site_policy_coverage" AS
SELECT
  site.site_id,
  site.site_code,
  site.site_group_id,
  coverage.local_government_unit_id,
  coverage.local_government_unit_code,
  coverage.psgc_code,
  coverage.local_government_unit_name,
  coverage.entitlement_type,
  coverage.statutory_discount_policy_registry_id,
  coverage.policy_code,
  coverage.policy_name,
  coverage.verification_status,
  coverage.policy_status,
  coverage.benefit_type,
  coverage.beneficiary_residency_scope,
  coverage.coverage_available,
  coverage.auto_application_allowed,
  coverage.source_scan_date,
  coverage.effective_from,
  coverage.effective_to,
  coverage.coverage_resolution_status
FROM sites.sites site
JOIN discounts.statutory_parking_lgu_policy_coverage coverage ON coverage.local_government_unit_id = site.local_government_unit_id;;