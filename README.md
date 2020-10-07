# router-scripts
Router command-line control scripts from http://ssb22.user.srcf.net/setup/upnp.html and http://ssb22.user.srcf.net/setup/netgear.html
(also mirrored at http://ssb22.gitlab.io/setup/upnp.html and http://ssb22.gitlab.io/setup/netgear.html just in case)

UPnP scripts
============

These scripts allow a UPnP-based home router to be controlled programmatically from a Unix or Linux box. They were tested on a “Sky Hub” in 2016/17 but usual disclaimers apply.

(If you have an older router with the widely-reported security problem of leaving its UPnP port open to the outside, I’d rather you switch off and don’t use UPnP. Thankfully such older routers usually provide a non-UPnP means of route configuration like the VMDG280 (below). Services like GRC ShieldsUp might be able to show if your older router is incorrectly handling UPnP security. But some newer routers are configurable only via UPnP, and do handle its security correctly—the scripts on this page can be useful for those.)

Installation: Make sure you have Python and the miniupnpc library (sudo pip install miniupnpc or apt-get install python-miniupnpc). Copy `upnp-*` into `/usr/local/bin` or wherever.

The scripts have been tested on both Python 2 and Python 3. The `#!` tags at the start assume your system has a python command with no number, pointing to whichever version you have as default.

# `upnp-add-port` (PortNum)
Add a simple port-forwarding rule to forward incoming port PortNum (1 through 65535) to the machine running this command. PortNum may optionally be followed by a different port number to use on the machine itself, for example if you want to reduce probing by using a non-standard external port while keeping the standard port on your network.

But many ISP-supplied routers will not apply UPnP forwarding rules to packets originating from inside your network even if addressed to your external IPv4 address, so to use your server from home you might still need to use its internal IP (you might want to edit the hosts files of your local machines).

Routers that lack non-UPnP forwarding options will often still allow you to specify a “DMZ” machine and have this respond to your external IPv4 address even for connections coming from inside your network (such as WiFi-connected mobile devices where it’s difficult to edit the hosts file).

DMZ however will expose all ports (except ones directed elsewhere), so you’ll have to do your own iptables work on the Linux box—my suggested starting point is:

`iptables -A INPUT ! -i lo+ -p tcp --syn ! -s 192.168.0.0/16 ! --dport 80 -j DROP`

(remember to add it to startup scripts before ifup; the package `iptables-persistent` might help, or if all your local-only servers are run from inetd you can try putting commands in /etc/default/openbsd-inetd)

# `upnp-date`
Shows the current date and time from the router (via HTTP)

Some ISP-supplied routers are ‘hardwired’ to use that ISP’s internal NTP servers at startup, so the router might get stuck in 1970 if you use it with a different ISP.

# `upnp-delete-port` (PortNum)
Delete a port-forwarding rule, specified by external port. The deletion takes effect only for new connections; existing connections to the port (e.g. open SSH sessions) are not affected.

So for example if you run a Web server which you only occasionally SSH into, you can reduce the level of SSH probing by keeping the port closed until you need it, open it via a CGI script and close it again from your login script. If you do this via router configuration then the scripts don’t need any special privileges on the server itself. If using the DMZ approach above, you’ll instead need ‘sudo’-enabled scripts (or ‘suid’ scripts in a protected directory) that do the `iptables -I` and `-D`.

# `upnp-ip-address`
Shows the router’s current external IP address

# `upnp-ports`
Shows the port forwarding table in a simple textual format

# `upnp-uptime`
Shows the uptime of the router

Routers might or might not persist the port-forwarding rules across a power cycle. For best results you might need to arrange for them to be re-done.

Netgear VMDG280 command-line control scripts
============================================

These scripts are old: I understand that the firmware of the router in question might have changed since I last had access to one, so I have no idea how many of these scripts still work. For modern UPnP-based routers, please try the UPnP command-line control scripts above instead.

Installation: Make sure `lynx` is on the system. Copy `netgear-*` into `/usr/local/bin` or wherever, and save the router’s admin password into `/etc/netgear-password` (readable by any users that need to run the netgear commands). The scripts assume a LAN IP of `192.168.0.1`.

# `netgear-add-port` (PortNum) (IpNum)
Add a simple port-forwarding rule to forward incoming port PortNum (1 through 65535) to IpNum (1 through 254), replacing an existing rule if necessary (see netgear-delete-port)

# `netgear-block` (IpNum)
Blocks the specified IP number (2 through 254) from making any new connections to the outside Internet. Existing connections are unaffected, and connections on the internal network are still allowed. Also, the computer could change its IP address to an unblocked one (only 30 of them can be blocked), and if the computer has the router password then it can unblock itself as well. It might be better to block by MAC address, which can be scheduled to a time period by the router itself (see “MAC Filtering” in the browser, and use netgear-date to check the router’s idea of the current time) and which also stops existing outgoing connections (internal connections still allowed), although some hardware allows MAC changing

# `netgear-date`
Shows the current date and time from the router. Not always accurate, and there’s no obvious way to set it, although it sometimes sets itself after being power-cycled.

# `netgear-delete-port` (PortNum)
Delete a port-forwarding rule whose first (or only) port is PortNum. The deletion takes effect only for new connections; existing connections to the port (e.g. open SSH sessions) are not affected.

So for example if you run a Web server which you only occasionally SSH into, you can reduce the level of SSH probing by keeping the port closed until you need it, open it via a CGI script and close it again from your login script. If you do this via router configuration then the scripts don’t need any special privileges on the server itself (apart from being able to read the router’s password).

# `netgear-dmz` [(IpNum)]
Sets the specified IP number (2 through 254) to receive all incoming traffic that is not handled by port forwarding; 0 turns this off (off is recommended if you might have insecure open ports!) When run without a number, reports the current setting.

# `netgear-filter-add` (domain)
Adds a domain to the forbidden websites list, if it’s not already listed. The router blocks outgoing HTTP connections (usually sending a “Web Site Blocked by Filter” response, but sometimes just dropping the connection) if any of these domains are mentioned in the request’s “Host” header. Subdomains of the specified domains are also covered. HTTPS traffic, and non-Web traffic, is not affected (and neither is connecting to a non-VirtualHost website by IP), but it might help with some situations. Up to 16 domains can be listed.

# `netgear-filter-list`
Lists forbidden website domains, in the order in which they were added.

# `netgear-gateway`
Shows the IP address of the ISP’s upstream gateway. If this IP responds to ping, it could be used to test your immediate link. This command has been known to fault occasionally.

# `netgear-ip-address`
Shows the router’s current external IP address. Has been known to fault occasionally.

# `netgear-password` [(NewPass)]
Changes the password, also updating /etc/netgear-password (must have write access). If new password is not specified, one is generated at random.

# `netgear-ping-off`
Tells the router not to respond to “ping” requests from outside

# `netgear-ping-on`
Tells the router to respond to “ping” requests from outside. This might help with diagnostics if running a server, and might also lead to a small increase in probing.

# `netgear-ping-status`
Shows the current status (on or off) of whether the router responds to “ping” requests from outside

# `netgear-ports`
Shows the port forwarding table in a simple textual format

# `netgear-unblock` (IpNum)
The reverse of netgear-block. Assumes the rule’s name has not been changed.

# `netgear-wifi-channel`
Shows or sets the WiFi channel (1 to 13 or auto). Setting the channel may break existing connections. “Auto” seems to choose a channel which currently has least interference (it chooses out of the three standard non-overlapping channels 1, 6 or 11, and re-running netgear-wifi-channel auto will re-evaluate its choice), but it doesn’t seem to do much accounting for varying interference over time, which is sometimes the cause of intermittent dropouts in a crowded neighbourhood. If a WiFi scanner shows SNR periodically dropping below 25, and you can’t find a channel that’s 22MHz (5 channel-widths) away from anything stronger than 50dB below your signal level, then you might need to use wired connections, or turn off the Netgear’s WiFi and get a better router. (You could improve positioning, but some environments seem to make this router drop connections even if they are 50–60dB stronger than the background; perhaps its firmware is overly sensitive.)

# `netgear-wifi-connections`
Lists the IP and MAC addresses of devices that are currently connected to WiFi

# `netgear-wifi-macadd` (MacAddr)
Adds the specified MAC address to the WiFi MAC access list. Up to 32 can be added. The list takes effect when “allow any” is turned off in the browser. Note that some devices are capable of changing their MAC addresses, and of observing which MAC addresses have connected, so MAC-based restrictions are effective only against casual users.

# `netgear-wifi-macdel` (RegExp)
Deletes from the WiFi MAC address list anything matching the regular expression RegExp, which can be a single MAC address or a regular expression matching multiple addresses (a single dot will match all addresses).

# `netgear-wifi-maclist`
Outputs the current WiFi MAC access list in a simple textual format.

# `netgear-wifi-off`
Switches off wireless Internet, leaving only wired connections active. Switching the radio off at times when it won’t be used might improve security (see below) and/or save a small amount of power.

# `netgear-wifi-on`
Switches wireless Internet back on. Note that the router gives wireless clients access to all the computers on your network, including any “internal” services, and WiFi security has been broken before, so you might wish to restrict which services run on your network when WiFi is enabled. You can set up a “guest network”, but (a) there is no way to run the guest network without also running a private one and (b) users of the guest network can’t connect to your own servers even on your public IP address, which must be a bug

# `netgear-wifi-status`
Shows the current status of WiFi (off or on)

All material © Silas S. Brown unless otherwise stated. 
Linux is the registered trademark of Linus Torvalds in the U.S. and other countries. 
Netgear is a registered trademark of Netgear Inc and/or its subsidiaries in the United States and/or other countries. 
Unix is a trademark of The Open Group. 
Wi-Fi is a trademark of the Wi-Fi Alliance. 
Any other trademarks I mentioned without realising are trademarks of their respective holders.
