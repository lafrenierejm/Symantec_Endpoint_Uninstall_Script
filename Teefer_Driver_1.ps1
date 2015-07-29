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
    [CmdletBinding()]

    param (
        [parameter(Mandatory=$true)][string]$literalPath,    # Path of value
        [parameter(Mandatory=$true)][string]$name    # Name of value
    )
    
    # return $false if path is not to a valid key
    if (-not (Test-Path -literalPath $literalPath -pathType Container)) {
        return $false
    }

    # Get the properties under $path
    $properties = Get-ItemProperty -literalPath $literalPath
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
<#  Remove-RegistryProperty-ByName

    parameters:
        [string] path
        [string] name
        
    Results:
        Delete property $name from $path
#>

function Remove-RegistryProperty-ByName {
    [CmdletBinding()]

    param (
        [parameter(Mandatory=$true)][string]$literalPath,    # Path of value
        [parameter(Mandatory=$true)][string]$name    # Name of value
    )
    
    # Remove the property if it exists
    if (Test-RegistryProperty-ByName -literalpath $literalPath -name $name) {
        Remove-ItemProperty -literalPath $literalPath -name $name
    }
    
    # Exit function
    return
}

################################################################################
<#  Cleanup

    Parameters:
        none
    
    Results:
        Delete variables created for this script, return to caller's location, and exit this scrip

    Credit goes to Ingo Karstein for the code featured in TechNet's 2011-08-21 The Scripting Guys
    http://blogs.technet.com/b/heyscriptingguy/archive/2011/08/21/clean-up-your-powershell-environment-by-tracking-variable-use.aspx
#>

Function Cleanup {
    # Apply Remove-Variable to all variables that didn't exist at beginning of script
    Get-Variable |
        Where-Object { $startupVariables -notcontains $_.name} |
            % {Remove-Variable -name "$($_.Name)" -force -scope "global"}
         
    # Return to location of caller of script
    Pop-Location
    
    # Return from this function
    Return
}

################################################################################
<# Entrance point to script #>

# Temporarily store existing variables so that they won't be removed at end of script
# Credit goes to Ingo Karstein for the code featured in TechNet's 2011-08-21 The Scripting Guys
# http://blogs.technet.com/b/heyscriptingguy/archive/2011/08/21/clean-up-your-powershell-environment-by-tracking-variable-use.aspx
$startupVariables = ""
new-variable -force -name startupVariables -value (Get-Variable | % {$_.Name})

<# Set the executing directory to the script's directory #>
Push-Location    # Push the current location to the stack
Set-Location (Split-Path -parent $MyInvocation.MyCommand.Definition)

<# Variables #>
[string]$step3Key = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Network\{4D36E974-E325-11CE-BFC1-08002BE10318}"
[string]$step5Key = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Network"

<# Steps 3-4 #>
if (Test-Path -literalPath $step3Key) {
    Get-ChildItem -literalPath $step3Key -recurse -errorAction silentlyContinue | ForEach {    # Recurse, passing each key
        $keyPath = $_.PsPath    # Stores the passed path
        $currentKey = Get-Item -literalPath $keyPath    # Get the key at that path
        
        $currentKey.GetValueNames() | Where {    # Pass name of each property in the current key
            $currentKey.GetValue($_) -cmatch "symc_teefer2" } | ForEach {    # Pass names of properties that contain string in value
                if ($_ -eq "ComponentId") {    # If that property is named ComponentId...
                    # Set Characteristics property to value 4000
                    Set-ItemProperty -literalPath $keyPath -name "Characteristics" -value "4000" -whatIf    # Uncomment whatIf to activate
                }
            }
    }
}

<# Steps 5-6 #>
# Remove property "Config" from $step5Key
Remove-RegistryProperty-ByName -literalPath $step5Key -name "Config"

<# Steps 8-13 #>
# Guide user through uninstalling Teefer from network connections
Write-Host "Open `"Control Panel > Network and Sharing Center`"."
Write-Host "Click `"Change adapter settings`" in the column on the left."
Write-Host "For each listing:"
Write-Host "`tRight click > `"Properties`""
Write-Host "`tSelect `"Teefer Driver`" if it exists and click `"Uninstall`"."
cmd /c pause    # Pause the script

# Delete any variables made over course of this script
Cleanup

# Exit the script
exit