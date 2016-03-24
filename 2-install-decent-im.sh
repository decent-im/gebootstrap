#!/bin/bash -e



emerge -v layman
echo "source /var/lib/layman/make.conf" >> /etc/portage/make.conf
layman -S
layman -a mva
layman -a lua

yes | layman -o https://raw.githubusercontent.com/decent-im/gentoo-overlay/master/layman.xml -f -a decent.im

### TODO Make sure `hostname -f` shows what you want to be your FQDN! decent-im generates configs based on that

# Install meta-package, which gives prosody(+modules), spectrum2(+skype, +irc etc), postgresql
emerge -v decent-im

emerge --config =net-im/decent-im-9999