
#-------------- Remove Default User Hive Entry --------------

#Set test value
$ValuePSDrive = $Null

#Set Default PS Drive Name
$DefHiveValue = "HKUDefaultHive"

#Remove PSDrive HKUDefaultHive if it is already loaded
If (Test-Path $DefHiveValue) {
    Try {
        $ValuePSDrive = Get-PSDrive -Name $DefHiveValue | Select-Object Name
    }
    Catch {
        $ErrorActionPreference = "silentlycontinue"
    }
    Finally {
        If ($ValuePSDrive -eq $DefHiveValue) {
            Remove-PSDrive $DefHiveValue
        }
    }
}

#Create PSDrive for HKU
New-PSDrive -PSProvider Registry -Name HKUDefaultHive -Root HKEY_USERS
 
#Load Default User Hive
Reg Load "HKU\DefaultHive" "C:\Users\Default\NTUser.dat"
 
#Set UniformDefaultHive Variable
$UniformKey = "HKUDefaultHive:\DefaultHive\Software\Unimap_moca"

#Reset test key value
$Value=$Null

#Test if key exists and remove it true
If (Test-Path $UniformKey) {
    Try {
        $Value = Get-Item -Path $UniformKey
    }
    Catch {
        $ErrorActionPreference = "silentlycontinue"
    }
    Finally {
        If ($Value -eq $UniformKey) {
            Remove-Item -Path $UniformKey -Force | Out-Null
        }
    }
}

#Unload Hive
Reg Unload 'HKU\DefaultHive'
 
#Remove PSDrive HKUDefaultHive
Remove-PSDrive "HKUDefaultHive"
#----------------------------

#Set variable for Uniform registry key
$RegistryPath = "Software\Unimap_moca"

#Set variable for User profiles in registry
$SID = 'S-1-5-21-\d+-\d+\-\d+\-\d+$'
$UserRegistryList = Get-ChildItem Registry::'HKU' | Select Name | Where {$_.Name -match $SID }

#Remove Uniform reg keys from every local user registry
Foreach ($UserRegistry in $UserRegistryList){

    New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS

    #Set variable for key to test
    $RegistryTarget = (Join-Path $UserRegistry.Name $RegistryPath) -replace 'HKEY_USERS', 'HKU:'
    write-host $RegistryTarget
    Test-Path $RegistryTarget

    #Reset test variable value
    $UserValue = $Null

    If (Test-Path $RegistryTarget) {
        Try {
            $UserValue = Test-Path $RegistryTarget
        }
        Catch {
            $ErrorActionPreference = "silentlycontinue"
        }
        Finally {
            If ($UserValue) {
                Remove-Item -Path $RegistryTarget -recurse -Force | Out-Null
            }
        }
    }
    Remove-PSDrive "HKU"
}
