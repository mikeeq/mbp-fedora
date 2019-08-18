repo --name=fedora-mbp --baseurl=http://fedora-mbp-repo.herokuapp.com/
### Selinux in permissive mode
bootloader --append=" enforcing=0"
### Disable gnome-initial-setup (not working)
firstboot --disable

# root password - root
rootpw root

### Install kernel from https://github.com/mikeeq/mbp-fedora-kernel
%packages

kernel-5.1.19-300.wifi.patch.fc30.x86_64
kernel-core-5.1.19-300.wifi.patch.fc30.x86_64
kernel-devel-5.1.19-300.wifi.patch.fc30.x86_64
kernel-modules-5.1.19-300.wifi.patch.fc30.x86_64
kernel-modules-extra-5.1.19-300.wifi.patch.fc30.x86_64

%end

### Remove other kernel versions than custom one
%post

dnf remove -y $(rpm -qa | grep kernel | grep -v oops | grep -v wifi)
sed -i 's/^SELINUX=.*$/SELINUX=permissive/' /etc/selinux/config
echo "fedora" | passwd fedora --stdin > /dev/null
usermod -aG wheel fedora > /dev/null

%end

%include fedora-live-workstation.ks
