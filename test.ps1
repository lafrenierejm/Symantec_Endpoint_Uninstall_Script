[string]$step9Key = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Test2"
[string]$step10Name = "beeet"
Write-Host "key: $step9Key`nName: $step10Name"
.\Remove-RegistryProperty-Name -literalPath $step9Key -name $step10Name