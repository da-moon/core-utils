# Core-Utils

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io#https://github.com/da-moon/core-utils)

## Outline

this repo consists of a collection of bash executable scripts that would help with improving developer experience in debian/ubuntu.
scripts under `bin` folder are meant to be put in `PATH`. 
They are also all flattened script and they don't source
any other script which helps with usin single `curl` commands to download and add them to path. 
all scripts can also be sourced for usage in other script becasue the main function in each file is exported.

## Executables

- [ ] `get-shfmt`:https://github.com/tmknom/shfmt/blob/master/Dockerfile
- [x] `fast-apt` : uses `aria2`  to download and install apt packages.it should increase `apt install | upgrade | dist-upgrade` 
speed tremendously. You can also use `fast-apt` command instead of `apt-get` since it wraps it. 
- [x] `gitt` : some helper utils and wrappers for `git`
helps with recursively generating a list of md5hashes in a list of given directories and extracting identical files
    - [x] `undo-commit` : undos the latest commit.
    - [x] `reset-local` : reset local repo to match remote branch.
    - [x] `pull-latest` : syncs local with remote.
    - [x] `list-branches` : lists all branches.
    - [ ] `new-branch` : creates a new branch from current and switches into it
    - [x] `repo-size` : calculates the repo size.
    - [x] `user-stats` : gets a user's contribution stats (lines added/deleted)
    - [ ] `clone` : uses aria2 to clone a repo and then extracts it
    - [ ] `latest-release` : gets latest release version or link of a git repo
    - [ ] `install-latest` : downloads and installs latest release of a git repo
- [x] `stream-dl` : uses `aria2` to download a `m3u8` stream (based on given url) and uses ffmpeg to convert it to mkv.
links passed to `stream-dl` must point to `m3u8` main plainlist file. to download multiple streams (multiple playlists),
store the links into a file (eg, `linx`) and run the following 

```bash
while IFS='|' read -r url name;do stream-dl "$name" "$url" < /dev/null ; done <linx
```

- [x] `get-hashi` : uses `aria2` to download latest version of software in hashicorp stack and install them under `/usr/bin`.
by default, it would install `vault`, `consul`, `nomad`, `terraform` and `packer`. if you pass in an input to the 
the command, it would override install targets. e.g.

```bash
get-hashi vault consul
```

- [x] `run-sc` : installs `shellcheck` and runs shellcheck. it is meant to be used with vscode
local setup. install [emeraldwalk.runonsave](https://marketplace.visualstudio.com/items?itemName=emeraldwalk.RunOnSave)
extension and add the following to `$PWD/.vscode/settings.json`

```json
{
    "emeraldwalk.runonsave": {
        "autoClearConsole": true,
        "commands": [
            {
                "isAsync": true,
                "cmd": "run-sc"
            }
        ]
}
```

after this, every time you save a file with `#!/usr/bin/env bash` shebang, it would run shell check on all
workspace files that had the shebang.

- [ ] `get-protobuf` : installs latest version of protobuf compiler.
- [ ] `get-go` : installs latest version of golang compiler and tool chain.
- [ ] `get-java` : installs latest version of java compiler.
- [ ] `futils` : helps with common file/directory related operation
    - [ ] `r-md5` : recursively generate a list of md5 hashes in a list of directories. It can also only output duplicates
    - [ ] `dedup` : remove duplicates in multiple dirs in case they already exist in an origin directory
- [ ] `extract` : automatically detects archive type and extracts it
- [ ] `docker-pull` : uses `aria2`  to download docker images and adds them to docker engine.

## Installation

the following commands assumes you either have `wget` installed

- `fast-apt`

```bash
sudo wget -q -O \
    /usr/bin/fast-apt \
    https://raw.githubusercontent.com/da-moon/core-utils/master/bin/fast-apt && \
sudo chmod +x /usr/bin/fast-apt
```

- `gitt`

```bash
sudo wget -q -O \
    /usr/bin/gitt \
    https://raw.githubusercontent.com/da-moon/core-utils/master/bin/gitt && \
sudo chmod +x /usr/bin/gitt
```

- `stream-dl`

```bash
sudo wget -q -O \
    /usr/bin/stream-dl \
    https://raw.githubusercontent.com/da-moon/core-utils/master/bin/stream-dl && \
sudo chmod +x /usr/bin/stream-dl
```

- `get-hashi`

```bash
sudo wget -q -O \
    /usr/bin/get-hashi \
    https://raw.githubusercontent.com/da-moon/core-utils/master/bin/get-hashi && \
sudo chmod +x /usr/bin/get-hashi
```

- `run-sc`

```bash
sudo wget -q -O \
    /usr/bin/run-sc \
    https://raw.githubusercontent.com/da-moon/core-utils/master/bin/run-sc && \
sudo chmod +x /usr/bin/run-sc
```

## Call Without Installation

if you don't want to add the scripts to your path for whatever reason, you can use the following examples, assuming you have `curl` installed.

- `fast-apt` : the following just installs base dependencies using `fast-apt`

```bash
curl -fsSL \
    https://raw.githubusercontent.com/da-moon/core-utils/master/bin/fast-apt | sudo bash -s -- \
    --init
```

- `get-hashi` : the following installs `consul` and `vault`

```bash
curl -fsSL \
    https://raw.githubusercontent.com/da-moon/core-utils/master/bin/get-hashi | sudo bash -s -- \
    vault \
    consul
```

## issues

- [x] `stream-dl` : install_apts not found
- [ ] `stream-dl` : issues with yarn / ffmpeg-bar install
- [ ] `run-sc` : broken pipe ?
