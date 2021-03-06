<#
    Copyright (C) 2015 Joseph M LaFreniere
    
    This is part of Symantec_Endpoint_Uninstall_Script

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
<#  Delete-RegistryKey-PropertyName

    Purpose:
        Remove registry key(s) if a property with a given name exists at in that key(s).
    
    parameters:
        [string] literalPath
        The path to the registry key.
        Parsed as a literalPath, so no wildcard interpretations.
        
        [string] name
        The name of the desired property.
        Parsed exactly as received; any regex must be passed to this script in the argument.
        
        [bool] recurse
        Set true if want to recurse into given path.
        Default is false.
        
        [int] exitSuccess
        Exit code for successful removal
        Default is 0
        
        [int] exitFail
        Exit code for when property is found, but removal fails
        Default is 1
        
        [int] exitNotFound
        Exit code for when property is neither found nor removed
        Default is 2
        
    Results:
        exitSuccess if any keys were removed
        exitFail if property was found, but removal of key failed
        exitNotFound if property was not found
#>

[CmdletBinding()]

param (
    [parameter(Mandatory=$true)][string]$literalPath,
    [parameter(Mandatory=$true)][string]$name,
    [bool]$recurse = $false,    # Default is no recursion
    [int]$exitSuccess = 0,
    [int]$exitFail = 1,
    [int]$exitNotFound = 2
)

# Assume key is found and removed
[int]$exitCode = $exitSuccess

# Look for property inside given key
if (.\Test-RegistryProperty-Name -literalPath $literalPath -name $name) {
    try {
        # Attempt to remove key, throw terminating error if unable
        Remove-Item -literalPath $literalPath -recurse -errorAction Stop
    }
    catch [system.exception] {
        $exitCode = $exitFail
    }
}

# If property was not found, try recurse
elseif ($recurse) {
    # Recurse through $literalPath, passing each new path
    Get-ChildItem -literalPath $literalPath -recurse -errorAction silentlyContinue | ForEach {
        # If property is inside the passed key, remove the key
        if (.\Test-RegistryProperty-Name -literalPath $_.PsPath -name $name) {
            try {
                Remove-Item -literalPath $currentKey -recurse -errorAction Stop # throw terminating error
            }
            catch [system.exception] {
                $exitCode = $exitFail
            }
        }
    }
}

# Property not found
else {
    $exitCode = $exitNotFound
}

# Exit the script, returning $exitCode
Exit $exitCode