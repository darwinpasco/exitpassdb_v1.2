-- Set comment to column: "status" on table: "statutory_discount_policy_import_review_submissions"
COMMENT ON COLUMN "discounts"."statutory_discount_policy_import_review_submissions"."status" IS 'Maker/checker review state. Final approval means DB repo alignment only, not production activation.';;

