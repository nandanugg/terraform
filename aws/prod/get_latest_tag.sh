#!/bin/bash

# Get all ECR repositories
repositories=$(aws ecr describe-repositories --query "repositories[*].repositoryName" --output json)

# Iterate through each repository
for repo in $(echo "$repositories" | jq -r '.[]'); do
  echo "Checking repository: $repo"  # Debugging output
  # List images and check for the latest tag
  tags=$(aws ecr list-images --repository-name "$repo" --filter "tagStatus=TAGGED" --query "imageIds[*].imageTag" --output json)
  if echo "$tags" | jq -r '.[]' | grep -q 'latest'; then
    echo "$repo"
  fi
done
