
#!/usr/bin/env bash
# shellcheck source=./lib/os/os.sh
source "$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)/os/os.sh"
# shellcheck source=./lib/git/git.sh
source "$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)/git/git.sh"

function docker_installer() {
    confirm_sudo
    [ "$(whoami)" = root ] || exec sudo "$0" "$@"
    local compose_version=$(get_latest_release_from_git "docker" "compose") 
    if [[ $# == 1 ]]; then
        compose_version="$1"
    fi
    log_info "started procedure for docker/docker-compose"
    log_info "adding docker apt repo key"
    add_key "https://download.docker.com/linux/$(get_distro_name)/gpg"
    add_repo "docker" "deb [arch=amd64] https://download.docker.com/linux/$(get_distro_name) $(get_debian_codename) stable"
    local -r packages=("docker-ce" "docker-ce-cli" "containerd.io")
    local -r download_list="/tmp/apt-fast.list"
    for pkg in "${packages[@]}"; do
        log_info "adding ${pkg} to install candidates"
        apt-get -y --print-uris install "$pkg" |
            grep -o -E "(ht|f)t(p|ps)://[^']+" >>"$download_list"
    done
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
    if os_command_is_available "docker"; then
        log_info "making docker directories"
        mkdir -p "$HOME/.docker"
        mkdir -p "$HOME/.local/share/applications/"
        mkdir -p "$HOME/.local/bin"
        log_info "adding docker image and transferring setting docker folder permission"
        

        if [[  -n "${USER+x}" ]]; then
                newgrp docker
                usermod -aG docker "$USER"
                chown "$USER":"$USER" "/home/$USER/.docker" -R
                chmod g+rwx "$HOME/.docker" -R
        fi
        if os_command_is_available "systemctl"; then
            log_info "enabling docker service"
            systemctl enable docker
        fi
    fi
    local -r url="https://github.com/docker/compose/releases/download/"$compose_version"/docker-compose-$(uname -s)-$(uname -m)"
    local -r compose_path="/usr/local/bin/docker-compose"
    log_info "installing docker-compose version $compose_version with url $url"
    curl \
        -L "$url" \
        -o "$compose_path" && \
    sudo chmod +x "$compose_path"
}
export -f docker_installer
