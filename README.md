# Core-Utils

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io#https://github.com/da-moon/core-utils)

## Outline

this repo consists of a collection of bash executable scripts that would help with improving developer experience in debian/ubuntu.
scripts under `bin` folder are meant to be put in `PATH`. 
They are also all flattened script and they don't source
any other script which helps with usin single `curl` commands to download and add them to path. 
all scripts can also be sourced for usage in other script becasue the main function in each file is exported.

## Executables

- [x] `fast-apt` : uses `aria2`  to download and install apt packages.it should increase `apt install | upgrade | dist-upgrade` 
speed tremendously. You can also use `fast-apt` command instead of `apt-get` since it wraps it. 
- [x] `stream-dl` : uses `aria2` to download a `m3u8` stream (based on given url) and uses ffmpeg to convert it to mkv.
links passed to `stream-dl` must point to `m3u8` main plainlist file. to download multiple streams (multiple playlists),
store the links into a file (eg, `linx`) and run the following 

```bash
while IFS='|' read -r url name;do stream-dl "$name" "$url" < /dev/null ; done <linx
```

- [ ] `fast-docker-pull` : uses `aria2`  to download docker images and adds them to docker engine.
