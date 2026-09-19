DO $$
DECLARE
  active_count integer;
  invalid_count integer;
  semantic_hash_mismatch_count integer;
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM sites.sites s
    JOIN sites.site_jurisdiction_assignments a
      ON a.site_id = s.site_id
     AND a.effective_to IS NULL
    WHERE s.site_id = '2d1dcdf8-f563-537c-8542-0bde7cc9da97'::uuid
      AND s.site_code = 'PITX-LEVEL-3'
      AND a.jurisdiction_id = 'f7a1b4b9-17a9-89de-5059-f72779616f23'::uuid
  ) THEN
    RAISE EXCEPTION 'PITX Level 3 does not carry the canonical City of Paranaque jurisdiction mapping.';
  END IF;

  SELECT count(*) INTO active_count
  FROM discounts.statutory_discount_policy_versions
  WHERE jurisdiction_id = 'f7a1b4b9-17a9-89de-5059-f72779616f23'::uuid
    AND policy_code IN ('PH_PARANAQUE_SENIOR_FREE_PARKING', 'PH_PARANAQUE_PWD_FREE_PARKING')
    AND transaction_publication_status = 'ACTIVE_FOR_TRANSACTION_USE';

  IF active_count <> 2 THEN
    RAISE EXCEPTION 'Expected two current transaction-active Paranaque free-parking policies, found %.', active_count;
  END IF;

  SELECT count(*) INTO invalid_count
  FROM discounts.statutory_discount_policy_versions v
  WHERE v.policy_code IN ('PH_PARANAQUE_SENIOR_FREE_PARKING', 'PH_PARANAQUE_PWD_FREE_PARKING')
    AND (
      v.source_verification_status <> 'VERIFIED_ACTIVE_OPERATIONAL'
      OR v.transaction_publication_status <> 'ACTIVE_FOR_TRANSACTION_USE'
      OR v.parking_service_applicability <> 'COVERED'
      OR v.benefit_type <> 'FULL_FEE_EXEMPTION'
      OR v.policy_effect_support_status <> 'SUPPORTED_BY_CURRENT_CALCULATION'
      OR v.discount_base_scope <> 'NOT_APPLICABLE'
      OR v.beneficiary_residency_scope <> 'RESIDENT_ONLY'
      OR v.full_fee_exempt IS DISTINCT FROM true
      OR v.free_duration_minutes IS NOT NULL
      OR v.discount_percentage_basis_points IS NOT NULL
      OR v.official_source_available IS DISTINCT FROM false
      OR v.ordinance_text_available IS DISTINCT FROM false
      OR v.policy_scope_type <> 'JURISDICTION'
      OR v.site_id IS NOT NULL
      OR v.site_group_id IS NOT NULL
    );

  IF invalid_count <> 0 THEN
    RAISE EXCEPTION 'One or more Paranaque policy versions violate the approved canonical semantics.';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM discounts.statutory_discount_policy_registry
    WHERE statutory_discount_policy_registry_id = '0afacef1-5dd5-009d-32dd-e93a2ea8e4bb'::uuid
      AND policy_code = 'PH_PARANAQUE_SENIOR_FREE_PARKING'
  ) OR NOT EXISTS (
    SELECT 1
    FROM discounts.statutory_discount_policy_registry
    WHERE statutory_discount_policy_registry_id = 'd08bee33-972d-8214-c409-6e0ffef264d5'::uuid
      AND policy_code = 'PH_PARANAQUE_PWD_FREE_PARKING'
  ) OR NOT EXISTS (
    SELECT 1
    FROM discounts.statutory_discount_policy_versions
    WHERE statutory_discount_policy_version_id = '3a22b6e2-5433-9a8b-cc60-139cf2a89a8e'::uuid
      AND policy_code = 'PH_PARANAQUE_SENIOR_FREE_PARKING'
  ) OR NOT EXISTS (
    SELECT 1
    FROM discounts.statutory_discount_policy_versions
    WHERE statutory_discount_policy_version_id = '4c7c504c-6ac1-8e79-3f88-4fbeae06f00d'::uuid
      AND policy_code = 'PH_PARANAQUE_PWD_FREE_PARKING'
  ) THEN
    RAISE EXCEPTION 'Canonical Paranaque policy or version identity is inconsistent.';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM discounts.statutory_discount_policy_versions v
    JOIN discounts.statutory_discount_policy_version_evidence_requirements e
      ON e.statutory_discount_policy_version_id = v.statutory_discount_policy_version_id
    WHERE v.policy_code = 'PH_PARANAQUE_SENIOR_FREE_PARKING'
      AND v.entitlement_type = 'SENIOR_CITIZEN'
      AND e.evidence_type = 'SENIOR_CITIZEN_ID'
      AND e.requirement_status = 'REQUIRED'
      AND v.ordinance_number IS NULL
      AND v.legal_basis_reference IS NULL
  ) THEN
    RAISE EXCEPTION 'Canonical Paranaque Senior Citizen policy/evidence or no-fabricated-ordinance invariant failed.';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM discounts.statutory_discount_policy_versions v
    JOIN discounts.statutory_discount_policy_version_evidence_requirements e
      ON e.statutory_discount_policy_version_id = v.statutory_discount_policy_version_id
    WHERE v.policy_code = 'PH_PARANAQUE_PWD_FREE_PARKING'
      AND v.entitlement_type = 'PWD'
      AND e.evidence_type = 'PWD_ID'
      AND e.requirement_status = 'REQUIRED'
      AND v.ordinance_number = 'City Ordinance No. 48'
      AND v.legal_basis_reference = 'City Ordinance No. 48'
  ) THEN
    RAISE EXCEPTION 'Canonical Paranaque PWD policy/evidence/authority-reference invariant failed.';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM discounts.statutory_discount_policy_versions
    WHERE policy_code IN ('PH_PARANAQUE_SENIOR_FREE_PARKING', 'PH_PARANAQUE_PWD_FREE_PARKING')
    GROUP BY policy_code
    HAVING count(*) FILTER (WHERE transaction_publication_status = 'ACTIVE_FOR_TRANSACTION_USE') <> 1
  ) THEN
    RAISE EXCEPTION 'A Paranaque entitlement has other than one transaction-active canonical policy version.';
  END IF;

  WITH canonical_material AS (
    SELECT
      v.policy_semantic_hash,
      'policyCode=' || v.policy_code
      || '|policyVersion=' || v.policy_version
      || '|entitlementType=' || v.entitlement_type::text
      || '|jurisdictionId=' || v.jurisdiction_id::text
      || '|publication=' || v.transaction_publication_status::text
      || '|verification=' || v.source_verification_status::text
      || '|parking=' || v.parking_service_applicability::text
      || '|benefit=' || v.benefit_type::text
      || '|residency=' || v.beneficiary_residency_scope::text
      || '|discountBase=' || v.discount_base_scope::text
      || '|evidence=' || e.evidence_type::text
      || '|ordinance=' || COALESCE(v.ordinance_number, 'null')
      || '|fullFeeExempt=' || lower(v.full_fee_exempt::text)
      || '|freeDuration=' || COALESCE(v.free_duration_minutes::text, 'null')
      || '|discountPercent=' || COALESCE(v.discount_percentage_basis_points::text, 'null') AS material
    FROM discounts.statutory_discount_policy_versions v
    JOIN discounts.statutory_discount_policy_version_evidence_requirements e
      ON e.statutory_discount_policy_version_id = v.statutory_discount_policy_version_id
     AND e.requirement_status = 'REQUIRED'
    WHERE v.policy_code IN ('PH_PARANAQUE_SENIOR_FREE_PARKING', 'PH_PARANAQUE_PWD_FREE_PARKING')
  )
  SELECT count(*) INTO semantic_hash_mismatch_count
  FROM canonical_material
  WHERE policy_semantic_hash <> 'sha256:' || encode(digest(material, 'sha256'), 'hex');

  IF semantic_hash_mismatch_count <> 0 THEN
    RAISE EXCEPTION 'Paranaque policy semantic hash validation failed for % policy versions.', semantic_hash_mismatch_count;
  END IF;
END $$;

SELECT
  v.policy_code,
  v.policy_version,
  v.entitlement_type,
  v.benefit_type,
  v.beneficiary_residency_scope,
  v.parking_service_applicability,
  v.transaction_publication_status,
  v.source_verification_status,
  v.ordinance_number,
  e.evidence_type
FROM discounts.statutory_discount_policy_versions v
JOIN discounts.statutory_discount_policy_version_evidence_requirements e
  ON e.statutory_discount_policy_version_id = v.statutory_discount_policy_version_id
WHERE v.policy_code IN ('PH_PARANAQUE_SENIOR_FREE_PARKING', 'PH_PARANAQUE_PWD_FREE_PARKING')
ORDER BY v.policy_code;
