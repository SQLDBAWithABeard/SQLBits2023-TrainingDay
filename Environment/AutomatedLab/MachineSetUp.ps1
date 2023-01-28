$remoteEventLogFirewallRuleDisplayGroup = "Remote Event Log Management"
try {
    Get-NetFirewallRule -DisplayGroup $remoteEventLogFirewallRuleDisplayGroup -Enabled true -ErrorAction Stop | Out-Null
    $message = "{1} Already got {0}" -f $remoteEventLogFirewallRuleDisplayGroup , $Env:COMPUTERNAME
    Write-Host  $message
} catch {
    $message = "{1} Need to set {0}" -f $remoteEventLogFirewallRuleDisplayGroup , $Env:COMPUTERNAME
    Write-Host $message
    Set-NetFirewallRule -DisplayGroup $remoteEventLogFirewallRuleDisplayGroup -Enabled true -PassThru | Out-Null
}
$remoteServiceFirewallRuleDisplayGroup = "Remote Service Management"
try {
    
    Get-NetFirewallRule -DisplayGroup $remoteServiceFirewallRuleDisplayGroup -Enabled true -ErrorAction Stop | Out-Null
    $message = "{1} Already got {0}" -f $remoteServiceFirewallRuleDisplayGroup , $Env:COMPUTERNAME
    Write-Host $message
} catch {
    $message = "{1} Need to set {0}" -f $remoteServiceFirewallRuleDisplayGroup , $Env:COMPUTERNAME
    Write-Host $message
    Set-NetFirewallRule -DisplayGroup $remoteServiceFirewallRuleDisplayGroup  -Enabled true -PassThru | Out-Null
}