
#----------- Remove Uniform Key from All Users and Default Hive -----------#

#Credit "Monte Elias Hazboun" for script cleanup
#We need our error to be terminating for our try/catch to work so we use erroraction stop

try {
    New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS -erroraction stop | Out-Null
}
catch [System.Management.Automation.SessionStateException] {
    Write-Warning "Drive Already exists"
}

#Set location to PSDrive
Set-Location HKU:

#Set variable for User SID selection
$SID = 'S-1-5-21-\d+-\d+\-\d+\-\d+$'

#Set variable for Uniform registry key
$RegistryKey = "\Software\Unimap_moca"

#Get existing User and Default Hives
$UserHives = Get-ChildItem | Where-Object { 
    $_.Name -Match $sid -or $_.Name -Match "Default" 
}

#Loop through each profile and remove the Registry Key
Foreach ($UserRegistry in $UserHives) {

    #Set variable for key to test
    $RegistryTarget = (Join-Path $UserRegistry.Name $RegistryKey)

    If (Test-Path $RegistryTarget) {
        Try {
            Remove-Item -Path Registry::$RegistryTarget -Recurse -Force -ErrorAction Stop
        }
        Catch [System.Management.Automation.ItemNotFoundException] {
            Write-Warning "$registrytarget was somehow deleted between the time we ran the test path and now."
        }
        Catch {
            Write-Warning "Some other error $($error[0].Exception). Most likely access denied"
        }
    }
}

#Remove PSDrive HKU
Remove-PSDrive "HKU" -Force
#----------------------#
