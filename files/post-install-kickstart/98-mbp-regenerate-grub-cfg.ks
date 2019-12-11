%post

grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
grub2-editenv - set "$(grub2-editenv - list | grep kernelopts) efi=noruntime modprobe.blacklist=thunderbolt"

%end
