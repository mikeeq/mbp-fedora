#!/bin/bash

set -eu -o pipefail

docker build -t fedora_iso:37 .

DOCKER_IMAGE=fedora_iso:37
LIVECD_CACHE_PATH=/var/cache/live

docker run \
  --privileged \
  --rm \
  -e FEDORA_DESKTOP_ENV="${FEDORA_DESKTOP_ENV:-gnome}" \
  -t \
  -v "$(pwd)":/repo \
  -v /dev:/dev \
  -w /repo \
  -v ${LIVECD_CACHE_PATH}:${LIVECD_CACHE_PATH} \
  ${DOCKER_IMAGE} \
  /bin/bash -c './build.sh'
