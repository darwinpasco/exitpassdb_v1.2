-- Create index "ix_hikcentral_gate_action_audits__consumption" to table: "hikcentral_gate_action_audits"
CREATE INDEX "ix_hikcentral_gate_action_audits__consumption" ON "gates"."hikcentral_gate_action_audits" ("gate_authorization_consumption_id");;
