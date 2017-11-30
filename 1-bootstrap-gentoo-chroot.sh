#!/bin/bash -e

set -x # Trace execution

. /etc/profile
env-update

# Beware of OOM killer
dd if=/dev/zero of=/swap bs=1M count=4096
mkswap /swap
swapon /swap
echo "/swap none swap defaults" > /etc/fstab
rc-update add swap boot

emerge --sync

gunzip -c /proc/config.gz > /usr/src/livecd.config
emerge gentoo-sources genkernel grub
cd /usr/src/linux

# This config works for Hetzner CX10. YMMV. Change accordingly.
make defconfig kvmconfig
echo "
CONFIG_SCSI_LOWLEVEL=y
CONFIG_SCSI_VIRTIO=y
CONFIG_VIRTIO_INPUT=y
CONFIG_VIRTIO_MMIO=y
CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES=y
" >> .config
make olddefconfig
cp .config /usr/src/kernel.config
genkernel --no-mountboot --kernel-config=/usr/src/kernel.config all

grub-install /dev/sda

# Care about networking setup. Disable upredictable "predictable ifnames"
echo 'GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX rootfstype=ext4 net.ifnames=0"' >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Configure networking
ln -s net.lo /etc/init.d/net.eth0
rc-update add net.eth0 default
echo 'config_eth0="dhcp"' >> /etc/conf.d/net

rc-update add sshd default

# Download my SSH keys. If you are not me, you want to change this
mkdir -p /root/.ssh
wget https://gist.github.com/andrey-utkin/2bb57efd85387edad34e/raw/b9d67d781f70699474154522eb84ff8bd528864d/authorized_keys -O /root/.ssh/authorized_keys

# Install handy stuff
emerge -v \
  gentoolkit \
  \
  syslog-ng \
  logrotate \
  \
  vim \
  app-misc/screen \
  tmux \
  bash-completion \


wget https://github.com/decent-im/gebootstrap/raw/master/2-install-decent-im.sh
chmod a+x 2-install-decent-im.sh
./2-install-decent-im.sh
