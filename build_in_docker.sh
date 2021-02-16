#!/bin/bash

set -eu -o pipefail

DOCKER_IMAGE=fedora:33

docker pull ${DOCKER_IMAGE}
docker run \
  --privileged \
  --rm \
  -t \
  -v "$(pwd)":/repo \
  ${DOCKER_IMAGE} \
  /bin/bash -c 'cd /repo && ./build.sh'
