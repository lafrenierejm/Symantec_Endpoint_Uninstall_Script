<#
    Copyright (C) 2015 Joseph M LaFreniere

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#>
################################################################################
<#
    Completes steps listed under the second "To remove the Teefer driver" section at
    https://support.symantec.com/en_US/article.TECH161956.html
#>
################################################################################
################################################################################
<# DeleteKeys_MatchProperty_EqName

    Parameters:
        [string] beginKey
        [bool] recurse
        [string] value
        
    Result:
        Delete reg keys with a property of name=$name and value=$value.
        Recurse through $beginKey, removing each found instance.
#>

Function DeleteKeys_MatchProperty_EqName {
    Param (
        [string]$beginKey,
        [string]$value,
        [string]$name)
        
    # Steps 3-4
    if (Test-Path -literalPath $beginKey) {
        Get-ChildItem -literalPath $beginKey -recurse -errorAction silentlyContinue | ForEach {    # Recurse, passing each key
            $keyPath = $_.PsPath    # Stores the passed path
            $currentKey = Get-Item -literalPath $keyPath    # Get the key at that path
            #Write-Host $currentKey
            
            $currentKey.GetValueNames() | Where {    # Pass name of each property in the current key
                $currentKey.GetValue($_) -cmatch $value } | ForEach {    # Pass names of properties that contain $value in value
                    if ($_ -eq $name) {    # If that property is named ComponentId...
                       #Write-Host $currentKey
                       Remove-Item -literalPath $currentKey
                    }
                }
        }
    }
}


################################################################################
<# DeleteKeys_ContainName

    Parameters:
        [string] beginKey
        [string] name
        
    Result:
        Delete reg keys with a property of name=$name and value=$value.
        Recurse through $beginKey, removing each found instance.
#>

Function DeleteKeys_ContainName {
    Param (
        [string]$beginKey,
        [string]$name)
        
    # Steps 3-4
    if (Test-Path -literalPath $beginKey) {
        Get-ChildItem -literalPath $beginKey -recurse -errorAction silentlyContinue | ForEach {    # Recurse, passing each key
            $keyPath = $_.PsPath    # Stores the passed path
            $currentKey = Get-Item -literalPath $keyPath    # Get the key at that path
            #Write-Host $currentKey
            
            $currentKey.GetValueNames() | Where {    # Pass name of each property in the current key
                if ($_ -eq "*$name*") {    # If a property's name contains $name
                   #Write-Host $currentKey
                   Remove-Item -literalPath $currentKey    # Delete the key
                }
            }
        }
    }
}

################################################################################
<# Entrance point to script #>

# Steps 1-3
Write-Host "1. Open command prompt with Administrator priveleges."
Write-Host "2. Run `"pnputil -e`""
Write-Host "3. Type `"pnputil -f -d oem<n>.inf`" to remove Symantec drivers from driver store, where <n> is a number corresponding to one of the Symantec drivers listed in the previous step."
Write-Host "4. Close the command prompt."
cmd /c pause


# Steps 5-6
[string]$step5Key = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}"
[string]$step6Value = "symc_teefer2"
[string]$step6Name = "ComponentId"
DeleteKeys_MatchProperty_EqName $step5Key $step6Value $step6Name

# Steps 7-8
[string]$step7Key = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceClasses\{ad498944-762f-11d0-8dcb-00c04fc3358c}"
[string]$step8Name = "SYMC_TEEFERMP"
DeleteKeys_ContainName $step7Key $step8Name

# Steps 9-10
[string]$step9Key = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceClasses\{cac88424-7515-4c03-82e6-71a87abac361}"
[string]$step10Name = "SYMC_TEEFERMP"
DeleteKeys_ContainName $step9Key $step10Name