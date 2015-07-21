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

# Iterate through $endpointRegFiles and parse each registry key into $endpointRegKeys
ForEach ($regKeyFile in $endpointRegFiles) {
    $endpointRegKeys += Get-Content $regKeyFile
}

# Remove all existing keys (Endpoint steps 3, 4, 6, 8, 9, 10, 11)
ForEach ($key in $endpointRegKeys) {           # Iterate through $endpointRegKeys
    if (Test-Path -LiteralPath $key) {         # Test for existence of each key
#       Write-Host "found $key"
#       Remove-Item $endpointRegKeys[$index]   # If found, delete key
    }
}