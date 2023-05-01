.PHONY: all backup_packages_cache update_gentoo_repo drop_vm

all: deployment.done

drop_vm:
	virsh shutdown decent-im-gebootstrap
	sleep 5
	virsh destroy decent-im-gebootstrap
	virsh undefine --remove-all-storage decent-im-gebootstrap

backup_packages_cache:
	rsync -rtv --progress root@decent-im-gebootstrap:/var/cache/{distfiles,binpkgs} cache

openstack.qcow2:
	# https://distfiles.gentoo.org/experimental/amd64/openstack/gentoo-openstack-amd64-default-nomultilib-20220721.qcow2
	curl -o $@.wip -L https://distfiles.gentoo.org/experimental/amd64/openstack/gentoo-openstack-amd64-default-nomultilib-latest.qcow2
	# check the signature
	# https://distfiles.gentoo.org/experimental/amd64/openstack/gentoo-openstack-amd64-default-nomultilib-20220721.qcow2.asc
	curl -o openstack.qcow2.asc -L https://distfiles.gentoo.org/experimental/amd64/openstack/gentoo-openstack-amd64-default-nomultilib-latest.qcow2.asc
	#gpg --verify openstack.qcow2.asc $@.wip # TODO releng@gentoo.org
	mv $@.wip $@


resized.qcow2: openstack.qcow2
	# expand the disk to not run out of space
	qemu-img create -f qcow2 -o preallocation=metadata $@.wip 10G
	virt-resize --expand /dev/sda3 $< $@.wip
	mv $@.wip $@

repos/gentoo/.git/HEAD:
	git clone --depth 1 -b master https://github.com/gentoo-mirror/gentoo.git repos/gentoo

update_gentoo_repo:
	cd repos/gentoo && git fetch --depth 1 && git reset --hard origin/master && git gc

repos/decent-im/.git/HEAD:
	git clone --depth 1 -b master https://github.com/decent-im/gentoo-overlay.git repos/decent-im

package_manager_enabled.qcow2: resized.qcow2 repos/gentoo/.git/HEAD repos/decent-im/.git/HEAD
	cp $< $@.wip

	virt-customize --format qcow2 --add $@.wip \
		--copy-in install-phase-files/etc:/ \
		--copy-in backup/:/ \
		--copy-in repos/gentoo:/var/db/repos \
		--copy-in repos/decent-im:/var/db/repos \
		--copy-in cache:/var \
		;
		#--run-command 'echo source /etc/portage/make.conf.decent-im >> /etc/portage/make.conf' \
		#--run-command 'tar -C / -xaf /backup/decent-im_public_*.tar.xz' \
		#--run-command 'tar -C / -xaf /backup/decent-im_private_*.tar.xz' \
		#;
	mv $@.wip $@

access_configured.qcow2: package_manager_enabled.qcow2
	cp $< $@.wip
	# --ssh-inject "root" is private data injection!
	virt-customize --format qcow2 --add $@.wip \
		--ssh-inject "root" \
		--root-password "random" \
		--password-crypto sha512 \
		> root-password.out \
		;
	mv $@.wip $@

domain_install.done: access_configured.qcow2
	cp $< decent-im-gebootstrap.qcow2
	sudo virt-install \
		--connect qemu:///system \
		--noautoconsole \
		--import \
		--name decent-im-gebootstrap \
		--disk path=decent-im-gebootstrap.qcow2,format=qcow2 \
		--network network=br0,model=virtio \
		--ram 4096 \
		--vcpus=2 \
		--os-variant=linux2020 \
		--cpu=host \
		;
	# change /etc/hosts entry based on
	# virsh net-dhcp-leases --network default
	touch $@

find_out_ipaddr.done: domain_install.done
	# human
	# * Login manually via virt-manager using the generated password, save IP into /etc/hosts
	# * Log in via SSH or otherwise get the host's keys into known_hosts
	false

service_pkg_installed.done: find_out_ipaddr.done
	# FIXME KVM host should have its own SSH keys trusted by VM?
	ssh -t root@decent-im-gebootstrap  emerge -tv --quiet-build=y rust-bin decent-im
	touch $@
