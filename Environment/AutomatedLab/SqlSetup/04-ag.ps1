$secStringPassword = 'dbatools.IO1' | ConvertTo-SecureString -AsPlainText -Force
[pscredential]$cred = New-Object System.Management.Automation.PSCredential ('theboss', $secStringPassword)
[pscredential]$domaincred = New-Object System.Management.Automation.PSCredential ('jessandbeard\theboss', $secStringPassword)

$PSDefaultParameterValues = @{
    '*Ad*:credential' = $cred
}

#TODO: way to test first?
#Get-DbaAgHadr -SqlInstance Beard2019AG1 -SqlCredential  $domaincred

# force restarts the instance

$SQLAgs | ForEach-Object {
    $message = "Setting hadr option for {0}" -f $_
    Write-PSFMessage -Level Host -Message $message
    Invoke-Command {
        $secStringPassword = 'dbatools.IO1' | ConvertTo-SecureString -AsPlainText -Force
        [pscredential]$cred = New-Object System.Management.Automation.PSCredential ('theboss', $secStringPassword)
        [pscredential]$domaincred = New-Object System.Management.Automation.PSCredential ('jessandbeard\theboss', $secStringPassword)

        try {
            Enable-DbaAgHadr -SqlInstance $Env:ComputerName -Credential $domaincred -Force -Confirm:$false
        } catch {
            $message = "Failed to set hadr option on {0}" -f $Env:ComputerName
            Write-PSFMessage -Level Error -Message $message -Exception $_.Exception
        }

    } -ComputerName $_ -Credential $domaincred
}


<#
$AgName = 'NotOnHolidayNowAreYouJess'
$AvailabilityGroupConfig = @{
    Name         = $AgName
    SharedPath   = '/var/opt/backups'
    Primary      = $dbatools1
    Secondary    = $dbatools2
    ClusterType  = 'None' # External. Wsfc
    Database     = 'pubs'
    SeedingMode  = 'Automatic' # or you guessed it - Manual
    FailoverMode = 'Manual' # or automatic or External
    Confirm      = $false
}
New-DbaAvailabilityGroup @AvailabilityGroupConfig
#>