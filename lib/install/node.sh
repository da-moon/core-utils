#!/usr/bin/env bash
# shellcheck source=./lib/os/os.sh
source "$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)/os/os.sh"
# end of shared base
function node_installer() {
    confirm_sudo
    [ "$(whoami)" = root ] || exec sudo "$0" "$@"
    # script specific packages
    local -r packages=("nodejs" "yarn")
    local -r download_list="/tmp/apt-fast.list"
    log_info "running NodeSource Node.js 12.x installer script"
    curl -fsSL https://deb.nodesource.com/setup_12.x | sudo bash -
    log_info "adding yarn apt repo key"
    add_key "https://dl.yarnpkg.com/debian/pubkey.gpg"
    add_repo "yarn-nightly" "deb https://nightly.yarnpkg.com/debian/ nightly main"
    for pkg in "${packages[@]}"; do
        log_info "adding ${pkg} to install candidates"
        apt-get -y --print-uris install "$pkg" |
            grep -o -E "(ht|f)t(p|ps)://[^']+" >>"$download_list"
    done
    # End of scriptspecific packages
    if file_exists "$download_list"; then
        log_info "started downloading packages with aria2"
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
    if os_command_is_available "yarn"; then
        log_info "yarn has been installed.fixing environment vars"
        add_to_path '`yarn global bin`'
        add_to_path '${home}/.yarn/bin'
    fi
}
export -f node_installer
