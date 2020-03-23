#!/usr/bin/bash
# shellcheck source=./lib/env/env.sh
source "$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)/env/env.sh"
# shellcheck source=./lib/log/log.sh
source "$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)/log/log.sh"
# shellcheck source=./lib/io/io.sh
source "$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)/file/file.sh"
# shellcheck source=./lib/string/string.sh
source "$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)/string/string.sh"
function is_root() {
    [ "$EUID" == 0 ]
}
function os_command_is_available() {
    local name
    name="$1"
    command -v "$name" >/dev/null
}
function has_sudo() {
    os_command_is_available "sudo"
}
function has_apt() {
    os_command_is_available "apt-get"
}
function has_parallel() {
    os_command_is_available "parallel"
}
function is_pkg_installed() {
    local -r pkg="$1"
    dpkg -s "$pkg" 2>/dev/null | grep ^Status | grep -q installed
}
function confirm_sudo() {
    if ! is_root; then
        log_error "needs root permission to run.exiting..."
        exit 1
    fi
    local target="sudo"
    if ! is_pkg_installed "apt-utils"; then
        log_info "apt-utils is not available ... installing now"
        apt-get -qq update &&
            DEBIAN_FRONTEND=noninteractive apt-get install -qqy apt-utils
    fi
    if ! has_sudo; then
        log_info "sudo is not available ... installing now"
        apt-get -qq update &&
            DEBIAN_FRONTEND=noninteractive apt-get install -qqy "$target"
    fi
}
function get_debian_codename() {
    local -r os_release=$(cat /etc/os-release)
    local -r version_codename_line=$(echo "$os_release" | grep -e VERSION_CODENAME)
    local -r result=$(string_strip_prefix "$version_codename_line" "VERSION_CODENAME=")
    echo "$result"
}
function add_key() {
    if [[ $# == 0 ]]; then
        log_error "No argument was passed to add_key method"
        exit 1
    fi
    [ "$(whoami)" = root ] || exec sudo "$0" "$@"
    curl -fsSL "$1" | apt-key add -
}
function add_repo() {
    if [[ $# != 2 ]]; then
        echo
        echo "desc : adds an apt repository"
        echo
        echo "method usage: add_repo [name] [address]"
        echo
        exit 1
    fi
    [ "$(whoami)" = root ] || exec sudo "$0" "$@"
    local -r dest="/etc/apt/sources.list.d/$1.list"
    local -r addr="$2"
    [ "$(whoami)" = root ] || exec sudo "$0" "$@"
    if file_exists "$dest"; then
        log_warn "a repo source for $1 already exists. deleting the existing one..."
        rm "$dest"
    fi
    log_info "adding repo for $1"
    echo "$addr" | tee "$dest"
    apt-get update
}
function apt_cleanup() {
    confirm_sudo
    [ "$(whoami)" = root ] || exec sudo "$0" "$@"
    if file_exists "/tmp/apt-fast.list"; then
        DEBIAN_FRONTEND=noninteractive apt-get install -y --fix-broken
        rm /tmp/apt-fast.list
    fi
    apt-get clean
    # rm -rf /var/lib/apt/lists/apt.llvm.org_disco_dists_llvm-toolchain-disco_InRelease /var/lib/apt/lists/apt.llvm.org_disco_dists_llvm-toolchain-disco_main_binary-amd64_Packages.lz4 /var/lib/apt/lists/archive.ubuntu.com_ubuntu_dists_disco-backports_InRelease /var/lib/apt/lists/archive.ubuntu.com_ubuntu_dists_disco-backports_main_binary-amd64_Packages.lz4 /var/lib/apt/lists/archive.ubuntu.com_ubuntu_dists_disco-backports_universe_binary-amd64_Packages.lz4 /var/lib/apt/lists/archive.ubuntu.com_ubuntu_dists_disco_InRelease /var/lib/apt/lists/archive.ubuntu.com_ubuntu_dists_disco_main_binary-amd64_Packages.lz4 /var/lib/apt/lists/archive.ubuntu.com_ubuntu_dists_disco_multiverse_binary-amd64_Packages.lz4 /var/lib/apt/lists/archive.ubuntu.com_ubuntu_dists_disco_restricted_binary-amd64_Packages.lz4 /var/lib/apt/lists/archive.ubuntu.com_ubuntu_dists_disco_universe_binary-amd64_Packages.lz4 /var/lib/apt/lists/archive.ubuntu.com_ubuntu_dists_disco-updates_InRelease /var/lib/apt/lists/archive.ubuntu.com_ubuntu_dists_disco-updates_main_binary-amd64_Packages.lz4 /var/lib/apt/lists/archive.ubuntu.com_ubuntu_dists_disco-updates_multiverse_binary-amd64_Packages.lz4 /var/lib/apt/lists/archive.ubuntu.com_ubuntu_dists_disco-updates_restricted_binary-amd64_Packages.lz4 /var/lib/apt/lists/archive.ubuntu.com_ubuntu_dists_disco-updates_universe_binary-amd64_Packages.lz4 /var/lib/apt/lists/auxfiles /var/lib/apt/lists/lock /var/lib/apt/lists/mkvtoolnix.download_debian_dists_buster_main_binary-amd64_Packages.lz4 /var/lib/apt/lists/mkvtoolnix.download_debian_dists_buster_Release /var/lib/apt/lists/mkvtoolnix.download_debian_dists_buster_Release.gpg /var/lib/apt/lists/partial /var/lib/apt/lists/ppa.launchpad.net_git-core_ppa_ubuntu_dists_disco_InRelease /var/lib/apt/lists/ppa.launchpad.net_git-core_ppa_ubuntu_dists_disco_main_binary-amd64_Packages.lz4 /var/lib/apt/lists/security.ubuntu.com_ubuntu_dists_disco-security_InRelease /var/lib/apt/lists/security.ubuntu.com_ubuntu_dists_disco-security_main_binary-amd64_Packages.lz4 /var/lib/apt/lists/security.ubuntu.com_ubuntu_dists_disco-security_multiverse_binary-amd64_Packages.lz4 /var/lib/apt/lists/security.ubuntu.com_ubuntu_dists_disco-security_restricted_binary-amd64_Packages.lz4 /var/lib/apt/lists/security.ubuntu.com_ubuntu_dists_disco-security_universe_binary-amd64_Packages.lz4
    rm -rf /var/cache/apt/archives/lock /var/cache/apt/archives/partial
}
function filter_installed() {
    local -r deps=("$@")
    local -r raw_list=$(dpkg -s ${deps[@]} 2>&1)
    local -r filtered=$(echo "${raw_list}" | grep -E "dpkg-query: package")
    local -r trimmed=$(echo "${filtered}" | sed -n "s,[^']*'([^']*).*,1,p")
    echo "$trimmed"
}
function assert_is_installed() {
    local -r name="$1"
    if ! os_command_is_installed "$name"; then
        log_error "'$name' is required but cannot be found in the system's PATH."
        exit 1
    fi
}
export -f is_root
export -f os_command_is_available
export -f has_sudo
export -f has_apt
export -f has_parallel
export -f is_pkg_installed
export -f confirm_sudo
export -f get_debian_codename
export -f add_key
export -f add_repo
export -f apt_cleanup
export -f filter_installed
export -f assert_is_installed
