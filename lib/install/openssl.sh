#!/usr/bin/env bash


# shellcheck source=./lib/install/init.sh
source "$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)/install/init.sh"
[[ -n "${BASH_SOURCE+x}" ]] && [[ $0 != $BASH_SOURCE ]] && echo "sourced path:${BASH_SOURCE[0]}"
