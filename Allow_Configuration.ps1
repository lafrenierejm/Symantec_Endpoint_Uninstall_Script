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
    Completes steps listed under the "To allow Symantec Endpoint Protection services to be configured" section at
    https://support.symantec.com/en_US/article.TECH161956.html
#>
################################################################################
################################################################################

Write-Host "1. Right-click the Symantec Endpoint Protection icon in the lower right corner of the screen, and click `"Open Symantec Endpoint Protection`"."
Write-Host "2. In the left pane, click `"Change Settings`"."
Write-Host "3. In the right pane, click `"Client Management > Configure Settings`"."
Write-Host "4. On the Tamper Protection tab, uncheck `"Protect Symantec security software from being tampered with or shut down`"."
Write-Host "5. Click `"OK`"."
Write-Host "6. Close Symantec Endpoint Protection."
cmd /c pause

exit