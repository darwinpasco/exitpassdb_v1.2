-- Create index "ix_hikcentral_gate_action_audits__vendor_system" to table: "hikcentral_gate_action_audits"
CREATE INDEX "ix_hikcentral_gate_action_audits__vendor_system" ON "gates"."hikcentral_gate_action_audits" ("vendor_system_id") WHERE ("vendor_system_id" IS NOT NULL);;
