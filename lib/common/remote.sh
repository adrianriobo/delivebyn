#!/bin/bash

# This lib includes common functions for handling
# remote connections

# Validate required envs to remote 
remote_required () {
    local validate=1

    [[ -z "${TARGET_HOST+x}" ]] \
        && echo "TARGET_HOST required" \
        && validate=0

    [[ -z "${TARGET_HOST_USERNAME+x}" ]] \
        && echo "TARGET_HOST_USERNAME required" \
        && validate=0

    [[ -z "${TARGET_HOST_KEY_PATH+x}" && -z "${TARGET_HOST_PASSWORD+x}" ]] \
        && echo "TARGET_HOST_KEY_PATH or TARGET_HOST_PASSWORD required" \
        && validate=0
    return $validate
}

# Define remote connect options
connect_options() {
    local options="-o StrictHostKeyChecking=no"
    options="$options -o UserKnownHostsFile=/dev/null"
    options="$options -o ServerAliveInterval=30"
    options="$options -o ServerAliveCountMax=1200"
    options="$options -o BatchMode=yes"
    options="$options -o ConnectTimeout=3"
    echo $options
}

ssh_config_file() {
    cat <<EOF > ssh_config
Host proxy_host
    StrictHostKeyChecking no
    HostName ${BASTION_HOST}
    User ${BASTION_HOST_USERNAME}
    IdentityFile ${BASTION_HOST_KEY_PATH}

Host target_host
    HostName ${TARGET_HOST}
    User ${TARGET_HOST_USERNAME}
    IdentityFile ${TARGET_HOST_KEY_PATH}
    ProxyJump proxy_host
EOF
    if [[ -z ${TARGET_HOST_KEY_PATH+x} ]]; then
        sed -i"" -e '9d' ssh_config
    fi
    if [[ -z ${BASTION_HOST_KEY_PATH+x} ]]; then
        sed -i"" -e '4d' ssh_config
    fi
    cat ssh_config
}

# If restart is involved, it can take a moment for the target host to become available again
# Check the connection to the host; "delay" in seconds, "repeats" in number of reps
# Run as: check_connection <repeats int> <delay int>
# e.g. check_connection 30 10
check_connection() {
    repeats=$1
    while [[ $repeats -gt 0 ]]
    do
        $(ssh_cmd "pwd")
        if [[ $? -gt 0 ]] 
        then
            echo "reps remaining: $repeats" >&2
            ((repeats--))
            sleep $2
        else
            break
        fi
    done
    # fail or pass the check
    if [[ $repeats -gt 0 ]]
    then
        return 0
    else
        return 1
    fi          
}

# Define remote connection
uri () {
    local remote="${TARGET_HOST_USERNAME}@${TARGET_HOST}"
    if [[ -n "${TARGET_HOST_DOMAIN}" ]]; then
        remote="${TARGET_HOST_USERNAME}@${TARGET_HOST_DOMAIN}@${TARGET_HOST}"
    fi
    echo "${remote}" 
}

# Generate SCP command
# $1 local path
# $2 remote path
scp_to_cmd () {
    cmd="scp -r $(connect_options) "
    if [[ -n "${BASTION_HOST}" && -n "${BASTION_HOST_USERNAME}" ]]; then
        echo "${cmd} -F ssh_config ${1} target_host:${2}"
    elif [[ -n "${TARGET_HOST_KEY_PATH}" ]]; then
        echo "${cmd} -i ${TARGET_HOST_KEY_PATH} ${1} $(uri):${2}"
    else
        echo "sshpass -p ${TARGET_HOST_PASSWORD} ${cmd} ${1} $(uri):${2}" 
    fi
}

# Generate SCP command
# $1 remote path
# $2 local path
scp_from_cmd () {
    cmd="scp -r $(connect_options) "
    if [[ -n "${BASTION_HOST}" && -n "${BASTION_HOST_USERNAME}" ]]; then
        echo "${cmd} -F ssh_config target_host:${1} ${2} "
    elif [[ -n "${TARGET_HOST_KEY_PATH}" ]]; then
        echo "${cmd} -i ${TARGET_HOST_KEY_PATH} $(uri):${1} ${2}"
    else
        echo "sshpass -p ${TARGET_HOST_PASSWORD} ${cmd} $(uri):${1} ${2}" 
    fi
}

# Generate SSH command
ssh_cmd () {
    cmd="ssh $(connect_options) "
    if [[ -n "${BASTION_HOST}" && -n "${BASTION_HOST_USERNAME}" ]]; then
        cmd+="-F ssh_config target_host "
    elif [[ -n "${TARGET_HOST_KEY_PATH}" ]]; then
        cmd+="-i ${TARGET_HOST_KEY_PATH} $(uri) "
    else
        cmd="sshpass -p ${TARGET_HOST_PASSWORD} ${cmd} $(uri) "
    fi
    
    # On AWS MacOS ssh session is not recognized as expected
    if [[ ${OS} == 'darwin' ]]; then
        cmd+="sudo su - ${TARGET_HOST_USERNAME} -c \"PATH=\$PATH:/usr/local/bin && $@\""
    else 
        cmd+=" $@"
    fi
    echo "${cmd}"
}