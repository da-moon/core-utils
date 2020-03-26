#!/usr/bin/env bash

[[ -n "${BASH_SOURCE+x}" ]] && [[ $0 != $BASH_SOURCE ]] && echo "sourced path:${BASH_SOURCE[0]}"

# shellcheck source=./lib/install/init.sh
source "$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)/lib/install/init.sh"
# shellcheck source=./lib/install/cpp.sh
source "$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)/lib/install/cpp.sh"

if [ -z "${BASH_SOURCE+x}" ]; then
    if ! is_root; then
        log_error "needs root permission to run.exiting..."
        exit 1
    fi

    init
    vscode_installer
    vscode_extension_installer
    exit $?
else
    if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
        if ! is_root; then
            log_error "needs root permission to run.exiting..."
            exit 1
        fi
        init
        vscode_installer
        vscode_extension_installer
        exit $?
    fi
fi
