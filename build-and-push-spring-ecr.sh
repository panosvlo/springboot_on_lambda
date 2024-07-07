#!/bin/bash

# Variables
REPOSITORY_NAME=unicorn-store-repo
IMAGE_NAME=unicorn-store-image

#cd to the directory
cd software/unicorn-store-spring

# Build the application
../../mvnw clean package -DskipTests

# Get the account id and region
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(aws configure get region)

# Create the ECR repository if it doesn't exist
aws ecr describe-repositories --repository-names ${REPOSITORY_NAME} > /dev/null 2>&1
if [ $? -ne 0 ]; then
    aws ecr create-repository --repository-name ${REPOSITORY_NAME} > /dev/null
fi

# Authenticate Docker to the Amazon ECR registry
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

# Build the Docker image
docker build -t ${IMAGE_NAME} .

# Tag the Docker image
docker tag ${IMAGE_NAME}:latest ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPOSITORY_NAME}:latest

# Push the Docker image to ECR
docker push ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPOSITORY_NAME}:latest

cd -
