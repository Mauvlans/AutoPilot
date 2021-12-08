function Test-Bitlocker ($BitlockerDrive) {
    #Tests the drive for existing Bitlocker keyprotectors
    try {
        Get-BitLockerVolume -MountPoint $BitlockerDrive -ErrorAction Stop
    } catch {
        Write-Output "Bitlocker was not found protecting the $BitlockerDrive drive. Terminating script!"
    }
}
function Get-KeyProtectorId ($BitlockerDrive) {
    #fetches the key protector ID of the drive
    $BitLockerVolume = Get-BitLockerVolume -MountPoint $BitlockerDrive
    $KeyProtector = $BitLockerVolume.KeyProtector | Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' }
    return $KeyProtector.KeyProtectorId
}
function Invoke-BitlockerEscrow ($BitlockerDrive,$BitlockerKey) {
    #Escrow the key into Azure AD
    try {
        BackupToAAD-BitLockerKeyProtector -MountPoint $BitlockerDrive -KeyProtectorId $BitlockerKey -ErrorAction SilentlyContinue
        Write-Output "Attempted to escrow key in Azure AD - Please verify manually!"
    } catch {
        Write-Error "This should never have happend? Debug me!"
    }
}
#endregion functions
#region execute
$BitlockerVolumers = Get-BitLockerVolume
$BitlockerVolumers |
ForEach-Object {
$MountPoint = $_.MountPoint
$RecoveryKey = [string]($_.KeyProtector).RecoveryPassword
if ($RecoveryKey.Length -gt 5) {
    $DriveLetter = $MountPoint
    Write-Output $DriveLetter
    Test-Bitlocker -BitlockerDrive $DriveLetter
    $KeyProtectorId = Get-KeyProtectorId -BitlockerDrive $DriveLetter
    Invoke-BitlockerEscrow -BitlockerDrive $DriveLetter -BitlockerKey $KeyProtectorId
}
}
