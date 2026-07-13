-- Create enum type "user_status_enum"
CREATE TYPE "identity"."user_status_enum" AS ENUM ('INVITED', 'ACTIVE', 'LOCKED', 'SUSPENDED', 'INACTIVE', 'RETIRED');;

