# mbp-fedora

[![Build Status](https://travis-ci.com/mikeeq/mbp-fedora.svg?branch=master)](https://travis-ci.com/mikeeq/mbp-fedora)

Fedora 30 iso with custom kernel built-in and selinux in permissive mode.

Kernel - <https://github.com/mikeeq/mbp-fedora-kernel>

## How to install

- Download .iso from releases
- Burn the image on USB stick >=8GB via:
  - dd - `dd bs=4M if=/home/user/Downloads/livecd-fedora-mbp-201908181858.iso of=/dev/sdc conv=fdatasync  status=progress`
  - rufus (GPT)- <https://rufus.ie/>
  - fedora media writer (custom image option)- <https://getfedora.org/pl/workstation/download/>
  - don't use `livecd-iso-to-disk`, because it's overwriting grub settings
- Install Fedora
- Default user: `fedora` pass: `fedora` (it's created due to gnome-initial-setup issue)

## TODO

- fix gnome-inital-setup
- fix selinux contexts
- add efibootmgr script for testing on VM
- alsa config - audio (mic)

## Known issues

- kernel/mac related issues are mentioned in kernel repo
- gnome-initial-setup is broken - it's crashing - nothing actually happens after user creation during initial setup (it should restart gnome session with created user)
- efibootmgr write command freezes Mac (it's executed in Anaconda during `Install bootloader...` step), probably nvram is blocked from writing
  - `Based on the behavior your describe this is an issue with the firmware and the inability to change NVRAM in the OS` - <https://bugs.launchpad.net/ubuntu/+source/efibootmgr/+bug/1671794/comments/4>

```
efibootmgr --c -w -L Fedora /d /dev/nvme0n1 -p 3 -l \EFI\fedora\shimx64.efi
```

- selinux - some security contexts aren't set, mostly for /run/udev/queue & systemd-journal etc, it's not working even with unmodified kickstart `fedora-live-workstation.ks`  - <https://forums.fedoraforum.org/showthread.php?309922-Getting-lots-of-failures-when-booting-my-LiveCD-with-a-custom-kernel>
![selinux issue](screenshots/selinux.png)

## Docs

### Fedora

- <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/installation_guide/s1-kickstart2-postinstallconfig>
- <https://fedoraproject.org/wiki/LiveOS_image>
- <https://docs.fedoraproject.org/en-US/quick-docs/creating-and-using-a-live-installation-image/>
- <https://forums.fedoraforum.org/showthread.php?309843-Fedora-24-livecd-creator-fails-to-create-initrd>
- <https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html#chapter-1-introduction>
- <https://fedoraproject.org/wiki/QA/Test_Days/Live_Image>
- <https://fedoraproject.org/wiki/How_to_create_a_Fedora_install_ISO_for_testing>
