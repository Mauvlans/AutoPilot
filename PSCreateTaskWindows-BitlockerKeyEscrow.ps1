# ***************************************************************************
#
# Purpose: This script creates a schedualed task and executes it to triger on 
# event 768 when disk encryption starts backes up all keys.
#
# ------------- DISCLAIMER -------------------------------------------------
# This script code is provided as is with no guarantee or waranty concerning
# the usability or impact on systems and may be used, distributed, and
# modified in any way provided the parties agree and acknowledge the 
# Microsoft or Microsoft Partners have neither accountabilty or 
# responsibility for results produced by use of this script.
#
# Microsoft will not provide any support through any means.
# ------------- DISCLAIMER -------------------------------------------------
#
# ***************************************************************************

# Script Added Here
$content = @'
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
'@
 
# creates custom folder and write PS script

$path = $(Join-Path $env:ProgramData CustomScripts)
if (!(Test-Path $path))
{
 New-Item -Path $path -ItemType Directory -Force -Confirm:$false
}
Out-File -FilePath $(Join-Path $env:ProgramData CustomScripts\EscrowBitlockerKey.ps1) -Encoding unicode -Force -InputObject $content -Confirm:$false
 
# register script as scheduled task

$taskName = "Escrow Bitlocker Key"
$Path = 'PowerShell.exe'
$Arguments = "-ExecutionPolicy Bypass -NonInteractive -WindowStyle Hidden -File c:\ProgramData\CustomScripts\EscrowBitlockerKey.ps1"

$Service = new-object -ComObject ("Schedule.Service")
$Service.Connect()
$RootFolder = $Service.GetFolder("\")
$TaskDefinition = $Service.NewTask(0) # TaskDefinition object https://msdn.microsoft.com/en-us/library/windows/desktop/aa382542(v=vs.85).aspx
$TaskDefinition.RegistrationInfo.Description = ''
$TaskDefinition.Settings.Enabled = $True
$TaskDefinition.Settings.AllowDemandStart = $True
$TaskDefinition.Settings.DisallowStartIfOnBatteries = $False
$Triggers = $TaskDefinition.Triggers
$Trigger = $Triggers.Create(0) ## 0 is an event trigger https://msdn.microsoft.com/en-us/library/windows/desktop/aa383898(v=vs.85).aspx
$Trigger.Enabled = $true
$TaskEndTime = [datetime]::Now.AddMinutes(30);$Trigger.EndBoundary = $TaskEndTime.ToString("yyyy-MM-dd'T'HH:mm:ss")
$Trigger.Id = '768' # 768 Bitlocker encryption was started for volume
$Trigger.Subscription = "<QueryList><Query Id='0' Path='Microsoft-Windows-BitLocker/BitLocker Management'><Select Path='Microsoft-Windows-BitLocker/BitLocker Management'>*[System[Provider[@Name='Microsoft-Windows-BitLocker-API'] and EventID=768]]</Select></Query></QueryList>"
$Action = $TaskDefinition.Actions.Create(0)
$Action.Path = $Path
$action.Arguments = $Arguments
$RootFolder.RegisterTaskDefinition($taskName, $TaskDefinition, 6, "NT AUTHORITY\SYSTEM", $null, 5) | Out-Null

Start-Sleep 10
Start-ScheduledTask -TaskName "Escrow Bitlocker Key"
