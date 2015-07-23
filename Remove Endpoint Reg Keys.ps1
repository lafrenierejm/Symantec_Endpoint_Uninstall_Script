<#
    Copyright (C) 2015 Joseph M LaFreniere

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
# Setup


# Temporarily store existing variables so that they won't be removed at end of script
# Credit goes to Ingo Karstein for the code featured in TechNet's 2011-08-21 The Scripting Guys
# http://blogs.technet.com/b/heyscriptingguy/archive/2011/08/21/clean-up-your-powershell-environment-by-tracking-variable-use.aspx
$startupVariables = ""
new-variable -force -name startupVariables -value (Get-Variable | % {$_.Name})

# Set the executing directory to the script's directory
Push-Location    # Push the current location to the stack
Set-Location (Split-Path -parent $MyInvocation.MyCommand.Definition)

[array]$endpointRegFiles = @(
#    "EndpointRegKeys03.txt",
#    "EndpointRegKeys04.txt",
#    "EndpointRegKeys06.txt",
#    "EndpointRegKeys08.txt",
#    "EndpointRegKeys09.txt",
#    "EndpointRegKeys10.txt",
#    "EndpointRegKeys11.txt"
    )
[array]$endpointRegKeys = @()
[array]$endpointStep19Strings = @(
    "Vpshell2",
    "VpShellEx",
    "VpshellRes"
)
[string]$endpointRegKeys05 = Get-Content "EndpointRegKeys05.txt"
[string]$endpointRegKeys07 = Get-Content "EndpointRegKeys07.txt"
[string]$endpointRegKeys12 = Get-Content "EndpointRegKeys12.txt"
[string]$endpointRegKeys18 = Get-Content "EndpointRegKeys18.txt"
[array]$endpointRegKeys19 = Get-Content "EndpointRegKeys19.txt"
#Set-Variable -name GUID -value "[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}" -option readOnly

################################################################################

# Steps 3, 4, 6, 8, 9, 10, 11
# Iterate through $endpointRegFiles and parse each registry key into $endpointRegKeys
ForEach ($regKeyFile in $endpointRegFiles) {
    $endpointRegKeys += Get-Content $regKeyFile
}
# Remove all existing keys
ForEach ($key in $endpointRegKeys) {            # Iterate through $endpointRegKeys
    if (Test-Path -literalPath $key) {          # Test for existence of each key
#       Write-Host "found $key"
#       Remove-Item $key                        # If found, delete key
    }
}

# Step 5
# Delete value SAVCE in HKEY_LOCAL_MACHINE\SOFTWARE\Symantec\InstalledApps
if (Get-ItemProperty -literalPath $endpointRegKeys05 -name "SAVCE" -errorAction silentlyContinue) {
    #Write-Host "Property `"SAVCE`" would have been removed from $endpointRegKeys05."
#   Remove-ItemProperty -literalPath $endpointRegKeys05 -name "SAVCE"
}

# Step 7
# Delete value SAVCE in HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432node\Symantec\InstalledApps
if (Get-ItemProperty -literalPath $endpointRegKeys07 -name "SAVCE" -errorAction silentlyContinue) {
    #Write-Host "Property `"SAVCE`" would have been removed from $endpointRegKeys07."
#   Remove-ItemProperty -literalPath $endpointRegKeys05 -name "SAVCE"
}

# Steps 12-17
# Remove key named 32 character-long hexadecimal GUID containing word "Symantec"
# Key will be inside HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
if (Test-Path -literalPath $endpointRegKeys12) {    # Test for existence of $endpointRegKeys12
    Get-ChildItem -literalPath $endpointRegKeys12 -recurse | ForEach-Object {    # Recurse through Uninstall, passing each key
        if ($_ -imatch "\{$GUID\}$") {              # Look only in keys ending in a GUID enclosed in braces
            if ((Get-ItemProperty -literalPath $_.PsPath) -imatch "symantec") {    # Look for key with value containing string "symantec"
                Write-Host "$_ would have been removed."    # Print the name of the key
#               Remove-Item -literalPath $_.PsPath    # Delete the key
            }
        }
    }
} else {    # $endpointRegKeys12 does not exist
    Write-Host "The registry key(s) `"$endpointRegKeys12`" not found; exiting script"    # Print error message
    Exit    # Exit script
}

# Step 18
# Remove values containing string "Symantec" from
# HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\SharedDLLs
if (Test-Path -literalPath $endpointRegKeys18) {    # Test for existence of $endpointRegKeys18
#    Remove-ItemProperty -literalPath $endpointRegKeys18 -name "*symantec*"    # Remove properties containing string "symantec" in their names
} else {    # $endpointRegKeys18 does not exist
    Write-Host "The registry key(s) `"$endpointRegKeys18`" not found; exiting script"    # Print error message
    Exit    # Exit script
}

# Step 19
# Remove all values containing or named:
# Vpshell2, VpShellEx, or VpshellRes
ForEach ($rootKey in $endpointRegKeys19) {
    #Write-Host $key
    Get-ChildItem -literalPath $rootKey -recurse -errorAction silentlyContinue | ForEach {    # Recurse through the registry, passing each key
        $keyPath = $_.PsPath    # Get the current directory path
        #Write-Host "keyPath = $keyPath"
        $currentKey = Get-Item -literalPath $keyPath    # Get the key at that path
        #Write-Host "currentKey = $currentKey"
        
        ForEach ($string in $endpointStep19Strings) {    # Go through each item in array $stringsToRemove
            #Write-Host $string    # Print the currently active string
#            Remove-ItemProperty -literalPath $keyPath -name $string  # Remove property with string as its name
            #if (Get-ItemProperty -literalPath $keyPath -name $string -errorAction silentlyContinue) {Write-Host "Step 19: $keyPath $string"}
            $currentKey.GetValueNames() | Where {    # Pass name of each property in the current key
                $currentKey.GetValue($_) -match $string} | ForEach {    # Pass only names of properties that contain the desired string
                #Write-Host "Step 19: $keyPath $_"    # Display key path and property name
#               Remove-ItemProperty -literalPath $keyPath -name $_    # Remove those properties from current key
            }
        }
    }
}


################################################################################
# Cleanup


# Apply Remove-Variable to all variables that didn't exist at beginning of script
Get-Variable |
    Where-Object { $startupVariables -notcontains $_.name} |
    % {Remove-Variable -name "$($_.Name)" -force -scope "global"}

# Return to the caller's location
Pop-Location