#!/bin/bash -e

emerge -v layman
echo "source /var/lib/layman/make.conf" >> /etc/portage/make.conf
layman -S
layman -a mva
layman -a lua

yes | layman -o https://raw.githubusercontent.com/decent-im/gentoo-overlay/master/layman.xml -f -a decent-im

# Switch to custom profile
ln -snfv /var/lib/layman/decent-im/profiles/hardened/linux/amd64/no-multilib /etc/portage/make.profile

# Let profile changes take effect (e.g. un-bindist openssl)
emerge --sync
emerge -vuDN @world

# Make sure `hostname -f` shows what you want to be your FQDN! decent-im generates configs based on that
EXTERNAL_IP=`dig +short myip.opendns.com @resolver1.opendns.com`
DNS_PTR=`dig +short -x $EXTERNAL_IP @resolver1.opendns.com`
FQDN=`echo $DNS_PTR | sed 's/[.]$//'`
echo "$FQDN" > /etc/fqdn
HOSTNAME=`echo $FQDN | sed 's/[.].*$//'`
DOMAIN=`echo $FQDN | sed 's/^[^.]*[.]//'`
echo "$HOSTNAME" > /etc/hostname
hostname $HOSTNAME

echo "Detected external IP: $EXTERNAL_IP"
echo "Detected FQDN: $FQDN"
echo "System-visible FQDN: `hostname -f`"

# Ensure no other domain present
sed -i /etc/resolv.conf -e 's/^domain.*$//'
echo "domain $DOMAIN" >> /etc/resolv.conf
echo "domain $DOMAIN" > /etc/resolv.conf.head

# Workaround until all lua packages support LUA_TARGETS
emerge -v dev-lang/lua:5.1
eselect lua set 5.1

# Install meta-package, which gives prosody(+modules), spectrum2(+skype, +irc etc), postgresql
emerge -v decent-im
dispatch-conf # Interactive. TODO Automate.
emerge --config =net-im/decent-im-9999
