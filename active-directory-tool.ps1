# Define the minimum and maximum lengths for the domain name
$domainNameMinLength = 3
$domainNameMaxLength = 63

# Install the Active Directory module if it's not already installed
if (-not (Get-Module -Name ActiveDirectory)) {
    Install-WindowsFeature RSAT-AD-PowerShell -ErrorAction Stop
}

# Prompt the user to enter a domain name
do {
    $domainName = Read-Host "Enter the name of the new domain (e.g. contoso.local):"
    if ($domainName.Length -lt $domainNameMinLength -or $domainName.Length -gt $domainNameMaxLength) {
        Write-Warning "Domain name must be between $domainNameMinLength and $domainNameMaxLength characters long. Please try again."
    }
} until ($domainName.Length -ge $domainNameMinLength -and $domainName.Length -le $domainNameMaxLength)

# Create the new forest
try {
    New-ADForest -DomainName $domainName -DomainMode Win2012R2 -ForestMode Win2012R2 -ErrorAction Stop
} catch {
    Write-Error "Failed to create forest: $_"
    break
}

# Prompt the user to enter a safe mode administrator password
do {
    $safeModeAdminPassword = Read-Host "Enter a password for the Safe Mode Administrator account:"
    $safeModeAdminPasswordConfirm = Read-Host "Confirm the password for the Safe Mode Administrator account:"
    if ($safeModeAdminPassword -ne $safeModeAdminPasswordConfirm) {
        Write-Warning "Passwords do not match. Please try again."
    }
} until ($safeModeAdminPassword -eq $safeModeAdminPasswordConfirm)

$safeModeAdminPasswordSecureString = ConvertTo-SecureString -String $safeModeAdminPassword -AsPlainText -Force

# Create the new domain controller
try {
    Install-ADDSDomainController -DomainName $domainName -NoGlobalCatalog:$false -InstallDns:$true -Credential (Get-Credential) -SafeModeAdministratorPassword $safeModeAdminPasswordSecureString -Force:$true -ErrorAction Stop
} catch {
    Write-Error "Failed to create domain controller: $_"
    break
}
