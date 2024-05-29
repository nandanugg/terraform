#!/usr/bin/env zsh

cluster_name="projectsprint"

# Retrieve and format service ARNs
echo "Retrieving services from cluster $cluster_name..."
service_arns=$(aws ecs list-services --cluster $cluster_name --query "serviceArns[]" --output text | tr '\t' '\n')

if [[ -z "$service_arns" ]]; then
    echo "No services found in the cluster."
    exit 1
fi

typeset -A service_to_remove

# Process each service ARN
for service_arn in ${(f)service_arns}; do
    # Ensure ARN does not have surrounding whitespace
    service_arn=$(echo "$service_arn" | xargs)

    # Describe the service using its ARN
    service_details=$(aws ecs describe-services --cluster $cluster_name --services "$service_arn" --query "services[0]")
    
    if [[ $? -ne 0 ]]; then
        echo "Failed to retrieve details for service ARN: $service_arn"
        continue
    fi

    service_name=$(echo "$service_details" | jq -r '.serviceName')
    out_of_spec_reasons=()

    # Check service name suffix
    if ! [[ $service_name =~ (-db-service|-service)$ ]]; then
        out_of_spec_reasons+=("Service $service_name has an invalid suffix.")
    fi

    # Check capacity provider
    capacity_provider=$(echo "$service_details" | jq -r '.capacityProviderStrategy[]?.capacityProvider // empty')
    if [[ $capacity_provider != "FARGATE_SPOT" ]]; then
        out_of_spec_reasons+=("Service $service_name is not using FARGATE_SPOT as its capacity provider.")
    fi

    # Check security groups
    sg_ids=$(echo "$service_details" | jq -r '.networkConfiguration.awsvpcConfiguration.securityGroups[] // empty')
    if ! [[ $sg_ids =~ "sg-0c2e16736403cd30e" || $sg_ids =~ "sg-096465013d3eedf65" ]]; then
        out_of_spec_reasons+=("Service $service_name uses non-standard security groups: $sg_ids")
    fi

    # Check public IP setting
    assign_public_ip=$(echo "$service_details" | jq -r '.networkConfiguration.awsvpcConfiguration.assignPublicIp // "DISABLED"')
    if [[ $assign_public_ip != "ENABLED" ]]; then
        out_of_spec_reasons+=("Service $service_name has Public IP turned off.")
    fi

    # If out of spec, mark for removal
    if [ ${#out_of_spec_reasons[@]} -ne 0 ]; then
        echo "Service $service_name is out of spec for the following reasons:"
        printf '%s\n' "${out_of_spec_reasons[@]}"
        service_to_remove[$service_arn]=$service_name
    fi
done

# Removing resources, ensuring order of removal
echo "Removing out-of-spec services..."
for service_arn in ${(k)service_to_remove}; do
    echo "Removing service: $service_to_remove[$service_arn]"
    aws ecs delete-service --cluster $cluster_name --service $service_arn --force 2>/dev/null
done

echo "Cleanup complete."
