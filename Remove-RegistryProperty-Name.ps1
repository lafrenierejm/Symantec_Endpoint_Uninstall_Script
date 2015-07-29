<#  Remove-RegistryProperty-Name

    Purpose:
        Delete property $name from $path

    parameters:
        [string] literalPath
        Parsed as a literalPath, so no wildcard interpretations.
        
        [string] name
        Parsed exactly as passed. Any regex must be included prior to passing as argument.
        
    Returns
        Exit code 0 if removal was successful
        Exit code 1 if there was nothing to remove
#>

[CmdletBinding()]

param (
    [parameter(Mandatory=$true)][string]$literalPath,
    [parameter(Mandatory=$true)][string]$name
)

# Remove the property
if (.\Test-RegistryProperty-Name -literalPath $path -name $name) {
    Remove-ItemProperty -literalPath $path -name $name
}

# Property does not exist as specified location
else {
    Exit 1
}

# Exit function
Exit 0