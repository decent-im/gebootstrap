DIRNAME = $(shell basename $$PWD)
#VM_NAME ?= ${DIRNAME}
VM_NAME ?= decent-im-gebootstrap


.PHONY: all backup_packages_cache update_gentoo_repo drop_vm

all: ${VM_NAME}.metapackage.installed

drop_vm:
	incus delete --force ${VM_NAME}

backup_packages_cache:
	mkdir -p cache
	rsync -rtv -e "ssh -F ${VM_NAME}.ssh_config" --progress root@`cat $(VM_NAME).ipv4`:/var/cache/binpkgs   cache
	rsync -rtv -e "ssh -F ${VM_NAME}.ssh_config" --progress root@`cat $(VM_NAME).ipv4`:/var/cache/distfiles cache
	incus exec ${VM_NAME} -- chown -R portage:portage /var/cache/binpkgs /var/cache/distfiles

repos/gentoo/.git/HEAD:
	mkdir -p repos
	git clone --depth 1 -b master https://github.com/gentoo-mirror/gentoo.git repos/gentoo

update_gentoo_repo:
	cd repos/gentoo && git fetch --depth 1 && git reset --hard origin/master && git gc

repos/decent-im/.git/HEAD:
	#git clone --depth 1 -b master https://github.com/decent-im/gentoo-overlay.git repos/decent-im
	mkdir -p repos
	git clone https://github.com/decent-im/gentoo-overlay.git repos/decent-im

# For unattended SSH connection from hypervisor into guest
ssh_key:
	ssh-keygen -f ssh_key -N ''

storage-pool.created:
	incus storage create decent-im-gebootstrap btrfs size=40GiB
	touch $@

${VM_NAME}.created: storage-pool.created ssh_key
	# The profile applied (default, or custom) should give desirable connectivity
	# Check out https://blog.simos.info/how-to-make-your-lxd-containers-get-ip-addresses-from-your-lan-using-a-bridge/
	# Your container could get LAN IP and globally routable IPv6
	incus launch --storage decent-im-gebootstrap images:gentoo/openrc decent-im-gebootstrap -c limits.cpu=2 -c limits.memory=4GiB
	touch $@

${VM_NAME}.access.configured: ${VM_NAME}.created
	test -f backup/root/.ssh/authorized_keys # place something there!
	incus file push -rv backup/root/.ssh/ ${VM_NAME}/'/root/'
	incus exec ${VM_NAME} -- chown -R root:root /root/.ssh
	incus exec ${VM_NAME} -- chmod u=rx,go= -R /root/.ssh
	incus file push -rv backup/etc/ssh/ssh_host_*_key* ${VM_NAME}/'/etc/ssh/' || true
	incus exec ${VM_NAME} -- rc-update add sshd default
	incus exec ${VM_NAME} -- /etc/init.d/sshd start || true # Transient "WARNING: sshd is already starting" breaks the script

	# Wait for ipv4 IP
	while ! incus list --format json ${VM_NAME} | jq --raw-output .[0].state.network.eth0.addresses[0].address | grep -q -F '.'; do echo -n .; sleep 1; done

	incus list --format json ${VM_NAME} | jq --raw-output .[0].state.network.eth0.addresses[0].address > ${VM_NAME}.ipv4
	incus list --format json ${VM_NAME} | jq --raw-output .[0].state.network.eth0.addresses[1].address > ${VM_NAME}.ipv6
	ssh-keyscan -H `cat $(VM_NAME).ipv4` > ${VM_NAME}.known_hosts

	echo "Host ${VM_NAME} `cat $(VM_NAME).ipv4`"            > ${VM_NAME}.ssh_config
	echo "  Hostname `cat $(VM_NAME).ipv4`"                >> ${VM_NAME}.ssh_config
	echo "  IdentityFile ssh_key"                          >> ${VM_NAME}.ssh_config
	echo "  User root"                                     >> ${VM_NAME}.ssh_config
	echo "  GlobalKnownHostsFile=${VM_NAME}.known_hosts"   >> ${VM_NAME}.ssh_config

	# persist host keys even if this is the first run ever
	mkdir -p backup/etc/ssh/
	rsync -rtv -e "ssh -F ${VM_NAME}.ssh_config" root@`cat $(VM_NAME).ipv4`:/etc/ssh/'ssh_host_*_key*' backup/etc/ssh/
	#incus file pull -rv ${VM_NAME}/'/etc/ssh' backup/etc # clunkier tool than rsync
	touch $@

${VM_NAME}.package_manager.configured: ${VM_NAME}.access.configured repos/decent-im/.git/HEAD
	# gentoo repo is currently not pinned to local checkout!
	# provided system image is not pinned too!
	# FIXME not idempotent:
	incus exec ${VM_NAME} -- mv /etc/portage/make.conf /etc/portage/make.conf.orig
	incus exec ${VM_NAME} -- mkdir /etc/portage/make.conf
	incus exec ${VM_NAME} -- mv /etc/portage/make.conf.orig /etc/portage/make.conf/make.conf
	rsync -rtv -e "ssh -F ${VM_NAME}.ssh_config" repos/decent-im root@`cat $(VM_NAME).ipv4`:/var/db/repos/
	rsync -rtv -e "ssh -F ${VM_NAME}.ssh_config" install-phase-files/etc/portage/ root@`cat $(VM_NAME).ipv4`:/etc/portage/
	rsync -rtv -e "ssh -F ${VM_NAME}.ssh_config" cache root@`cat $(VM_NAME).ipv4`:/var/
	touch $@

${VM_NAME}.metapackage.installed: ${VM_NAME}.package_manager.configured
	# enable binary packages from distro:
	incus exec ${VM_NAME} -- emerge -u getuto
	incus exec ${VM_NAME} -- getuto

	incus exec ${VM_NAME} -- emerge decent-im
	make VM_NAME=${VM_NAME} backup_packages_cache
	touch $@

utopia.achieved:
	# add subdomains in DNS - chat, irc, proxy, pubsub
	# edit /etc/conf.d/hostname
	# edit /etc/decent.im/config
	# run decent.im_postinst (FIXME will fail at least on biboumi)
	# drop in the website contents
	false
	touch $@
