#!/bin/bash

set -eu -o pipefail

DOCKER_IMAGE=fedora:34

docker pull ${DOCKER_IMAGE}
docker run \
  --privileged \
  --rm \
  -e FEDORA_DESKTOP_ENV="${FEDORA_DESKTOP_ENV:-gnome}" \
  -t \
  -v "$(pwd)":/repo \
  ${DOCKER_IMAGE} \
  /bin/bash -c 'cd /repo && ./build.sh'
