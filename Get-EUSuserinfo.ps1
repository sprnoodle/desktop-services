#Import-Module ActiveRolesManagementShell -Verbose
<#
.SYNOPSIS

Using LANID of userGets EU information including FirstName, LastName, HomeDirectory, and email
Saves information to C:\Users\%username%\Documents\WindowsPowerShell\Reference\UserInfo.csv

.PARAMETER Computer 

File of computers to be removed from Active Directory

.EXAMPLE 

PS> Get-UserInfo -LANIDS <c:\FILE_PATH\file.txt>
Get Users' name, email, HomeDirectory

.NOTES 

Original Author: Christopher Strader
#>
function Get-UserInfo{
    # Specifies a path to one or more locations.
    [Parameter(Mandatory=$true,
               Position=0,
               ParameterSetName="LANIDS",
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true,
               HelpMessage="Path to one or more locations.")]
    [Alias("PSPath")]
    [ValidateNotNullOrEmpty()]
    [string[]]$LANIDS
    
    connect-qadservice w1pvap1098 -proxy
    
    $Users = Get-Content $LANIDS

    Foreach ($User in $Users.UniqueUserName){
        Get-QADUser -Identity $User | 
        Select FirstName, LastName, HomeDirectory, Email |
        Export-CSV "C:\Users\%username%\Documents\WindowsPowerShell\Reference\UserInfo.csv" `
        -Append -NoTypeInformation -Force
    }
    Disconnect-QADService
}