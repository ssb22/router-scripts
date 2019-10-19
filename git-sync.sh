#!/bin/bash
git pull --no-edit
wget -N http://ssb22.user.srcf.net/setup/netgear.tgz http://ssb22.user.srcf.net/setup/upnp.tgz
tar -zxf netgear.tgz ; tar -zxf upnp.tgz
git add netgear-* upnp-*
git commit -am update && git push
