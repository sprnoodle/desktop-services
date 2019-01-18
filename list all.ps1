$servers = #serverpath
$installType = #type of install
Get-ChildItem -path $servers -Recurse -Include $installType -ErrorAction SilentlyContinue | Select-Object FullName | 
Export-Csv -path c:\users\$env:UserName\desktop\appinstalls.csv