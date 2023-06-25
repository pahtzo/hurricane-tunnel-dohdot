<#
20230624-1601
Disables Chromium based browsers DoH and the built-in DNS client to force OS lookups.

Stand-alone script to add the required Windows registry policy entries to disable DoH
and the browsers' built-in DNS client.  This forces DNS lookups via the OS's DNS client and configured servers.

Open an Adminstrative Powershell window, at the prompt type:
powershell -ep bypass

This will open a new prompt with the Execution policy disabled.
From this prompt type:
.\disable-DoH-chromium-based.ps1

This will add the new policies for Chrome, Brave, and Edge browsers.

Close all browsers and test.
#>

# Google Chrome
New-Item -Path 'HKLM:\Software\Policies\Google\Chrome' -Force
New-ItemProperty -Path 'HKLM:\Software\Policies\Google\Chrome' -Name 'DnsOverHttpMode' -Value 'off' -PropertyType String
New-ItemProperty -Path 'HKLM:\Software\Policies\Google\Chrome' -Name 'BuiltInDnsClientEnabled' -Value 0x0 -PropertyType Dword
# Brave Browser
New-Item -Path 'HKLM:\Software\Policies\BraveSoftware\Brave' -Force
New-ItemProperty -Path 'HKLM:\Software\Policies\BraveSoftware\Brave' -Name 'DnsOverHttpMode' -Value 'off' -PropertyType String
New-ItemProperty -Path 'HKLM:\Software\Policies\BraveSoftware\Brave' -Name 'BuiltInDnsClientEnabled' -Value 0x0 -PropertyType Dword
# Microsoft Edge
New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Force
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Name 'DnsOverHttpMode' -Value 'off' -PropertyType String
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Name 'BuiltInDnsClientEnabled' -Value 0x0 -PropertyType Dword

