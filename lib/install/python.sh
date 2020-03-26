#!/usr/bin/env bash


# shellcheck source=./lib/install/init.sh
source "$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)/install/init.sh"
[[ -n "${BASH_SOURCE+x}" ]] && [[ $0 != $BASH_SOURCE ]] && echo "sourced path:${BASH_SOURCE[0]}"

function python_installer() {
    if  os_command_is_available "pyenv"; then
        log_warn "pyenv has already been installed...skipping installation." 
    else
        log_info "pyenv not found. Installing ..." 
        curl -fsSL https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash 
        add_to_path '$HOME/.pyenv/bin'
        add_to_path '$HOME/.pyenv/shims'
        add_to_bashrc 'eval "$(pyenv init -)"'
        add_to_bashrc 'eval "$(pyenv virtualenv-init -)"'
        # exec $SHELL
    fi
    pyenv update
    if  os_command_is_available "python3"; then
        log_warn "python3 has already been installed...skipping installation." 
    else
        log_info "python3 not found. Installing ..." 
        pyenv install 3.7.7
        pyenv global 3.7.7
    fi
    if  os_command_is_available "python2"; then
        log_warn "python2 has already been installed...skipping installation." 
    else
        log_info "python2 not found. Installing ..." 
        pyenv install 2.7.17 
        pyenv global 2.7.17
    fi
    log_info "installing pip for python 2" 
    python2 -m pip install --upgrade pip
    log_info "installing pip for python 3" 
    python3 -m pip install --upgrade pip
    log_info "installing useful pip dependancies" 
    python3 -m pip \
            install --upgrade \
                    setuptools \
                    wheel \
                    virtualenv \
                    pipenv \
                    pylint \
                    rope \
                    flake8 \
                    mypy \
                    autopep8 \
                    pep8 \
                    pylama \
                    pydocstyle \
                    bandit \
                    notebook \
                    python-language-server[all]==0.25.0 \
                    twine
    rm -rf /tmp/*
}

export -f python_installer