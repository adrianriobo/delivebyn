#!/bin/bash

# Import libs
source remote.sh

# Default values
TARGET_CLEANUP="${TARGET_CLEANUP:-"true"}"
CHECK_CONNECTION="${CHECK_CONNECTION:-"true"}"
CHECK_CONNECTION_ATTEMPTS=${CHECK_CONNECTION_ATTEMPTS:-30}
CHECK_CONNECTION_DELAY=${CHECK_CONNECTION_DELAY:-10}

# Debug
if [ "${DEBUG:-}" = "true" ]; then
    set -xuo 
fi

# Validate
if [[ ! remote_required ]] || [[ ! mamp_required ]] || [[ -z "${ASSETS_FOLDER+x}" ]]; then
    exit 1
fi

if [ "${CHECK_CONNECTION:-}" = "true" ]; then
    check_connection  ${CHECK_CONNECTION_ATTEMPTS} ${CHECK_CONNECTION_DELAY}
    if [[ $? -gt 0 ]]
    then
        exit 1
    fi
fi

# Create execution folder 
echo "Create assets folder on target"
TARGET_FOLDER="${TARGET_FOLDER:-"deliverest-${RANDOM}"}"
$(ssh_cmd "mkdir -p ${TARGET_FOLDER}")

# Copy asset
echo "Copy assets folder to target"
$(scp_to_cmd "${ASSETS_FOLDER}/*" "${TARGET_FOLDER}/")

# Exec command
$(ssh_cmd "$@")

# If remote workload includes a reboot this is the only way to ensure we can 
# copy results if any or cleanup
if [ "${CHECK_CONNECTION:-}" = "true" ]; then
    check_connection  ${CHECK_CONNECTION_ATTEMPTS} ${CHECK_CONNECTION_DELAY}
    if [[ $? -gt 0 ]]
    then
        exit 1
    fi
fi

# Copy results
if [[ ! -z "${TARGET_RESULTS+x}" ]]; then
    # If exec create some reuslts we define the env and they will be copied to OUTPUT_FOLDER
    OUTPUT_FOLDER="${OUTPUT_FOLDER:-"/output"}"
    $(scp_from_cmd "${TARGET_FOLDER}/${TARGET_RESULTS}" "${OUTPUT_FOLDER}/")
fi

if [ "${TARGET_CLEANUP:-}" = "true" ]; then
    $(ssh_cmd "rm -r ${TARGET_FOLDER}")
fi