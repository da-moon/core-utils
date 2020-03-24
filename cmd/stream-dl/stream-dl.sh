#!/usr/bin/env bash
# shellcheck source=./lib/install/init.sh
source "$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)lib/install/init.sh"
# shellcheck source=./lib/install/node.sh
source "$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)lib/install/node.sh"
# shellcheck source=./lib/install/ffmpeg.sh
source "$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)lib/install/ffmpeg.sh"

function m3u8_downloader() {
    local -r playlist_file="index.m3u8"
    local -r download_list="linx"
    local -r chunks_dir="/tmp/stream-dl-chunks"
    local -r name="$1"
    local -r url="$2"
    local -r stream_root=${url%/*}
    mkdir -p "${chunks_dir}/${name}"
    pushd "${chunks_dir}/${name}" >/dev/null 2>&1
    if file_exists "$download_list"; then
        rm "$download_list"
    fi
    if file_exists "${playlist_file}"; then
        rm "${playlist_file}"
    fi
    wget -qnc "${url}" -O "${playlist_file}"
    for i in $(grep -Ev '#EXT' ${playlist_file}); do
        echo "${stream_root}/${i}" >>"$download_list"
    done
    if file_exists "$download_list"; then
        downloader "$download_list"
    fi
    [[ "$?" != 0 ]] && popd
    popd >/dev/null 2>&1
    if file_exists "${chunks_dir}/${name}/${playlist_file}"; then
        ffmpeg-bar -nostdin -allowed_extensions ALL -i "${chunks_dir}/${name}/${playlist_file}" -c copy "${name}.mkv"
        rm -rf "${chunks_dir}/${name}"
    fi

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
function help() {
    echo
    echo "Usage: [$(basename "$0")] [OPTIONAL ARG] [COMMAND | COMMAND <FLAG> <ARG>]"
    echo
    echo
    echo -e "[Synopsis]:\tuses aria2 to download m3u8 streams and converts them to mkv with ffmpeg"
    echo
    echo -e "[hint]:\t\tuse the following to read playlist links from file in which"
    echo -e "\t\t| is used as seperator; i.e. {URL}|{name}.do not put extention in name."
    echo -e "\t\tdo not keep file extention in name."
    echo
    echo -e "while IFS='|' read -r url name;do $(basename "$0") \"\$name\" \"\$url\"< /dev/null ; done <linx"
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
    echo "  $(basename "$0") \\"
    echo "      \${name} \\"
    echo "      \${link} "
    echo
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
            node_installer
            ffmpeg_installer
            shift
            ;;
        --update)
            update
            shift
            ;;
        *)
            m3u8_downloader "${@}"
            exit $?
            ;;
        esac
        shift
    done
}

if [ -n ${BASH_SOURCE+x} ]; then
    main "${@}"
    exit $?
fi
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "${@}"
    exit $?
fi
