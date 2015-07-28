<#
    Copyright (C) 2015 Joseph M LaFreniere

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#>
################################################################################
<#
    Completes steps listed under the "Remove the Teefer driver (may not be present):" section at
    https://support.symantec.com/en_US/article.TECH161956.html
#>
################################################################################
################################################################################
# Setup

# Temporarily store existing variables so that they won't be removed at end of script
# Credit goes to Ingo Karstein for the code featured in TechNet's 2011-08-21 The Scripting Guys
# http://blogs.technet.com/b/heyscriptingguy/archive/2011/08/21/clean-up-your-powershell-environment-by-tracking-variable-use.aspx
$startupVariables = ""
new-variable -force -name startupVariables -value (Get-Variable | % {$_.Name})

# Set the executing directory to the script's directory
Push-Location    # Push the current location to the stack
Set-Location (Split-Path -parent $MyInvocation.MyCommand.Definition)

[string]$characteristicsRegRoot = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Network\{4D36E974-E325-11CE-BFC1-08002BE10318}"
[string]$configRegKey = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Network"
[bool]$teeferPresent = $false


################################################################################
# Execute actions specified by Symantec

# Steps 3-4
if (Test-Path -literalPath $characteristicsRegRoot) {
    Get-ChildItem -literalPath $characteristicsRegRoot -recurse -errorAction silentlyContinue | ForEach {    # Recurse, passing each key
        $keyPath = $_.PsPath    # Stores the passed path
        $currentKey = Get-Item -literalPath $keyPath    # Get the key at that path
        
        $currentKey.GetValueNames() | Where {    # Pass name of each property in the current key
            $currentKey.GetValue($_) -cmatch "symc_teefer2" } | ForEach {    # Pass names of properties that contain string in value
                if ($_ -eq "ComponentId") {    # If that property is named ComponentId...
                    # Set Characteristics property to value 4000
                    $teeferPresent = $true
                    Set-ItemProperty -literalPath $keyPath -name "Characteristics" -value "4000" -whatIf    # Uncomment whatIf to activate
                }
            }
    }
}

# Steps 5-6
# Remove Config property in HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Network
if (Test-Path -literalPath $configRegKey) {
    Remove-ItemProperty -literalPath $configRegKey -name "Config" -whatIf    # Uncomment whatIf to activate
}   

if ($teeferPresent) {
    Write-Host "Uninstall the Teefer Driver from every network device listed in Network Connections."
}

################################################################################
# Cleanup

function Cleanup {
    # Apply Remove-Variable to all variables that didn't exist at beginning of script
    Get-Variable |
        Where-Object { $startupVariables -notcontains $_.name} |
            % {Remove-Variable -name "$($_.Name)" -force -scope "global"}
         
    # Return to the caller's location
    Pop-Location
    
    # Exit the script
    Exit
}