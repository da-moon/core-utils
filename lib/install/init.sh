#!/usr/bin/env bash
# shellcheck source=./lib/os/os.sh
source "$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)/os/os.sh"
function init() {
    confirm_sudo
    [ "$(whoami)" = root ] || exec sudo "$0" "$@"
    DEBIAN_FRONTEND=noninteractive apt-get update -qq
    if ! os_command_is_available "aria2c"; then
        log_info "aria2 not available.installing aria2 ..."
        DEBIAN_FRONTEND=noninteractive apt-get install -yqq aria2
    fi
    if ! os_command_is_available "curl"; then
        log_info "curl not available.installing aria2 ..."
        DEBIAN_FRONTEND=noninteractive apt-get install -yqq curl
    fi
    if ! os_command_is_available "netselect-apt"; then
        log_info "netselect-apt not available.installing netselect-apt ..."
        if ! os_command_is_available "wget"; then
            log_info "wget not available.installing wget ..."
            DEBIAN_FRONTEND=noninteractive apt-get install -yqq wget
        fi
        DEBIAN_FRONTEND=noninteractive apt-get install -y --fix-broken
        pushd "/tmp/" >/dev/null 2>&1
        rm -rf netselect*
        echo "http://ftp.us.debian.org/debian/pool/main/n/netselect/netselect_0.3.ds1-28+b1_amd64.deb" >>/tmp/netselect.list
        echo "http://ftp.us.debian.org/debian/pool/main/n/netselect/netselect-apt_0.3.ds1-28_all.deb" >>/tmp/netselect.list
        aria2c \
            -j 16 \
            --continue=true \
            --max-connection-per-server=16 \
            --optimize-concurrent-downloads \
            --connect-timeout=600 \
            --timeout=600 \
            --input-file=/tmp/netselect.list
        dpkg -i netselect_0.3.ds1-28+b1_amd64.deb
        dpkg -i netselect-apt_0.3.ds1-28_all.deb
        rm -rf netselect*
        [[ "$?" != 0 ]] && popd
        popd >/dev/null 2>&1
    fi
    if ! file_exists "/etc/apt/sources-fast.list"; then
        log_warn "fast apt sources have not been added. adding now ..."
        netselect-apt \
            --tests 15 \
            --sources \
            --nonfree \
            --outfile /etc/apt/sources-fast.list \
            stable
    fi
    deps=("git" "apt-utils" "unzip" "build-essential" "software-properties-common"
        "make" "vim" "nano" "ca-certificates" "parallel"
        "wget" "gcc" "g++" "jq" "unzip" "ufw" "tmux"
        "apt-transport-https" "bzip2" "zip")
    local -r not_installed=$(filter_installed "${deps[@]}")
    for pkg in $not_installed; do
        log_info "adding ${pkg} to install candidates"
        apt-get -y --print-uris install "$pkg" |
            grep -o -E "(ht|f)t(p|ps)://[^\']+" >>/tmp/apt-fast.list
    done
    pushd "/var/cache/apt/archives/" >/dev/null 2>&1
    aria2c \
        -j 16 \
        --continue=true \
        --max-connection-per-server=16 \
        --optimize-concurrent-downloads \
        --connect-timeout=600 \
        --timeout=600 \
        --input-file=/tmp/apt-fast.list
    [[ "$?" != 0 ]] && popd
    popd >/dev/null 2>&1
    for pkg in $not_installed; do
        log_info "installing $pkg"
        sudo apt-get install -yqq "$pkg"
    done
    if has_parallel; then
        log_info "parallelizing env ..."
        env_parallel --install
    fi
}
export -f init
