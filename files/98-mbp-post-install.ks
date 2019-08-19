%post --nochroot

sed -i s/^SELINUX=.*$/SELINUX=permissive/ $ANA_INSTALL_PATH/etc/selinux/config
touch $ANA_INSTALL_PATH/.autorelabel
# rm -rf /etc/grub.d/30_os-prober
# grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg

%end
