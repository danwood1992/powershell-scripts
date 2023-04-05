echo "Tool for setting up active direcrtory "
echo "======================================"
# Install the Active Directory module if it's not already installed
if (-not (Get-Module -Name ActiveDirectory)) {
    Install-WindowsFeature RSAT-AD-PowerShell
}

# Prompt the user to enter a domain name
$domainName = Read-Host "Enter the name of the new domain (e.g. contoso.local):"

# Create the new forest
New-ADForest -DomainName $domainName -DomainMode Win2012R2 -ForestMode Win2012R2

# Prompt the user to enter a safe mode administrator password
$safeModeAdminPassword = Read-Host "Enter a password for the Safe Mode Administrator account:"
$safeModeAdminPasswordSecureString = ConvertTo-SecureString -String $safeModeAdminPassword -AsPlainText -Force

# Create the new domain controller
Install-ADDSDomainController -DomainName $domainName -NoGlobalCatalog:$false -InstallDns:$true -Credential (Get-Credential) -SafeModeAdministratorPassword $safeModeAdminPasswordSecureString -Force:$true
