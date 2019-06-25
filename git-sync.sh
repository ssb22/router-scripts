#!/bin/bash
git pull --no-edit
wget -N http://people.ds.cam.ac.uk/ssb22/setup/netgear.tgz http://people.ds.cam.ac.uk/ssb22/setup/upnp.tgz
tar -zxf netgear.tgz ; tar -zxf upnp.tgz
git add netgear-* upnp-*
git commit -am update && git push
