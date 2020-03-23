function array_contains() {
    local -r needle="$1"
    shift
    local -ra haystack=("$@")
    local item
    for item in "${haystack[@]}"; do
        if [[ "$item" == "$needle" ]]; then
            return 0
        fi
    done
    return 1
}
# https://stackoverflow.com/a/15988793/2308858
function array_split() {
    local -r separator="$1"
    local -r str="$2"
    local -a ary=()
    IFS="$separator" read -ra ary <<<"$str"
    # echo "${ary[*]}"
    echo "${ary[@]}"
}
function array_join() {
    local -r separator="$1"
    shift
    local -ar values=("$@")
    local out=""
    for ((i = 0; i < "${#values[@]}"; i++)); do
        if [[ "$i" -gt 0 ]]; then
            out="${out}${separator}"
        fi
        out="${out}${values[i]}"
    done
    echo -n "$out"
}
# https://stackoverflow.com/a/13216833/2308858
function array_prepend() {
    local -r prefix="$1"
    shift 1
    local -ar ary=("$@")
    updated_ary=("${ary[@]/#/$prefix}")
    echo "${updated_ary[*]}"
}
export -f array_contains
export -f array_split
export -f array_join
export -f array_prepend 
set -o errtrace
set -o functrace
set -o errexit
set -o nounset
set -o pipefail
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }' 
# "extract <file> [path]" "extract any given archive"
function extract() {
    if ! os_command_is_installed "unzip"; then
        log_error "unzip is not available. existing..."
        exit 1
    fi
    if [[ -f "$1" ]]; then
        if [[ "$2" == "" ]]; then
            case "$1" in
            *.rar)
                rar x "$1" "${1%.rar}"/
                if ! os_command_is_installed "rar"; then
                    log_error "rar is not available. existing..."
                    exit 1
                fi
                ;;
            *.tar.bz2) mkdir -p "${1%.tar.bz2}" && tar xjf "$1" -C "${1%.tar.bz2}"/ ;;
            *.tar.gz) mkdir -p "${1%.tar.gz}" && tar xzf "$1" -C "${1%.tar.gz}"/ ;;
            *.tar.xz) mkdir -p "${1%.tar.xz}" && tar xf "$1" -C "${1%.tar.xz}"/ ;;
            *.tar) mkdir -p "${1%.tar}" && tar xf "$1" -C "${1%.tar}"/ ;;
            *.tbz2) mkdir -p "${1%.tbz2}" && tar xjf "$1" -C "${1%.tbz2}"/ ;;
            *.tgz) mkdir -p "${1%.tgz}" && tar xzf "$1" -C "${1%.tgz}"/ ;;
            *.zip)
                if ! os_command_is_installed "unzip"; then
                    log_error "unzip is not available. existing..."
                    exit 1
                fi
                unzip -oq "$1" -d "${1%.zip}"/
                ;;
            # *.zip) unzip "$1" -d "${1%.zip}"/ ;;
            *.7z) 7za e "$1" -o"${1%.7z}"/ ;;
            *) log_error "$1 cannot be extracted." ;;
            esac
        else
            case "$1" in
            *.rar)
                if ! os_command_is_installed "rar"; then
                    log_error "rar is not available. existing..."
                    exit 1
                fi
                rar x "$1" "$2"
                ;;
            *.tar.bz2) mkdir -p "$2" && tar xjf "$1" -C "$2" ;;
            *.tar.gz) mkdir -p "$2" && tar xzf "$1" -C "$2" ;;
            *.tar.xz) mkdir -p "$2" && tar xf "$1" -C "$2" ;;
            *.tar) mkdir -p "$2" && tar xf "$1" -C "$2" ;;
            *.tbz2) mkdir -p "$2" && tar xjf "$1" -C "$2" ;;
            *.tgz) mkdir -p "$2" && tar xzf "$1" -C "$2" ;;
            *.zip)
                if ! os_command_is_installed "unzip"; then
                    log_error "unzip is not available. existing..."
                    exit 1
                fi
                unzip -oq "$1" -d "$2"
                ;;
            # *.zip) unzip "$1" -d "$2" ;;
            *.7z) 7z e "$1" -o"$2"/ ;;
            *) log_error "$1 cannot be extracted." ;;
            esac
        fi
    else
        log_error "$1 cannot be extracted."
    fi
}
export -f extract 
function file_exists() {
    local -r file="$1"
    [[ -f "$file" ]]
}
function get_file_name() {
    local -r target="$1"
    echo "${target##*/}"
}
function get_file_dir() {
    local -r target="$1"
    echo "${target%/*}"
}
function file_exists() {
    local -r file="$1"
    [[ -f "$file" ]]
}
function append_line_to_file() {
    if [[ $# != 2 ]]; then
        echo
        echo "desc : adds a line to a file in case it hasn't already been added "
        echo
        echo "method usage: append_line_to_file [target file] [line]"
        echo
        exit 1
    fi
    local -r dest="$1"
    local -r payload="$2"
    assert_not_empty "file path" "$dest" "needs a file path to work"
    assert_not_empty "line " "$payload" "needs a line to append to file"
    if [[ -z $(grep "$payload" "$dest") ]]; then
        echo "$payload" >>"$dest"
    fi
}
function add_to_bashrc() {
    if [[ $# != 1 ]]; then
        echo
        echo "desc : appends a line to .bashrc in case it hasn't been already added "
        echo
        echo "method usage: add_to_bashrc [line]"
        echo
        exit 1
    fi
    source "$HOME/.bashrc"
    local payload="$1"
    log_info "adding $payload to '$HOME/.bashrc'"
    append_line_to_file "$HOME/.bashrc" "$payload"
    source "$HOME/.bashrc"
}
function add_profile_env_var() {
    if [[ $# != 2 ]]; then
        echo
        echo "desc : adds and exports a variable to .bashrc "
        echo
        echo "method usage: add_profile_env_var [variable name] [variable value]"
        echo
        exit 1
    fi
    local key="$1"
    local value="$2"
    add_to_bashrc "export $key=$value"
}
function add_to_path() {
    if [[ $# != 1 ]]; then
        echo
        echo "desc : adds a directory to path in case it hasn't been already added "
        echo
        echo "method usage: add_to_path [target directory]"
        echo
        exit 1
    fi
    local target_dir="$1"
    add_profile_env_var "PATH" "$PATH:$target_dir"
}
export -f file_exists
export -f get_file_name
export -f get_file_dir
export -f file_exists
export -f append_line_to_file
export -f add_to_bashrc
export -f add_profile_env_var
export -f add_to_path 
# package functions
function is_git_available() {
    if ! os_command_is_available "git"; then
        log_error "git is not available. existing..."
        exit 1
    fi
}
function git_undo_commit() {
    is_git_available
    git reset --soft HEAD~
}
function git_reset_local() {
    is_git_available
    git fetch origin
    git reset --hard origin/master
}
function git_pull_latest() {
    is_git_available
    git pull --rebase origin master
}
function git_list_branches() {
    is_git_available
    git branch -a
}
function git_new_branch() {
    is_git_available
    if [[ $# == 1 ]]; then
        echo
        echo "desc : creates a new branch"
        echo
        echo "method usage: git_new_branch <branch name>"
        echo
        exit 1
    fi
    local -r name="$1"
    assert_not_empty "name" "$name" "branch name is needed"
    git checkout -b "$name"
}
function git_repo_size() {
    is_git_available
    # do not show output of git bundle create {>/dev/null 2>&1} ...
    git bundle create .tmp-git-bundle --all >/dev/null 2>&1
    # check for existance of du
    if ! os_command_is_available "du"; then
        log_error "du is not available. existing..."
        exit 1
    fi
    local -r size=$(du -sh .tmp-git-bundle | cut -f1)
    rm .tmp-git-bundle
    echo "$size"
}
function git_user_stats() {
    if [[ $# == 1 ]]; then
        echo
        echo "desc : returns users contributions"
        echo
        echo "method usage: git_user_stats <user name>"
        echo
        exit 1
    fi
    local -r user_name="$1"
    assert_not_empty "user_name" "$user_name" "git username is needed"
    res=$(git log --author="$user_name" --pretty=tformat: --numstat | awk -v GREEN='033[1;32m' -v PLAIN='033[0m' -v RED='033[1;31m' 'BEGIN { add = 0; subs = 0 } { add += $1; subs += $2 } END { printf "Total: %s+%s%s / %s-%s%sn", GREEN, add, PLAIN, RED, subs, PLAIN }')
    echo "$res"
}
function git_clone() {
    is_git_available
    if [[ $# == 0 ]]; then
        echo
        echo "desc : clones and extracts a reposiory lists with aria2"
        echo
        echo "method usage: git_new_branch <branch name>"
        echo
        exit 1
    fi
    local -r repos=("$@")
    local -r download_list="/tmp/git-dl.list"
    if file_exists "${download_list}"; then
        log_warn "existing git candidate download list detected.deleting..."
        rm "$download_list"
    fi
    for repo in "${repos[@]}"; do
        assert_not_empty "repo" "$repo" "repo url cannot be empty"
        name=$(get_file_name "$repo")
        if file_exists "$PWD/$name.zip"; then
            log_warn "an exisitng clone of repositry archive exists.deleting..."
            rm "$PWD/$name.zip"
        fi
        log_info "cloning $repo"
        local -r url="$repo/archive/master.zip"
        echo "${url}" >>"${download_list}"
        echo " dir=$PWD" >>"${download_list}"
        echo " out=$name.zip" >>"${download_list}"
    done
    if file_exists "${download_list}"; then
        aria2c --continue=true --max-concurrent-downloads=16 --max-connection-per-server=16 --optimize-concurrent-downloads --connect-timeout=600 --timeout=600 --input-file="${download_list}"
    fi
    for repo in "${repos[@]}"; do
        name=$(get_file_name "$repo")
        if file_exists "$PWD/$name.zip"; then
            extract "$PWD/$name.zip" "$name"
            mv "$PWD/$name/$name-master" "$PWD"
            rm -rf "$PWD/$name/"
            mv "$PWD/$name-master/" "$PWD/$name/"
            rm "$PWD/$name.zip"
        fi
    done
}
function git_release_list() {
    if [[ $# != 2 ]]; then
        echo
        echo "desc : get a repo's releases from"
        echo
        echo "method usage: get_releases_from_git [repo owner] [repo name]"
        echo
        exit 1
    fi
    local -r owner="$1"
    local -r repo="$2"
    local -r reply=$(curl -sL "https://api.github.com/repos/${owner}/${repo}/tags")
    local -r versions=$(echo "${reply}" | jq -r '.[].name')
    local -r sorted=$(echo "${versions}" | sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n)
    local -r trimmed=$(echo "${sorted}" | grep -v -E 'beta|master|pre|rc|test')
    echo "$trimmed"
}
export -f s
export -f is_git_available
export -f git_undo_commit
export -f git_reset_local
export -f git_pull_latest
export -f git_list_branches
export -f git_new_branch
export -f git_repo_size
export -f git_user_stats
export -f git_clone
export -f git_release_list 
function ffmpeg_installer() {
    apt_cleanup
    confirm_sudo
    [ "$(whoami)" = root ] || exec sudo "$0" "$@"
    local -r packages=("mkvtoolnix" "ffmpeg")
    log_info "adding mkvtoolnix apt repo key"
    add_key "https://mkvtoolnix.download/gpg-pub-moritzbunkus.txt"
    add_repo "mkvtoolnix" "deb https://mkvtoolnix.download/debian/ buster main"
    for pkg in "${packages[@]}"; do
        log_info "adding ${pkg} to install candidates"
        apt-get -y --print-uris install "$pkg" |
            grep -o -E "(ht|f)t(p|ps)://[^']+" >>/tmp/apt-fast.list
    done
    # End of scriptspecific packages
    if file_exists "/tmp/apt-fast.list"; then
        pushd "/var/cache/apt/archives/" >/dev/null 2>&1
        aria2c --continue=true --max-concurrent-downloads=16 --max-connection-per-server=16 --optimize-concurrent-downloads --connect-timeout=600 --timeout=600 --input-file=/tmp/apt-fast.list
        [[ "$?" != 0 ]] && popd
        popd >/dev/null 2>&1
        for pkg in "${packages[@]}"; do
            log_info "installing $pkg"
            sudo apt-get install -yqq "$pkg"
        done
        apt_cleanup
    fi
    if os_command_is_available "npm"; then
        log_info "install ffmpeg-progress-bar ..."
        npm install --global ffmpeg-progressbar-cli
    fi
}
export -f ffmpeg_installer 
function init() {
    apt_cleanup
    confirm_sudo
    [ "$(whoami)" = root ] || exec sudo "$0" "$@"
    DEBIAN_FRONTEND=noninteractive apt-get update
    log_info "downloading and installing core dependancies"
    if ! os_command_is_available "aria2c"; then
        log_info "aria2 not available.installing aria2 ..."
        DEBIAN_FRONTEND=noninteractive apt-get install -yqq aria2
    fi
    if ! os_command_is_available "curl"; then
        log_info "curl not available.installing aria2 ..."
        DEBIAN_FRONTEND=noninteractive apt-get install -yqq curl
    fi
    if ! os_command_is_available "wget"; then
        log_info "wget not available.installing wget ..."
        DEBIAN_FRONTEND=noninteractive apt-get install -yqq wget
    fi
    DEBIAN_FRONTEND=noninteractive apt-get install -y --fix-broken
    if ! os_command_is_available "netselect-apt"; then
        log_info "netselect-apt not available.installing netselect-apt ..."
        pushd "/tmp/" >/dev/null 2>&1
        rm -rf netselect*
        echo "http://ftp.us.debian.org/debian/pool/main/n/netselect/netselect_0.3.ds1-28+b1_amd64.deb" >>/tmp/netselect.list
        echo "http://ftp.us.debian.org/debian/pool/main/n/netselect/netselect-apt_0.3.ds1-28_all.deb" >>/tmp/netselect.list
        aria2c --continue=true --max-concurrent-downloads=16 --max-connection-per-server=16 --optimize-concurrent-downloads --connect-timeout=600 --timeout=600 --input-file=/tmp/netselect.list
        dpkg -i netselect_0.3.ds1-28+b1_amd64.deb
        dpkg -i netselect-apt_0.3.ds1-28_all.deb
        rm -rf netselect*
        [[ "$?" != 0 ]] && popd
        popd >/dev/null 2>&1
    fi
    if ! file_exists "/etc/apt/sources-fast.list"; then
        log_warn "fast apt sources have not been added. adding now ..."
        netselect-apt --tests 15 --sources --nonfree --outfile /etc/apt/sources-fast.list stable
    fi
    deps=("git" "apt-utils" "unzip" "build-essential" "software-properties-common"
        "make" "vim" "nano" "ca-certificates" "parallel"
        "wget" "gcc" "g++" "jq" "unzip" "ufw" "tmux"
        "apt-transport-https" "bzip2" "zip")
    local -r not_installed=$(filter_installed "${deps[@]}")
    for pkg in $not_installed; do
        log_info "adding ${pkg} to install candidates"
        apt-get -y --print-uris install "$pkg" |
            grep -o -E "(ht|f)t(p|ps)://[^']+" >>/tmp/apt-fast.list
    done
    if file_exists "/tmp/apt-fast.list"; then
        pushd "/var/cache/apt/archives/" >/dev/null 2>&1
        aria2c --continue=true --max-concurrent-downloads=16 --max-connection-per-server=16 --optimize-concurrent-downloads --connect-timeout=600 --timeout=600 --input-file=/tmp/apt-fast.list
        [[ "$?" != 0 ]] && popd
        popd >/dev/null 2>&1
        for pkg in $not_installed; do
            log_info "installing $pkg"
            sudo apt-get install -yqq "$pkg"
        done
        apt_cleanup
    fi
    if has_parallel; then
        log_info "parallelizing env ..."
        env_parallel --install
    fi
}
export -f init 
# end of shared base
function node_installer() {
    apt_cleanup
    confirm_sudo
    [ "$(whoami)" = root ] || exec sudo "$0" "$@"
    # script specific packages
    local -r packages=("nodejs" "yarn")
    log_info "running NodeSource Node.js 12.x installer script"
    curl -fsSL https://deb.nodesource.com/setup_12.x | sudo bash -
    log_info "adding yarn apt repo key"
    add_key "https://dl.yarnpkg.com/debian/pubkey.gpg"
    add_repo "yarn-nightly" "deb https://nightly.yarnpkg.com/debian/ nightly main"
    for pkg in "${packages[@]}"; do
        log_info "adding ${pkg} to install candidates"
        apt-get -y --print-uris install "$pkg" |
            grep -o -E "(ht|f)t(p|ps)://[^']+" >>/tmp/apt-fast.list
    done
    # End of scriptspecific packages
    if file_exists "/tmp/apt-fast.list"; then
        pushd "/var/cache/apt/archives/" >/dev/null 2>&1
        aria2c --continue=true --max-concurrent-downloads=16 --max-connection-per-server=16 --optimize-concurrent-downloads --connect-timeout=600 --timeout=600 --input-file=/tmp/apt-fast.list
        [[ "$?" != 0 ]] && popd
        popd >/dev/null 2>&1
        for pkg in "${packages[@]}"; do
            log_info "installing $pkg"
            sudo apt-get install -yqq "$pkg"
        done
        apt_cleanup
    fi
    if os_command_is_available "yarn"; then
        add_to_path '`yarn global bin`'
        add_to_path '${home}/.yarn/bin'
    fi
}
export -f node_installer 
function log() {
    local -r level="$1"
    local -r message="$2"
    local -r timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local -r script_name="$(basename "$0")"
    local color
    case "$level" in
    INFO)
        color="string_green"
        ;;
    WARN)
        color="string_yellow"
        ;;
    ERROR)
        color="string_red"
        ;;
    esac
    # echo >&2 -e "$(string_colorify "${color}" "${timestamp} [${level}] ==>") $(string_blue "[$script_name]") ${message}"
    echo >&2 -e "$(${color} "${timestamp} [${level}] ==>") $(string_blue "[$script_name]") ${message}"
}
function log_info() {
    local -r message="$1"
    log "INFO" "$message"
}
function log_warn() {
    local -r message="$1"
    log "WARN" "$message"
}
function log_error() {
    local -r message="$1"
    log "ERROR" "$message"
}
export -f log
export -f log_info
export -f log_warn
export -f log_error 
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
# Return true (0) if the first string contains the second string
function string_contains() {
    local -r haystack="$1"
    local -r needle="$2"
    [[ "$haystack" == *"$needle"* ]]
}
# Returns true (0) if the first string (assumed to contain multiple lines)
# contains the second string (needle).
# The needle can contain regular expressions.
function string_multiline_contains() {
    local -r haystack="$1"
    local -r needle="$2"
    echo "$haystack" | grep -q "$needle"
}
# Convert the given string to uppercase
function string_to_uppercase() {
    local -r str="$1"
    echo "$str" | awk '{print toupper($0)}'
}
# eg .
# string_strip_prefix "foo=bar" "foo=" ===> "bar"
# string_strip_prefix "foo=bar" "*=" ===> "bar"
function string_strip_prefix() {
    local -r str="$1"
    local -r prefix="$2"
    echo "${str#$prefix}"
}
# eg:
# string_strip_suffix "foo=bar" "=bar" ===> "foo"
# string_strip_suffix "foo=bar" "=*" ===> "foo"
function string_strip_suffix() {
    local -r str="$1"
    local -r suffix="$2"
    echo "${str%$suffix}"
}
# Return true if the given response is empty or "null"
# "null" is from jq parsing.
function string_is_empty_or_null() {
    local -r response="$1"
    [[ -z "$response" || "$response" == "null" ]]
}
# https://misc.flogisoft.com/bash/tip_colors_and_formatting
function string_colorify() {
    local -r input="$2"
    # checking for colour availablity
    ncolors=$(tput colors)
    if [[ $ncolors -ge 8 ]]; then
        local -r color_code="$1"
        echo -e "e[1me[$color_code"m"$inpute[0m"
    else
        echo -e "$input"
    fi
}
function string_blue() {
    local -r color_code="34"
    local -r input="$1"
    echo -e "$(string_colorify "${color_code}" "${input}")"
}
function string_yellow() {
    local -r color_code="93"
    local -r input="$1"
    echo -e "$(string_colorify "${color_code}" "${input}")"
}
function string_green() {
    local -r color_code="32"
    local -r input="$1"
    echo -e "$(string_colorify "${color_code}" "${input}")"
}
function string_red() {
    local -r color_code="31"
    local -r input="$1"
    echo -e "$(string_colorify "${color_code}" "${input}")"
}
function assert_not_empty() {
    local -r arg_name="$1"
    local -r arg_value="$2"
    local -r reason="$3"
    if [[ -z "$arg_value" ]]; then
        log_error "'$arg_name' cannot be empty. $reason"
        exit 1
    fi
}
export -f string_contains
export -f string_multiline_contains
export -f string_to_uppercase
export -f string_strip_prefix
export -f string_strip_suffix
export -f string_is_empty_or_null
export -f string_colorify
export -f string_blue
export -f string_yellow
export -f string_green
export -f string_red
export -f assert_not_empty 
