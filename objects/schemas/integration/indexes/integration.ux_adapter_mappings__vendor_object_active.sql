-- Create index "ux_adapter_mappings__vendor_object_active" to table: "adapter_mappings"
CREATE UNIQUE INDEX "ux_adapter_mappings__vendor_object_active" ON "integration"."adapter_mappings" ("vendor_system_id", "mapping_type", "vendor_object_type", "vendor_object_ref") WHERE (mapping_status = 'ACTIVE'::integration.adapter_mapping_status_enum);;

