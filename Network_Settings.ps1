<#
    Copyright (C) 2015 Joseph M LaFreniere
    
    This is part of Symantec_Endpoint_Uninstall_Script

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

[array]$snacNpKeys = @(
    "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\NetworkProvider\HwOrder",
    "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NetworkProvider\Order")
[array]$pathKeys = @(
    "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\RasMan\PPP\EAP\13",
    "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\RasMan\PPP\EAP\25",
    "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\RasMan\PPP\EAP\26",
    "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\RasMan\PPP\EAP\4")
[array]$pathValues = @(
    "ConfigUIPath",
    "IdentityPath",
    "InteractiveUIPath",
    "Path")
$deleteKey = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\RasMan\PPP\EAP\88"


################################################################################
# Execute actions specified by Symantec


# Steps 1-3: Remove SnacNp from HwOrder\Order lists
ForEach ($key in $scanNpKeys) {
    If (Test-Path -literalPath $key) {
        $value = Get-ItemProperty -literalPath $ -name "ProviderOrder"
        $value = $value -replace "[,]{0,}SnacNP[,]{0,}$" ""    # Replace SnacNP and accompanying commas if at end of string
        $value = $value -replace "SnacNp[,]{0,}", ""    # Replace SnacNP and following commas if not at end of string
        Set-ItemProperty -literalPath $key -name "ProviderOrder" -value $value
    } else {
        Write-Host "Key $key does not exist"
    }
}

# Steps 5-7: Restore backup of Path properties in Rasman\PPP\EAP
ForEach ($key in $pathKeys) {
    If (Test-Path -literalPath $key) {
        ForEach ($value in $pathValues) {
            $backup = $value + "Backup"    # Form name for the backup key
            Remove-ItemProperty -literalPath $key -name $value    # Delete the current key
            Rename-ItemProperty -literalPath $key -name $backup -newName $value    # Rename backup to replace current
        }
    } Else {
        Write-Host "Key $key does not exist."
    }
}

# Step 8: Delete RasMan\PPP\EAP\88
If (Test-Path -literalPath $deleteKey) {
    Remove-Item -literalpath $deleteKey
}

# Call the Cleanup function
Cleanup


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