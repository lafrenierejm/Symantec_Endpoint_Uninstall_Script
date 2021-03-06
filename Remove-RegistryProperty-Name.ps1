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
<#  Remove-RegistryProperty-Name

    Purpose:
        Delete property $name from $path

    parameters:
        [string] literalPath
        Parsed as a literalPath, so no wildcard interpretations.
        
        [string] name
        Parsed exactly as passed. Any regex must be included prior to passing as argument.
        
        [int] exitSuccess
        Exit code for successful removal
        Default is 0
        
        [int] exitFail
        Exit code for when property is found, but removal fails
        Default is 1
        
        [int] exitNotFound
        Exit code for when is neither found nor removed
        Default is 2
        
    Returns
        exitSuccess if key was found and removed
        exitFail if key was found but not removed
        exitNotFound is key was not found
#>

[CmdletBinding()]

param (
    [parameter(Mandatory=$true)][string]$literalPath,
    [parameter(Mandatory=$true)][string]$name,
    [int]$exitSuccess = 0,
    [int]$exitFail = 1,
    [int]$exitNotfound = 2
)

# Assume property is found and removed
[int]$exitCode = $exitSuccess

if (.\Test-RegistryProperty-Name -literalPath $literalPath -name $name) {
    # Attempt to remove
    try {
        Remove-ItemProperty -literalPath $literalPath -name $name -errorAction Stop
    }
    # Removal unsuccessful, set exit code to $exitFail
    catch [system.exception] {
        $exitCode = $exitFail
    }
}

# Property was not found
else {
    $exitCode = $exitNotFound
}

# Exit function
Exit $exitCode