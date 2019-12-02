#!/bin/sh

FEDORA_KERNEL_BRANCH_NAME=f31
LIVECD_CACHE_PATH=/var/cache/live

### Debug commands
echo "FEDORA_KERNEL_BRANCH_NAME=$FEDORA_KERNEL_BRANCH_NAME"
pwd
ls
echo "CPU threads: $(nproc --all)"
cat /proc/cpuinfo | grep 'model name' | uniq

### Dependencies
dnf install -y git livecd-tools zip

### Copy efibootmgr fix for anaconda
mkdir -p /tmp/kickstart_files/
cp -rfv files/* /tmp/kickstart_files/

### Clone Fedora kickstarts repo
git clone https://pagure.io/fedora-kickstarts.git
cd fedora-kickstarts
git checkout $FEDORA_KERNEL_BRANCH_NAME

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
livecd-creator --verbose --config=fedora-mbp.ks --cache=${LIVECD_CACHE_PATH}
livecd_exitcode=$?

### Zip iso and split it into multiple parts - github max size of release attachment is 2GB, where ISO is sometimes bigger than that
mkdir -p ./output_zip
zip -s 1500m ./output_zip/livecd.zip *.iso

find ./ | grep ".iso"
find ./ | grep ".zip"
kill "$bgPID"

exit $livecd_exitcode
