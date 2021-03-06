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
<#
    Completes steps listed under the "To remove Symantec Endpoint Protection from the registry" section at
    https://support.symantec.com/en_US/article.TECH161956.html
#>
################################################################################
################################################################################
<#  Remove-RegistryKey-ByName

    parameters:
        [string] regKey
        
    Results:
        Delete $regKey and its children
#>

function Remove-RegistryKey-ByName {
    param (
        [parameter(Mandatory=$true)][string]$regKey
    )
    
    # Delete the key if it exists
    if (Test-Path -literalPath $regKey) {
        Remove-Item -literalPath $regKey -recurse -force
    }

    # return from the function
    return
}

################################################################################
<#  Test-RegistryProperty-ByName

    Based on the Test-RegistrykeyValue function from the Carbon Powershell module.
    Carbon is licensed under Apache v2: http://get-carbon.org/
    
    parameters:
        [string] path
        [string] name
        
    Results:
        returns $true if property named $name exists in $path
        returns $false if does not exist
#>

function Test-RegistryProperty-ByName {
    param (
        [parameter(Mandatory=$true)][string]$path,    # Path of value
        [parameter(Mandatory=$true)][string]$name    # Name of value
    )
    
    # return $false if path is not to a valid key
    if (-not (Test-Path -literalPath $path -pathType Container)) {
        return $false
    }

    # Get the properties under $path
    $properties = Get-ItemProperty -literalPath $path
    if (-not $properties) {    # See if properties exist
        return $false
    }
    
    # Get the specific property from $properties
    $member = Get-Member -inputObject $properties -name $name
    if ($member) {
        return $true
    } else {
        return $false
    }
}

################################################################################
<#  Remove-RegistryProperty-ByName

    parameters:
        [string] path
        [string] name
        
    Results:
        Delete property $name from $path
#>

function Remove-RegistryProperty-ByName {
    param (
        [parameter(Mandatory=$true)][string]$path,    # Path of value
        [parameter(Mandatory=$true)][string]$name    # Name of value
    )
    
    # Remove the property if it exists
    if (Test-RegistryProperty-ByName $path $name) {
        Remove-ItemProperty -literalPath $path -name $name
    }
    
    # Exit function
    return
}

################################################################################
<#  Cleanup

    parameters:
        none
    
    Results:
        Delete variables created for this script, return to caller's location, and exit this scrip

    Credit for var removal to Ingo Karstein for the code featured in TechNet's 2011-08-21 The Scripting Guys
    http://blogs.technet.com/b/heyscriptingguy/archive/2011/08/21/clean-up-your-powershell-environment-by-tracking-variable-use.aspx
#>

function Cleanup {
    # Apply Remove-Variable to all variables that didn't exist at beginning of script
    Get-Variable |
        Where-Object { $startupVariables -notcontains $_.name} |
            % {Remove-Variable -name "$($_.Name)" -force -scope "global"}
         
    # return to location of caller of script
    Pop-Location
    
    # return from this function
    return
}

################################################################################
<# Entrance to script #>

# Temporarily store existing variables so that they won't be removed at end of script
$startupVariables = ""
new-variable -force -name startupVariables -value (Get-Variable | % {$_.Name})

# Set the executing directory to the script's directory
Push-Location    # Push the current location to the stack
Set-Location (Split-Path -parent $MyInvocation.MyCommand.Definition)

# Variables
[array]$regFiles = @(
    "EndpointRegKeys03.txt",
    "EndpointRegKeys04.txt",
    "EndpointRegKeys06.txt",
    "EndpointRegKeys08.txt",
    "EndpointRegKeys09.txt",
    "EndpointRegKeys10.txt",
    "EndpointRegKeys11.txt")
[array]$regKeys = @()
[string]$step5Keys = Get-Content "EndpointRegKeys05.txt"
[string]$step7Keys = Get-Content "EndpointRegKeys07.txt"
[string]$step12Keys = Get-Content "EndpointRegKeys12.txt"
[string]$step18Keys = Get-Content "EndpointRegKeys18.txt"
[array]$endpointStep19Strings = @(
    "Vpshell2",
    "VpShellEx",
    "VpshellRes")
[array]$step19Keys = Get-Content "EndpointRegKeys19.txt"
Set-Variable -name GUID -value "[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}" -option readOnly

# Steps 3, 4, 6, 8, 9, 10, 11
# Iterate through $regFiles and parse each registry key into $regKeys
forEach ($regKeyFile in $regFiles) {
    $regKeys += Get-Content $regKeyFile
}
# Iterate through $regKeys and remove all keys
forEach ($key in $regKeys) {    # Iterate through $regKeys
    Remove-RegistryKey-ByName $key
}

# Step 5
# Delete value SAVCE in HKEY_LOCAL_MACHINE\SOFTWARE\Symantec\InstalledApps
Remove-RegistryProperty-ByName $step5Keys "SAVCE"

# Step 7
# Delete value SAVCE in HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432node\Symantec\InstalledApps
Remove-RegistryProperty-ByName $step7Keys "SAVCE"

# Steps 12-17
# Remove key named 32 character-long hexadecimal GUID containing word "Symantec"
# Key will be inside HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
if (Test-Path -literalPath $step12Keys) {    # Test for existence of $step12Keys
    Get-ChildItem -literalPath $step12Keys -recurse | forEach-Object {    # Recurse through Uninstall, passing each key
        if ($_ -imatch "\{$GUID\}$") {              # Look only in keys ending in a GUID enclosed in braces
            if ((Get-ItemProperty -literalPath $_.PsPath) -imatch "symantec") {    # Look for key with value containing string "symantec"
                #Write-Host "$_ would have been removed."    # Print the name of the key
                Remove-Item -literalPath $_.PsPath    # Delete the key
            }
        }
    }
} else {    # $step12Keys does not exist
    Write-Host "The registry key $step12Keys not found."    # Print error message
}

# Step 18
# Remove values in $step18Keys containing string "Symantec" in name
Remove-RegistryProperty-ByName $step18Keys "*Symantec*"

# Step 19
# Remove all values containing or named:
# Vpshell2, VpShellEx, or VpshellRes
forEach ($rootKey in $step19Keys) {
    Get-ChildItem -literalPath $rootKey -recurse -errorAction silentlyContinue | forEach {    # Recurse through the registry, passing each key
        $keyPath = $_.PsPath    # Get the current directory path
        $currentKey = Get-Item -literalPath $keyPath    # Get the key at that path
        #Write-Host "keyPath = $keyPath"
        #Write-Host "currentKey = $currentKey"
        
        forEach ($string in $endpointStep19Strings) {    # Go through each item in array $stringsToRemove
            Write-Host "Path: $keyPath`nString: $string"
            Remove-RegistryProperty-ByName $keyPath $string  # Remove property with string as its name
            $currentKey.GetValueNames() | Where {    # Pass name of each property in the current key
                $currentKey.GetValue($_) -match $string} | forEach {    # Pass only names of properties that contain the desired string
                    #Write-Host "Step 19: $keyPath $_"    # Display key path and property name
                    Remove-RegistryProperty-ByName $keyPath $_    # Remove those properties from current key
                }
        }
    }
}

# Delete any variables made over course of this script and return to caller's location
Cleanup

# Exit the script
exit