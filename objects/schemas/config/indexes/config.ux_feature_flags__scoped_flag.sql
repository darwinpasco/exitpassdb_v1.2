-- Create index "ux_feature_flags__scoped_flag" to table: "feature_flags"
CREATE UNIQUE INDEX "ux_feature_flags__scoped_flag" ON "config"."feature_flags" ("flag_code", "environment_code", (COALESCE(site_group_id, '00000000-0000-0000-0000-000000000000'::uuid)), (COALESCE(site_id, '00000000-0000-0000-0000-000000000000'::uuid)), (COALESCE(merchant_id, '00000000-0000-0000-0000-000000000000'::uuid)), (COALESCE(payment_rail_id, '00000000-0000-0000-0000-000000000000'::uuid)), (COALESCE(service_identity_id, '00000000-0000-0000-0000-000000000000'::uuid)));;

