<#
.SYNOPSIS

Mirror-Group workflow copies installation packages from Application package repositories, pastes the files remotely,
executes the installations remotely, removes installation files. Log is created on local machine.
Each installation is parallel processed across multiple machines.

The workflow receives data from csv under RefPath. 
The csv needs to have headers Device, Software, Path in order to run successfully.
Refer to all-installs2.csv or Software_Path for installation paths for respective software.

Store csv files under C:\Users\%username%\Documents\WindowsPowershell\Run
Log output to C:\Users\%username%\WindowsPowershell\Logs\EUSInstalls_log.txt

Device = New Computer Name
Software = Installed software names on old device returned from Win32_Product to be mirrored on new device
Path = installation path on software repository

.PARAMETER RefPath

Directory of files to run that contain device name, software, name, path of installation

.EXAMPLE 

PS> Deploy-EUSInstalls -RefPath ".\Installs"
Install applications from csv files under Installs

.NOTES 

Original Author: Christopher Strader
#>
workflow Deploy-EUSInstalls {

param([string[]]$RefPath)


    $UserInstalls = Get-ChildItem "C:\Users\%username%\Documents\WindowsPowershell\Run" -File -Recurse
    
    Foreach -parallel ($User in $UserInstalls){
        
        Function Mirror-User {

        Param([string[]]$LANID)
        
        #$InstallPaths = @(Foreach ($UserInstall in $UserInstalls) {Join-Path -Path $RefPath -ChildPath $UserInstall})

        $InstallLog = "C:\Users\%username%\WindowsPowershell\Logs\EUSInstalls_log.txt"
        $LocalPath = "c:\Users\Public\Documents"

        $Mirror = Import-CSV -Path "C:\Users\%username%\Documents\WindowsPowershell\Run\$LANID"
            
            For ($i = 0; $i -lt $Mirror.Software.Count; $i++){
                $computer = $Mirror.Device[0]
                $Software = $Mirror.Software[$i]
                $Install = $Mirror.Path[$i]
                
                If ($Install -ne $null){
                    #Get Parent of Child of Install to prep for copy, run, remove
                    $ParentPath = Split-Path -Path $Install
                    $Parent = Split-Path -Path $ParentPath -leaf
                    $Child = Split-Path -Path $Install -leaf
                    $LocalInstall = Join-Path -Path $LocalPath -ChildPath $Parent
                    $Local = Join-Path -Path $LocalInstall -ChildPath $Child
                
                    #Contains \\$computer 
                    $LocalPathRemote = "\\$computer\c$\Users\Public\Documents"                
                    $LocalR = Join-Path -Path $LocalPathRemote -ChildPath $Parent
        
                    #Contains \\$computer...exe
                    $LocalRemote = Join-Path -Path $LocalR -ChildPath $Child

                    #Test Connection to PC
                    If (Test-Connection -ComputerName $computer -Count 1 -Quiet){
                        "$computer is online" | Out-File $InstallLog -Append
                               
                        #Copy Install to local 
                        If (Test-Path -Path $Install){
            
                            "Copying $Software to $computer for $LANID" | Out-File $InstallLog -Append
                        
                            Copy-Item -Path $ParentPath -Recurse -Destination $LocalPathRemote
                                                
                            "Installing $Software on $computer for $LANID" | Out-File $InstallLog -Append
                
                            #Remote Execution
                            psexec.exe \\$computer $Local
            
                            #Delete Install in Public Documents
                            "Removing $LocalR for $LANID on $computer" | Out-File $InstallLog -Append

                            Remove-Item -Path $LocalR -Force -Recurse
                    
                            } else {"$Install not found for $User to install on $computer"}
                            } else {#If offline, send device to list for rerun
                        "$computer is offline" | 
                        Out-file "$InstallLog" -Append
                        $computer | 
                        Out-file "$RefPath\tryagain.txt" -Append}
                    } else {"$Software not found" | Out-file $InstallLog -Append}
        } "Mirroring Complete for $LANID on $computer" | Out-file $InstallLog -Append
}

    Mirror-User -LANID $User
    }
}