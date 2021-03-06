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
    Completes steps listed under the "To find and remove the product GUID" section at
    https://support.symantec.com/en_US/article.TECH161956.html
#>
################################################################################
################################################################################
# Setup

# Temporarily store existing variables so that they won't be removed at end of script
$startupVariables = ""
new-variable -force -name startupVariables -value (Get-Variable | % {$_.Name})

# Set the executing directory to the script's directory
Push-Location    # Push the current location to the stack
Set-Location (Split-Path -parent $MyInvocation.MyCommand.Definition)

# Variables for FindGUID
[string]$guid = ""
[string]$beginSearch = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products"
[string]$endSearch = "InstallProperties"
[string]$stringToSearch = "Symantec Endpoint Protection"

# Variables for DeleteGUID
[array]$rootKeys = @(
    "Registry::HKEY_CLASSES_ROOT",
    "Registry::HKEY_CURRENT_USER",
    "Registry::HKEY_LOCAL_MACHINE",
    "Registry::HKEY_USERS",
    "Registry::HKEY_CURRENT_CONFIG")

################################################################################
# FindGUID
#
# Parameters:
#     key to begin search
#     key where search should end
#     term to search for
# Result:
#     returns the GUID as a string

Function FindGUID {
    # Function parameters
    Param (
        [string]$beginKey,
        [string]$endKey,
        [string]$searchTerm)
        
    # Local variables
    [string]$guid = $null
    
    # Function body
    If (Test-Path -literalPath $beginKey) {    # Test for existence of $beginSearch
        Get-ChildItem -literalPath $beginKey -recurse | ForEach-Object {    # Recurse through $beginSearch, passing each key
            If ((Get-ItemProperty -literalPath $_.PsPath) -imatch $searchTerm) {    # Look for key with value containing $searchTerm
                [string]$foundKey = ($_ -split "\\")[-1]    # split by \ and return last item
                If ($foundKey -eq $endKey) {    # We've stopped at the correct key
                    $guid = ($_ -split "\\")[-2]    # split by \ and return second-to-last item as $guid
                }
            }
        }
    } Else {
        $guid = $null
        Write-Host "Critical error: GUID not found"
    }
    
    Return $guid
}

################################################################################
# DeleteAllValues
#
# Parameters:
#     root key
#     string to search for
# Result:
#     All properties in the key or its children containg the string are deleted

Function DeleteGUID {
    Param (
        [string]$parentKey,
        [string]$stringToRemove)
        
    If (Test-Path -literalPath $parentKey) {
        Get-ChildItem -literalPath $parentKey -recurse -errorAction silentlyContinue | ForEach {    # Recurse through the registry, passing each key
            $currentPath = $_.PsPath    # Get the current path
            $currentKey = Get-Item -literalPath $currentPath    # Get the key at that path
            #Write-Host "Current path: $currentPath"
            #Write-Host "Current key: $currentKey"
            
            # Remove property with string as its name
            Remove-ItemProperty -literalPath $currentPath -name $stringToRemove
            
            # Remove properties with string in their values
            $currentKey.GetValueNames() | Where {    # Pass name of each property in the current key
                $currentKey.GetValue($_) -match $stringToRemove} | ForEach {    # Pass only names of properties that contain desired string
                    Write-Host "Step 19: $currentPath $_"    # Display key path and property name
                    Remove-ItemProperty -literalPath $currentPath -name $_    # Remove those properties from current key
                }
        }
    }
    
    # End of function
    Return
}

################################################################################
# Execute actions specified by Symantec
$guid = FindGUID $beginSearch $endSearch $stringToSearch
Write-Host "Function-returned GUID: $guid"

ForEach ($rootKey in $rootKeys) {
    DeleteGUID $rootKey $guid
}
        
################################################################################
# Cleanup

# PURPOSE:
# Delete variables created for this script, return to caller's location, and exit this scrip

# Credit goes to Ingo Karstein for the code featured in TechNet's 2011-08-21 The Scripting Guys
# http://blogs.technet.com/b/heyscriptingguy/archive/2011/08/21/clean-up-your-powershell-environment-by-tracking-variable-use.aspx

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