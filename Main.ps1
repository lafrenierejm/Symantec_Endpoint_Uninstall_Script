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
<# Entry to script
#>

<# Variables #>
# startPoint determines which file the script begins execution at
[int]$startPoint
if (Test-Path .\startPoint.txt) {
    $startPoint = Get-Content "startPoint.txt"
}
else {
    $startPoint = 0
}

# Ensure script is being run with adminstrative priveleges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
[Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script requires Administrator rights. Please re-run with proper privileges."
    exit
}