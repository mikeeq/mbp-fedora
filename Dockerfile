FROM fedora:35

RUN dnf upgrade -y \
  && dnf install -y \
    git \
    curl \
    zip \
    make \
    livecd-tools
