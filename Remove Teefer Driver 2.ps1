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
<# DeleteKeyContainValue

    Parameters:
        [string] beginKey
        [bool] recurse
        [string] value
        
    Result:
        Deletes all reg values set to $value.
        Always start in $beginKey, recurse if $recurse = $true.
#>

Function DeleteKeysByEqValue {
    Param (
        [string]$beginKey,
        [bool]$recurse,
        [string]$value,
        [string]$name)
        
    # Steps 3-4
    if (Test-Path -literalPath $beginKey) {
        Get-ChildItem -literalPath $beginKey -recurse -errorAction silentlyContinue | ForEach {    # Recurse, passing each key
            $keyPath = $_.PsPath    # Stores the passed path
            $currentKey = Get-Item -literalPath $keyPath    # Get the key at that path
            
            $currentKey.GetValueNames() | Where {    # Pass name of each property in the current key
                $currentKey.GetValue($_) -cmatch "symc_teefer2" } | ForEach {    # Pass names of properties that contain string in value
                    if ($_ -eq "ComponentId") {    # If that property is named ComponentId...
                       Write-Host $currentKey
                       #Remove-Item -literalPath $currentKey
                    }
                }
        }
    }
}

################################################################################
