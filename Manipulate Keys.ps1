[array]$endpointServices = @(
    "Symantec Management Client",
    "Symantec Network Access Control",
    "Symantec Endpoint Protection"
)
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

Write-Host "Right-click the Symantec Endpoint Protection icon in the lower right corner of the screen, and click Open Symantec Endpoint Protection."
Write-Host "In the left pane, click Change Settings."
Write-Host "In the right pane, click Client Management > Configure Settings."
Write-Host "On the Tamper Protection tab, uncheck Protect Symantec security software from being tampered with or shut down."
Write-Host "Click OK."
Write-Host "Close Symantec Endpoint Protection."

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