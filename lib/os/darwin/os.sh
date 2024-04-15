#!/bin/bash

# This lib includes common functions with specific syntax for darwin

# #1 folder name to be removed
remove_folder () {
    echo "rm -r ${1}"
}