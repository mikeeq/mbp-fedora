repo --name=fedora-mbp --baseurl=http://fedora-mbp-repo.herokuapp.com/

%include fedora-live-workstation.ks

%post --nochroot

sed -i -e '/rhgb/s/$/ selinux=0/' $(ls /var/tmp/*/iso-*/EFI/BOOT/grub.cfg)

%end
