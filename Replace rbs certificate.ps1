# This file contains the list of servers you want to copy the SSL cert too
$computers = gc "C:\scripts\servers.txt"
 
# This is the location of the SSL cert we want to copy
$source = "C:\Users\user\Desktop\Cluster-SSL-Cert.crt"
 
# The destination location you want the SSL cert to be copied to
$destination = "C:\ProgramData\Rubrik\Rubrik Backup Service\" 

# Here we check to make sure the location is available on the destination 
foreach ($computer in $computers) {
if ((Test-Path -Path \\$computer\$destination)) {
Copy-Item $source -Destination \\$computer\$destination -Recurse
} else {
"\\$computer\$destination is not reachable or does not exist"
}
}