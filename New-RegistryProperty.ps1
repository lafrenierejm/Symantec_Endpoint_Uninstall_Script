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
<#  New-RegistryProperty

    parameters:
        [string] literalPath
        The path to the registry key.
        Parsed as a literalPath, so no wildcard interpretations.
        
        [string] name
        The name of the property to create.
        
        [string] value
        The value of the property to create.
        
        [string] propertyType
        The type of property to create. (https://msdn.microsoft.com/en-us/library/microsoft.win32.registryvaluekind.aspx)
        Default is "String"
        
        [int] exitSuccess
        Exit code for successful removal
        Default is 0
        
        [int] exitInvalidPath
        Exit code for when path doesn't go to a container
        Default is 1
        
        [int] exitAlreadyExists
        Exit code for when property with desired name already exists in the specified location
        Default is 2
        
        [int] exitNoCreate
        Exit code for when path and exitence were valid, but property creation failed
        Default is 3
    
    Results:
        Attempts to creates a registry property
        
        exitSuccess if creation is successful
        exitInvalidPath if path is invalid
        exitAlreadyExists if path is valid but property already exists with $name
        exitNoCreate is path is valid and property is unique, but creation itself fails
#>

[CmdletBinding()]

param (
    [string]$literalPath,
    [string]$name,
    [string]$value,
    [string]$propertyType = "String",
    [int]$exitSuccess = 0,
    [int]$exitInvalidPath = 1,
    [int]$exitAlreadyExists = 2,
    [int]$exitNoCreate = 3
)

# Exit code, assume success
[int]$exitCode = $exitSuccess

# If path is not to a container, $success = $false
if (-not (Test-Path -literalPath $literalPath -pathType Container)) {
    Write-Host "Path is not valid."
    $exitCode = $exitInvalidPath
}

# If property already exists at that location, $success = $false
elseif (.\Test-RegistryProperty-Name.ps1 -literalPath $literalPath -propertyName $name) {
    Write-Host "Property already exists."
    $exitCode = $exitAlreadyExists
}

# Else attempt to create the property
else {
    try {
        New-ItemProperty -literalPath $literalPath -name $name -propertyType $propertyType -value $value -errorAction Stop
    }
    catch [system.exception] {
        $exitCode = $exitNoCreate
    }
}

# Exit returning the code corresponding to the action
exit $exitCode