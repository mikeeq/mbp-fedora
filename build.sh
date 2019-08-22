#!/bin/sh

FEDORA_KERNEL_BRANCH_NAME=f30
LIVECD_CACHE_PATH=/var/lib/libvirt/live2
### Debug commands
echo "FEDORA_KERNEL_BRANCH_NAME=$FEDORA_KERNEL_BRANCH_NAME"
pwd
ls
echo "CPU threads: $(nproc --all)"
cat /proc/cpuinfo | grep 'model name' | uniq

### Dependencies
dnf install -y git livecd-tools

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

find ./ | grep ".iso"
kill "$bgPID"

exit $livecd_exitcode
