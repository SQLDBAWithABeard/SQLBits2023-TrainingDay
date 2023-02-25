$secStringPassword = 'dbatools.IO1' | ConvertTo-SecureString -AsPlainText -Force
[pscredential]$cred = New-Object System.Management.Automation.PSCredential ('theboss', $secStringPassword)
[pscredential]$domaincred = New-Object System.Management.Automation.PSCredential ('jessandbeard\theboss', $secStringPassword)

$PSDefaultParameterValues = @{
    '*Ad*:credential' = $cred
}

$PSDefaultParameterValues = @{
    '*dba*:SqlCredential' = $domaincred
    '*dba*:Credential' = $domaincred
    '*dba*:PrimarySqlCredential' = $domaincred
    '*dba*:SecondarySqlCredential' = $domaincred
}

#region Enable Hadr on in stances

#Get-DbaAgHadr -SqlInstance Beard2019AG1 -SqlCredential  $domaincred

$SQLAgs | ForEach-Object {
    $sqlagnode = $psitem
    $message = ("Setting hadr option for {0}" -f $_)
    Write-PSFMessage -Level Host -Message $message

    try {
        Write-PSFMessage -Level Host -Message ('hadr section' -f $sqlagnode)

        if(-not (Get-DbaAgHadr -SqlInstance $sqlagnode).IsHadrEnabled) {
            Write-PSFMessage -Level Host -Message ('hadr not enabled on {0} - enabling...' -f $sqlagnode)

            # force restarts the instance
            Enable-DbaAgHadr -SqlInstance $sqlagnode -Confirm:$false

            Invoke-Command -scriptblock { get-service MSSQLSERVER | Restart-Service -Force } -cn $sqlagnode -Credential $domaincred
        } else {
            Write-PSFMessage -Level Host -Message ('hadr already enabled on {0}' -f $sqlagnode)
        }
    } catch {
        $message = "Failed to set hadr option on {0}" -f $sqlagnode
        Write-PSFMessage -Level Error -Message $message -Exception $_.Exception
    }

}

#region createAg

$AgName = 'DragonAg'
$primaryAgReplica = 'Beard2019AG1'
$secondaryAgRelica = 'Beard2019AG2','Beard2019AG3'

if(Get-DbaAvailabilityGroup -SqlInstance $primaryAgReplica -AvailabilityGroup $AgName) {
    Write-PSFMessage -Level Host -Message ('AG exists on {0}' -f $primaryAgReplica)
} else {
    Write-PSFMessage -Level Host -Message ('Creating the {0} AG on {1}' -f $agName, $primaryAgReplica)


    $AvailabilityGroupConfig = @{
        Name         = $AgName
        SharedPath   = '\\poshfs1\SQLBackups\Shared'
        Primary      = $primaryAgReplica
        Secondary    = $secondaryAgRelica
        ClusterType  = 'Wsfc' # External. Wsfc. None
        FailoverMode = 'Automatic' # or automatic or External
        Confirm      = $false
        IpAddress    = '192.168.2.68'
    }
    New-DbaAvailabilityGroup @AvailabilityGroupConfig -verbose
}

if((Get-DbaAgDatabase -SqlInstance $primaryAgReplica -AvailabilityGroup $AgName | Measure-Object).Count -ge 5) {
    Write-PSFMessage -Level Host -Message ('AG has 5 databases already')
} else {
    # add 5 random databases to the AG
    $dbs = Get-Random -Count 5 (Get-DbaDatabase -SqlInstance $primaryAgReplica -ExcludeSystem -ExcludeDatabase ReportServer, ReportServerTempDB)
    $dbs | Set-DbaDbRecoveryModel -RecoveryModel Full -Confirm:$false
    $agDatabaseConfig = @{
        SqlInstance       = $primaryAgReplica
        AvailabilityGroup = $AgName
        Database          = $dbs.Name
        Secondary         = $secondaryAgRelica
        SeedingMode       = 'Manual'
        SharedPath        = '\\poshfs1\SQLBackups\Shared'

    }
    Add-DbaAgDatabase @agDatabaseConfig
}



#TODO: IF replicas > 3 then boot out beard2019ag4
#TODO: IF more than 5 databases boot some out
#TODO: IF ag isn't running on node 1 put it back