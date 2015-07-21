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
[int]$index
[bool]$keyFound

# Increment through $endpointRegFiles and parse each registry key into $endpointRegKeys
$index = 0
while (($index -ge 0) -and ($index -lt $endpointRegFiles.Count)) {    # Loop while 0 < i < endpointRegKeys.Count
    $endpointRegKeys += Get-Content $endpointRegFiles[$index]
    $index++
}

# Remove all existing keys (Endpoint steps 3, 4, 6, 8, 9, 10, 11)
$index = 0
while (($index -ge 0) -and ($index -lt $endpointRegKeys.Count)) {    # Loop while 0 < i < endpointRegKeys.Count
    $keyFound = Test-Path -LiteralPath $endpointRegKeys[$index]    # Test for existence of each key
    if ($keyFound) {                                       # If found, delete key
        Remove-Item $endpointRegKeys[$index]
    }
    $index++
}