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
    Completes steps listed under the "To stop Symantec Endpoint Protection" section at
    https://support.symantec.com/en_US/article.TECH161956.html
#>
################################################################################
################################################################################


# Temporarily store existing variables so that they won't be removed at end of script
# Credit goes to Ingo Karstein for the code featured in TechNet's 2011-08-21 The Scripting Guys
# http://blogs.technet.com/b/heyscriptingguy/archive/2011/08/21/clean-up-your-powershell-environment-by-tracking-variable-use.aspx
$startupVariables = ""
new-variable -force -name startupVariables -value (Get-Variable | % {$_.Name})

# Set the executing directory to the script's directory
Push-Location    # Push the current location to the stack
Set-Location (Split-Path -parent $MyInvocation.MyCommand.Definition)

[array]$services = @(    # Services to be disabled
    "Symantec Management Client",
    "Symantec Network Access Control",
    "Symantec Endpoint Protection" )
[array]$regKeys = @(    # Registry keys to be modified
    "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SepMasterService",
    "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SmcService",
    "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SNAC" )


################################################################################
# Execute actions specified by Symantec


# Stop and disable each service
ForEach($service in $services) {
    Stop-Service -name $service #-whatIf    # Uncomment "whatIf" flag to disable
    Set-Service -name $service -startupType "Disabled" #-whatIf    # Uncomment "whatIf" flag to disable
}
    
# Change the value of Start in each key to 4
ForEach($key in $regKeys) {
    if (Test-Path $key) {
        Set-ItemProperty -literalPath $key -name "Start" -value "4" -errorAction silentlyContinue
    } else {
        Write-Host "$key does not exist. No value changed."
    }
}


################################################################################
# Cleanup


Get-Variable |    # Apply Remove-Variable to all variables that didn't exist at beginning of script
    Where-Object { $startupVariables -notcontains $_.name} |
    % {Remove-Variable -name "$($_.Name)" -force -scope "global"}
     
Pop-Location    # Return to the caller's location