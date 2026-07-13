-- Create enum type "event_broker_type_enum"
CREATE TYPE "events"."event_broker_type_enum" AS ENUM ('RABBITMQ', 'KAFKA', 'AZURE_SERVICE_BUS', 'AWS_SNS_SQS', 'WEBHOOK', 'IN_PROCESS', 'OTHER');;

