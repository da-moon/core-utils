#!/usr/bin/bash
# shellcheck source=./lib/install/init.sh
source "$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)lib/install/init.sh"
# shellcheck source=./lib/git/git.sh
source "$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)lib/git/git.sh"

function help() {
echo
echo "Usage: [$(basename "$0")] [OPTIONAL ARG] [COMMAND | COMMAND <FLAG> <ARG>]"
echo
echo
echo -e "[Synopsis]:tAssisting with git operations."
echo
echo "Commands:"
echo
echo -e " undo-committttUndo the latest commit."
echo
echo -e " reset-localtttReset local repo to match remote."
echo
echo -e " pull-latesttttSync local with remote"
echo
echo -e " list-branchestttList all branches."
echo
echo -e " new-branchtttCreates a new branch from current and switches into it"
echo
echo -e " repo-sizetttCalculate the repo size."
echo
echo -e " user-stats tttCalculate total contribution for a user"
echo -e " [flag] --name <arg> ttTarget user's name"
echo
echo -e " clone tttfast cloning git repos by downloading it with aria2.can take multiple addresses"
echo -e " [flag] --addr <arg> ttaddress of the git repo (without .git)"
echo
echo -e " release-list ttfinds a list of releases of a repo"
echo -e " [flag] --owner <arg> ttrepo owner"
echo -e " [flag] --name <arg> ttrepo name"
echo
echo -e " latest-release ttfinds latest release of a repo. can also download it if needed"
echo -e " [flag] --addr <arg> ttaddress of the git repo (without .git)"
echo -e " [flag|optional] --link treturns download link instead of version number.[DEFAULT false]"
echo
echo -e " install-latest ttdownloads, unarchives and 'installs' latest release of a repo"
echo -e " [flag] --addr <arg> ttaddress of the git repo (without .git)"
echo -e " [flag|optional] --path tpath to store the release binary in.[DEFAULT '/usr/local/bin']"
echo
echo "Optional Flags:"
echo
echo -e " --initttinitializes and installs dependancies for $(basename "$0")"
echo -e " --updatettupdates $(basename "$0") to the letest version at master branch."
echo -e " --pathttSets target repo path."
echo -e " tttBy default, it is the directory terminal is running in."
echo
echo "Example:"
echo
echo " $(basename "$0") \"
echo " undo-commit"
echo
echo " $(basename "$0") \"
echo " --path "/workspace/core-utils" \"
echo " user-stats \"
echo " --name da-moon"
echo
echo " $(basename "$0") clone \"
echo " --addr https://github.com/jbruchon/jdupes \"
echo " --addr https://github.com/openssl/openssl \"
echo " --addr https://github.com/protocolbuffers/protobuf "
echo
}

function update() {
local -r url="https://raw.githubusercontent.com/da-moon/core-utils/master/bin/$(basename "$0")"
local -r install_location=$(whereis "$(basename "$0")" | grep -E -o "$(basename "$0").*" | cut -f2- -d: | tr -s ' ' | cut -d ' ' -f2)
log_info "updating $(basename "$0") located at $install_location"
if [ ! -w "$install_location" ]; then
log_info "needs sudo for updating file at $install_location"
confirm_sudo
[ "$(whoami)" = root ] || exec sudo "$0" "$@"
fi
log_info "removing old file at $install_location"
rm "$install_location"
log_info "downloading $url"
wget -q -O "$install_location" "$url"
log_info "setting $install_location as executable"
chmod +x "$install_location"
}
function main() {
if [[ $# == 0 ]]; then
help
exit 1
fi
local path="."
while [[ $# -gt 0 ]]; do
local key="$1"
case "$key" in
--init)
log_info "initializing $(basename "$0")"
init
shift
;;
--update)
update
shift
;;
--path)
if [[ $# == 1 ]]; then
log_error "path value user input is needed. existing..."
exit 1
fi
path="$2"
assert_not_empty "path" "$path" "user input is needed"
shift
;;
undo-commit)
pushd "$path" >/dev/null 2>&1
git_undo_commit
[[ "$?" != 0 ]] && popd
popd >/dev/null 2>&1
shift
exit
;;
reset-local)
pushd "$path" >/dev/null 2>&1
git_reset_local
[[ "$?" != 0 ]] && popd
popd >/dev/null 2>&1
shift
exit
;;
pull-latest)
pushd "$path" >/dev/null 2>&1
git_pull_latest
[[ "$?" != 0 ]] && popd
popd >/dev/null 2>&1
shift
exit
;;
list-branches)
# temporary directory change
pushd "$path" >/dev/null 2>&1
git_list_branches
[[ "$?" != 0 ]] && popd
popd >/dev/null 2>&1
shift
exit
;;
repo-size)
pushd "$path" >/dev/null 2>&1
local size
size=$(git_repo_size)
[[ "$?" != 0 ]] && popd
popd >/dev/null 2>&1
log_info "repo size is $size"
shift
exit
;;

user-stats)
if [[ "$2" != "--name" ]]; then
log_error "[$2] is an invalid flag. existing..."
exit 1
fi
if [[ $# == 2 ]]; then
log_error "git username is needed. existing..."
exit 1
fi
pushd "$path" >/dev/null 2>&1
res=$(git_user_stats "$3")
log_info "$res"
[[ "$?" != 0 ]] && popd
popd >/dev/null 2>&1
shift
exit
;;
clone)
while [[ "$#" -ge 0 ]]; do
shift
if [[ "$#" != 0 ]]; then
local subkey="$1"
case "$subkey" in
--addr)
shift
git_clone "$1"
;;
*)
log_error "Unrecognized option: $subkey"
echo -e "ttttRun '$(basename "$0") --help' for a list of known subcommands." >&2
exit 1
;;
esac
fi

done
shift
exit
;;
--help)
help
exit
;;
*)
log_error "Unrecognized option: $key"
echo -e "ttttRun '$(basename "$0") --help' for a list of known subcommands." >&2
exit 1
;;
esac
shift
done
}

if [ -n ${BASH_SOURCE+x} ]; then
main "${@}"
exit $?
fi
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
else
main "${@}"
exit $?
fi

list=("https://github.com/jbruchon/jdupes "
"https://github.com/openssl/openssl"
"https://github.com/protocolbuffers/protobuf")
