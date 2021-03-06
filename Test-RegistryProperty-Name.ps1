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

<#
    This code is based on the Test-RegistrykeyValue function from the Carbon Powershell module.
    Carbon is copyright 2012 Aaron Jensen and licensed under Apache v2, which is GPLv3 compatible.
    The Carbon project is available at <http://get-carbon.org/>.
#>
################################################################################
<#  Test-RegistryProperty-Name

    Based on the Test-RegistrykeyValue function from the Carbon Powershell module.
    Carbon is copyright 2012 Aaron Jensen and licensed under Apache v2
    http://get-carbon.org/
    
    parameters:
        [string] literalPath
        The path to the registry key.
        Parsed as a literalPath, so no wildcard interpretations.
        
        [string] name
        The name of the desired property.
        Parsed exactly as received; any regex must be passed to this script in the argument.
        
    Results:
        Returns $true if property $name exists in $literalPath
        returns $false othwerwise
#>

[CmdletBinding()]

param (
    [parameter(Mandatory=$true)][string]$literalPath,
    [parameter(Mandatory=$true)][string]$name
)

# return $false if $literalPath is not to a valid key
if (-not (Test-Path -literalPath $literalPath -pathType Container)) {
    return $false
}

# Get the properties in $literalPath
$properties = Get-ItemProperty -literalPath $literalPath
if (-not $properties) {    # See if properties exist
    return $false
}

# Get the specific property from $properties
$member = Get-Member -inputObject $properties -name $name
if ($member) {    # If any object were found...
    return $true
} else {
    return $false
}