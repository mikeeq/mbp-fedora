# mbp-fedora

[![Build Status](https://travis-ci.com/mikeeq/mbp-fedora.svg?branch=master)](https://travis-ci.com/mikeeq/mbp-fedora)

Fedora 30 ISO with Apple T2 patches built-in (Macbooks produced >= 2018).

All available Apple T2 drivers are integrated with this iso. Most things work, besides those mentioned in [not working section](#not-working).

Kernel - <https://github.com/mikeeq/mbp-fedora-kernel>

Drivers:

- Apple T2 (audio, keyboard, touchpad) - <https://github.com/MCMrARM/mbp2018-bridge-drv>
- Touchbar - <https://github.com/roadrunner2/macbook12-spi-driver/tree/mbp15>

## How to install

- Turn off secure boot - <https://support.apple.com/en-us/HT208330>
- Download .iso from releases section - <https://github.com/mikeeq/mbp-fedora/releases/latest>
  - If it's splitted into multiple zip parts, you need to join splitted files into one and then extract it via `unzip` or extract them directly via `7z x` or `7za x`
    - <https://unix.stackexchange.com/questions/40480/how-to-unzip-a-multipart-spanned-zip-on-linux>
- Burn the image on USB stick >=8GB via:
  - dd - `dd bs=4M if=/home/user/Downloads/livecd-fedora-mbp-201908181858.iso of=/dev/sdc conv=fdatasync status=progress`
  - rufus (GPT)- <https://rufus.ie/>
  - fedora media writer (custom image option)- <https://getfedora.org/en/workstation/download/>
  - don't use `livecd-iso-to-disk`, because it's overwriting grub settings
- Install Fedora
  - Boot directly from MacOS boot manager. (You can boot into it by pressing and holding option key after clicking power-on button).
    - There will be three boot options available, usually the third one works for me. (There are three of them, because there are three partitions in ISO: 1) ISO9660: with installer data, 2) fat32, 3) hfs+)
  - You should use standard partition layout during partitioning your Disk in anaconda, because i haven't tested LVM scenario yet. <https://github.com/mikeeq/mbp-fedora/issues/2>
    - /boot/efi - 1024MB Linux HFS+ ESP
    - /boot - 1024MB EXT4
    - / - xxxGB EXT4
