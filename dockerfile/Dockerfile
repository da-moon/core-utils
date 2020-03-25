FROM debian

ARG SHELLCHECK_VERSION=stable
ARG SHELLCHECK_FORMAT=gcc
USER root
RUN apt-get update && apt-get install -yqq curl
RUN curl -fsSL \
    https://raw.githubusercontent.com/da-moon/core-utils/master/bin/fast-apt | bash -s -- \
    --init

ENV HOME=/home/gitpod

RUN useradd -l -u 33333 -G sudo -md /home/gitpod -s /bin/bash -p gitpod gitpod \
    # passwordless sudo for users in the 'sudo' group
    && sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers
ENV HOME=/home/gitpod

WORKDIR $HOME

# custom Bash prompt
RUN { echo && echo "PS1='\[\e]0;\u \w\a\]\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \\\$ '" ; } >> .bashrc

### Gitpod user (2) ###
USER gitpod
# use sudo so that user does not get sudo usage info on (the first) login
RUN sudo echo "Running 'sudo' for Gitpod: success" && \
    # create .bashrc.d folder and source it in the bashrc
    mkdir /home/gitpod/.bashrc.d && \
    (echo; echo "for i in \$(ls \$HOME/.bashrc.d/*); do source \$i; done"; echo) >> /home/gitpod/.bashrc
# installing shell check
USER root
RUN aria2c "https://storage.googleapis.com/shellcheck/shellcheck-${SHELLCHECK_VERSION}.linux.x86_64.tar.xz"
RUN tar -xvf shellcheck-"${SHELLCHECK_VERSION}".linux.x86_64.tar.xz
RUN cp shellcheck-"${SHELLCHECK_VERSION}"/shellcheck /usr/bin/
RUN shellcheck --version
