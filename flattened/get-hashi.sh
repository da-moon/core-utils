if [ -z "${BASH_SOURCE+x}" ]; then
    if ! is_root; then
        log_error "needs root permission to run.exiting..."
        exit 1
    fi
    init
    stack=("vault" "consul" "nomad" "terraform" "packer")
    if [[ "$#" != 0 ]]; then
        stack=("${@}")
    fi
    log_info "install targets ${stack[*]}"
    get_hashi "${stack[@]}"
    exit $?
else
    if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
        if ! is_root; then
            log_error "needs root permission to run.exiting..."
            exit 1
        fi
        init
        stack=("vault" "consul" "nomad" "terraform" "packer")
        if [[ "$#" != 0 ]]; then
            stack=("${@}")
        fi
        log_info "install targets ${stack[*]}"
        get_hashi "${stack[@]}"
        exit $?
    fi
fi 
