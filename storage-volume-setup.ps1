echo "onlining disks"
Get-Disk | where-Object IsOffline -Eq $True | IsOffline -Eq $False
Set-Volume -Driveletter "" -NewFileSystemLabel ""

