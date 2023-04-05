# Define the minimum and maximum sizes for the volume
$volumeSizeMin = 1 # GB
$volumeSizeMax = 1024 # TB

# Define the valid parity options
$validParities = "simple", "mirror", "parity"

# Display a header
Write-Host "Storage tool for Windows Server"
Write-Host "================================"

# Display all current disks on the server
Get-Disk | Format-Table

# Check for any offline disks
$offlineDisks = Get-Disk | Where-Object {$_.OperationalStatus -ne "Online"}

if ($offlineDisks.Count -eq 0) {
    Write-Host "All disks are online."
} else {
    # Prompt the user to select which disks to bring online
    Write-Host "The following disks are offline:`n"
    $offlineDisks | Format-Table
    $disksToBringOnline = Read-Host "Enter the numbers of the disks you want to bring online (separated by commas):"

    # Prompt the user to name each disk and create a new volume
    $volumes = $disksToBringOnline.Split(",") | ForEach-Object {
        $diskNumber = $_.Trim()
        $disk = Get-Disk -Number $diskNumber
        $diskName = Read-Host "Enter a name for disk $diskNumber:"
        $size = Read-Host "Enter the size of the volume you want to create on disk $diskNumber (in GB, minimum $volumeSizeMin, maximum $volumeSizeMax):"
        while ($size -lt $volumeSizeMin -or $size -gt $volumeSizeMax) {
            Write-Warning "Invalid volume size. Please enter a value between $volumeSizeMin and $volumeSizeMax GB."
            $size = Read-Host "Enter the size of the volume you want to create on disk $diskNumber (in GB, minimum $volumeSizeMin, maximum $volumeSizeMax):"
        }
        $parity = Read-Host "Enter the parity for the volume you want to create on disk $diskNumber (valid options: simple/mirror/parity):"
        while (-not $validParities.Contains($parity)) {
            Write-Warning "Invalid parity option. Please enter a valid option (simple/mirror/parity)."
            $parity = Read-Host "Enter the parity for the volume you want to create on disk $diskNumber (valid options: simple/mirror/parity):"
        }
        $volumeName = Read-Host "Enter a name for the volume you want to create on disk $diskNumber:"
        New-Volume -FriendlyName $volumeName -StoragePoolFriendlyName "StoragePool01" -PhysicalDisks $disk -FileSystem CSVFS_ReFS -ResiliencySettingName $parity -Size $size"GB"
    }

    # Bring the selected disks online
    $disksToBringOnline.Split(",") | ForEach-Object {
        $diskNumber = $_.Trim()
        Get-Disk -Number $diskNumber | Set-Disk -IsOffline $false
        Write-Host "Disk $diskNumber ('$($diskNames[$diskNumber-1])') has been brought online."
    }

    # Display the new volumes
    Write-Host "`nNew volumes:`n"
    Get-Volume $volumes | Format-Table
}
