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

[string]$beginSearch = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products"
[string]$endSearch = "InstallProperties"
[string]$stringToSearch = "Symantec Endpoint Protection"
[string]$GUID = ""

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
    Param (
        [string]$beginKey,
        [string]$endKey,
        [string]$searchTerm)
    
    If (Test-Path -literalPath $beginKey) {    # Test for existence of $beginSearch
        Get-ChildItem -literalPath $beginKey -recurse | ForEach-Object {    # Recurse through $beginSearch, passing each key
            If ((Get-ItemProperty -literalPath $_.PsPath) -imatch $searchTerm) {    # Look for key with value containing $searchTerm
                Write-Host $_    # Display the found key
#                [string]$foundKey = $_ -replace "
#                If ($_.PsPath -eq $endSearch) {    # Check against the desired key
            }
        }
    } Else {
        $GUID = $null
        Write-Host "Critical error: GUID not found"
        Exit
    }
    
    Return
}

################################################################################
# Execute actions specified by Symantec

FindGUID $beginSearch $endSearch $stringToSearch
        
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