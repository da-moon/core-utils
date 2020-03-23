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
function array_split() {
    local -r separator="$1"
    local -r str="$2"
    local -a ary=()
    IFS="$separator" read -ra ary <<<"$str"
    echo "${ary[@]}"
}
function array_join() {
    local -r separator="$1"
    shift
    local -ar values=("$@")
    local out=""
        if [[ "$i" -gt 0 ]]; then
            out="${out}${separator}"
        fi
        out="${out}${values[i]}"
    done
    echo -n "$out"
}
function array_prepend() {
    local -r prefix="$1"
    shift 1
    local -ar ary=("$@")
    echo "${updated_ary[*]}"
} 
set -o errtrace
set -o functrace
set -o errexit
set -o nounset
set -o pipefail
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }' 
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
            *.7z) 7z e "$1" -o"$2"/ ;;
            *) log_error "$1 cannot be extracted." ;;
            esac
        fi
    else
        log_error "$1 cannot be extracted."
    fi
} 
function file_exists() {
    local -r file="$1"
    [[ -f "$file" ]]
}
function get_file_name() {
    local -r target="$1"
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
        echo
        echo "desc : adds a line to a file in case it hasn't already been added  "
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
        echo
        echo "desc : appends a line to .bashrc in case it hasn't been already added "
        echo
        echo "method usage: add_to_bashrc [line]"
        echo
        exit 1
    fi
    local payload="$1"
    log_info "adding $payload to '\$HOME/.bashrc'"
    append_line_to_file "$HOME/.bashrc" "$payload"
}
function add_profile_env_var() {
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
        echo
        echo "desc : adds a directory to path in case it hasn't been already added "
        echo
        echo "method usage: add_to_path [target directory]"
        echo
        exit 1
    fi
    local target_dir="$1"
    add_profile_env_var "PATH" "\$PATH:$target_dir"
} 
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
        echo
        echo "desc : creates a new branch"
        echo
        echo "method usage: git_new_branch <branch name>"
        echo
        exit 1
    fi
    local -r name = "$1"
    assert_not_empty "name" "$name" "branch name is needed"
    git checkout -b "$name"
}
function git_repo_size() {
    is_git_available
    git bundle create .tmp-git-bundle --all >/dev/null 2>&1
    if ! os_command_is_available "du"; then
        log_error "du is not available. existing..."
        exit 1
    fi
    local -r size=$(du -sh .tmp-git-bundle | cut -f1)
    rm .tmp-git-bundle
    echo "$size"
}
function git_user_stats() {
        echo
        echo "desc : returns users contributions"
        echo
        echo "method usage: git_user_stats <user name>"
        echo
        exit 1
    fi
    local -r user_name="$1"
    assert_not_empty "user_name" "$user_name" "git username is needed"
    res=$(git log --author="$user_name" --pretty=tformat: --numstat | awk -v GREEN='\033[1;32m' -v PLAIN='\033[0m' -v RED='\033[1;31m' 'BEGIN { add = 0; subs = 0 } { add += $1; subs += $2 } END { printf "Total: %s+%s%s / %s-%s%s\n", GREEN, add, PLAIN, RED, subs, PLAIN }')
    echo "$res"
}
function git_clone() {
    is_git_available
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
        name=$(get_file_name $repo)
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
        aria2c \
            --continue=true \
            --max-concurrent-downloads=16 \
            --max-connection-per-server=16 \
            --optimize-concurrent-downloads \
            --connect-timeout=600 \
            --timeout=600 \
            --input-file="${download_list}"
    fi
    for repo in "${repos[@]}"; do
        name=$(get_file_name $repo)
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
        echo
        echo "desc : get a repo's releases from"
        echo
        echo "method usage: get_releases_from_git [repo owner] [repo name]"
        echo
        exit 1
    fi
    local -r owner="$1"
    local -r repo="$2"
    local -r reply=$(curl -sL https://api.github.com/repos/${owner}/${repo}/tags)
    local -r versions=$(echo "${reply}" | jq -r '.[].name')
    local -r sorted=$(echo "${versions}" | sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n)
    local -r trimmed=$(echo "${sorted}" | grep -v -E 'beta|master|pre|rc|test')
    echo "$trimmed"
}
function ffmpeg_installer() {
    apt_cleanup
    confirm_sudo
    [ "$(whoami)" = root ] || exec sudo "$0" "$@"
    local -r packages=("mkvtoolnix" "ffmpeg")
    log_info "adding mkvtoolnix apt repo key"
    add_key "https://mkvtoolnix.download/gpg-pub-moritzbunkus.txt"
    add_repo "mkvtoolnix" "deb https://mkvtoolnix.download/debian/ buster main"
    for pkg in $packages; do
        log_info "adding ${pkg} to install candidates"
        apt-get -y --print-uris install "$pkg" |
            grep -o -E "(ht|f)t(p|ps)://[^\']+" >>/tmp/apt-fast.list
    done
    if file_exists "/tmp/apt-fast.list"; then
        pushd "/var/cache/apt/archives/" >/dev/null 2>&1
        aria2c \
            --continue=true \
            --max-concurrent-downloads=16 \
            --max-connection-per-server=16 \
            --optimize-concurrent-downloads \
            --connect-timeout=600 \
            --timeout=600 \
            --input-file=/tmp/apt-fast.list
        [[ "$?" != 0 ]] && popd
        popd >/dev/null 2>&1
        for pkg in $packages; do
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
        aria2c \
            --continue=true \
            --max-concurrent-downloads=16 \
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
        netselect-apt \
            --tests 15 \
            --nonfree \
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
    if file_exists "/tmp/apt-fast.list"; then
        pushd "/var/cache/apt/archives/" >/dev/null 2>&1
        aria2c \
            --continue=true \
            --max-concurrent-downloads=16 \
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
        apt_cleanup
    fi
    if has_parallel; then
        log_info "parallelizing env  ..."
        env_parallel --install
    fi
} 
function node_installer() {
    apt_cleanup
    confirm_sudo
    [ "$(whoami)" = root ] || exec sudo "$0" "$@"
    local -r packages=("nodejs" "yarn")
    log_info "running NodeSource Node.js 12.x installer script"
    log_info "adding yarn apt repo key"
    add_key "https://dl.yarnpkg.com/debian/pubkey.gpg"
    add_repo "yarn-nightly" "deb https://nightly.yarnpkg.com/debian/ nightly main"
    for pkg in $packages; do
        log_info "adding ${pkg} to install candidates"
        apt-get -y --print-uris install "$pkg" |
            grep -o -E "(ht|f)t(p|ps)://[^\']+" >>/tmp/apt-fast.list
    done
    if file_exists "/tmp/apt-fast.list"; then
        pushd "/var/cache/apt/archives/" >/dev/null 2>&1
        aria2c \
            --continue=true \
            --max-concurrent-downloads=16 \
            --max-connection-per-server=16 \
            --optimize-concurrent-downloads \
            --connect-timeout=600 \
            --timeout=600 \
            --input-file=/tmp/apt-fast.list
        [[ "$?" != 0 ]] && popd
        popd >/dev/null 2>&1
        for pkg in $packages; do
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
    if ! $(is_root); then
        log_error "needs root permission to run.exiting..."
        exit 1
    fi
    local target="sudo"
    if ! is_pkg_installed "apt-utils"; then
        log_info "apt-utils is not available ... installing now"
        apt-get -qq update &&
            DEBIAN_FRONTEND=noninteractive apt-get install -qqy apt-utils
    fi
    if ! $(has_sudo); then
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
        log_error "No argument was passed to add_key method"
        exit 1
    fi
    [ "$(whoami)" = root ] || exec sudo "$0" "$@"
    curl -fsSL "$1" | apt-key add -
}
function add_repo() {
        echo
        echo "desc : adds an apt repository"
        echo
        echo "method usage: add_repo [name] [address]"
        echo
        exit 1
    fi
    [ "$(whoami)" = root ] || exec sudo "$0" "$@"
    local -r addr="$2"
    [ "$(whoami)" = root ] || exec sudo "$0" "$@"
    if file_exists "$dest"; then
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
    rm -rf /var/cache/apt/archives/*
}
function filter_installed() {
    local -r deps=("$@")
    local -r raw_list=$(dpkg -s ${deps[@]} 2>&1)
    local -r filtered=$(echo "${raw_list}" | grep -E "dpkg-query: package")
    local -r trimmed=$(echo "${filtered}" | sed -n "s,[^']*'\([^']*\).*,\1,p")
    echo "$trimmed"
}
function assert_is_installed() {
    local -r name="$1"
    if ! os_command_is_installed "$name"; then
        log_error "'$name' is required but cannot be found in the system's PATH."
        exit 1
    fi
} 
function string_contains() {
    local -r haystack="$1"
    local -r needle="$2"
    [[ "$haystack" == *"$needle"* ]]
}
function string_multiline_contains() {
    local -r haystack="$1"
    local -r needle="$2"
    echo "$haystack" | grep -q "$needle"
}
function string_to_uppercase() {
    local -r str="$1"
    echo "$str" | awk '{print toupper($0)}'
}
function string_strip_prefix() {
    local -r str="$1"
    local -r prefix="$2"
}
function string_strip_suffix() {
    local -r str="$1"
    local -r suffix="$2"
    echo "${str%$suffix}"
}
function string_is_empty_or_null() {
    local -r response="$1"
    [[ -z "$response" || "$response" == "null" ]]
}
function string_colorify() {
    local -r input="$2"
    ncolors=$(tput colors)
    if [[ $ncolors -ge 8 ]]; then
        local -r color_code="$1"
        echo -e "\e[1m\e[$color_code"m"$input\e[0m"
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
