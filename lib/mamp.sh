#!/bin/bash

# This lib includes common functions for handling
# asstes on multi architeture multi platform environments

# Validate required envs to remote 
mamp_required () {
    local validate=1

    [[ -z "${ARCH+x}" ]] \
        && echo "ARCH required" \
        && validate=0

    [[ -z "${OS+x}" ]] \
        && echo "OS required" \
        && validate=0

    return $validate
}
