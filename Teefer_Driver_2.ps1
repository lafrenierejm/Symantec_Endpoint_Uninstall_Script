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
    Completes steps listed under the second "To remove the Teefer driver" section at
    https://support.symantec.com/en_US/article.TECH161956.html
#>
################################################################################
################################################################################
<#  Delete-Keys-ContainName

    Parameters:
        [string] beginKey
        [string] name
        
    Results:
        Delete reg keys with a property of name=$name and value=$value.
        Recurse through $beginKey, removing each found instance.
#>

Function Delete-Keys-KeyName {
    [CmdletBinding()]
    
    param (
        [string]$literalPath,
        [string]$name
    )
        
    # Steps 3-4
    if (Test-Path -literalPath $literalPath) {
        Get-ChildItem -literalPath $literalPath -recurse -errorAction silentlyContinue | ForEach {    # Recurse, passing each key
            $keyPath = $_.PsPath    # Stores the passed path
            $currentKey = Get-Item -literalPath $keyPath    # Get the key at that path
            #Write-Host $currentKey
            
            $currentKey.GetValueNames() | Where {    # Pass name of each property in the current key
                if ($_ -eq $name) {    # If a property's name contains $name
                   #Write-Host $currentKey
                   Remove-Item -literalPath $currentKey    # Delete the key
                }
            }
        }
    }
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

# Steps 1-3
Write-Host "1. Open command prompt with Administrator priveleges."
Write-Host "2. Run `"pnputil -e`""
Write-Host "3. Type `"pnputil -f -d oem<n>.inf`" to remove Symantec drivers from driver store, where <n> is a number corresponding to one of the Symantec drivers listed in the previous step."
Write-Host "4. Close the command prompt."
cmd /c pause

# Steps 5-6
[string]$step5Key = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}"
[string]$step6Value = "symc_teefer2"
[string]$step6Name = "ComponentId"
.\Remove-RegistryKey-PropertyName_PropertyValue -literalPath $step5Key -name $step6Name -value $step6Value -recurse $false

# Steps 7-8
[string]$step7Key = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceClasses\{ad498944-762f-11d0-8dcb-00c04fc3358c}"
[string]$step8Name = "SYMC_TEEFERMP"
Delete-Keys-KeyName -literalPath $step7Key -name "*$step8Name*"

# Steps 9-10
[string]$step9Key = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceClasses\{cac88424-7515-4c03-82e6-71a87abac361}"
[string]$step10Name = "SYMC_TEEFERMP"
Delete-Keys-KeyName -literalPath $step9Key -name "*$step10Name*"

# Steps 12-13
Write-Host "In the Device Manager (devmgmt.msc), go to Network Adapters, and delete all entries with `"teefer`" in them."
Write-Host "Delete all network adapters to which teefer was attached."
cmd /c pause

# Delete any variables made over course of this script
Cleanup

# Exit the script
exit