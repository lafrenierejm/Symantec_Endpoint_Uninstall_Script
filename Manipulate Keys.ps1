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
[string]$endpointRegKeys05 = Get-Content "EndpointRegKeys05.txt"
[string]$endpointRegKeys07 = Get-Content "EndpointRegKeys07.txt"
[string]$endpointRegKeys12 = Get-Content "EndpointRegKeys12.txt"
[string]$endpointRegKeys18 = Get-Content "EndpointRegKeys18.txt"
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
if (Get-ItemProperty -literalPath $endpointRegKeys05 -name "SAVCE" -errorAction SilentlyContinue) {
#   Write-Host "Property SAVCE would have been removed from $endpointRegKeys05."
#   Remove-ItemProperty -literalPath $endpointRegKeys05 -name "SAVCE"
}

# Step 7
# Delete value SAVCE in HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432node\Symantec\InstalledApps
if (Get-ItemProperty -literalPath $endpointRegKeys07 -name "SAVCE" -errorAction SilentlyContinue) {
    #Write-Host "Property SAVCE would have been removed from $endpointRegKeys07."
#   Remove-ItemProperty -literalPath $endpointRegKeys05 -name "SAVCE"
}

# Steps 12-17
# Remove key named 32 character-long hexadecimal GUID containing word "Symantec"
# Key will be inside HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
if (Test-Path -literalPath $endpointRegKeys12) {    # Test for existence of $endpointRegKeys12
    Get-ChildItem -literalPath $endpointRegKeys12 -recurse | ForEach-Object {    # Recurse through Uninstall, passing each key
        if ($_ -imatch "\{$GUID\}$") {              # Look only in keys ending in a GUID enclosed in braces
            if ((Get-ItemProperty -literalPath $_.PsPath) -match "symantec") {    # If key has a value containing string "symantec"...
                #Write-Host "`n$_ would have been removed.`n"    # Print the name of the key
    #           Remove-Item -literalPath $_.PsPath    # Delete the key
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
    Get-ItemProperty -path $endpointRegKeys18 -name "*symantec*" | ForEach {    # Pass properties containing string "symantec" in their names
        Write-Host "$_"    # Print the name of the property
#        Remove-ItemProperty $_    # Remove the property
    }
} else {    # $endpointRegKeys18 does not exist
    Write-Host "The registry key(s) `"$endpointRegKeys18`" not found; exiting script"    # Print error message
    Exit    # Exit script
}