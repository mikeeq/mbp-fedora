### Add rpm repo hosted on heroku https://github.com/mikeeq/mbp-fedora-kernel/releases
repo --name=fedora-mbp --baseurl=http://fedora-mbp-repo.herokuapp.com/

### Selinux in permissive mode
bootloader --append="enforcing=0 efi=noruntime pcie_ports=compat modprobe.blacklist=thunderbolt"

### Accepting EULA
eula --agreed

### Install kernel from hosted rpm repo
%packages

git
gcc
gcc-c++
make
iwd
kernel-5.4.8-200.mbp.fc31.x86_64
kernel-core-5.4.8-200.mbp.fc31.x86_64
kernel-devel-5.4.8-200.mbp.fc31.x86_64
kernel-modules-5.4.8-200.mbp.fc31.x86_64
kernel-modules-extra-5.4.8-200.mbp.fc31.x86_64
kernel-modules-internal-5.4.8-200.mbp.fc31.x86_64

%end


%post
### Add dns server configuration
echo 'nameserver 8.8.8.8' > /etc/resolv.conf

KERNEL_VERSION=5.4.8-200.mbp.fc31.x86_64
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
git clone --single-branch --branch ${BCE_DRIVER_BRANCH_NAME} ${BCE_DRIVER_GIT_URL} /opt/drivers/bce
git -C /opt/drivers/bce/ checkout ${BCE_DRIVER_COMMIT_HASH}

git clone --single-branch --branch ${APPLE_IB_DRIVER_BRANCH_NAME} ${APPLE_IB_DRIVER_GIT_URL} /opt/drivers/touchbar
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

### Remove temporary
dnf remove -y kernel-headers
rm -rf /opt/drivers
rm -rf /etc/resolv.conf

sed -i '/^type=rpm.*/a exclude=kernel,kernel-core,kernel-devel,kernel-modules,kernel-modules-extra,kernel-modules-internal' /etc/yum.repos.d/fedora*.repo
echo -e '[mbp-fedora-kernel]\nname=mbp-fedora-kernel\nbaseurl=http://fedora-mbp-repo.herokuapp.com/\nenabled=1\ngpgcheck=0' > /etc/yum.repos.d/mbp-fedora-kernel.repo
echo -e '[device]\nwifi.backend=iwd' > /etc/NetworkManager/conf.d/wifi_backend.conf
%end


%post --nochroot
### Remove efibootmgr part from bootloader installation step in anaconda
cp -rfv /tmp/kickstart_files/anaconda/efi.py ${INSTALL_ROOT}/usr/lib64/python3.7/site-packages/pyanaconda/bootloader/efi.py

### Post install anaconda scripts - Reformatting HFS+ EFI partition to FAT32
cp -rfv /tmp/kickstart_files/post-install-kickstart/*.ks ${INSTALL_ROOT}/usr/share/anaconda/post-scripts/

### Copy audio config files
mkdir -p ${INSTALL_ROOT}/usr/share/alsa/cards/
cp -rfv /tmp/kickstart_files/audio/AppleT2.conf ${INSTALL_ROOT}/usr/share/alsa/cards/AppleT2.conf
cp -rfv /tmp/kickstart_files/audio/apple-t2.conf ${INSTALL_ROOT}/usr/share/pulseaudio/alsa-mixer/profile-sets/apple-t2.conf
cp -rfv /tmp/kickstart_files/audio/91-pulseaudio-custom.rules ${INSTALL_ROOT}/usr/lib/udev/rules.d/91-pulseaudio-custom.rules

### Copy suspend fix
cp -rfv /tmp/kickstart_files/suspend/rmmod_tb.sh ${INSTALL_ROOT}/lib/systemd/system-sleep/rmmod_tb.sh
chmod +x ${INSTALL_ROOT}/lib/systemd/system-sleep/rmmod_tb.sh

%end


%include fedora-live-workstation.ks
