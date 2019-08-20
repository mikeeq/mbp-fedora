%post --nochroot

EFI_DEV=$(df | grep '/boot/efi' | awk '{print $1})

### Set SELinux to run in permissive mode
sed -i s/^SELINUX=.*$/SELINUX=permissive/ $ANA_INSTALL_PATH/etc/selinux/config

### HFS+ boot partition reformatting to FAT32
mkdir -p /opt/efi_backup
cp -rfv $ANA_INSTALL_PATH/boot/efi/* /opt/efi_backup/
umount $EFI_DEV
mkfs.vfat -F 32 $EFI_DEV
mount $EFI_DEV $ANA_INSTALL_PATH/boot/efi/
cp -rfv /opt/efi_backup/* $ANA_INSTALL_PATH/boot/efi/

# touch $ANA_INSTALL_PATH/.autorelabel
# rm -rf /etc/grub.d/30_os-prober
# grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg

%end
