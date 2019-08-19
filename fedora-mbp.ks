# Add rpm repo hosted on heroku https://github.com/mikeeq/mbp-fedora-kernel/releases
repo --name=fedora-mbp --baseurl=http://fedora-mbp-repo.herokuapp.com/

### Selinux in permissive mode
## enforcing=0 is not saved after installation in grub
bootloader --append=" enforcing=0"

### Disable gnome-initial-setup (not working)
eula --agreed
firstboot --disable
services --disabled="initial-setup-graphical"

### Install kernel from hosted rpm repo
%packages

git
gcc
gcc-c++
make
kernel-5.1.19-300.wifi.patch.fc30.x86_64
kernel-core-5.1.19-300.wifi.patch.fc30.x86_64
kernel-devel-5.1.19-300.wifi.patch.fc30.x86_64
kernel-modules-5.1.19-300.wifi.patch.fc30.x86_64
kernel-modules-extra-5.1.19-300.wifi.patch.fc30.x86_64

%end

### Remove other kernel versions than custom one
%post
KERNEL_VERSION=5.1.19-300.wifi.patch.fc30.x86_64

echo 'nameserver 8.8.8.8' > /etc/resolv.conf

rpm -e $(rpm -qa | grep kernel | grep -v headers | grep -v oops | grep -v wifi)

mkdir -p /opt/drivers
git clone https://github.com/MCMrARM/mbp2018-bridge-drv.git /opt/drivers/bce
git clone --single-branch --branch mbp15 https://github.com/roadrunner2/macbook12-spi-driver.git /opt/drivers/touchbar
PATH=/usr/share/Modules/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/bin make -C /lib/modules/${KERNEL_VERSION}/build/ M=/opt/drivers/bce modules
PATH=/usr/share/Modules/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/bin make -C /lib/modules/${KERNEL_VERSION}/build/ M=/opt/drivers/touchbar modules
cp -rf /opt/drivers/bce/*.ko /lib/modules/${KERNEL_VERSION}/extra/
cp -rf /opt/drivers/touchbar/*.ko /lib/modules/${KERNEL_VERSION}/extra/

echo -e 'hid-apple\nbcm5974\nbce' > /etc/modules-load.d/bce.conf
echo -e 'blacklist applesmc' > /etc/modprobe.d/blacklist.conf
echo -e 'add_drivers+="bce hid_apple"' >> /etc/dracut.conf
/usr/sbin/depmod -a ${KERNEL_VERSION}
dracut -f /boot/initramfs-$KERNEL_VERSION.img $KERNEL_VERSION

/usr/sbin/useradd fedora
echo 'fedora' | /usr/bin/passwd fedora --stdin > /dev/null
/usr/sbin/usermod -aG wheel fedora > /dev/null

dnf remove -y kernel-headers
rm -rf /opt/drivers
rm -rf /etc/resolv.conf

echo -e 'exclude=kernel*' >> /etc/dnf/dnf.conf
%end

### Remove efibootmgr part from bootloader installation step in anaconda
%post --nochroot

cp -rfv /tmp/kickstart_files/efi.py /var/tmp/imgcreate-*/install_root/usr/lib64/python3.7/site-packages/pyanaconda/bootloader/efi.py
cp -rfv /tmp/kickstart_files/98-mbp-post-install.ks /var/tmp/imgcreate-*/install_root/usr/share/anaconda/post-scripts/

%end

%include fedora-live-workstation.ks
