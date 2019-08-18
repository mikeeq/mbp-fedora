#!/bin/sh

FEDORA_KERNEL_BRANCH_NAME=f30

### Debug commands
echo "FEDORA_KERNEL_BRANCH_NAME=$FEDORA_KERNEL_BRANCH_NAME"
pwd
ls
echo "CPU threads: $(nproc --all)"
cat /proc/cpuinfo | grep 'model name' | uniq

### Dependencies
dnf install -y git livecd-tools

### Clone Fedora kickstarts repo
git clone https://pagure.io/fedora-kickstarts.git
cd fedora-kickstarts
git checkout $FEDORA_KERNEL_BRANCH_NAME

### Copy fedora-mbp kickstart file
cp -rfv ../fedora-mbp.ks ./
mkdir -p /var/cache/live

### Workaround - travis_wait
while true
do
  date
  sleep 30
done &
bgPID=$!

### Generate LiveCD iso
livecd-creator --verbose --config=fedora-mbp.ks --cache=/var/lib/libvirt/live2
livecd_exitcode=$?

find / | grep ".iso"
kill "$bgPID"

exit $livecd_exitcode
