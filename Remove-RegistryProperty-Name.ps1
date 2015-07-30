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