- Login with default user: `fedora` pass: `fedora` (it's created due to gnome-initial-setup issue)
- Put wifi firmware files to `/lib/firmware/brcm/`
  - tutorial - <https://github.com/mikeeq/mbp-fedora-kernel/#working-with-mbp-fedora-kernel>
- You can put back SELinux in enforcing mode by changing the value in `/etc/selinux/config` but remember about relabelling your OS partition `touch /.autorelabel` before changing SELinux mode

## Not working

- Dynamic audio input/output change (on connecting/disconnecting headphones jack)
- Suspend/Resume (sleep mode)
- TouchID - (@MCMrARM is working on it - https://github.com/Dunedan/mbp-2016-linux/issues/71#issuecomment-528545490)

## TODO

- fix gnome-inital-setup
- fix selinux security contexts
- alsa/pulseaudio config
  - Dynamic audio input/output change (on connecting/disconnecting headphones jack)
- disable iBridge network interface (awkward internal Ethernet device?)
- disable not working camera device
  - there are two video devices (web cameras) initialized/discovered, don't know why yet

  ```
  ➜ ls -l /sys/class/video4linux/
  total 0
  lrwxrwxrwx. 1 root root 0 Aug 23 15:14 video0 -> ../../devices/pci0000:00/0000:00:1d.4/0000:02:00.1/bce/bce/bce-vhci/usb7/7-2/7-2:1.0/video4linux/video0
  lrwxrwxrwx. 1 root root 0 Aug 23 15:14 video1 -> ../../devices/pci0000:00/0000:00:1d.4/0000:02:00.1/bce/bce/bce-vhci/usb7/7-2/7-2:1.0/video4linux/video1
  ➜ cat /sys/class/video4linux/*/dev
  81:0
  81:1
  ```

- verify `brcmf_chip_tcm_rambase` returns

## Known issues

- Kernel/Mac related issues are mentioned in kernel repo
- Anaconda sometimes could not finish installation process and it's freezing on `Network Configuration` step, probably due to iBridge internal network interface

> workaround - it's a final step of installation, just reboot your Mac (installation is complete)

- Wifi could have problems with connecting to secure networks (WPA2)
  - wpa_supplicant error - `CTRL-EVENT-ASSOC-REJECT bssid= status_code=16`
    - there are two workaround available:
      - you can stick with wpa_supplicant as wifi backend and you will need to reload broadcom module every time you connect to network

      ```
      ## Run as root
      modprobe -r brcmfmac; modprobe brcmfmac
      ```

      - or you can change your wifi backend to iwd (it's less problematic, it's crashing sometimes, but it's more stable than wpa_supplicant [with broadcom wifi])

      ```
      ## Run all commands as root
      # install NetworkManager with iwd support
      dnf copr enable nyk/networkmanager-iwd
      dnf update NetworkManager

      # Change wifi backend which NetworkManager is using
      vi /etc/NetworkManager/conf.d/wifi_backend.conf

      [device]
      wifi.backend=iwd

      # enable iwd autostart
      systemctl enable iwd

      # start iwd
      /usr/libexec/iwd
      systemctl start iwd
      systemctl restart NetworkManager
      ```

- Macbooks with Apple T2 can't boot EFI binaries from HFS+ formatted ESP - only FAT32 (FAT32 have to be labelled as msftdata).

> workaround applied - HFS+ ESP is reformatted to FAT32 in post-scripts step and labelled as `msftdata`

- gnome-initial-setup is broken - nothing actually happens after user creation during initial setup (it should restart gnome session with created user)

> workaround applied - default Fedora user created

- efibootmgr write command freezes Mac (it's executed in Anaconda during `Install bootloader...` step), probably nvram is blocked from writing
  - `Based on the behavior your describe this is an issue with the firmware and the inability to change NVRAM in the OS` - <https://bugs.launchpad.net/ubuntu/+source/efibootmgr/+bug/1671794/comments/4>

```
efibootmgr --c -w -L Fedora /d /dev/nvme0n1 -p 3 -l \EFI\fedora\shimx64.efi
```

> workaround applied - efibootmgr execution is removed from anaconda

- SELinux - some security contexts aren't set, mostly for `/run/udev/queue` & `systemd-journal` etc, it's not working even with unmodified kickstart `fedora-live-workstation.ks`  - <https://forums.fedoraforum.org/showthread.php?309922-Getting-lots-of-failures-when-booting-my-LiveCD-with-a-custom-kernel>

> workaround applied - SELinux is set to work in permissive mode `/etc/selinux/config`

![selinux issue](screenshots/selinux.png)

## Docs

### Fedora

- <https://fedoraproject.org/wiki/LiveOS_image>
- <https://docs.fedoraproject.org/en-US/quick-docs/creating-and-using-a-live-installation-image/>
- <https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html#chapter-1-introduction>
- <https://forums.fedoraforum.org/showthread.php?309843-Fedora-24-livecd-creator-fails-to-create-initrd>
- <https://fedoraproject.org/wiki/QA/Test_Days/Live_Image>
- <https://fedoraproject.org/wiki/How_to_create_a_Fedora_install_ISO_for_testing>

### Github

- GitHub issue (RE history): <https://github.com/Dunedan/mbp-2016-linux/issues/71>
- VHCI+Sound driver (Apple T2): <https://github.com/MCMrARM/mbp2018-bridge-drv/>
- hid-apple keyboard backlight patch: <https://github.com/MCMrARM/mbp2018-etc>
- alsa/pulseaudio config files: <https://gist.github.com/MCMrARM/c357291e4e5c18894bea10665dcebffb>
- TouchBar driver: <https://github.com/roadrunner2/macbook12-spi-driver/tree/mbp15>
- Kernel patches (all are mentioned in github issue above): <https://github.com/aunali1/linux-mbp-arch>
- ArchLinux kernel patches: <https://github.com/ppaulweber/linux-mba>

## Credits

- @MCMrARM - thanks for all RE work
- @ozbenh - thanks for submitting NVME patch
- @roadrunner2 - thanks for SPI (touchbar) driver
- @aunali1 - thanks for ArchLinux Kernel CI
- @ppaulweber - thanks for keyboard and Macbook Air patches
