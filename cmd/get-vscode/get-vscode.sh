#!/usr/bin/env bash
# shellcheck source=./lib/install/init.sh
source "$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)/lib/install/init.sh"
# shellcheck source=./lib/install/vscode.sh
source "$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)/lib/install/vscode.sh"

if [ -z "${BASH_SOURCE+x}" ]; then
    init
    vscode_installer
    vscode_extension_installer
    exit $?
else
    if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
        init
        vscode_installer
        vscode_extension_installer
        exit $?
    fi
fi
