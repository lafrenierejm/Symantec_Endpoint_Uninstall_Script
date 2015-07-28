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
<# DeleteKeysByProperty

    Parameters:
        [string] beginKey
        [bool] recurse
        [string] value
        
    Result:
        Delete reg keys with a property of name=$name and value=$value.
        Recurse through $beginKey, removing each found instance.
#>

Function DeleteKeysByProperty {
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

[string]$step4Key = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}"
[string]$step4Value = "symc_teefer2"
[string]$step4Name = "ComponentId"
DeleteKeysByProperty $step4Key $step4Value $step4Name