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

$providerHwOrder  = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\NetworkProvider\HwOrder"
$providerOrder = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NetworkProvider\Order"
$backupRegRoot = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\RasMan\PPP\EAP"
[array]$backupKeys = @(
    "13",
    "25",
    "26",
    "4")
[array]$backupValues = @(
    "ConfigUIPath",
    "IdentityPath",
    "InteractiveUIPath",
    "Path")
$deleteKey = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\RasMan\PPP\EAP\88"


################################################################################
# Execute actions specified by Symantec


# Steps 1-3; remove SnacNp from HwOrder\ProviderOrder lists
if (Test-Path -literalPath $providerHwOrder) {
    $value = Get-ItemProperty -literalPath $providerHwOrder -name "Value"
    $value = $value -replace "[,]{0,}SnacNP[,]{0,}$" ""    # Replace SnacNP and accompanying commas if at end of string
    $value = $value -replace "SnacNp[,]{0,}", ""    # Replace SnacNP and following commas if not at end of string
    Set-ItemProperty -literalPath $providerHwOrder -name "Value" -value $value
} else {
    Write-Host "Key $providerHwOrder does not exist"
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