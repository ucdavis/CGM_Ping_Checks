<#
    Title: CGM_Ping_Checks.ps1
    Authors: Taylor McDougall and Dean Bunn
    Last Edit: 2021-08-13
#>

#Import Json Configuration File
$cgm_config = Get-Content -Raw -Path .\cgm_config.json | ConvertFrom-Json;

#Var for Failed Systems Count
$nFailedSystemsCnt = 0; 

#Loop Through CGM Systems
foreach($cgmSystem in $cgm_config.systems)
{
    
    #Check System Availability Status
    if(Test-Connection -ComputerName $cgmSystem.name -Quiet)
    {
        $cgmSystem.ping_failed_count = 0;
        $cgmSystem.ping_status = "success";
    }
    else
    {
        $cgmSystem.ping_failed_count++;
        $cgmSystem.ping_status = "failed";
    }

    #Check Overall Status
    if($cgmSystem.ping_failed_count -ge $cgm_config.max_fails)
    {
        $nFailedSystemsCnt++;
        $cgmSystem.ping_status = "notify";
    }

}

#Check to If Notice Needs to Be Sent
if($nFailedSystemsCnt -gt 0)
{
    #Get Current Date
    $rptDate = Get-Date -Format g;

    #Vars for Alert Email Notice
    [string]$msgSubject = "CGM System Down Notice for " + $rptDate;
    [string]$msgFrom = $cgm_config.sender;
    [string]$smtpServer = $cgm_config.smtp_server;
    [string]$msgBody = "<html>
                        <body>
                        <h3>CGM System Down Notice</h3>";

    #Array of CGM Techs Contacts
    $CGMTechs = @();

    #Load CGM Techs
    foreach($cgmTech in $cgm_config.receivers)
    {
        $CGMTechs += $cgmTech.address;
    }

    #Read Password In
    $cgmPwd = cat .\specpass.txt | convertto-securestring;

    #Setup Credential for Account
    $cgmCred = New-Object System.Management.Automation.PSCredential($cgm_config.sender,$cgmPwd);

    foreach($cgmSystem in $cgm_config.systems)
    {

        if($cgmSystem.ping_status -eq "notify")
        {
            $msgBody += "<p>" + $cgmSystem.displayname + " has failed ping</p>";   
        }
         
    }

    $msgBody += "<br /><br /><br /></body></html>";

    #Send Alert Email Message 
    Send-MailMessage -SmtpServer $smtpServer -Port 587 -Credential $cgmCred -Subject $msgSubject -From $msgFrom -To $CGMTechs -Body $msgBody –BodyAsHtml -UseSsl;
}

#Save CGM Config File
$cgm_config | ConvertTo-Json | Out-File .\cgm_config.json;

#Save CGM Config Backup Only If It Loaded Correctly
if($cgm_config -ne $null -and [string]::IsNullOrEmpty($cgm_config.sender) -eq $false)
{
    $cgm_config | ConvertTo-Json | Out-File .\config_backup\cgm_config.json;
}
