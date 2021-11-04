#!/bin/bash

set -eu -o pipefail

FEDORA_VERSION=35
FEDORA_KICKSTARTS_GIT_URL=https://pagure.io/fedora-kickstarts.git
FEDORA_KICKSTARTS_BRANCH_NAME=f35
FEDORA_KICKSTARTS_COMMIT_HASH=410251a8a5854d978e22ca8fc902cc8763a72038        # https://pagure.io/fedora-kickstarts/commits/f35
LIVECD_CACHE_PATH=/var/cache/live
ARTIFACT_NAME="livecd-mbp-${FEDORA_KICKSTARTS_BRANCH_NAME}-$(date +'%Y%m%d').zip"

### Debug commands
echo "FEDORA_KICKSTARTS_BRANCH_NAME=${FEDORA_KICKSTARTS_BRANCH_NAME}"
echo "FEDORA_KICKSTARTS_COMMIT_HASH=${FEDORA_KICKSTARTS_COMMIT_HASH}"
pwd
ls
echo "CPU threads: $(nproc --all)"
grep 'model name' /proc/cpuinfo | uniq

### Dependencies
# dnf install -y git curl zip livecd-tools-27.1-9.fc34.x86_64
dnf install -y git curl zip livecd-tools

### Copy efibootmgr fix for anaconda
mkdir -p /tmp/kickstart_files/
cp -rfv files/* /tmp/kickstart_files/

### Clone Fedora kickstarts repo
git clone --single-branch --branch ${FEDORA_KICKSTARTS_BRANCH_NAME} ${FEDORA_KICKSTARTS_GIT_URL}
cd fedora-kickstarts
git checkout $FEDORA_KICKSTARTS_COMMIT_HASH

### Copy fedora-mbp kickstart file
cp -rfv ../fedora-mbp.ks ./
mkdir -p ${LIVECD_CACHE_PATH}

### Workaround - travis_wait
while true
do
  date
  sleep 30
done &
bgPID=$!

### Generate LiveCD iso
livecd-creator --verbose --releasever=${FEDORA_VERSION} --config=fedora-mbp.ks --cache=${LIVECD_CACHE_PATH}
livecd_exitcode=$?

### Zip iso and split it into multiple parts - github max size of release attachment is 2GB, where ISO is sometimes bigger than that
mkdir -p ./output_zip
zip -s 1000m ./output_zip/"${ARTIFACT_NAME}" ./*.iso

### Calculate sha256 sums of built ISO
sha256sum ./output_zip/* > ./output_zip/sha256
sha256sum ./*.iso >> ./output_zip/sha256

find ./ | grep ".iso"
find ./ | grep ".zip"
kill "$bgPID"

exit $livecd_exitcode
