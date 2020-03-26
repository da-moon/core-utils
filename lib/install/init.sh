#!/usr/bin/env bash


# shellcheck source=./lib/os/os.sh
source "$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)/os/os.sh"
[[ -n "${BASH_SOURCE+x}" ]] && [[ $0 != $BASH_SOURCE ]] && echo "sourced path:${BASH_SOURCE[0]}"
function fast_apt() {
    # [ "$(whoami)" = root ] || exec sudo "$0" "$@"
    if echo "$@" | grep -q "upgrade\|install\|dist-upgrade"; then
        local -r download_list="/tmp/apt-fast.list"
        local -r apt_cache="/var/cache/apt/archives"
        local -r command="${1}"
        shift
        local -r uris=$(apt-get -y --print-uris $command "${@}")
        local -r urls=($(echo ${uris} | grep -o -E "(ht|f)t(p|ps)://[^\']+" ))
        for link in ${urls[@]}; do
            log_info "adding ${link} to download candidates"
            echo "$link" >>"$download_list"
            echo " dir=$apt_cache" >>"$download_list"
        done
        if  file_exists "$download_list"; then
            downloader "$download_list"
            sudo apt-get $command -y "$@" 
            log_info "cleaning up apt cache ..."
            apt_cleanup
        else
            log_warn "there are no install candidates at $download_list "
            log_info "cleaning up apt cache ..."
            apt_cleanup
        fi
    else
        sudo apt-get "$@"
    fi
}
export -f fast_apt

function init() {
    confirm_sudo
    # [ "$(whoami)" = root ] || exec sudo "$0" "$@"
    if ! os_command_is_available "aria2c"; then
        log_info "aria2 not available.installing aria2 ..."
        sudo apt-get install -yqq aria2
    fi
    if ! os_command_is_available "curl"; then
        log_info "curl not available.installing curl ..."
        sudo apt-get install -yqq curl
    fi
    if ! os_command_is_available "netselect-apt"; then
        log_info "netselect-apt not available.installing netselect-apt ..."
        if ! os_command_is_available "wget"; then
            log_info "wget not available.installing wget ..."
            sudo apt-get install -yqq wget
        fi
        sudo apt-get install -y --fix-broken
        pushd "/tmp/" >/dev/null 2>&1
        rm -rf netselect*
        echo "http://ftp.us.debian.org/debian/pool/main/n/netselect/netselect_0.3.ds1-28+b1_amd64.deb" >>/tmp/netselect.list
        echo "http://ftp.us.debian.org/debian/pool/main/n/netselect/netselect-apt_0.3.ds1-28_all.deb" >>/tmp/netselect.list
        local -r netselect_links="/tmp/netselect.list"
        downloader "$netselect_links"
        sudo dpkg -i netselect_0.3.ds1-28+b1_amd64.deb
        sudo dpkg -i netselect-apt_0.3.ds1-28_all.deb
        rm -rf netselect*
        [[ "$?" != 0 ]] && popd
        popd >/dev/null 2>&1
    fi
    if ! file_exists "/etc/apt/sources-fast.list"; then
        log_warn "fast apt sources have not been added. adding now ..."
        sudo netselect-apt \
            --tests 15 \
            --sources \
            --nonfree \
            --outfile /etc/apt/sources-fast.list \
            stable
        sudo apt-get update
    fi
      packages=("git" 
        "apt-utils" 
        "unzip" 
        "build-essential" 
        "software-properties-common"
        "make" 
        "vim" 
        "nano" 
        "ca-certificates"
        "wget" 
        "jq" 
        "apt-transport-https" 
        "parallel"
        "gcc"
        "g++"
        "ufw"
        "progress"
        "bzip2"
        "strace"
        "tmux"
        "zip")
    fast_apt "install" "${packages[@]}"
    if has_parallel; then
        log_info "parallelizing env ..."
        env_parallel --install
    fi
}
export -f init
bash_version="4"
if ! min_bash_version "$bash_version"; then
    log_error "you bash version is ${BASH_VERSINFO}.Minimum supported version is $bash_version"
    exit 1
fi
