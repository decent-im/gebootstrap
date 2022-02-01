===================================
Bootstrap tool for decent.im server
===================================

Supported usecases
------------------

* Chroot
* Virtual machine, VPS

Should work for Docker, too.

How to use
----------

Follow the step sequence per the table below.


===========================  ========  =========  ============
 Step                         Chroot    VM, VPS    How?
===========================  ========  =========  ============
Boot into rescue system       Skip      Do         Manually
Partition and format disk     Skip      Do         Manually
Add swap                      Skip      Do         Manually
Deploy gebootstrap scripts    Do        Do         Put ``gebootstrap/`` dir where rootfs is to be
Deploy stage3                 Do        Do         Run ``gebootstrap/1000_deploy_stage3``, or use your stage4 or what you have
Deploy Gentoo repo            Do        Do         Manually. Drop in gentoo.git, or portage snapshot, into /var/db/repos/gentoo
Make your adjustments         Do        Do         For example, set up remote access, configure binhost. Optional.
Chroot into stage3            Do        Do         Run ``gebootstrap/2000_chroot``

. /etc/profile
env-update

Configure system for d.im     Do        Do         Run ``gebootstrap/3000_configure``
Install d.im software         Do        Do         Run ``gebootstrap/4000_install``
Install kernel                Skip      Do

perl-cleaner --all
emerge tmux gentoo-kernel-bin grub gentoolkit

Set up bootloader             Skip      Do
grub-install
grub-mkconfig
ln -sv net.lo /etc/init.d/net.eth0
rc-update add net.eth0 default
rc-update add sshd default
copy ~/.ssh/authorized_keys

Reboot into new system        Skip      Do

set hostname

emerge --depclean --ask
emerge -atv dhcpcd

deploy website manually

set up MTA

===========================  ========  =========  ============
