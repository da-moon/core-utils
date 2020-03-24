FROM gitpod/workspace-full
USER root
ARG SHELLCHECK_VERSION=stable
ARG SHELLCHECK_FORMAT=gcc
# RUN curl -fsSL \
#     https://raw.githubusercontent.com/da-moon/core-utils/master/bin/fast-apt | sudo bash -s -- \
#     --init
# RUN aria2c "https://storage.googleapis.com/shellcheck/shellcheck-${SHELLCHECK_VERSION}.linux.x86_64.tar.xz"
# RUN tar -xvf shellcheck-"${SHELLCHECK_VERSION}".linux.x86_64.tar.xz
# RUN cp shellcheck-"${SHELLCHECK_VERSION}"/shellcheck /usr/bin/
# RUN shellcheck --version
RUN echo 'export PATH="/workspace/core-utils/bin:$PATH"' >>~/.bashrc
# RUN wget -q -O /usr/bin/stream-dl https://raw.githubusercontent.com/da-moon/core-utils/master/bin/stream-dl
# RUN chmod +x "/usr/bin/stream-dl"
# RUN stream-dl --init
# RUN curl -fsSL \
#     https://raw.githubusercontent.com/da-moon/core-utils/master/bin/get-hashi | sudo bash -s -- 
# RUN wget -q -O /usr/bin/run-sc https://raw.githubusercontent.com/da-moon/core-utils/master/bin/run-sc
# RUN chmod +x "/usr/bin/run-sc"
# RUN wget -q -O /usr/bin/gitt https://raw.githubusercontent.com/da-moon/core-utils/master/bin/gitt
# RUN chmod +x "/usr/bin/gitt"
# RUN gitt --init
RUN echo 'alias make=''make -j$(nproc)''' >>~/.bashrc
CMD ["bash"] 
