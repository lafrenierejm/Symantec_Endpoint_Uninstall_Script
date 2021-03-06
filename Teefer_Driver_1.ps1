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
<#  Get-RegistryKeys-PropertyName_PropertyValue

    Purpose:
        Get registry key(s) if a property with a given name and value exists in key(s).
    
    parameters:
        [string] literalPath
        The path to the registry key.
        Parsed as a literalPath, so no wildcard interpretations.
        
        [string] name
        The name of the desired property.
        Parsed exactly as received; any regex must be passed to this script in the argument.
        
        [string] oldValue
        The value to look for.
        Parsed exactly as received; any regex must be passed to this script in the argument.
        
        [string] newValue
        The new value to set.
        Parsed exactly as received; any regex must be passed to this script in the argument.
        
        [bool] recurse
        $true to recurse through $literalPath
        Default is $false.
        
    Results:
        An array of the key paths with those properties will be returned from the function.
#>

function Get-RegistryKeys-PropertyName_PropertyValue {
    [CmdletBinding()]

    param (
        [parameter(Mandatory=$true)][string]$literalPath,
        [parameter(Mandatory=$true)][string]$name,
        [parameter(Mandatory=$true)][string]$value,
        [bool]$recurse = $false
    )
    
    [array]$pathsToReturn = @()
    
    # Look for property inside given key
    if (.\Test-RegistryProperty-Name -literalPath $literalPath -name $name) {
        $currentKey = Get-Item -literalPath $literalPath    # Get the key at the path
        
        # If key contains propertie $name with $value
        if ($currentKey.GetValue($name) -cmatch $value) {
            # Add key to the array
            $pathsToReturn += $literalPath
        }
    }

    Write-Host $pathsToReturn

    # Recurse if flag is set
    if ($recurse) {
        # Recurse through $literalPath, passing each new path
        Get-ChildItem -literalPath $literalPath -recurse -errorAction silentlyContinue | ForEach {
            if (.\Test-RegistryProperty-Name -literalPath $_.PsPath -name $name) {
                $currentKey = Get-Item -literalPath $_.PsPath    # Get the key at the path
                
                # If key contains propertie $name with $oldValue
                if ($currentKey.GetValue($name) -cmatch $value) {
                    # Add that key to the array
                    Write-Host $_
                    $pathsToReturn += $_
                }
            }
        }
    }
    
    Write-Host $pathsToReturn
    
    return $pathsToReturn
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
$startupVariables = ""
new-variable -force -name startupVariables -value (Get-Variable | % {$_.Name})

# Set the executing directory to the script's directory
Push-Location    # Push the current location to the stack
Set-Location (Split-Path -parent $MyInvocation.MyCommand.Definition)


<# Steps 3-4 #>
# Variables
[string]$step3Key = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Network\{4D36E974-E325-11CE-BFC1-08002BE10318}"
[array]$keyPaths = Get-RegistryKeys-PropertyName_PropertyValue -literalPath $step3key -name "ComponentID" -value "symc_teefer2"
# Find keys that have value of ComponentId that is set to symc_teefer2, and update the value of Characteristics to 40000
foreach ($key in $keyPaths) {
    # Test Characteristics's existence in the returned keys
    if (($key.count -gt 0) -and (.\Test-RegistryProperty-Name.ps1 -literalPath $key -name "Characteristics")) {
        Set-ItemProperty -literalPath $key -name "Characteristics" -value "40000"    # Set the new value
    }
}

<# Steps 5-6 #>
[string]$step5Key = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Network"
.\Remove-RegistryProperty-Name.ps1 -literalPath $step5Key -name "Config"

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