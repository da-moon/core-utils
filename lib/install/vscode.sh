#!/usr/bin/env bash
# shellcheck source=./lib/install/init.sh
source "$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)/install/init.sh"
function vscode_installer() {
    if  os_command_is_available "code"; then
        log_warn "vscode has already been installed...skipping installation." 
        exit 0
    fi
    log_info "started procedure for installing vscode"
    log_info "adding vscode apt repo key"
    add_key "https://packages.microsoft.com/keys/microsoft.asc"
    add_repo "vscode" "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
    local -r packages="code"
    fast_apt "install" "${packages[@]}"
}
export -f vscode_installer
function vscode_extension_installer() {
    if  !os_command_is_available "code"; then
        log_error "vscode_extension_installer cannot proceed forward since code was not found in path."
        exit 1
    fi    
    if  os_command_is_available "go"; then
        log_info "go toolchain detected... installing vscode golang tools"
        go get -u -v github.com/ramya-rao-a/go-outline
        go get -u -v github.com/acroca/go-symbols
        go get -u -v github.com/mdempsky/gocode
        go get -u -v github.com/rogpeppe/godef
        go get -u -v golang.org/x/tools/cmd/godoc
        go get -u -v github.com/zmb3/gogetdoc
        go get -u -v golang.org/x/lint/golint
        go get -u -v github.com/fatih/gomodifytags
        go get -u -v golang.org/x/tools/cmd/gorename
        go get -u -v sourcegraph.com/sqs/goreturns
        go get -u -v golang.org/x/tools/cmd/goimports
        go get -u -v github.com/cweill/gotests/...
        go get -u -v golang.org/x/tools/cmd/guru
        go get -u -v github.com/josharian/impl
        go get -u -v github.com/haya14busa/goplay/cmd/goplay
        go get -u -v github.com/uudashr/gopkgs/cmd/gopkgs
        go get -u -v github.com/davidrjenni/reftools/cmd/fillstruct
        go get -u -v github.com/alecthomas/gometalinter
        gometalinter --install
        go get -u -v github.com/cuonglm/gocmt
        go get -u -v honnef.co/go/tools/cmd/staticcheck
        pushd "${GOPATH}/src/honnef.co/go/tools/cmd/staticcheck" >/dev/null 2>&1
            git checkout 2019.2
            go get
            go install
        [[ "$?" != 0 ]] && popd
        popd >/dev/null 2>&1
    fi
    log_info "installing some helpful vscode extensions"
    code --install-extension esbenp.prettier-vscode
    code --install-extension ms-azuretools.vscode-docker
    code --install-extension ms-python.anaconda-extension-pack
    code --install-extension ms-python.python
    code --install-extension ms-vscode-remote.remote-containers
    code --install-extension ms-vscode-remote.remote-ssh
    code --install-extension ms-vscode-remote.remote-ssh-edit
    code --install-extension ms-vscode-remote.remote-wsl
    code --install-extension ms-vscode-remote.vscode-remote-extensionpack
    code --install-extension ms-vscode.Go
    code --install-extension puorc.awesome-vhdl
    code --install-extension redhat.vscode-yaml
    code --install-extension ripwu.protobuf-helper
    code --install-extension Vinrobot.vhdl-formatter
    code --install-extension wholroyd.HCL
    code --install-extension xaver.clang-format
    code --install-extension zxh404.vscode-proto3
    code --install-extension yzane.markdown-pdf
    code --install-extension yzhang.markdown-all-in-one
    code --install-extension wmaurer.change-case
    code --install-extension alefragnani.Bookmarks
}
export -f vscode_extension_installer