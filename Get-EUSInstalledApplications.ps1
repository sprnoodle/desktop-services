<#
.SYNOPSIS

Get a list of installed applications on device.

.PARAMETER Computer 
Name of Computer

.PARAMETER LANID
User LANID and output file name

.PARAMETER OutputPath

Defined path to save file

.EXAMPLE 

PS> Get-InstalledApplications -Computer <computer name> -LANID <LANID> -OutputPath "C:\Users\User\Documents\EU Installs\"
Gets installed applications on <computer name>
outputs the information as a CSV labelled with the user name
Saves the file under Path C:\Users\User\Documents\EU Installs\

.NOTES 
Original Author: Christopher Strader
Uses WMI-Object Win32_Product to locate processes
#>
function Get-InstalledApplications {
    param([string[]]$Computer,
        [string[]]$LANID,
        [string[]]$OutputPath)
    
   # $OutputPath = Join-Path -Path "$OutputPath" -ChildPath "$LANID.csv"
    $OutputPath
    If (Test-Connection -ComputerName $Computer -Count 1 -Quiet){
        "$Computer online"
        Get-WmiObject -Class Win32_Product -Computer $Computer | 
        select-object Name | 
        Export-CSV -Path $OutputPath\$LANID.csv -notypeinformation -Append
            
        } else {
            "$Computer offline"
            }
}