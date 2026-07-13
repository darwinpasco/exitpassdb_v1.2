-- Create "issue_exit_authorization" function
CREATE FUNCTION "core"."issue_exit_authorization" () RETURNS void LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'core.issue_exit_authorization is a v1.2 routine placeholder and must be implemented before production use'; END; $$;;

