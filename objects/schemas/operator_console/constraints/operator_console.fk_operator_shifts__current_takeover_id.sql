DO $$ BEGIN
    ALTER TABLE operator_console.operator_shifts
        ADD CONSTRAINT fk_operator_shifts__current_takeover_id
        FOREIGN KEY (current_takeover_id)
        REFERENCES operator_console.shift_takeovers(shift_takeover_id)
        DEFERRABLE INITIALLY IMMEDIATE;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;;

