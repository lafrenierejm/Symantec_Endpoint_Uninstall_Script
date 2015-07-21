[array]$endpointRegFiles = @(
    "EndpointRegKeys03.txt",
    "EndpointRegKeys04.txt",
    "EndpointRegKeys06.txt",
    "EndpointRegKeys08.txt",
    "EndpointRegKeys09.txt",
    "EndpointRegKeys10.txt",
    "EndpointRegKeys11.txt"
)
[array]$endpointRegKeys = @()
[string]$endpointRegKeys05 = Get-Content "EndpointRegKeys05.txt"

# Steps 3, 4, 6, 8, 9, 10, 11
# Iterate through $endpointRegFiles and parse each registry key into $endpointRegKeys
ForEach ($regKeyFile in $endpointRegFiles) {
    $endpointRegKeys += Get-Content $regKeyFile
}
# Remove all existing keys
ForEach ($key in $endpointRegKeys) {           # Iterate through $endpointRegKeys
    if (Test-Path -literalPath $key) {         # Test for existence of each key
        Write-Host "found $key"
#       Remove-Item $endpointRegKeys[$index]   # If found, delete key
    }
}

# Step 5
# Delete value SAVCE in HKEY_LOCAL_MACHINE\SOFTWARE\Symantec\InstalledApps
if(Get-ItemProperty -literalPath $endpointRegKeys05 -name "SAVCE" -ea 0) {     # -ea flag is erroraction, 0 means silent
    Write-Host "Property SAVCE would have been removed from $endpointStep5."
#   Remove-ItemProperty -literalPath $endpointRegKeys05 -name "SAVCE"
}