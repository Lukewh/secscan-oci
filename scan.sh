#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage $0 /path/to/project"
    echo ""
    exit 1
fi

SECSCAN=$(which secscan-client)
DOCKER=$(which docker)
PROJECT_PATH="${1}"
PROJECT=(${PROJECT_PATH//// })
PROJECT=${PROJECT[-1]}
OUTPUT="${PROJECT_PATH}/${PROJECT}.tar"

if [ -z $SECSCAN ]; then
    echo "secscan-client not found. You can install it with:"
    echo "  snap install canonical-secscan-client"
    echo ""
    echo "Once installed connect your home directory:"
    echo "  snap connect canonical-secscan-client:home"
    echo ""
    echo "Now you can run this script again <3"
    echo ""
    exit 1
fi

if [ -z $DOCKER ]; then
    echo "Docker not found. Please install and set up Docker"
    echo "then run this script again."
    exit 1
fi

step_header () {
    echo "> Step ${1} <"
    echo "----"
    echo ""
}

step_1_build () {
    step_header "1: Build docker image"
    
    docker build --tag "webteam:${1}" "${2}"
}

step_2_OCI () {
    step_header "2: Saving OCI image to ${1}"

    docker save -o "${1}" "webteam:${2}"
}

step_3_submit () {
    step_header "3: Submitting OCI image via secscan-client"

    secscan-client submit --scanner blackduck --type container-image --format oci "${1}" --token "${2}/${3}.token"
}

echo "========================"
echo "== All deps satisfied =="
echo "========================"
echo ""

step_1_build ${PROJECT} ${PROJECT_PATH}

step_2_OCI ${OUTPUT} ${PROJECT}

step_3_submit ${OUTPUT} ${PROJECT_PATH} ${PROJECT}

echo "To check on the status of the request you can use the following command:"
echo "  secscan-client status --token ${PROJECT_PATH}/${PROJECT}.token"
echo ""
echo "Thanks <3"

