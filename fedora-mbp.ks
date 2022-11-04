### Add rpm repo hosted on heroku https://github.com/mikeeq/mbp-fedora-kernel/releases
repo --name=fedora-mbp --baseurl=https://fedora-mbp-repo.herokuapp.com/

### Selinux in permissive mode
bootloader --append="intel_iommu=on iommu=pt pcie_ports=compat"

### Accepting EULA
eula --agreed

### Install kernel from hosted rpm repo
# https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html#chapter-9-package-selection
%packages

## Install mbp-fedora-kernel, mbp-fedora-t2-config, mbp-fedora-t2-repo
-kernel-5.*.fc37.x86_64
kernel-*.*[0-9].mbp.fc36.x86_64
mbp-fedora-t2-config
mbp-fedora-t2-repo

%end

%post
### Remove not compatible kernels
rpm -e $(rpm -qa | grep kernel | grep -v headers | grep -v oops | grep -v wifi | grep -v mbp)

%end

%post --nochroot
### Post install anaconda scripts - Reformatting HFS+ EFI partition to FAT32 and rebuilding grub config
cp -rfv /tmp/kickstart_files/post-install-kickstart/*.ks ${INSTALL_ROOT}/usr/share/anaconda/post-scripts/

%end
