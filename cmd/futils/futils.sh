#!/usr/bin/bash
# shellcheck source=./lib/install/init.sh
source "$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)lib/install/init.sh"
# shellcheck source=./lib/file/file.sh
source "$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)lib/file/file.sh"

function help() {
    echo
    echo "Usage: [$(basename "$0")] [OPTIONAL FLAG] [COMMAND | COMMAND <FLAG> <ARG>]"
    echo
    echo
    echo -e "[Synopsis]:\ta collection of file/folder operation helpers"
    echo
    echo -e "  r-md5\t\t\tRecursively generate md5 hashes in target dirs ."
    echo -e "  [flag|optional]\t--dupes \tonly list duplicates.[DEFAULT: 'false']"
    echo -e "  [flag|optional]\t--output <arg> \tTarget to store the list in.[DEFAULT: 'mdsums.list']"
    echo -e "  [flag(s)|optional]\t--dir <arg> \tDirectories to search.[DEFAULT: '$PWD']"
    echo
    echo -e "  dedup\t\t\tRecursively finds duplicate files in directory by comparing them"
    echo -e "\t\t\twith files in an origin directory ."
    echo -e "  \t\t\tIt does not delete duplicates in origin directory"
    echo -e "  [flag|optional]\t--output <arg> \tTarget to store the list of deleted files in."
    echo -e "  [flag]\t\t--origin <arg> \torigin directory."
    echo -e "  [flag(s)]\t\t--target <arg> \tdirectories to be deduplicated."
    echo
    echo
    echo "Optional Flags:"
    echo
    echo -e "  --init\t\tinitializes and installs dependancies for $(basename "$0")"
    echo -e "  --update\t\tupdates $(basename "$0") to the letest version at master branch."
    echo
    echo "Example:"
    echo
    echo "  sudo $(basename "$0") --init "
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
    while [[ $# -gt 0 ]]; do
        local key="$1"

        case "$key" in
        --init)
            log_info "initializing futils"
            init
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
            log_error "Unrecognized option: $key"
            echo -e "\t\t\t\tRun '$(basename "$0") --help' for a list of known subcommands." >&2
            exit 1
            ;;
        esac
        shift
    done
}
if [ -n ${BASH_SOURCE+x} ]; then
    main "${@}"
    exit $?
fi
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
else
    main "${@}"
    exit $?
fi
