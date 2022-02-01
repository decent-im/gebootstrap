all: check

check: test_img.qcow2
	false # TODO run tests

test_img.qcow2: installed.qcow2
	false # TODO

resized.qcow2: openstack.qcow2
	# expand the disk to not run out of space
	qemu-img create -f qcow2 -o preallocation=metadata resize_wip.qcow2 10G
	virt-resize --expand /dev/sda3 openstack.qcow2 resize_wip.qcow2
	mv resize_wip.qcow2 resized.qcow2


tree_fetched.qcow2: resized.qcow2
	cp resized.qcow2 tree_fetch_wip.qcow2

	# replace broken make.profile symlink
	virt-customize --format qcow2 --add tree_fetch_wip.qcow2 \
		--run-command "rm /etc/portage/make.profile"
	virt-customize --format qcow2 --add tree_fetch_wip.qcow2 \
		--run-command \
		"ln -sv /var/db/repos/gentoo/profiles/default/linux/amd64/17.1/no-multilib /etc/portage/make.profile"

	# to make emerge commands work, the package repo must be fetched
	virt-customize --format qcow2 --add tree_fetch_wip.qcow2 \
		--run-command "emaint sync -A"
	mv tree_fetch_wip.qcow2 tree_fetched.qcow2


git_installed.qcow2: tree_fetched.qcow2
	cp tree_fetched.qcow2 git_install_wip.qcow2

	# TODO USE=-perl emerge dev-vcs/git
	virt-customize --format qcow2 --add git_install_wip.qcow2 \
		--memsize 4096 --smp 4 \
		--run-command "USE=-perl emerge dev-vcs/git"
	mv git_install_wip.qcow2 git_installed.qcow2

installed.qcow2: git_installed.qcow2
	cp git_installed.qcow2 install_wip.qcow2

	virt-customize --format qcow2 --add install_wip.qcow2 \
		--run-command "rm /etc/portage/make.profile"
	# inject /etc/portage/repos.conf/decent-im.conf
	# also switches to custom profile, see 3000_configure
	virt-customize --format qcow2 --add install_wip.qcow2 \
		--copy-in install-phase-files/etc:/

	# fetch decent-im repo which is git-based
	virt-customize --format qcow2 --add install_wip.qcow2 \
		--run-command "emaint sync --repo decent-im"

	# rebuild @world after the profile changes
	virt-customize --format qcow2 --add install_wip.qcow2 \
		--memsize 4096 --smp 4 \
		--run-command "emerge -tv --update --deep --changed-use @world"

	virt-customize --format qcow2 --add install_wip.qcow2 \
		--memsize 4096 --smp 4 \
		--run-command "emerge --depclean"

	# emerge decent-im
	virt-customize --format qcow2 --add install_wip.qcow2 \
		--memsize 4096 --smp 4 \
		--run-command "emerge -tv net-im/decent-im"

	mv install_wip.qcow2 installed.qcow2

openstack.qcow2:
	curl -o openstack_wip.qcow2 -L https://distfiles.gentoo.org/experimental/amd64/openstack/gentoo-openstack-amd64-default-nomultilib-latest.qcow2
	# check the signature
	curl -o openstack.qcow2.asc -L https://distfiles.gentoo.org/experimental/amd64/openstack/gentoo-openstack-amd64-default-nomultilib-latest.qcow2.asc
	gpg --verify openstack.qcow2.asc openstack_wip.qcow2
	mv openstack_wip.qcow2 openstack.qcow2
