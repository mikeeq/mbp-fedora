#!/bin/sh

DOCKER_IMAGE=fedora:31

docker pull ${DOCKER_IMAGE}
docker run \
  --privileged \
  -t \
  --rm \
  -v $(pwd):/repo \
  ${DOCKER_IMAGE} \
  /bin/bash -c 'cd /repo && ./build.sh'
