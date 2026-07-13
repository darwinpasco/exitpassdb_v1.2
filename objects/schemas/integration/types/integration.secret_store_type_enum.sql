-- Create enum type "secret_store_type_enum"
CREATE TYPE "integration"."secret_store_type_enum" AS ENUM ('KEY_VAULT', 'SECRETS_MANAGER', 'CERTIFICATE_STORE', 'HSM', 'ENVIRONMENT_REFERENCE', 'OTHER');;

