#!/bin/bash

# Import libs
source /usr/local/bin/remote.sh
source /usr/local/bin/${OS}/os.sh

# Default values
TARGET_CLEANUP="${TARGET_CLEANUP:-"true"}"
CHECK_CONNECTION="${CHECK_CONNECTION:-"true"}"
CHECK_CONNECTION_ATTEMPTS=${CHECK_CONNECTION_ATTEMPTS:-30}
CHECK_CONNECTION_DELAY=${CHECK_CONNECTION_DELAY:-10}
SSH_CMD_ATTEMPTS=${SSH_CMD_ATTEMPTS:-5}
SSH_CMD_DELAY=${SSH_CMD_DELAY:-5}

# Debug
if [ "${DEBUG:-}" = "true" ]; then
    set -xuo 
fi

# Validate
if [[ ! remote_required ]] || [[ ! mamp_required ]] || [[ -z "${ASSETS_FOLDER+x}" ]]; then
    exit 1
fi

# Create ssh config file is using proxy connection
if [[ -n "${BASTION_HOST+x}" && -n "${BASTION_HOST_USERNAME+x}" ]];then
    ssh_config_file
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
mkdir_cmd="$(ssh_cmd mkdir -p ${TARGET_FOLDER})"
exec_and_retry ${SSH_CMD_ATTEMPTS} ${SSH_CMD_DELAY} ${mkdir_cmd}

# Copy asset
echo "Copy assets folder to target"
scp_cmd="$(scp_to_cmd "${ASSETS_FOLDER}/*" "${TARGET_FOLDER}/")"
exec_and_retry ${SSH_CMD_ATTEMPTS} ${SSH_CMD_DELAY} ${scp_cmd}

# Exec command
exec_and_retry ${SSH_CMD_ATTEMPTS} ${SSH_CMD_DELAY} "$(ssh_cmd $@)"

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
    scp_cmd="$(scp_from_cmd "${TARGET_FOLDER}/${TARGET_RESULTS}" "${OUTPUT_FOLDER}/")"
    exec_and_retry ${SSH_CMD_ATTEMPTS} ${SSH_CMD_DELAY} ${scp_cmd}
fi

if [ "${TARGET_CLEANUP:-}" = "true" ]; then
    # This will create the cmd based on OS env with the right syntax
    cmd="$(remove_folder ${TARGET_FOLDER})"
    exec_and_retry ${SSH_CMD_ATTEMPTS} ${SSH_CMD_DELAY} "$(ssh_cmd $cmd)"
fi