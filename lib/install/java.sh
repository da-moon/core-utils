#!/usr/bin/env bash


# shellcheck source=./lib/install/init.sh
source "$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)/install/init.sh"
# shellcheck source=./lib/extract/extract.sh
source "$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)/extract/extract.sh"
[[ -n "${BASH_SOURCE+x}" ]] && [[ $0 != $BASH_SOURCE ]] && echo "sourced path:${BASH_SOURCE[0]}"
function java_installer() {
    # [ "`whoami`" = root ] || exec sudo "$0" "$@"
    log_info "started procedure for java"
    log_info "downloading sdkman script"
    curl -fsSL "https://get.sdkman.io" | bash 
    log_info "running sdkman init script"
    chmod +x ${HOME}/.sdkman/bin/sdkman-init.sh
    source ${HOME}/.sdkman/bin/sdkman-init.sh 
    sdk install java 11.0.6.hs-adpt 
    log_info "installing gradle"
    sdk install gradle 
    log_info "installing maven"
    sdk install maven 
    log_info "cleaning up"
    sdk flush archives 
    sdk flush temp 
    log_info "storing setting at ${HOME}/.m2/settings.xml "

    mkdir -p $HOME/.m2 
    printf '<settings>\n  <localRepository>/workspace/m2-repository/</localRepository>\n</settings>\n' > $HOME/.m2/settings.xml
    add_to_bashrc '[[ -s \"$HOME/.sdkman/bin/sdkman-init.sh\" ]] && source \"$HOME/.sdkman/bin/sdkman-init.sh\"'
    add_profile_env_var "SDKMAN_DIR" '${HOME}/.sdkman/'
    mkdir -p ${HOME}/.gradle/
    add_profile_env_var "GRADLE_USER_HOME" '${HOME}/.gradle/'
}