COMMENT ON FUNCTION discounts.apply_statutory_discount_payable_basis(uuid, uuid, uuid) IS
    'Finalizes a REQUESTED statutory discount payable-basis application by superseding the original active tariff snapshot, creating one statutory-adjusted ACTIVE tariff snapshot, and marking the application APPLIED. The routine does not create payment, provider, gate, coupon, reconciliation, or AUB records.';;

