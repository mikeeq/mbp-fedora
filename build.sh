#!/bin/sh

### Debug commands
pwd
ls
echo "CPU threads: $(nproc --all)"
cat /proc/cpuinfo | grep 'model name' | uniq

dnf install -y git livecd-tools spin-kickstarts

git clone https://pagure.io/fedora-kickstarts.git
cd fedora-kickstarts
git checkout f30

cp -rfv ../fedora-mbp.ks ./
mkdir -p /var/cache/live
while true; do date sleep 30; done &

livecd-creator --verbose --config=fedora-mbp.ks --cache=/var/cache/live

find / | grep ".iso"
