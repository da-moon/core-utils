#!/usr/bin/env bash
# shellcheck source=./lib/install/init.sh
source "$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)/install/init.sh"
function ffmpeg_installer() {
    confirm_sudo
    [ "$(whoami)" = root ] || exec sudo "$0" "$@"
    local -r packages=("mkvtoolnix" "ffmpeg")
    local -r download_list="/tmp/apt-fast.list"
    log_info "adding mkvtoolnix apt repo key"
    add_key "https://mkvtoolnix.download/gpg-pub-moritzbunkus.txt"
    add_repo "mkvtoolnix" "deb https://mkvtoolnix.download/$(get_distro_name)/ $(get_debian_codename) main"
    fast_apt "install" "${packages[@]}"
    if os_command_is_available "npm"; then
        if ! os_command_is_available "ffmpeg-bar"; then
            log_info "install ffmpeg-progress-bar ..."
            npm install --global ffmpeg-progressbar-cli
        else
            log_info "ffmpeg-progress-bar already installed.skipping ..."
        fi
    fi
}
export -f ffmpeg_installer
