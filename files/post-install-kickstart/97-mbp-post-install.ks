%post --nochroot

# Adding Fedora icon and label to Mac boot entry
mkdir -p ${ANA_INSTALL_PATH}/boot/efi/
mkdir -p ${ANA_INSTALL_PATH}/boot/efi/System/Library/CoreServices/

cp -rfv ${ANA_INSTALL_PATH}/usr/share/anaconda/mac_extras/.VolumeIcon.icns ${ANA_INSTALL_PATH}/boot/efi/
cp -rfv ${ANA_INSTALL_PATH}/usr/share/anaconda/mac_extras/.disk_label ${ANA_INSTALL_PATH}/boot/efi/System/Library/CoreServices/

%end
