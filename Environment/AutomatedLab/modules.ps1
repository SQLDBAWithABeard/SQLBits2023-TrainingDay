Set-PSRepository PsGallery -InstallationPolicy Trusted
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
if ($null -eq (Get-Module PowershellGet -ListAvailable)) {
    Install-Module PowershellGet -Force
}
if (Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue | Where-Object { $_.Version -lt [Version]2.8.5.201 }) {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false
}
$modules = @(
    'dbatools',
    'dbachecks',
    'PSFrameWork',
    'Pester'
    'ImportExcel'
)
foreach ($module in $modules) {
    if (Get-Module $module -ListAvailable) {
        Write-Host "Module $module is already installed - Updating"
        Update-Module $module
    } else {
        Write-Host "Installing module $module"
        Install-Module $module -Scope AllUsers -Force
    }
}

if((Get-WindowsFeature -Name RSAT).InstallState -ne 'Installed') {
    Install-WindowsFeature RSAT
}


# https://wmatthyssen.com/2022/06/16/powershell-script-set-customized-server-settings-on-azure-windows-vms-running-windows-server-2016-windows-server-2019-or-windows-server-2022/
$remoteEventLogFirewallRuleDisplayGroup = "Remote Event Log Management"
try {
    Get-NetFirewallRule -DisplayGroup $remoteEventLogFirewallRuleDisplayGroup -Enabled true -ErrorAction Stop | Out-Null
} catch {
    Set-NetFirewallRule -DisplayGroup $remoteEventLogFirewallRuleDisplayGroup -Enabled true -PassThru | Out-Null
}