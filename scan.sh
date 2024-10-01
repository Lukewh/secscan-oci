#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage $0 /path/to/project"
    echo ""
    exit 1
fi

PROJECT_PATH="${1}"
PROJECT=(${PROJECT_PATH//// })
PROJECT=${PROJECT[-1]}
OUTPUT="${PROJECT_PATH}/${PROJECT}.tar"

echo "Building image"
docker build --tag "webteam:${PROJECT}" "${PROJECT_PATH}"
echo "Saving OCI image to ${OUTPUT}" 
docker save -o "${OUTPUT}" "webteam:${PROJECT}"

echo "Submitting OCI image to secscan-client"
secscan-client submit --scanner blackduck --type container-image --format oci "${OUTPUT}" --token "${PROJECT_PATH}/${PROJECT}.token"

echo "To check on the status of the request you can use the following command:"
echo "  secscan-client status --token ${PROJECT_PATH}/${PROJECT}.token"
echo ""
echo "Thanks <3"
