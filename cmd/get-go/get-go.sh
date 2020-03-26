#!/usr/bin/env bash
# shellcheck source=./lib/install/init.sh
source "$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)/lib/install/init.sh"
# shellcheck source=./lib/install/go.sh
source "$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)/lib/install/go.sh"
function help() {
    echo
    echo "Usage: [$(basename "$0")] [OPTIONAL ARG] [COMMAND | COMMAND <FLAG> <ARG>]"
    echo
    echo
    echo -e "[Synopsis]:\tdownloads and install lates version of go toolchain"
    echo -e "  --user\t\tuser to install go toolchain for"
    echo -e "\t\tgo folders will be created under '$${home}/go'"
    echo
    echo
    echo "Optional Flags:"
    echo
    echo -e "  --update\t\tupdates $(basename "$0") to the letest version at master branch."
    echo
    echo "Example:"
    echo
    echo "  sudo $(basename "$0") --user gitpod "
    echo
}
function update() {
    local -r url="https://raw.githubusercontent.com/da-moon/core-utils/master/bin/$(basename "$0")"
    local -r install_location=$(whereis "$(basename "$0")" | grep -E -o "$(basename "$0").*" | cut -f2- -d: | tr -s ' ' | cut -d ' ' -f2)
    log_info "updating $(basename "$0") located at $install_location"
    if [ ! -w "$install_location" ]; then
        log_info "needs sudo for updating file at $install_location"
        confirm_sudo
        [ "$(whoami)" = root ] || exec sudo "$0" "$@"
    fi
    log_info "removing old file at $install_location"
    rm "$install_location"
    log_info "downloading $url"
    wget -q -O "$install_location" "$url"
    log_info "setting $install_location as executable"
    chmod +x "$install_location"
}
function main() {
    if [[ $# == 0 ]]; then
        help
        exit
    fi
    local version=$(get_go_latest_version)
    local user
    while [[ $# -gt 0 ]]; do
        local key="$1"
        case "$key" in
        --user)
            if ! is_root; then
                log_error "needs root permission to run.exiting..."
                exit 1
            fi
            shift
            user="$1"
            ;;
        --version)
            if ! is_root; then
                log_error "needs root permission to run.exiting..."
                exit 1
            fi
            shift
            version="$1"
            ;;
        --update)
            update
            shift
            ;;
        *)
        if [ -z ${user+x} ]; then 
            help
            exit
         else
            init
            go_installer "${user}" "${version}"
            exit
        fi
            ;;
        esac
        shift
    done
}

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
