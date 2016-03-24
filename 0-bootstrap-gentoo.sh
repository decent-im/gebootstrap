#!/bin/bash -e

### Boot with Rescue System

### Download this script and execute
### wget https://github.com/decent-im/decent.im-gentoo-installer/raw/master/0-bootstrap-gentoo.sh
### chmod a+x 0-bootstrap-gentoo.sh
### ./0-bootstrap-gentoo.sh

### TODO Create single partition on /dev/sda

### If you really need, create and mount filesystem
### mkfs.ext4 /dev/sda1
### mount /dev/sda1 /mnt
### cd /mnt

# Download stage3
DISTFILES_DIR='http://distfiles.gentoo.org/releases/amd64/autobuilds'
STAGE_PATH=`wget $DISTFILES_DIR/latest-stage3-amd64-hardened+nomultilib.txt -O - -q | tail -1 | sed 's/ .*//'`
wget $DISTFILES_DIR/$STAGE_PATH
tar xaf stage*.tar.*

http://distfiles.gentoo.org/releases/snapshots/current/portage-latest.tar.xz
tar xaf portage-latest.tar.xz -C usr

for x in dev sys proc
do
  mount --rbind {/,}$x
done

wget https://github.com/decent-im/decent.im-gentoo-installer/raw/master/1-bootstrap-gentoo-chroot.sh
chmod a+x 1-bootstrap-gentoo-chroot.sh
chroot . 1-bootstrap-gentoo-chroot.sh
