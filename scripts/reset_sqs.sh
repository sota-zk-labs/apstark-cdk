#!/bin/bash -e

# Set the endpoint URL
ENDPOINT_URL="http://localhost:4566"

# Define an array of queue names
QUEUES=(
    "madara_orchestrator_snos_job_processing_queue"
    "madara_orchestrator_snos_job_verification_queue"
    "madara_orchestrator_proving_job_processing_queue"
    "madara_orchestrator_proving_job_verification_queue"
    "madara_orchestrator_data_submission_job_processing_queue"
    "madara_orchestrator_data_submission_job_verification_queue"
    "madara_orchestrator_update_state_job_processing_queue"
    "madara_orchestrator_update_state_job_verification_queue"
    "madara_orchestrator_job_handle_failure_queue"
    "madara_orchestrator_worker_trigger_queue"
)

# Loop through the queues and purge each one
echo "----------------------------"
for QUEUE in "${QUEUES[@]}"; do
    QUEUE_URL="${ENDPOINT_URL}/000000000000/${QUEUE}"
    echo "Purging queue: ${QUEUE}"
    aws --endpoint-url ${ENDPOINT_URL} sqs purge-queue --queue-url "${QUEUE_URL}"
    echo "Queue purged: ${QUEUE}"
done

# Loop through the queues and recreate each one
echo "----------------------------"
for QUEUE in "${QUEUES[@]}"; do
    echo "Creating queue: ${QUEUE}"
    aws --endpoint-url ${ENDPOINT_URL} sqs create-queue --queue-name "${QUEUE}"
done

echo "All queues have been created."