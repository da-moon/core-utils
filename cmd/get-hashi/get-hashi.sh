#!/usr/bin/env bash
# shellcheck source=./lib/install/init.sh
source "$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)lib/install/init.sh"
# shellcheck source=./lib/extract/extract.sh
source "$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)lib/extract/extract.sh"

function get_hashi_latest_version() {
    if [[ $# != 1 ]]; then
        echo
        echo "desc : gets latest version of a hashicorp software"
        echo
        echo "method usage: get_hashi_latest_version [software name]"
        echo
        exit 1
    fi
    assert_not_empty "get_hashi_latest_version" "$1" "user input is needed"
    local -r reply=$(curl -sL "https://releases.hashicorp.com/${1}/index.json")
    local -r versions=$(echo "$reply" | jq -r '.versions[].version')
    local -r sorted=$(echo "$versions" | sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n)
    local -r trimmed=$(echo "$sorted" | grep -E -v 'ent|rc|beta')
    local -r latest=$(echo "$trimmed" | tail -1)
    echo "$latest"
}
function get_hashi() {
    if [[ $# == 0 ]]; then
        echo
        echo "desc : downloads and installs lastes hashicorp software"
        echo
        echo "method usage: get_hashi [list of software name]"
        echo
        exit 1
    fi
    [ "$(whoami)" = root ] || exec sudo "$0" "$@"
    local -r packages=("$@")
    local -r download_list="/tmp/hashistack.list"
    rm -f "${download_list}"
    for name in "${packages[@]}"; do
        log_info "adding ${name}"
        rm -f "/tmp/${name}"*
        local version
        local url
        version=$(get_hashi_latest_version "${name}")
        log_info "adding ${name} version ${version} to download-list ${download_list}"
        url="https://releases.hashicorp.com/${name}/${version}/${name}_${version}_linux_amd64.zip"
        echo "${url}" >>"${download_list}"
        echo " out=${name}.zip" >>"${download_list}"
    done
    if file_exists "${download_list}"; then
        pushd "/tmp/" >/dev/null 2>&1
        downloader "$download_list"
        [[ "$?" != 0 ]] && popd
        popd >/dev/null 2>&1
    fi

    local -r install_dir="/usr/bin/"
    for name in "${packages[@]}"; do
        extract "/tmp/${name}.zip" "$install_dir"
        mkdir -p "/etc/${name}/" "/var/${name}/"
        mkdir -p "/etc/${name}/" "/var/${name}/"
        chmod -R 0600 "/etc/${name}/" "/var/${name}/"
        chmod 0750 "/usr/bin/${name}"
        # fails gitpod build
        # chown "${USER}:${USER}" "/usr/bin/${name}"
        if [[ "$name" == "vault" ]]; then
            setcap cap_ipc_lock=+ep /usr/bin/vault
        fi
        chmod +x "${install_dir}/${name}"
        rm "/tmp/${name}.zip"
        # confirming install was successful
        # breaks gitpod build at the moment
        # $name --version >/dev/null
    done
}
if [ -n ${BASH_SOURCE+x} ]; then
    install_deps
    stack=("vault" "consul" "nomad" "terraform" "packer")
    if [[ "$#" != 0 ]]; then
        stack=("${@}")
    fi
    log_info "install targets ${stack[*]}"
    get_hashi "${stack[@]}"
    exit $?
fi
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    install_deps
    stack=("vault" "consul" "nomad" "terraform" "packer")
    if [[ "$#" != 0 ]]; then
        stack=("${@}")
    fi
    log_info "install targets ${stack[*]}"
    get_hashi "${stack[@]}"
    exit $?
fi
