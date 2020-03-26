#!/usr/bin/env bash
# shellcheck source=./lib/install/init.sh
source "$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)/install/init.sh"

function homebrew_installer() {
    if is_root; then
        log_error "homebrew installer must be invoked without root.exiting..."
        exit 1
    fi
    local -r url="https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh"
    log_info "started procedure for installing homebrew"
    pushd "$HOME" >/dev/null 2>&1
        mkdir -p $HOME/.cache && \
        log_info "running main script to install homebrew"
        sh -c "$(curl -fsSL $url)"
        # add_profile_env_var "MANPATH" '$MANPATH:/home/linuxbrew/.linuxbrew/share/man'
        # add_profile_env_var "INFOPATH" '$INFOPATH:/home/linuxbrew/.linuxbrew/share/info'
        add_to_path '/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin/'
        log_info "testing homebrew installation..."
        log_info "uninstalling cmake..."
        sudo apt-get remove -yqq cmake
        log_info "installing cmake with brew..."
        brew install cmake
        [[ "$?" != 0 ]] && popd
    popd >/dev/null 2>&1
}
export -f homebrew_installer