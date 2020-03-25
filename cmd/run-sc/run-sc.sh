#!/usr/bin/env bash
# shellcheck source=./lib/install/init.sh
source "$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)/lib/install/init.sh"
function run_shellcheck() {
    local -r format="${1}"
    shift
    local -i exit_code
    local -a results
    shellcheck --version
    echo
    printf "Shellcheck is scanning (%s) files:\n" "$#"
    printf "  %s\n" "$@"
    echo
    set +e
    IFS=$'\n' \
        results=$(shellcheck \
            --exclude=SC1117 \
            --external-sources \
            --format="$format" \
            "$@" 2>&1)
    exit_code=$?
    set -e
    case "$exit_code" in
    0)
        echo "All files successfully scanned with no issues"
        ;;
    1)
        printf "All files successfully scanned with some issues (%s):\n" ${#results[@]}
        printf "  %s\n" "${results[@]}"
        exit $exit_code
        ;;

    2)
        printf "the following files could not be processed (%s):\n" ${#results[@]}
        printf "  %s\n" "${results[@]}"
        exit $exit_code
        ;;

    3)
        echo "ShellCheck was invoked with faulty syntax:"
        printf "  %s\n" "${results[@]}"
        exit $exit_code
        ;;

    4)
        echo "ShellCheck was invoked with faulty options:"
        printf "  %s\n" "${results[@]}"
        exit $exit_code
        ;;
    *)
        echo "Unrecognized exit code '$exit_code' returned from shellcheck"
        set -x
        exit 1
        ;;

    esac
}

function main() {
    local -a check_files
    local -r format="${1:-gcc}"
    local filename="${2:-}"
    local line
    WORKING_DIR="$(
        readlink -f \
            "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/"
    )"
    if [[ -z "$filename" ]]; then
        while read -r filename; do
            set +e
            IFS= read -rd '' line < <(head -n 1 "$filename")
            set -e
            if [[ "$line" =~ ^#!/usr/bin/env\ +bash ]]; then
                check_files+=("$filename")
            fi
        done < <(find "$WORKING_DIR" -path ./.git -prune -o -type f -print)
    else
        check_files=("$filename")
    fi
    run_shellcheck "$format" "${check_files[@]}"
}

if [ -z "${BASH_SOURCE+x}" ]; then
    main "${@}"
    exit $?
else
    if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
        export -f run_shellcheck
    else
        main "${@}"
        exit $?
    fi
fi
