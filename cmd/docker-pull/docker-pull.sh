#!/usr/bin/env bash

[[ -n "${BASH_SOURCE+x}" ]] && [[ $0 != $BASH_SOURCE ]] && echo "sourced path:${BASH_SOURCE[0]}"

# shellcheck source=./lib/install/init.sh
source "$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)/lib/install/init.sh"
