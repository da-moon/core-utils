#!/usr/bin/env bash
# shellcheck source=./lib/install/init.sh
source "$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)/lib/install/init.sh"
# shellcheck source=./lib/install/vscode.sh
source "$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)/lib/install/vscode.sh"

function help() {
    echo
    echo "Usage: [$(basename "$0")] [OPTIONAL ARG] [COMMAND | COMMAND <FLAG> <ARG>]"
    echo
    echo
    echo -e "[Synopsis]:\tinstalls vscode"
    echo
    echo
    echo "Optional Flags:"
    echo
    echo -e "  --extensions\t\tinstalls useful extensions.Must be ran without sudo"
    echo -e "  --update\t\tupdates $(basename "$0") to the latest version at master branch."
    echo
    echo "Example:"
    echo
    echo "  sudo $(basename "$0") "
    echo
    echo "  $(basename "$0") --extensions "
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
   
    while [[ $# -gt 0 ]]; do
        local key="$1"

        case "$key" in
        --extensions)
            vscode_extension_installer
            shift
            ;;
        --update)
            update
            shift
            ;;
        --help)
            help
            exit
            ;;

        *)
            help
            exit
            ;;
        esac
        shift
    done
    init
    vscode_installer
}

if [ -z "${BASH_SOURCE+x}" ]; then
    main "${@}"
    exit $?
else
    if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
        main "${@}"
        exit $?
    fi
fi