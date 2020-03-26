
#!/usr/bin/env bash
# shellcheck source=./lib/install/init.sh
source "$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)/install/init.sh"
# shellcheck source=./lib/git/git.sh
source "$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)/git/git.sh"

function docker_installer() {
    if ! is_root; then
        log_error "needs root permission to run.exiting..."
        exit 1
    fi
    if [[ $# == 0 ]]; then
        log_error "No argument was passed to go_installer"
        exit 1
    fi
    local -r user="$1"
    local home="/home/$user"
    confirm_sudo
    local compose_version=$(get_latest_release_from_git "docker" "compose") 
    if [[ $# == 2 ]]; then
        compose_version="$2"
    fi
    log_info "started procedure for docker/docker-compose"
    log_info "adding docker apt repo key"
    if ! os_command_is_available "docker"; then
        add_key "https://download.docker.com/linux/$(get_distro_name)/gpg"
        add_repo "docker" "deb [arch=amd64] https://download.docker.com/linux/$(get_distro_name) $(get_debian_codename) stable"
    fi    
    local -r packages=("docker-ce" "docker-ce-cli" "containerd.io")
    fast_apt "install" "${packages[@]}"
    if os_command_is_available "docker"; then
        if [[  -n "${home+x}" ]]; then
            log_info "making docker directories"
            mkdir -p "$home/.docker"
            mkdir -p "$home/.local/share/applications/"
            mkdir -p "$home/.local/bin"
        fi
        if [[  -n "${user+x}" ]]; then
            log_info "adding docker image and transferring setting docker folder permission to ${user}"
            sudo newgrp docker
            sudo usermod -aG docker "$user"
            sudo chown "$user":"$user" "/$home/.docker" -R
            sudo chmod g+rwx "$home/.docker" -R
        fi
        if os_command_is_available "systemctl"; then
            log_info "enabling docker service"
            systemctl enable docker
        fi
    fi
    local -r url="https://github.com/docker/compose/releases/download/"$compose_version"/docker-compose-$(uname -s)-$(uname -m)"
    local -r compose_path="/usr/local/bin/docker-compose"
    log_info "installing docker-compose version $compose_version for ${user} with url $url"
    sudo curl \
        -L "$url" \
        -o "$compose_path" && \
    sudo chmod +x "$compose_path"
}
export -f docker_installer
