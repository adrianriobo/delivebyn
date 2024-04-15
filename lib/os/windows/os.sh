#!/bin/bash

# This lib includes common functions with specific syntax for windows

# #1 folder name to be removed
remove_folder () {
    echo "Remove-Item \"${1}\" -Recurse -Force"
}

