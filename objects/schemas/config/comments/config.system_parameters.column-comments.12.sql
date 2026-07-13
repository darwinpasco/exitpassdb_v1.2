-- Set comment to column: "is_sensitive" on table: "system_parameters"
COMMENT ON COLUMN "config"."system_parameters"."is_sensitive" IS 'Indicates sensitive configuration metadata. Must not mean secret storage.';;

