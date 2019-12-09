#!/bin/sh

# DOCKER_IMAGE=fedora:31
DOCKER_IMAGE=fedora_iso:31
LIVECD_CACHE_PATH=/var/cache/live

docker pull ${DOCKER_IMAGE}
docker run \
  --privileged \
  --device-cgroup-rule="b 7:* rmw" \
  --rm \
  -t \
  -v $(pwd):/repo \
  -v ${LIVECD_CACHE_PATH}:${LIVECD_CACHE_PATH} \
  ${DOCKER_IMAGE} \
  /bin/bash -c 'cd /repo && ./build.sh'
