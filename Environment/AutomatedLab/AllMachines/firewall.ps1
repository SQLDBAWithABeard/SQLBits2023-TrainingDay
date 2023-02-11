
$FirewallGroups = @( 'Remote Desktop', 'Remote Event Log Management', 'Remote Service Management' )
$FirewallNames = @( 'File and Printer Sharing (Echo Request - ICMPv4-in)' )

$FireWallsConfig = @(
    @{DisplayName = 'SQL Server'
        Direction = 'Inbound'
        Protocol  = 'TCP'
        LocalPort = '1433'
    }
)

foreach ($FirewallName in $FirewallNames) {
    try {
        Get-NetFirewallRule -DisplayName $FirewallName -Enabled true -ErrorAction Stop | Out-Null
        $message = "{1} Already got {0}" -f $FirewallName , $Env:COMPUTERNAME
        Write-Host  $message
    } catch {
        $message = "{1} Need to set {0}" -f $FirewallName , $Env:COMPUTERNAME
        Write-Host $message
        Set-NetFirewallRule -DisplayName $FirewallName -Enabled true -PassThru | Out-Null
    }
}

foreach ($FirewallGroup in $FirewallGroups) {
    try {
        Get-NetFirewallRule -DisplayGroup $FirewallGroup -Enabled true -ErrorAction Stop | Out-Null
        $message = "{1} Already got {0}" -f $FirewallGroup , $Env:COMPUTERNAME
        Write-Host  $message
    } catch {
        $message = "{1} Need to set {0}" -f $FirewallGroup , $Env:COMPUTERNAME
        Write-Host $message
        Set-NetFirewallRule -DisplayGroup $FirewallGroup -Enabled true -PassThru | Out-Null
    }
}
foreach ($FireWallConfig in $firewallsConfig) {

    if (-not (Get-NetFirewallRule -DisplayName $FireWallConfig.DisplayName -ErrorAction SilentlyContinue)) {
        $message = "{1} Need to set {0}" -f $FireWallConfig.DisplayName , $Env:COMPUTERNAME
        Write-Host  $message

        New-NetFirewallRule @FireWallConfig
    } else {
        $message = "{1} Already got {0}" -f $FireWallConfig.DisplayName , $Env:COMPUTERNAME
        Write-Host  $message
    }
}