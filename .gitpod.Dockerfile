FROM gitpod/workspace-full-vnc
USER root
ARG SHELLCHECK_VERSION=stable
ARG SHELLCHECK_FORMAT=gcc
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yqq aria2
RUN aria2c "https://storage.googleapis.com/shellcheck/shellcheck-${SHELLCHECK_VERSION}.linux.x86_64.tar.xz"
RUN tar -xvf shellcheck-"${SHELLCHECK_VERSION}".linux.x86_64.tar.xz
RUN cp shellcheck-"${SHELLCHECK_VERSION}"/shellcheck /usr/bin/
RUN shellcheck --version
RUN echo 'export PATH="/workspace/core-utils/bin:$PATH"' >>~/.bashrc
RUN aria2c --dir="/usr/bin/" --out="fast-apt" "https://raw.githubusercontent.com/da-moon/core-utils/master/bin/fast-apt"
RUN chmod +x "/usr/bin/fast-apt"
RUN fast-apt --init
# RUN aria2c --dir="/usr/bin/" --out="stream-dl" "https://raw.githubusercontent.com/da-moon/core-utils/master/bin/stream-dl"
# RUN chmod +x "/usr/bin/stream-dl"
# RUN stream-dl --init
CMD ["bash"]
