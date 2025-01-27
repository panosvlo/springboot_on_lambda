#bin/sh

set -e

# Build the database setup function
./mvnw clean package -f infrastructure/db-setup/pom.xml

# Build the unicorn application
./mvnw clean package -f software/unicorn-store-spring/pom.xml

# Deploy the infrastructure
cd infrastructure/cdk

export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)

cdk bootstrap
cdk deploy UnicornStoreInfrastructure --require-approval never --outputs-file target/output.json

# Execute the DB Setup function to create the table
aws lambda invoke --function-name $(cat target/output.json | jq -r '.UnicornStoreInfrastructure.DbSetupArn') /dev/stdout | cat;

cd -