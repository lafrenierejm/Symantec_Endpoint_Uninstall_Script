[array]$regFiles = @(
    "EndpointRegKeys03.txt",
    "EndpointRegKeys04.txt",
    "EndpointRegKeys06.txt",
    "EndpointRegKeys08.txt",
    "EndpointRegKeys09.txt",
    "EndpointRegKeys10.txt",
    "EndpointRegKeys11.txt"
)
[int]$index = 0
[array]$regKeys = @()

# Increment through $regFiles and parse each registry key into $regKeys
while (($index -ge 0) -and ($index -lt $regFiles.Count)) {    # Loop while 0 < i < regKeys.Count
    $regKeys += Get-Content $regFiles[$index]
    $index++
}

# Remove all existing keys
$index = 0
[bool]$found
while (($index -ge 0) -and ($index -lt $regKeys.Count)) {    # Loop while 0 < i < regKeys.Count
    $found = Test-Path -LiteralPath $regKeys[$index]    # Test for existence of each key
    $index++
}