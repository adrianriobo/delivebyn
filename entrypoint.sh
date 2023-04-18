#!/bin/bash

# Import libs
source remote.sh

# Debug
if [ "${DEBUG:-}" = "true" ]; then
    set -xuo 
fi

# Validate
if [[ ! remote_required ]] || [[ ! mamp_required ]] || [[ -z "${ASSETS_FOLDER+x}" ]]; then
    exit 1
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

# Copy results
if [[ ! -z "${TARGET_RESULTS+x}" ]]; then
    # If exec create some reuslts we define the env and they will be copied to OUTPUT_FOLDER
    OUTPUT_FOLDER="${OUTPUT_FOLDER:-"/output"}"
    $(scp_from_cmd "${TARGET_FOLDER}/${TARGET_RESULTS}" "${OUTPUT_FOLDER}/")
fi

if [ "${TARGET_CLENAUP:-}" = "true" ]; then
    $(ssh_cmd "rm -fr ${TARGET_FOLDER}")
fi