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
    Runs through the other scripts sequentially
#>
################################################################################
<#  Registry-Backup

    parameters:
        none
    
    Results:
        Creates a backup of the registry at a location specified by the user
#>

function Registry-Backup {
    param ()
    
    Write-Host "Creating a system restore point prior to beginning uninstallation..."
    Checkpoint-Computer -description "Prior to uninstalling Symantec Endpoint" -restorePointType "APPLICATION_UNINSTALL"
    Get-EventLog -LogName application -InstanceId 8194 -Newest 1 | fl *
    
    # return from this function
    return
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
         
    # return to location of caller of script
    Pop-Location
    
    # return from this function
    return
}

################################################################################
<# Entry to script #>

# Temporarily store existing variables so that they won't be removed at end of script
$startupVariables = ""
new-variable -force -name startupVariables -value (Get-Variable | % {$_.Name})

# Set the executing directory to the script's directory
Push-Location    # Push the current location to the stack
Set-Location (Split-Path -parent $MyInvocation.MyCommand.Definition)

# startPoint determines which file the script begins execution at
[int]$startPoint = 0

# Ensure script is being run with adminstrative priveleges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
[Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script requires Administrator rights. Please re-run with proper privileges."
    Cleanup
    exit
}

while ($startPoint -lt 10) {
    if (Test-Path -literalPath .\startPoint.txt) {
        $startPoint = Get-Content "startPoint.txt"
    }
    switch ($startPoint) {
        0 {
            #Registry-Backup
            $startPoint += 1 | Out-File -filePath ".\startPoint.txt"
        }
        1 {
            
        default {
            Write-Host '$startPoint went out of bounds (> 10).'
            Cleanup
            exit
        }
    }
}