[string]$step9Key = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Test2"
[string]$step10Name = "beeet"
[int]$exitCode = 8
Write-Host "key: $step9Key Name: $step10Name int: $code"
.\Remove-RegistryKey-PropertyName -literalPath $step9Key -name $step10Name -recurse $false
#Write-Host $code.Value
Write-Host $error[0]
Write-Host $LastExitCode