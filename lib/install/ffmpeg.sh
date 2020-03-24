#!/usr/bin/env bash
# shellcheck source=./lib/os/os.sh
source "$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)/os/os.sh"
function ffmpeg_installer() {
    confirm_sudo
    [ "$(whoami)" = root ] || exec sudo "$0" "$@"
    local -r packages=("mkvtoolnix" "ffmpeg")
    local -r download_list="/tmp/apt-fast.list"
    log_info "adding mkvtoolnix apt repo key"
    add_key "https://mkvtoolnix.download/gpg-pub-moritzbunkus.txt"
    add_repo "mkvtoolnix" "deb https://mkvtoolnix.download/debian/ buster main"
    for pkg in "${packages[@]}"; do
        log_info "adding ${pkg} to install candidates"
        apt-get -y --print-uris install "$pkg" |
            grep -o -E "(ht|f)t(p|ps)://[^']+" >>"$download_list"
    done
    # End of scriptspecific packages
    if file_exists "$download_list"; then
        pushd "/var/cache/apt/archives/" >/dev/null 2>&1
        downloader "$download_list"
        [[ "$?" != 0 ]] && popd
        popd >/dev/null 2>&1
        for pkg in "${packages[@]}"; do
            log_info "installing $pkg"
            sudo apt-get install -yqq "$pkg"
        done
        apt_cleanup
    fi
    if os_command_is_available "npm"; then
        log_info "install ffmpeg-progress-bar ..."
        npm install --global ffmpeg-progressbar-cli
    fi
}
export -f ffmpeg_installer
