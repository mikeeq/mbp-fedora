### Add rpm repo hosted on heroku https://github.com/mikeeq/mbp-fedora-kernel/releases
repo --name=fedora-mbp --baseurl=https://fedora-mbp-repo.herokuapp.com/
# TODO: add gpg key for repo
# TODO: make sure BLS is working

### Selinux in permissive mode
bootloader --append="enforcing=0 intel_iommu=on iommu=pt pcie_ports=compat"

### Accepting EULA
eula --agreed

### Install kernel from hosted rpm repo
# https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html#chapter-9-package-selection
%packages

curl
wpa_supplicant
-shim-ia32-15.[0-9]*-[0-9].x86_64
-shim-x64-15.[0-9]*-[0-9].x86_64
-kernel-5.*.fc37.x86_64
kernel-*.*[0-9].mbp.fc36.x86_64
mbp-fedora-t2-config

## Install mbp-fedora-kernel and remove newer shim than 15-8

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

KERNEL_VERSION=6.0.5-200.mbp.fc36.x86_64
UPDATE_SCRIPT_BRANCH=v6.0-f36

/usr/sbin/depmod -a ${KERNEL_VERSION}
dracut -f /boot/initramfs-$KERNEL_VERSION.img $KERNEL_VERSION

### Adding fedora-mbp yum repo gpg key
curl -sSL "https://raw.githubusercontent.com/mikeeq/mbp-fedora-kernel/${UPDATE_SCRIPT_BRANCH}/yum-repo/fedora-mbp.gpg" > ./fedora-mbp.gpg
rpm --import ./fedora-mbp.gpg
rm -rf ./fedora-mbp.gpg

### Remove temporary
mv /etc/resolv.conf_backup /etc/resolv.conf

### Remove not compatible kernels
rpm -e $(rpm -qa | grep kernel | grep -v headers | grep -v oops | grep -v wifi | grep -v mbp)

### Add kernel RPM packages to YUM/DNF exclusions
sed -i '/^type=rpm.*/a exclude=kernel,kernel-core,kernel-devel,kernel-devel-matched,kernel-modules,kernel-modules-extra,kernel-modules-internal,shim-*' /etc/yum.repos.d/fedora*.repo

%end

%post --nochroot
### Copy grub config without finding macos partition
cp -rfv /tmp/kickstart_files/grub/30_os-prober ${INSTALL_ROOT}/etc/grub.d/30_os-prober
chmod 755 ${INSTALL_ROOT}/etc/grub.d/30_os-prober

### Post install anaconda scripts - Reformatting HFS+ EFI partition to FAT32
cp -rfv /tmp/kickstart_files/post-install-kickstart/*.ks ${INSTALL_ROOT}/usr/share/anaconda/post-scripts/

%end
