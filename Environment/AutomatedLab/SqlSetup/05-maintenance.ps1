

$secStringPassword = 'dbatools.IO1' | ConvertTo-SecureString -AsPlainText -Force
[pscredential]$cred = New-Object System.Management.Automation.PSCredential ('theboss', $secStringPassword)
[pscredential]$domaincred = New-Object System.Management.Automation.PSCredential ('jessandbeard\theboss', $secStringPassword)

$PSDefaultParameterValues = @{
    '*Ad*:credential' = $cred
}

$SQLHosts | ForEach-Object {
    Invoke-Command {
        $BackupPath = '\\POSHFS1\SQLBackups'

        $Message = "Installing maintenance solution on {0}" -f ($ENV:COMPUTERNAME)
        Write-PSFMessage -Level Host -Message $Message

        Install-DbaMaintenanceSolution -SqlInstance localhost -Database master -SqlCredential $domaincred -BackupLocation $BackupPath -InstallJobs -ReplaceExisting
        Set-Service -Name SQLServerAgent -StartupType Automatic
        Start-Service -Name SQLServerAgent

        $jobs = 'DatabaseBackup - SYSTEM_DATABASES - FULL', 'DatabaseBackup - USER_DATABASES - FULL', 'DatabaseBackup - USER_DATABASES - DIFF', 'DatabaseBackup - USER_DATABASES - LOG'

        $jobs | ForEach-Object {
            Start-DbaAgentJob -SqlInstance localhost -Job $_ -SqlCredential $domaincred
        }

        $schedulesplat = @{
            FrequencyType           = "Daily"
            SqlInstance             = 'localhost'
            Schedule                = "WorkingWeek-Every-15-Minute"
            Force                   = $true
            StartTime               = "070736"
            EndTime                 = "200000"
            FrequencySubdayInterval = 15
            FrequencySubdayType     = "Minutes"
            SqlCredential           = $domaincred

        }
        New-DbaAgentSchedule @schedulesplat

        $schedulesplat = @{
            FrequencyType           = "Daily"
            FrequencyInterval       = "Weekdays"
            SqlInstance             = 'localhost'
            Schedule                = "WorkingWeek-Every-4-hours"
            Force                   = $true
            StartTime               = "070036"
            EndTime                 = "200000"
            FrequencySubdayInterval = 4
            FrequencySubdayType     = "Hours"
            SqlCredential           = $domaincred

        }
        New-DbaAgentSchedule @schedulesplat

        $schedulesplat = @{
            FrequencyType     = "Daily"
            FrequencyInterval = "Everyday"
            SqlInstance       = 'localhost'
            Schedule          = "WorkingWeek-9am"
            Force             = $true
            StartTime         = "090036"
            SqlCredential     = $domaincred

        }
        New-DbaAgentSchedule @schedulesplat

        $schedulesplat = @{
            FrequencyType     = "Daily"
            FrequencyInterval = "Weekdays"
            SqlInstance       = 'localhost'
            Schedule          = "WorkingWeek-2pm"
            Force             = $true
            StartTime         = "140036"
            SqlCredential     = $domaincred

        }
        New-DbaAgentSchedule @schedulesplat

        $schedulesplat = @{
            FrequencyType     = "Daily"
            FrequencyInterval = "Everyday"
            SqlInstance       = 'localhost'
            Schedule          = "WorkingWeek-6pm"
            Force             = $true
            StartTime         = "180000"
            SqlCredential     = $domaincred
        }
        New-DbaAgentSchedule @schedulesplat

        Set-DbaAgentJob -SqlInstance localhost -Job 'DatabaseBackup - SYSTEM_DATABASES - FULL' -Schedule 'WorkingWeek-6pm' -SqlCredential $domaincred
        Set-DbaAgentJob -SqlInstance localhost -Job 'DatabaseBackup - USER_DATABASES - FULL' -Schedule 'WorkingWeek-6pm' -SqlCredential $domaincred
        Set-DbaAgentJob -SqlInstance localhost -Job 'DatabaseBackup - USER_DATABASES - FULL' -Schedule 'WorkingWeek-2pm' -SqlCredential $domaincred
        Set-DbaAgentJob -SqlInstance localhost -Job 'DatabaseBackup - USER_DATABASES - FULL' -Schedule 'WorkingWeek-9am' -SqlCredential $domaincred
        Set-DbaAgentJob -SqlInstance localhost -Job 'DatabaseBackup - USER_DATABASES - DIFF' -Schedule 'WorkingWeek-Every-4-hours' -SqlCredential $domaincred
        Set-DbaAgentJob -SqlInstance localhost -Job 'DatabaseBackup - USER_DATABASES - LOG' -Schedule 'WorkingWeek-Every-4-hours' -SqlCredential $domaincred

    } -ComputerName $_ -Credential $domaincred
}