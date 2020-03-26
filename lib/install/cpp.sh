#!/usr/bin/env bash
# shellcheck source=./lib/install/init.sh
source "$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)/install/init.sh"
[[ -n "${BASH_SOURCE+x}" ]] && [[ $0 != $BASH_SOURCE ]] && echo "sourced path:${BASH_SOURCE[0]}"
function cpp_installer() {
    if ! is_root; then
        log_error "needs root permission to run.exiting..."
        exit 1
    fi
    confirm_sudo
    [ "`whoami`" = root ] || exec sudo "$0" "$@"
    log_info "started procedure for llvm/cpp/c toolchains"
    log_info "adding llvm apt repo key"
    add_key "https://apt.llvm.org/llvm-snapshot.gpg.key"
    add_repo "llvm" "deb http://apt.llvm.org/$(get_debian_codename)/ llvm-toolchain-$(get_debian_codename) main"
    # @todo add clang-tools 
    # breaks gp build atm
    local -r packages=("g++" "gcc" "clang-format" "clang-tidy" "clangd" "gdb" "lld")
    fast_apt "install" "${packages[@]}"
}
export -f cpp_installer