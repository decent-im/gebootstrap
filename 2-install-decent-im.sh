#!/bin/bash -e

emerge -v layman
echo "source /var/lib/layman/make.conf" >> /etc/portage/make.conf
layman -S
layman -a mva
layman -a lua
layman -a dev-zero

yes | layman -o https://raw.githubusercontent.com/decent-im/gentoo-overlay/master/layman.xml -f -a decent-im

# Switch to custom profile
rm -f /etc/portage/make.profile
mkdir /etc/portage/make.profile
cat > /etc/portage/make.profile/parent <<EOF
/usr/portage/profiles/default/linux/amd64/17.0/no-multilib
/var/lib/layman/decent-im/profiles/features/decent.im
EOF

# Let profile changes take effect (e.g. un-bindist openssl)
emerge --sync
emerge -vuDN @world

# Workaround until all lua packages support LUA_TARGETS
emerge -v dev-lang/lua:5.1
eselect lua set 5.1

# Install meta-package, which gives prosody(+modules), spectrum2(+skype, +irc etc), postgresql
emerge -v decent-im
dispatch-conf # Interactive. TODO Automate.
emerge --config =net-im/decent-im-9999
