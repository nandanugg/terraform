#!/bin/bash

# Define the cluster name
cluster_name="projectsprint"

# Get a list of all task definitions
task_defs=$(aws ecs list-task-definitions --query "taskDefinitionArns[]" --output text)

# Loop through each task definition
for task_def in $task_defs; do
    # Extract the base name of the task definition, ignoring the version number
    task_def_base=$(echo "$task_def" | sed 's/:[^:]*$//')

    # Get full details of the task definition
    task_details=$(aws ecs describe-task-definition --task-definition $task_def)
    out_of_spec_reasons=()

    # Extract needed properties and check conditions
    os=$(echo "$task_details" | jq -r '.taskDefinition.runtimePlatform.operatingSystem // empty')
    cpu=$(echo "$task_details" | jq -r '.taskDefinition.cpu // empty')
    memory=$(echo "$task_details" | jq -r '.taskDefinition.memory // empty')

    if [[ $os != "LINUX" ]]; then
        out_of_spec_reasons+=("Task Definition $task_def has an unusual OS: $os")
    fi
    if [[ $cpu -gt 256 ]]; then
        out_of_spec_reasons+=("Task Definition $task_def has high CPU allocation: $cpu units")
    fi
    if [[ $memory -gt 512 ]]; then
        out_of_spec_reasons+=("Task Definition $task_def has high memory allocation: $memory MiB")
    fi

    # If any out of spec reasons, handle dependencies and deregister
    if [ ${#out_of_spec_reasons[@]} -ne 0 ]; then
        echo "Task Definition $task_def is out of spec for the following reasons:"
        printf '%s\n' "${out_of_spec_reasons[@]}"

        # Find and stop services using this task definition
        services=$(aws ecs list-services --cluster $cluster_name --query "serviceArns[]" --output text)
        for service in $services; do
            service_detail=$(aws ecs describe-services --cluster $cluster_name --services $service --query "services[0]")
            service_task_def=$(echo "$service_detail" | jq -r '.taskDefinition')

            if [[ "$service_task_def" == "$task_def" ]]; then
                echo "Service $service uses this out of spec task definition. Stopping and deregistering service..."
                aws ecs update-service --cluster $cluster_name --service $service --desired-count 0
                aws ecs delete-service --cluster $cluster_name --service $service --force 2>/dev/null
            fi
        done

        # Check for log groups and delete if set
        if echo "$task_details" | jq -e '.taskDefinition.containerDefinitions[].logConfiguration' >/dev/null; then
            log_group_name=$(echo "$task_details" | jq -r '.taskDefinition.containerDefinitions[].logConfiguration.options.group // empty')
            if [[ -n $log_group_name ]]; then
                echo "Deleting associated log group $log_group_name"
                aws logs delete-log-group --log-group-name $log_group_name 2>/dev/null
            fi
        fi

        # Deregister the task definition
        echo "Deregistering task definition $task_def"
        aws ecs deregister-task-definition --task-definition $task_def 2>/dev/null
    fi
done
