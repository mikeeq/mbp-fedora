%post --nochroot

EFI_DEV=$(df | grep '/boot/efi' | awk '{print $1}')
EFI_PARTITION=${EFI_DEV#/dev/nvme0n1p}

if cat ${ANA_INSTALL_PATH}/etc/fstab | grep hfsplus ; then
  ### HFS+ boot partition reformatting to FAT32
  mkdir -p ${ANA_INSTALL_PATH}/opt/efi_backup
  cp -rfv ${ANA_INSTALL_PATH}/boot/efi/* ${ANA_INSTALL_PATH}/opt/efi_backup/
  cp -rfv ${ANA_INSTALL_PATH}/boot/efi/.VolumeIcon.icns ${ANA_INSTALL_PATH}/opt/efi_backup/.VolumeIcon.icns
  umount $EFI_DEV
  mkfs.vfat -F 32 $EFI_DEV
  mount $EFI_DEV ${ANA_INSTALL_PATH}/boot/efi/
  cp -rfv ${ANA_INSTALL_PATH}/opt/efi_backup/* ${ANA_INSTALL_PATH}/boot/efi/
  cp -rfv ${ANA_INSTALL_PATH}/opt/efi_backup/.VolumeIcon.icns ${ANA_INSTALL_PATH}/boot/efi/
  cp -rfv ${ANA_INSTALL_PATH}/boot/efi/EFI/fedora/.disk_label ${ANA_INSTALL_PATH}/boot/efi/System/Library/CoreServices/
  parted /dev/nvme0n1 set ${EFI_PARTITION} msftdata on
  rm -rfv ${ANA_INSTALL_PATH}/opt/efi_backup

  ### Change fstab
  sed -i '/hfsplus/d' ${ANA_INSTALL_PATH}/etc/fstab
  EFI_FAT_UUID=$(blkid ${EFI_DEV} -o export | grep -e '^UUID')
  echo "${EFI_FAT_UUID} /boot/efi vfat defaults 0 2" >> ${ANA_INSTALL_PATH}/etc/fstab

  # touch ${ANA_INSTALL_PATH}/.autorelabel
  # rm -rf /etc/grub.d/30_os-prober
  # grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
else
  echo "OS installed on non-Apple device..."
fi

%end
