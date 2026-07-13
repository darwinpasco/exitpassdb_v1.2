-- Create "create_or_reuse_payment_attempt" function
CREATE FUNCTION "core"."create_or_reuse_payment_attempt" () RETURNS void LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'core.create_or_reuse_payment_attempt is a v1.2 routine placeholder and must be implemented before production use'; END; $$;;

