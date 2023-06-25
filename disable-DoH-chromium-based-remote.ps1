<#
20230624-1601
Disables Chromium based browsers DoH and the built-in DNS client to force OS lookups.

This assumes you have winrm enabled on all the computers and can remotely execute powershell commands.

This will enable winrm but might require a visit to each PC, or use of Sysinternals Suite psexec:

winrm quickconfig
Set-Service -Name WinRM -StartupType Automatic
Start-Service -Name WinRM

Remote Invoke-Command script to add the required Windows registry policy entries to disable DoH
and the browsers' built-in DNS client.  This forces DNS lookups via the OS's DNS client and configured servers.

This script has to be run from a normal Powershell prompt, not an Administrative one.
From the prompt open another new powershell with:
powershell -ep bypass

From the new prompt type:
.\disable-DoH-chromium-based-remote.ps1

This will add the new policies for Chrome, Brave, and Edge browsers to the list of computers in the $pcs variable (provided they're online).

Close all browsers and test.

#>

# Get an Administrator level windows credential for the domain joined PCs, or,
# if in WORKGROUP mode an admin account that has the same name and password on all computers in the workgroup.

$cred = Get-Credential

$pcs = ('PC1','PC2','PC3')

Invoke-Command -ScriptBlock {
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
} -Credential $cred -ComputerName $pcs

