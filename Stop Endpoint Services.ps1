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

# Set the executing directory to the script's directory
Push-Location    # Push the current location to the stack
Set-Location (Split-Path -parent $MyInvocation.MyCommand.Definition)

[array]$services = @(    # Services to be disabled
    "Symantec Management Client",
    "Symantec Network Access Control",
    "Symantec Endpoint Protection")

################################################################################

# Stop and disable each service
ForEach($service in $services) {
    Set-Service -name $service -startupType "Disabled" -status "Stopped" -whatif    # Comment "whatif" flag to enable
}
    

################################################################################

# Cleanup
Pop-Location    # Return to the caller's location