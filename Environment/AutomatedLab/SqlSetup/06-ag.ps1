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
    $message = ("Setting hadr option for {0}" -f $_)
    Write-PSFMessage -Level Host -Message $message
    Invoke-Command {
        $secStringPassword = 'dbatools.IO1' | ConvertTo-SecureString -AsPlainText -Force
        [pscredential]$cred = New-Object System.Management.Automation.PSCredential ('theboss', $secStringPassword)
        [pscredential]$domaincred = New-Object System.Management.Automation.PSCredential ('jessandbeard\theboss', $secStringPassword)

        try {
            Write-PSFMessage -Level Host -Message ('hadr section' -f $Env:ComputerName)
            <#
            if(-not (Get-DbaAgHadr -SqlInstance $Env:ComputerName).IsHadrEnabled) {
                Write-PSFMessage -Level Host -Message ('hadr not enabled on {0} - enabling...' -f $Env:ComputerName)

                # force restarts the instance
                Enable-DbaAgHadr -SqlInstance $Env:ComputerName -Force -Confirm:$false
            } else {
                Write-PSFMessage -Level Host -Message ('hadr already enabled on {0}' -f $Env:ComputerName)

            }
            #>
        } catch {
            $message = "Failed to set hadr option on {0}" -f $Env:ComputerName
            Write-PSFMessage -Level Error -Message $message -Exception $_.Exception
        }

    } -ComputerName $_ -Credential $domaincred
}
#endregion

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
        ClusterType  = 'None' # External. Wsfc
        SeedingMode  = 'Automatic' # or you guessed it - Manual
        FailoverMode = 'Manual' # or automatic or External
        Confirm      = $false
    }
    New-DbaAvailabilityGroup @AvailabilityGroupConfig
}

#endregion



#region add listener
# Add-DbaAgListener -SqlInstance $server -AvailabilityGroup MikeyAG -IPAddress $listener -Name AGListener
#endregion

#region add databases
# Add-DbaAgDatabase -SqlInstance $server -AvailabilityGroup MikeyAG -Database NewDB4AG -Secondary $server2
#endregion

