<#  Test-RegistryProperty-Name

    Based on the Test-RegistrykeyValue function from the Carbon Powershell module.
    Carbon is copyright 2012 Aaron Jensen and licensed under Apache v2
    http://get-carbon.org/
    
    Purpose:
        Determine if a property with a given name exists at a specified location without throwing errors.
    
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