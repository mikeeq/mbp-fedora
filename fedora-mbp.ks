repo --name=fedora-mbp --baseurl=http://fedora-mbp-repo.herokuapp.com/
bootloader --append="selinux=0"

repo --name=fedora --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch --excludepkgs=kernel,kernel-core,kernel-modules,kernel-modules-extra,kernel-devel
repo --name=updates --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f$releasever&arch=$basearch --excludepkgs=kernel,kernel-core,kernel-modules,kernel-modules-extra,kernel-devel

%packages

kernel-5.1.19-300.wifi.patch.fc30.x86_64
kernel-core-5.1.19-300.wifi.patch.fc30.x86_64
kernel-devel-5.1.19-300.wifi.patch.fc30.x86_64
kernel-modules-5.1.19-300.wifi.patch.fc30.x86_64
kernel-modules-extra-5.1.19-300.wifi.patch.fc30.x86_64

%end

%include fedora-live-workstation.ks
