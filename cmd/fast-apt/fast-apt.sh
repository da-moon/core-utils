#!/usr/bin/env bash
# shellcheck source=./lib/install/init.sh
source "$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)lib/install/init.sh"

function fast_apt() {
    [ "$(whoami)" = root ] || exec sudo "$0" "$@"
    if echo "$@" | grep -q "upgrade\|install\|dist-upgrade"; then
        log_info "getting uris for $@"
        local -r download_list="/tmp/apt-fast.list"
        local -r uri=$(apt-get -y --print-uris $@ | grep -o -E "(ht|f)t(p|ps)://[^\']+")
        echo "${uri[@]}" >> "$download_list"
        pushd "/var/cache/apt/archives/" >/dev/null 2>&1
        downloader "$download_list"
        [[ "$?" != 0 ]] && popd
        popd >/dev/null 2>&1
        apt-get "$@" -y
        apt_cleanup
    else
        apt-get "$@"
    fi
}
function help() {
    echo
    echo "Usage: [$(basename "$0")] [OPTIONAL ARG] [COMMAND | COMMAND <FLAG> <ARG>]"
    echo
    echo
    echo -e "[Synopsis]:\twrapper around apt-get which uses aria2 to download packages"
    echo -e "\t\twhen running 'install' 'upgrade' and 'dist-upgrade'."
    echo -e "\t\tin other cases, it just passes the command to apt-get"
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
    echo "  sudo $(basename "$0") \\"
    echo "      install -q nano"
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
            log_info "initializing $(basename "$0")"
            init
            shift
            ;;
        --update)
            update
            shift
            ;;
        *)
            fast_apt "${@}"
            exit $?
            ;;
        esac
        shift
    done
}
if [ -n "${BASH_SOURCE+x}" ]; then
    main "${@}"
    exit $?
fi
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    export -f fast_apt
    main "${@}"
    exit $?
fi
