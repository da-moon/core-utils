
#!/usr/bin/env bash
# shellcheck source=./lib/install/init.sh
source "$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)/install/init.sh"
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
    if ! os_command_is_available "docker"; then
        add_key "https://download.docker.com/linux/$(get_distro_name)/gpg"
        add_repo "docker" "deb [arch=amd64] https://download.docker.com/linux/$(get_distro_name) $(get_debian_codename) stable"
    fi    
    local -r packages=("docker-ce" "docker-ce-cli" "containerd.io")
    fast_apt "install" "${packages[@]}"
    if os_command_is_available "docker"; then
        if [[  -n "${HOME+x}" ]]; then
            log_info "making docker directories"
            mkdir -p "$HOME/.docker"
            mkdir -p "$HOME/.local/share/applications/"
            mkdir -p "$HOME/.local/bin"
        fi
        if [[  -n "${USER+x}" ]]; then
            log_info "adding docker image and transferring setting docker folder permission"
            newgrp docker
            usermod -aG docker "$USER"
            chown "$USER":"$USER" "/$HOME/.docker" -R
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
    chmod +x "$compose_path"
}
export -f docker_installer
