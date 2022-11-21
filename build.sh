#!/bin/bash

set -eu -o pipefail

CURRENT_PWD=$(pwd)
FEDORA_VERSION=37
FEDORA_KICKSTARTS_GIT_URL=https://pagure.io/fedora-kickstarts.git
FEDORA_KICKSTARTS_BRANCH_NAME=f37
FEDORA_KICKSTARTS_COMMIT_HASH=a000cf7510a9304aec2374112627c0a727389a12        # https://pagure.io/fedora-kickstarts/commits/f37
LIVECD_TOOLS_GIT_URL=https://github.com/livecd-tools/livecd-tools
LIVECD_TOOLS_GIT_BRANCH_NAME=main
LIVECD_TOOLS_GIT_COMMIT_HASH=51bd0fefdfd6c06c03990d46b4e7d838cefc9da4
LIVECD_CACHE_PATH=/var/cache/live

FEDORA_DESKTOP_ENV="${FEDORA_DESKTOP_ENV:-}"
ARTIFACT_NAME="livecd-mbp-${FEDORA_KICKSTARTS_BRANCH_NAME}-${FEDORA_DESKTOP_ENV}-$(date +'%Y%m%d').zip"

### Debug commands
echo "FEDORA_KICKSTARTS_BRANCH_NAME=${FEDORA_KICKSTARTS_BRANCH_NAME}"
echo "FEDORA_KICKSTARTS_COMMIT_HASH=${FEDORA_KICKSTARTS_COMMIT_HASH}"
pwd
ls
echo "CPU threads: $(nproc --all)"
grep 'model name' /proc/cpuinfo | uniq

echo >&2 "===]> Info: Installing dependencies..."
dnf install -y \
  git \
  curl \
  zip \
  make \
  livecd-tools


[ -x "$(command -v python)" ] || ln -s /usr/bin/python3 /usr/bin/python

echo >&2 "===]> Info: Install livecd-tools from git"
git clone --single-branch --branch ${LIVECD_TOOLS_GIT_BRANCH_NAME} ${LIVECD_TOOLS_GIT_URL} /tmp/livecd-tools
cd /tmp/livecd-tools
git checkout $LIVECD_TOOLS_GIT_COMMIT_HASH
make install
cd "${CURRENT_PWD}"

echo >&2 "===]> Info: Copy files to /tmp/kickstart_files/ path"
mkdir -p /tmp/kickstart_files/
cp -rfv files/* /tmp/kickstart_files/

echo >&2 "===]> Info: Clone Fedora kickstarts repo"
git clone --single-branch --branch ${FEDORA_KICKSTARTS_BRANCH_NAME} ${FEDORA_KICKSTARTS_GIT_URL} /tmp/fedora-kickstarts
cd /tmp/fedora-kickstarts
git checkout $FEDORA_KICKSTARTS_COMMIT_HASH

echo >&2 "===]> Info: Copy fedora-mbp kickstart file"
cp -rfv "${CURRENT_PWD}"/fedora-mbp*.ks ./
mkdir -p ${LIVECD_CACHE_PATH}

### Workaround - travis_wait
while true
do
  date
  sleep 30
done &
bgPID=$!

echo >&2 "===]> Info: Generate LiveCD iso - fedora-mbp-${FEDORA_DESKTOP_ENV}.ks"
livecd-creator --verbose --releasever=${FEDORA_VERSION} --config="fedora-mbp-${FEDORA_DESKTOP_ENV}.ks" --cache=${LIVECD_CACHE_PATH}
livecd_exitcode=$?

echo >&2 "===]> Info: Move iso artifact to repo dir"
cp -rfv ./*.iso "${CURRENT_PWD}"/
cd "${CURRENT_PWD}"

echo >&2 "===]> Info: Zip iso and split it into multiple parts"
# Github max size of release attachment is 2GB, where ISO is sometimes bigger than that
mkdir -p ./output_zip
du -sh ./*.iso
zip -s 800m ./output_zip/"${ARTIFACT_NAME}" ./*.iso

echo >&2 "===]> Info: Calculate sha256 sums of built ISO"
sha256sum ./output_zip/* > "./output_zip/sha256_${FEDORA_DESKTOP_ENV}"
sha256sum ./*.iso >> "./output_zip/sha256_${FEDORA_DESKTOP_ENV}"

cat "./output_zip/sha256_${FEDORA_DESKTOP_ENV}"

find ./ | grep ".iso"
find ./ | grep ".zip"
kill "$bgPID"

exit $livecd_exitcode
