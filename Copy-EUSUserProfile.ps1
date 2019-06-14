<#
.SYNOPSIS

Copies user profile from old machine and transfers to Home Drive and new machine

.PARAMETER OldPC 

Old machine name, origin of files

.PARAMETER LANID 

User LANID. Do not include the domain.

.PARAMETER NewPC 

New device name.

.PARAMETER HomeDrive 

Destination on the HomeDrive, files are copied under HomeDrive\ProfileCopy

.EXAMPLE 

PS> Copy-EUSUserProfile -OldPC <old device name. -LANID <User LANID> -

.NOTES 
Planned implementation to recover user's home drive automatically
Original Author: Christopher Strader
#>
function Copy-EUSUserProfile{

    param([string[]]$OldPC,
    [string[]]$LANID,
    [string[]]$NewPC,
    [string[]]$HomeDrive)

    $NewPCDocs = "\\$NewPC\C$\users\$LANID\"
    $Children = Get-ChildItem "\\$OldPC\C$\users\$LANID"
    $HomePath = "$HomeDrive\ProfileCopy"

    Foreach ($Child in $Children){
        $Path = Join-Path -Path "\\$OldPC\c$\users\$LANID" -ChildPath $Child
        "Copying $Path to $NewPCDocs"
        Copy-Item -Path $Path -Destination $NewPCDocs -Force -Recurse
        "Copying $Path to $HomeDrive"
        Copy-Item -Path $Path -Destination $HomeDrive -Force -Recurse
    }

    Foreach ($Child in $Children){
        $NewPC = Join-Path -Path $OldPC -ChildPath $Child
        "Testing connection to $NewPC"
        If (Test-Path -Path $NewPC){
            "$NewPC copied successfully"}
            else {"$NewPC not found"}

        
        $HomePath = Join-Path -Path $HomeDrive -ChildPath $Child
        
        "Testing $HomePath"
        
        If (Test-Path -Path $HomePath){
            "$HomePath copied successfully"}
            else {"$HomePath not found"}
    }
}