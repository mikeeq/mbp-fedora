#!/bin/sh

rm -rf /opt/drivers

### PART FROM KICKSTART

KERNEL_VERSION=5.3.15-300.mbp.fc31.x86_64
BCE_DRIVER_GIT_URL=https://github.com/MCMrARM/mbp2018-bridge-drv.git
BCE_DRIVER_BRANCH_NAME=master
BCE_DRIVER_COMMIT_HASH=7330e638b9a32b4ae9ea97857f33838b5613cad3
APPLE_IB_DRIVER_GIT_URL=https://github.com/roadrunner2/macbook12-spi-driver.git
APPLE_IB_DRIVER_BRANCH_NAME=mbp15
APPLE_IB_DRIVER_COMMIT_HASH=90cea3e8e32db60147df8d39836bd1d2a5161871

### Remove not compatible kernels
rpm -e $(rpm -qa | grep kernel | grep -v headers | grep -v oops | grep -v wifi | grep -v mbp)

### Install custom drivers
mkdir -p /opt/drivers
git clone --single-branch --branch ${BCE_DRIVER_BRANCH_NAME} https://github.com/MCMrARM/mbp2018-bridge-drv.git /opt/drivers/bce
git -C /opt/drivers/bce/ checkout ${BCE_DRIVER_COMMIT_HASH}

### Patch bce for kernel 5.3
git -C /opt/drivers/bce apply $(pwd)/files/patches/bce_5_3.patch

git clone --single-branch --branch ${APPLE_IB_DRIVER_BRANCH_NAME} https://github.com/roadrunner2/macbook12-spi-driver.git /opt/drivers/touchbar
git -C /opt/drivers/touchbar/ checkout ${APPLE_IB_DRIVER_COMMIT_HASH}
PATH=/usr/share/Modules/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/bin make -C /lib/modules/${KERNEL_VERSION}/build/ M=/opt/drivers/bce modules
PATH=/usr/share/Modules/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/bin make -C /lib/modules/${KERNEL_VERSION}/build/ M=/opt/drivers/touchbar modules
cp -rf /opt/drivers/bce/*.ko /lib/modules/${KERNEL_VERSION}/extra/
cp -rf /opt/drivers/touchbar/*.ko /lib/modules/${KERNEL_VERSION}/extra/

### Add custom drivers to be loaded at boot
echo -e 'hid-apple\nbcm5974\nsnd-seq\nbce' > /etc/modules-load.d/bce.conf
echo -e 'blacklist thunderbolt' > /etc/modprobe.d/blacklist.conf
echo -e 'add_drivers+="hid_apple snd-seq bce"\nforce_drivers+="hid_apple snd-seq bce"' > /etc/dracut.conf
/usr/sbin/depmod -a ${KERNEL_VERSION}
dracut -f /boot/initramfs-$KERNEL_VERSION.img $KERNEL_VERSION
