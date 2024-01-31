#!/bin/bash

# Exit immediately if any command exits with a non-zero status
set -e

# Prevents being loaded twice
if [[ -n $_INIT_SH_LOADED ]]; then
    exit 0
else
    export _INIT_SH_LOADED=1
fi

# Exit if it is not interactive. For example, bash test.sh is not interactive when calling bash to run the script
# The only mode that becomes interactive is the bash mode that waits for the user to enter a command
case "$-" in
*i*) ;;
*) exit 0 ;;
esac

echo "init.sh"

# Clear PATH and delete duplicate paths
# export PATH=$(echo $PATH | awk -v RS=':' '!a[$0]++ {if (NR>1) printf(":"); printf("%s", $0)}')
