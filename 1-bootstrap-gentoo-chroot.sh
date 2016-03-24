#!/bin/bash -e

# This is Part 2 of https://gist.github.com/andrey-utkin/8edf529233ce3aa86cea

set -x # Trace execution

. /etc/profile
env-update

dd if=/dev/zero of=/swap bs=1M count=4096
mkswap /swap
echo "/swap none swap defaults" >> /etc/fstab

gunzip -c /proc/config.gz /usr/src/livecd.config
emerge hardened-sources
cd /usr/src/linux
cp ../livecd.config .config
make localmodconfig
cp .config ../localmodconfig.config
genkernel --kernel-config=/usr/src/localmodconfig.config all

grub2-install /dev/sda
grub2-mkconfig -o /boot/grub/grub.conf

mkdir -p /root/.ssh
wget https://gist.github.com/andrey-utkin/2bb57efd85387edad34e -O /root/.ssh/authorized_keys

### Install important stuff
emerge -v \
  gentoolkit \
  eselect \
  \
  syslog-ng \
  logrotate \
  \
  app-editors/vim \
  screen \
  tmux \
  bash-completion \


wget https://gist.github.com/andrey-utkin/04640c05d52c1a35a9f7 -O decent.im-install.sh
chmod a+x decent.im-install.sh
./decent.im-install.sh