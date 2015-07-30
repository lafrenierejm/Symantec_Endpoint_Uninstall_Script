[string]$key = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Test2"
[string]$propertyName = "beet"
[string]$propertyValue = "test"

.\Remove-RegistryKey-PropertyName_PropertyValue.ps1 -literalPath $key -name $propertyName -value $propertyValue -recurse $true -exitFail 306
Write-Host $LastExitCode