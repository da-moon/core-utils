#!/usr/bin/env bash

[[ -n "${BASH_SOURCE+x}" ]] && [[ $0 != $BASH_SOURCE ]] && echo "sourced path:${BASH_SOURCE[0]}"

# shellcheck source=./lib/install/init.sh
source "$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)/lib/install/init.sh"
# shellcheck source=./lib/install/java.sh
source "$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)/lib/install/java.sh"

if [ -z "${BASH_SOURCE+x}" ]; then
    # init
    java_installer
    exit $?
else
    if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
        # init
        java_installer
        exit $?
    fi
fi
