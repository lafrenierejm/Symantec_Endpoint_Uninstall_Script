<#  Remove-RegistryProperty-Name

    Purpose:
        Delete property $name from $path

    parameters:
        [string] literalPath
        Parsed as a literalPath, so no wildcard interpretations.
        
        [string] name
        Parsed exactly as passed. Any regex must be included prior to passing as argument.
        
    Returns
        Exit code 0 if key was found and 
        Exit code 1 if there was nothing to remove
#>

[CmdletBinding()]

param (
    [parameter(Mandatory=$true)][string]$literalPath,
    [parameter(Mandatory=$true)][string]$name
)

# Remove the property
if (.\Test-RegistryProperty-Name -literalPath $literalPath -name $name) {
    # Property was found, attempt to remove
    try {
        Remove-ItemProperty -literalPath $literalPath -name $name
    }
    # Property not found, exit with code 1
    catch {
        Exit 1
    }
}

# Exit function
Exit 0