

$secStringPassword = 'dbatools.IO1' | ConvertTo-SecureString -AsPlainText -Force
[pscredential]$cred = New-Object System.Management.Automation.PSCredential ('theboss', $secStringPassword)
[pscredential]$domaincred = New-Object System.Management.Automation.PSCredential ('jessandbeard\theboss', $secStringPassword)

$PSDefaultParameterValues = @{
    '*Ad*:credential' = $cred
}

# only want databases on the standalone boxes and primary replica
$SASQLHosts, $primaryAgReplica | ForEach-Object {
    $Message = "Installing maintenance solution on {0}" -f $_

    $Message = "Adding databases on {0}" -f $_
    Write-PSFMessage -Level Host -Message $Message
    Invoke-Command {
        $BackupPath = '\\POSHFS1\SQLBackups'
        $secStringPassword = 'dbatools.IO1' | ConvertTo-SecureString -AsPlainText -Force
        [pscredential]$cred = New-Object System.Management.Automation.PSCredential ('theboss', $secStringPassword)
        [pscredential]$domaincred = New-Object System.Management.Automation.PSCredential ('jessandbeard\theboss', $secStringPassword)

        # totally used chatgpt to get these !
        $DBNames = "ProjectPhoenix","OperationCatalyst","InnovateX","EfficiencyDrive","ProfitPeak","StreamlineX","OptimizeX","RevolutionizeX","ElevateX","Apex","Summit","Vanguard","Horizon","Titan","Mercury","Nova","Prime","Infinity","Victory","Dynamo","Peak","Eclipse","Summit","Renaissance","Millennium","Vanguard","Summit","Odyssey","Apollo","Odyssey","Vision","Ascend","Peak","Explorer","Summit","EaglesFlight","ProjectPhoenix","Blueprints","VentureCapital","Innovate","Elevate","Horizon","New Frontier","Navigator","Voyage","Ascend","Explorer","Skyline","Empower","Rise","Eureka","Insight","Pinnacle","Optimizer","Crown Jewel","Trailblazer","Metamorphosis","NextGen","Progress","Accelerate","Prime","PeakPerformance","NewHeights","Achievement","Milestone","Optimize","Evolve","Efficiency","Empowerment","Revolution","Empyrean","Inventive","Synergy","Quantum","Optimization","ParadigmShift","Empowerment","SwipeEase","PocketPal","Swirl","PocketGenie","MyTime","SnapSync","SmartScoop","GoGoGo","AppyHour","PocketSolutions","SwipeLife","MyDay","PocketPro","TouchGo","SwipeTech","MyPlan","SnapPlan","SmartScheduler","GoPlan","AppyPlanner","PocketPlanner","SwipePlanner","MyTask","PocketTask","TouchTask","SwipeTask","MyEvent","PocketEvent","TouchEvent","SwipeEvent","MyReminder","PocketReminder","TouchReminder","SwipeReminder","MySchedule","PocketSchedule","SwipeSchedule","MyCommunity","PocketCommunity","SwipeCommunity","MyGoal","PocketGoal","SwipeGoal","MyFitness","PocketFitness","ProfitStream","EfficiencyPro","BusinessBoost","EnterpriseEdge","ProfitPro","InnovateIQ","WorkWise","TaskMasterPro","BusinessFlow","EfficiencyExpert","ProfitPilot","EnterpriseElevate","BusinessBrain","WorkforceOptimizer","TaskTrackerPro","BusinessBridge","EfficiencyEmpower","ProfitPilot","EnterpriseOptimizer","BusinessBasics","WorkforceNavigator","TaskMasterProPlus","BusinessBeyond","EfficiencyEmpire","ProfitPeak","EnterpriseEfficiency","BusinessBuddy","WorkforceWise","TaskTrackerProPlus","BusinessBolster","EfficiencyExcel","ProfitProdigy","EnterpriseExpert","BusinessBenefit","WorkforceWin","TaskMasterProMax","BusinessBlast","EfficiencyEra","ProfitPrime","EnterpriseEmpower","BusinessBreakthrough","WorkforceWonder","TaskTrackerProMax","BusinessBravo","EfficiencyEmpyrean","ProfitParadise","EnterpriseEmpowerment","BusinessBoom","WorkforceWorld","TaskMasterProElite"

        $Message = "Installing databases on {0}" -f ($ENV:COMPUTERNAME)
        Write-PSFMessage -Level Host -Message $Message

        $CountofDbs = (Get-DbaDatabase -SqlInstance localhost -SqlCredential $domaincred -ExcludeSystem).Count
        if ($CountofDbs -lt 25) {
            Get-Random -InputObject $DBNames -Count (25 - $CountofDbs) | ForEach-Object {
                $Message = "Creating database {0}" -f $_
                Write-PSFMessage -Level Host -Message $Message
                Restore-DbaDatabase -SqlInstance localhost -Path "$BackupPath\AdventureWorks_FULL_COPY_ONLY.bak" -Database $_ -WithReplace -SqlCredential $domaincred -ReplaceDbNameInFile
            }
        }

        $Message = "Setting recovery model to full for databases on {0}" -f ($ENV:COMPUTERNAME)
        Write-PSFMessage -Level Host -Message $Message

        Get-DbaDatabase -SqlInstance Jess2017 -ExcludeSystem -ExcludeDatabase ReportServer, ReportServerTempdb -SqlCredential $domaincred |Set-DbaDbRecoveryModel -RecoveryModel Full -Confirm:$false

        $Message = "Setting compatability for some databases on {0}" -f ($ENV:COMPUTERNAME)
        Write-PSFMessage -Level Host -Message $Message

        $MaxCompatabilityLevel = (Get-DbaDbCompatibility -SqlInstance localhost -SqlCredential $domaincred).Compatability

        $CompatabilityLevels = @(
            'Version90',
            'Version100',
            'Version110',
            'Version120',
            'Version130',
            'Version140',
            'Version150',
            'Version160'
        )

        #TODO: something with compat levels?

    } -ComputerName $_ -Credential $domaincred
}