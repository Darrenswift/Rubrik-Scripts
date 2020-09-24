Import-Module Rubrik
$rubrik_ip = 'ip'
$rubrik_user = 'notauser'
$rubrik_pass = 'notapass'
Connect-Rubrik -Server $rubrik_ip -Username $rubrik_user -Password $(ConvertTo-SecureString -String $rubrik_pass -AsPlainText -Force) | Out-Null

$DBs = Get-RubrikDatabase -PrimaryClusterID local
$filePath = '.\Rubrik_DB_Model.csv'

if (Test-Path $filePath) {
    $CSV_Data = Get-Content $filePath | where {$_ -notmatch '^#'} | ConvertFrom-Csv -Header id,name,relic,instanceName,recoveryModel,effectiveSlaDomainName

    foreach($DB in $DBs){

        $DB_isLiveMount = $DB.isLiveMount
        if($DB_isLiveMount -eq "True"){
            #do nothing skip
        } else {

            $DB_ID = $DB.id
            $DB_Name = $DB.Name
            $DB_InstanceName = $DB.instanceName
            $DB_effectiveSlaDomainName = $DB.effectiveSlaDomainName
            $DB_recoveryModel = $DB.recoveryModel
            $DB_relic = $DB.isRelic

            if($DB_relic -eq "True"){
                # DB is a Relic, not checking
            } else {
                $CSV_DB = $CSV_Data | ? { $_.id -eq $DB_ID }
                if($CSV_DB.recoveryModel -eq ""){
                    #DB state not recorded - offline DB?
                } else {
                    if($CSV_DB.recoveryModel -eq $DB_recoveryModel){
                        #recovery model hasn't changed - do nothing
                    } else {
                        #notify here - currently using write-host to display on screen
                        write-host $DB_InstanceName'/'$DB_Name 'has changed recovery Model from' $CSV_DB.recoveryModel 'to' $DB_recoveryModel
                    }
                }
            }
        }
    }

    #Deal with CSV replace
    $csv=@()
    foreach($DB in $DBs){
        $csv+=New-Object PSObject -Property @{id=$DB.id;name=$DB.Name;instanceName=$DB.instanceName;effectiveSlaDomainName=$DB.effectiveSlaDomainName;recoveryModel=$DB.recoveryModel;relic=$DB.isRelic}
    }

    $csv | Export-CSV .\Rubrik_DB_Model.csv -notype -Force
} else {
    #file doesn't exist - can't check against last run, so create CSV file

    $csv=@()
    foreach($DB in $DBs){
        $csv+=New-Object PSObject -Property @{id=$DB.id;name=$DB.Name;instanceName=$DB.instanceName;effectiveSlaDomainName=$DB.effectiveSlaDomainName;recoveryModel=$DB.recoveryModel;relic=$DB.isRelic}
    }

    $csv | Export-CSV .\Rubrik_DB_Model.csv -notype -Force
}
