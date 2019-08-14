# mbp-fedora
[![Build Status](https://travis-ci.org/mikeeq/mbp-fedora.svg?branch=master)](https://travis-ci.org/mikeeq/mbp-fedora)

Fedora 30 iso with custom kernel built-in and selinux disabled.

Kernel - <https://github.com/mikeeq/mbp-fedora-kernel>

## Known issues:

- selinux - i don't know why but with selinux enabled livecd iso don't want to boot? Several systemd services are failling to start, like: journal or gnome desktop env. ![selinux issue](screenshots/selinux.png)
- kernel/mac related issues you will find in kernel repo

## Docs:

### Fedora:

- <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/installation_guide/s1-kickstart2-postinstallconfig>
- <https://fedoraproject.org/wiki/LiveOS_image>
- <https://docs.fedoraproject.org/en-US/quick-docs/creating-and-using-a-live-installation-image/>
- <https://forums.fedoraforum.org/showthread.php?309843-Fedora-24-livecd-creator-fails-to-create-initrd>
- <https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html#chapter-1-introduction>
- <https://fedoraproject.org/wiki/QA/Test_Days/Live_Image>
