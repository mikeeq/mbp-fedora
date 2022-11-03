#!/bin/bash

set -eu -o pipefail

DOCKER_IMAGE=fedora:36

docker pull ${DOCKER_IMAGE}
docker run \
  --privileged \
  --rm \
  -e FEDORA_DESKTOP_ENV="${FEDORA_DESKTOP_ENV:-gnome}" \
  -t \
  -v "$(pwd)":/repo \
  -w /repo \
  ${DOCKER_IMAGE} \
  /bin/bash -c './build.sh'
