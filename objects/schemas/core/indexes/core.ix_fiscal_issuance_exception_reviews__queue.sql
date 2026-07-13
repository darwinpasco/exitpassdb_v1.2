CREATE INDEX IF NOT EXISTS ix_fiscal_issuance_exception_reviews__queue
    ON core.fiscal_issuance_exception_reviews (review_status, exception_category, updated_at DESC);;

