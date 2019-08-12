%include fedora-live-workstation.ks

%post

echo 'nameserver 8.8.8.8' > /etc/resolv.conf
dnf remove -y kernel
rpm -ivh https://github.com/mikeeq/mbp-fedora-kernel/releases/download/v5.2.8/kernel-5.2.8-200.wifi.patch.fc30.x86_64.rpm https://github.com/mikeeq/mbp-fedora-kernel/releases/download/v5.2.8/kernel-core-5.2.8-200.wifi.patch.fc30.x86_64.rpm https://github.com/mikeeq/mbp-fedora-kernel/releases/download/v5.2.8/kernel-modules-5.2.8-200.wifi.patch.fc30.x86_64.rpm https://github.com/mikeeq/mbp-fedora-kernel/releases/download/v5.2.8/kernel-modules-extra-5.2.8-200.wifi.patch.fc30.x86_64.rpm https://github.com/mikeeq/mbp-fedora-kernel/releases/download/v5.2.8/kernel-devel-5.2.8-200.wifi.patch.fc30.x86_64.rpm
rm -rf /etc/resolv.conf

%end
