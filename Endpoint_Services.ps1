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
    Completes steps listed under the "To stop Symantec Endpoint Protection" section at
    https://support.symantec.com/en_US/article.TECH161956.html
#>
################################################################################
################################################################################
<#  Test-Service

    Based on the Test-Service function from version 19.0 of Carbon Powershell module.
    Carbon is copyright 2012 Aaron Jensen and licensed under Apache v2
    http://get-carbon.org/
    
    Parameters:
        [string] name
        
    Results:
        $true if service named $name exists
        $false otherwise
#>

function Test-Service {
    [CmdletBinding()]
    
    param (
        [parameter(Mandatory=$true)][string]$name    # The name of the service to test.
    )
    
    [bool]$exists = $false
    $service = Get-Service -Name "$name*" |
                    Where-Object { $_.Name -eq $name }

    # Test for existence of $service
    if ($service) {
        $exists = $true
    }
    
    # Return value of $exists
    return $exists
}

################################################################################
<#  Disable-Service

    Parameters:
        [string] name
        
    Results:
        Stops and disables the service named $name
#>

function Disable-Service {
    [CmdletBinding()]
    
    param (
        [parameter(Mandatory=$true)][string]$name    # The name of the service to test.
    )
    
    if (Test-Service -name $name) {
        Stop-Service -name $service #-whatIf    # Uncomment "whatIf" flag to disable
        Set-Service -name $service -startupType "Disabled" #-whatIf    # Uncomment "whatIf" flag to disable
    }
    
    # Return from this function
    return
}

################################################################################
<#  Test-RegistryProperty-ByName

    Based on the Test-Service function from version 19.0 of Carbon Powershell module.
    Carbon copyright 2012 Aaron Jensen and licensed under Apache v2
    http://get-carbon.org/
    
    parameters:
        [string] path
        [string] name
        
    Results:
        returns $true if property named $name exists in $path
        returns $false if does not exist
#>

function Test-RegistryProperty-ByName {
    param (
        [parameter(Mandatory=$true)][string]$path,    # Path of value
        [parameter(Mandatory=$true)][string]$name    # Name of value
    )
    
    # return $false if path is not to a valid key
    if (-not (Test-Path -literalPath $path -pathType Container)) {
        return $false
    }

    # Get the properties under $path
    $properties = Get-ItemProperty -literalPath $path
    if (-not $properties) {    # See if properties exist
        return $false
    }
    
    # Get the specific property from $properties
    $member = Get-Member -inputObject $properties -name $name
    if ($member) {
        return $true
    } else {
        return $false
    }
}

################################################################################
<#  Cleanup

    parameters:
        none
    
    Results:
        Delete variables created for this script, return to caller's location, and exit this scrip

    Credit for var removal to Ingo Karstein for the code featured in TechNet's 2011-08-21 The Scripting Guys
    http://blogs.technet.com/b/heyscriptingguy/archive/2011/08/21/clean-up-your-powershell-environment-by-tracking-variable-use.aspx
#>

function Cleanup {
    # Apply Remove-Variable to all variables that didn't exist at beginning of script
    Get-Variable |
        Where-Object { $startupVariables -notcontains $_.name} |
            % {Remove-Variable -name "$($_.Name)" -force -scope "global"}
         
    # Return to location of caller of script
    Pop-Location
    
    # Return from this function
    return
}

################################################################################
<# Entrance to script
#>

# Temporarily store existing variables so that they won't be removed at end of script
$startupVariables = ""
new-variable -force -name startupVariables -value (Get-Variable | % {$_.Name})

# Set the executing directory to the script's directory
Push-Location    # Push the current location to the stack
Set-Location (Split-Path -parent $MyInvocation.MyCommand.Definition)

<# Stop and disable each service #>
# Services to be disabled
[array]$services = @(
    "Symantec Management Client",
    "Symantec Network Access Control",
    "Symantec Endpoint Protection")
# Increment through and disable the services
forEach ($service in $services) {
    Disable-Service -name $service
}
    
<# Change the values the reg properties named Start to 4 #>
# Registry keys to be modified
[array]$regKeys = @(
    "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SepMasterService",
    "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SmcService",
    "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SNAC")
# Increment through and change values
forEach ($key in $regKeys) {
    if (Test-RegistryProperty-ByName $key "Start") {
        Set-ItemProperty -literalPath $key -name "Start" -value "4"
    }
}

# Delete any variables made over course of this script and return to caller's location
Cleanup

# Exit the script
exit