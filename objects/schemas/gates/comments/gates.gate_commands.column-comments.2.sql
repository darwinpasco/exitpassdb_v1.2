-- Set comment to column: "source_processing_id" on table: "gate_commands"
COMMENT ON COLUMN "gates"."gate_commands"."source_processing_id" IS 'Consumed-processing inbox row that produced this command intent.';;
