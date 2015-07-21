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

Write-Host "Right-click the Symantec Endpoint Protection icon in the lower right corner of the screen, and click Open Symantec Endpoint Protection."
Write-Host "In the left pane, click Change Settings."
Write-Host "In the right pane, click Client Management > Configure Settings."
Write-Host "On the Tamper Protection tab, uncheck Protect Symantec security software from being tampered with or shut down."
Write-Host "Click OK."
Write-Host "Close Symantec Endpoint Protection."

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