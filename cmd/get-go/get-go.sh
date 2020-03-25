#!/usr/bin/env bash
# shellcheck source=./lib/install/init.sh
source "$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)/lib/install/init.sh"
# shellcheck source=./lib/install/go.sh
source "$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)/lib/install/go.sh"

if [ -z "${BASH_SOURCE+x}" ]; then
    init
    version=$(get_go_latest_version) 
    log_info "started go toolchain ${version} installation"
    go_installer "$version"
    exit $?
else
    if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
        init
        version=$(get_go_latest_version) 
        log_info "started go toolchain ${version} installation"
        go_installer "$version"
        exit $?
    fi
fi
