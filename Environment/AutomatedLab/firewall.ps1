
if(-not (Get-NetFirewallRule -DisplayName 'SQL Server' -ErrorAction SilentlyContinue)) {
    Write-Host ('Adding firewall rule')
    New-NetFirewallRule -DisplayName 'SQL Server' -Direction Inbound -Protocol TCP -LocalPort 1433
} else {
    Write-Host ('Firewall rule found')
}