#!/bin/bash -e

### TODO Boot with Rescue System
### Download this script and execute
### wget https://gist.github.com/andrey-utkin/8edf529233ce3aa86cea -o bootstrap-gentoo.sh
### chmod bootstrap-gentoo.sh
### ./bootstrap-gentoo.sh

### TODO Create single partition on /dev/sda

mkfs.ext4 /dev/sda1
mount /dev/sda1 /mnt
cd /mnt

### TODO Download and extract stage3
tar xaf stage*.tar.*
http://distfiles.gentoo.org/releases/snapshots/current/portage-latest.tar.xz
tar xaf portage-latest.tar.xz -C usr

for x in dev sys proc
do
  mount --rbind {/,}$x
done

wget https://gist.github.com/andrey-utkin/103dfe4f39d5b4ddc5de -O bootstrap-gentoo-chroot.sh
chmod a+x bootstrap-gentoo-chroot.sh
chroot . bootstrap-gentoo-chroot.sh

reboot
