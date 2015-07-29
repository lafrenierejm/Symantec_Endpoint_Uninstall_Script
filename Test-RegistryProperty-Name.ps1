<#  Test-RegistryProperty-Name

    Based on the Test-RegistrykeyValue function from the Carbon Powershell module.
    Carbon is copyright 2012 Aaron Jensen and licensed under Apache v2
    http://get-carbon.org/
    
    parameters:
        [string] the literalPath (no wildcards) to the registry key
        [string] name
        
    Results:
        returns $true if property named $name exists in $path
        returns $false if does not exist
#>

[CmdletBinding()]

param (
    [parameter(Mandatory=$true)][string]$literalPath,
    [parameter(Mandatory=$true)][string]$name    # Name of value
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