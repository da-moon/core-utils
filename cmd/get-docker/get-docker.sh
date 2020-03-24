#!/usr/bin/env bash
# shellcheck source=./lib/install/init.sh
source "$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)lib/install/init.sh"
# shellcheck source=./lib/install/docker.sh
source "$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)lib/install/docker.sh"
# shellcheck source=./lib/git/git.sh
source "$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)lib/git/git.sh"

if [ -z "${BASH_SOURCE+x}" ]; then
    init
    compose_version=$(get_latest_release_from_git "docker" "compose") 
    log_info "started docker and docker-compose ${compose_version} installation"
    docker_installer "$compose_version"
    exit $?
else
    if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
        init
        compose_version=$(get_latest_release_from_git "docker" "compose") 
        log_info "started docker and docker-compose ${compose_version} installation"
        docker_installer "$compose_version"
        exit $?
    fi
fi
