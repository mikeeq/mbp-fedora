### Add rpm repo hosted on heroku https://github.com/mikeeq/mbp-fedora-kernel/releases
repo --name=fedora-mbp --baseurl=http://fedora-mbp-repo.herokuapp.com/

### Selinux in permissive mode
bootloader --append="enforcing=0 efi=noruntime pcie_ports=compat"

### Accepting EULA
eula --agreed

### Install kernel from hosted rpm repo
%packages

git
gcc
gcc-c++
make
iwd
wpa_supplicant
-shim-ia32-15.4-*.x86_64
-shim-x64-15.4-*.x86_64
-kernel-5.*.fc36.x86_64
-kernel-core-5.*.fc36.x86_64
-kernel-devel-5.*.fc36.x86_64
-kernel-devel-matched-5.*.fc36.x86_64
-kernel-modules-5.*.fc36.x86_64
-kernel-modules-extra-5.*.fc36.x86_64
-kernel-modules-internal-5.*.fc36.x86_64
kernel-5.18.5-200.mbp.fc33.x86_64
kernel-core-5.18.5-200.mbp.fc33.x86_64
kernel-devel-5.18.5-200.mbp.fc33.x86_64
kernel-devel-matched-5.18.5-200.mbp.fc33.x86_64
kernel-modules-5.18.5-200.mbp.fc33.x86_64
kernel-modules-extra-5.18.5-200.mbp.fc33.x86_64
kernel-modules-internal-5.18.5-200.mbp.fc33.x86_64

%end


%post
### Add dns server configuration
echo "===]> Info: Printing PWD"
pwd
echo "===]> Info: Printing /etc/resolv.conf"
cat /etc/resolv.conf
echo "===]> Info: Listing /etc/resolv.conf"
ls -la /etc/resolv.conf
echo "===]> Info: Renaming default /etc/resolv.conf"
mv /etc/resolv.conf /etc/resolv.conf_backup
echo "===]> Info: Add Google DNS to /etc/resolv.conf"
echo 'nameserver 8.8.8.8' > /etc/resolv.conf
echo "===]> Info: Print /etc/resolv.conf"
cat /etc/resolv.conf

KERNEL_VERSION=5.18.5-200.mbp.fc33.x86_64
UPDATE_SCRIPT_BRANCH=v5.18-f36

### Remove not compatible kernels
rpm -e $(rpm -qa | grep kernel | grep -v headers | grep -v oops | grep -v wifi | grep -v mbp)

### Add custom drivers to be loaded at boot
echo -e 'hid-apple\nbcm5974\nsnd-seq\napple_bce' > /etc/modules-load.d/apple_bce.conf
echo -e 'add_drivers+=" hid_apple snd-seq apple_bce "\nforce_drivers+=" hid_apple snd-seq apple_bce "' > /etc/dracut.conf
/usr/sbin/depmod -a ${KERNEL_VERSION}
dracut -f /boot/initramfs-$KERNEL_VERSION.img $KERNEL_VERSION

### Add update_kernel_mbp script
curl -L https://raw.githubusercontent.com/mikeeq/mbp-fedora-kernel/${UPDATE_SCRIPT_BRANCH}/update_kernel_mbp.sh -o /usr/bin/update_kernel_mbp
chmod +x /usr/bin/update_kernel_mbp

### Remove temporary
dnf remove -y kernel-headers
rm -rf /opt/drivers
mv /etc/resolv.conf_backup /etc/resolv.conf

### Add kernel RPM packages to YUM/DNF exclusions
sed -i '/^type=rpm.*/a exclude=kernel,kernel-core,kernel-devel,kernel-devel-matched,kernel-modules,kernel-modules-extra,kernel-modules-internal,shim-*' /etc/yum.repos.d/fedora*.repo

%end

%post --nochroot
### Copy grub config without finding macos partition
cp -rfv /tmp/kickstart_files/grub/30_os-prober ${INSTALL_ROOT}/etc/grub.d/30_os-prober
chmod 755 ${INSTALL_ROOT}/etc/grub.d/30_os-prober

### Post install anaconda scripts - Reformatting HFS+ EFI partition to FAT32
cp -rfv /tmp/kickstart_files/post-install-kickstart/*.ks ${INSTALL_ROOT}/usr/share/anaconda/post-scripts/

### Copy audio config files
mkdir -p ${INSTALL_ROOT}/usr/share/alsa/cards/
cp -rfv /tmp/kickstart_files/audio/AppleT2.conf ${INSTALL_ROOT}/usr/share/alsa/cards/AppleT2.conf
cp -rfv /tmp/kickstart_files/audio/apple-t2.conf ${INSTALL_ROOT}/usr/share/alsa-card-profile/mixer/profile-sets/apple-t2.conf
cp -rfv /tmp/kickstart_files/audio/91-pulseaudio-custom.rules ${INSTALL_ROOT}/usr/lib/udev/rules.d/91-pulseaudio-custom.rules

### Copy suspend fix
cp -rfv /tmp/kickstart_files/suspend/rmmod_tb.sh ${INSTALL_ROOT}/lib/systemd/system-sleep/rmmod_tb.sh
chmod +x ${INSTALL_ROOT}/lib/systemd/system-sleep/rmmod_tb.sh

%end
