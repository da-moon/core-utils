#!/usr/bin/env bash
# shellcheck source=./lib/install/init.sh
source "$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)/install/init.sh"
# shellcheck source=./lib/extract/extract.sh
source "$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)/extract/extract.sh"

function get_go_latest_version() {
    local -r reply=$(curl -sL https://golang.org/dl/?mode=json)
    local -r versions=$(echo "$reply" | jq -r '.[].version')
    local -r sorted=$(echo "$versions" | sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n)
    local -r trimmed=$(echo "$sorted" | egrep -v 'beta')
    local -r latest=$(echo "$trimmed" | tail -1)
    echo "$(string_strip_prefix "$latest" "go")"
}
function go_installer() {
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
    if is_pkg_installed "golang-go"; then
        log_warn "golang-go is installed, removing..."
        sudo apt-get remove -yqq golang-go
    fi
    local arch
    arch=$(arch_probe)
    case "$arch" in
        i*)
            arch="386"
        ;;
        x*)
            arch="amd64"
        ;;
        aarch64)
            arch="armv6l"
        ;;
        armv7l)
            arch="armv6l"
        ;;
    esac
    local -r os=$(os_name)
    local -r uuid=$(unique_id 6)
    local version
    version=$(get_go_latest_version)
    if [[ $# == 2 ]]; then
        version="$2"
    fi
    local -r download_dir="/tmp/go_tmp_${uuid}"
    local -r root_dir="/usr/local"
    local -r file_name="go${version}.${os}-${arch}.tar.gz"
    local -r url="https://storage.googleapis.com/golang/${file_name}"
    log_info "installing go ${version} arch ${arch} for user ${user}"
    mkdir -p "${download_dir}"
    local -r go_archive="${download_dir}/${file_name}"
    local -r download_list="/tmp/go-lang.list"
    rm -f "${download_list}"
    log_info "about to download go version ${version} for os ${os} and arch ${arch}"
    if file_exists "$go_archive"; then
        log_warn "$go_archive has already been downloaded. deleting the existing one..."
        rm "$go_archive"
    fi
    echo "${url}" >>"${download_list}"
    echo " dir=${download_dir}" >>"${download_list}"
    echo " out=${file_name}" >>"${download_list}"
    if file_exists "${download_list}"; then
        downloader "$download_list"
    fi
    local -r go_root="${root_dir}/go"
    log_info "removing any existing installations at $go_root"
    sudo rm -rf "$go_root" 
    log_info "extracting ${go_archive} into ${go_root}"
    extract "${go_archive}" "${root_dir}"
    local -r go_tool_dir="${go_root}/bin"
    # testing installation
    log_info "testing extracted go tool "
    "$go_tool_dir/go" version
    # creating go folders
    log_info "creating GOPATH folders at \$HOME/go/bin \$HOME/go/pkg \$HOME/go/src"
    log_info "making go dirs at ${home}"
    mkdir -p "${home}/go/bin"
    mkdir -p "${home}/go/src"
    mkdir -p "${home}/go/pkg"
    log_info "setting ownership of go dirs to ${user}"
    sudo chown "${user}":"${user}" "${home}/go" -R
    sudo chmod g+rwx "${home}/go" -R
    # adding go to path
    log_info "adding GO env variables to \$HOME/.bashrc"
    add_profile_env_var "GOPATH" '$HOME/go'
    add_profile_env_var "GOROOT" "${go_root}"
    add_profile_env_var "GO111MODULE" 'off'
    add_to_path '$GOROOT/bin:$GOPATH/bin'
    # testing path
    log_info "making sure go was successfully added to path"
    go version
    log_info "cleaning up ${go_archive}"
    rm -rf "${go_archive}"
    rm -f "${download_list}"
}
export -f go_installer
export -f get_go_latest_version
