<#
.SYNOPSIS

Terminates a running process on a remote workstation

.PARAMETER Process 

Name of Process does not accept wildcards

.PARAMETER Computer

Name of Device

.EXAMPLE 

PS> Kill-Process -Process notepad.exe -Computer LFDCABCD123
Terminates notepad.exe on remote workstation LFDCABCD123

.NOTES 
Original Author: Christopher Strader
Planned functionality to accept terminating process on current workstation and group of workstations
#>
function Close-RemoteProcess {
    
    Param([string[]]$Process, [string[]]$Computer)
    
    $ProcessSearch = Get-WmiObject -Computer $Computer -Class Win32_Process | 
    where Name -EQ $Process
    $ProcessSearch | Remove-WMIObject
}