FROM gitpod/workspace-full
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
RUN wget -q -O /usr/bin/fast-apt https://raw.githubusercontent.com/da-moon/core-utils/master/bin/fast-apt
RUN chmod +x "/usr/bin/fast-apt"
RUN fast-apt --init
RUN wget -q -O /usr/bin/stream-dl https://raw.githubusercontent.com/da-moon/core-utils/master/bin/stream-dl
RUN chmod +x "/usr/bin/stream-dl"
RUN stream-dl --init
# RUN wget -q -O /usr/bin/get-hashi https://raw.githubusercontent.com/da-moon/core-utils/master/bin/get-hashi
# RUN chmod +x "/usr/bin/get-hashi"
# RUN get-hashi
RUN curl -fsSL \
    https://raw.githubusercontent.com/da-moon/core-utils/master/bin/get-hashi | sudo bash -s -- 
RUN wget -q -O /usr/bin/run-sc https://raw.githubusercontent.com/da-moon/core-utils/master/bin/run-sc
RUN chmod +x "/usr/bin/run-sc"
CMD ["bash"]
