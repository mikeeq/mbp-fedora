FROM fedora:36

RUN dnf upgrade -y \
  && dnf install -y \
    git \
    curl \
    zip \
    make \
    livecd-tools
