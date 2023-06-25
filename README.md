## Chromium based browsers DoT and DoH causing Google Search 403 Forbidden errors on HE.net Tunnelbroker IPv6. ##

WARNING! Use at your own risk!

These steps specifically downgrade the security of DNS over TLS (DoT) and DNS over HTTPS (DoH) to cleartext old-school DNS.

This post is specific to users running Netgate pfSense Plus 23.05 with pfBlockerNG 3.2.0_5 and Windows machines using Chormium-based browsers.

pfSense Plus Firewall information:
Based on pfSense 2.6.0 CE upgraded to pfSense Plus 23.05 (personal/lab use license).

Version	23.05-RELEASE (amd64)
built on Mon May 22 15:04:36 UTC 2023
FreeBSD 14.0-CURRENT

Packages installed:

pfBlockerNG 3.2.0_5 Description:
Manage IPv4/v6 List Sources into 'Deny, Permit or Match' formats.
GeoIP database by MaxMind Inc. (GeoLite2 Free version).
De-Duplication, Suppression, and Reputation enhancements.
Provision to download from diverse List formats.
Advanced Integration for Proofpoint ET IQRisk IP Reputation Threat Sources.
Domain Name (DNSBL) blocking via Unbound DNS Resolver.

System_Patches 2.2.4 Description:
A package to apply and maintain custom and recommended system patches.

System_Patches installed:
Recommended System Patches for Netgate pfSense® Plus software version 23.05 as of 20230624:
* Fix alias bulk import breaking configuration (Redmine #14412)				
* Fix Outbound NAT "Other Subnet" Translation address input validation (Redmine #14354)				
* Fix IPv6 over IPv4 tunneling PF ruleset error (Redmine #14415)				
* Fix GUI Max Processes value not saving (Redmine #14425)				
* Fix missing ngeth interfaces triggering reassignment (Redmine #14410)				
* Fix Captive Portal PHP error when processing used MACs (Redmine #14446)				

Unbound Resolver

System DNS server(s)
* 127.0.0.1
* 1.1.1.3
* 1.0.0.3
* 2606:4700:4700::1113
* 2606:4700:4700::1003

HE.net TunnelBroker configuration:
* WAN static IP.
* WANv6 GIF tunnel via HE.net Tunnel Broker service configured per pfSense documentation.
* Primary routed tunnel /64 in use on LAN.
* Single routed /48 with a few /64 nets sliced out for guest and lab networks.
* DHCPv6 enabled with RA Managed flags.

Keep in mind, as always, BACKUP your firewall BEFORE proceeding!  

Set pfBlockerNG configuration settings:
* pfBlockerNG Python Unbound mode enabled.
* pfBlockerNG DNSBL CNAME Validation enabled.
* pfBlockerNG DNSBL no AAAA enabled.
* pfBlockerNG DNSBL Python no AAAA List:

google.com<br>
www.google.com<br>

Under pfBlockerNG / Update set Force Option "Reload" and Reload Option "All", click Run to reload pfBlockerNG.

Under Firewall / Rules, set internal LAN based IPv6 interfaces to allow port 53 (DNS) but NOT port 853 (DNS over TLS) with
destination set to "This Firewall".

I use a port alias group for globally allowed outbound IP services, just don't add 853 to the list.

At this point the firewall will block DoT and AAAA lookups for google.com and www.google.com.  However, that's not the end.

Chromium and other modern browsers, along with many mobile devices (iPhones, iPads, Androids) will have built-in DoH DNS over
HTTPS for name resolution running inside the browser directly.  This idiotic feature bypasses the OS and firewall from seeing
the lookups to google and will result in the 403 "no soup for you" messages we're seeing on the HE.net IPv6 tunnel broker connections.

I can't help with the mobile devices but for Windows it's relativly simple to set a few policy based registry keys to disable the
browser's built-in DNS client.  Setting these values will force ALL DNS queries from the browser to go through the OS DNS client
in the clear and hence to the firewall in the clear where pfBlockerNG will catch them and force a standard IPv4-only A lookup for
the domains listed in the Python no AAAA list.

Since the HE.net Tunnelbroker service is mainly for learning, testing, and IPv6 certification it should NOT be used in a production environment.
With that said, having done both network administration as well as information security I'm going to let the admin in me win this argument
(although I still cringe at the fact we have to downgrade security just to get to google.com).  The infosec guy in me says just use
duckduckgo.com and ditch google unless you really need it, then use it on your mobile device off your network as needed.

The Windows side is easy enough to revert the registry changes by simply deleting the values we're about to create.
Alternately, you could just set them to their default enabled values.

Chromium policy links to the keys and values needed:
* https://chromeenterprise.google/policies/#DnsOverHttpsMode
* https://chromeenterprise.google/policies/#BuiltInDnsClientEnabled

Netgate pfSense Documentation:
* https://docs.netgate.com/pfsense/en/latest/

Tested sucessfully on multiple Windows 10 22H2 x64 machines.

The best bet is to get your firewall rules and pfBlockerNG configured then test a single PC first.
There are two powershell scripts you can use to disable DoH for Chrome, Brave, and Edge browsers.
These are non-discriminatory, they set the policy keys and values for all three browsers whether they're installed or not.

* disable-DoH-chromium-based.ps1 - For use on a single PC in an Administrator elevated Powershell session.
* disable-DoH-chromium-based-remote.ps1 - For remote installation on multiple PCs via Invoke-Command with Administrator
  credentials from a non-elevated Powershell session.
