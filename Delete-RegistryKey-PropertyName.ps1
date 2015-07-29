<#  Delete-RegistryKey-Name

    Parameters:
        [string] literalPath
        
        [string] name
        $name should include any desired wildcards in the argument itself.
        
        [bool] recurse
        
    Results:
        Delete reg key at $literalPath containing a property of name=$name.
        If $recurse is set, recurse through $literalPath, removing each found instance.
#>

[CmdletBinding()]

param (
    [string]$literalPath,
    [string]$name,
    [bool]$recurse = $false    # Default is no recursion
)

# Look for property inside given key
if (.\Test-RegistryProperty-Name -literalPath $literalPath -name $name) {
    Remove-Item -literalPath $literalPath -recurse    # Delete the key
}

# If property was not found, try recurse
elseif ($recurse) {
    # Recurse through $literalPath, passing each new path
    Get-ChildItem -literalPath $literalPath -recurse -errorAction silentlyContinue | ForEach {
        # If property is inside the passed key, delete the key
        if (.\Test-RegistryProperty-Name -literalPath $_.PsPath -name $name) {
            Remove-Item -literalPath $currentKey -recurse
        }
    }
}

# Exit the script
exit