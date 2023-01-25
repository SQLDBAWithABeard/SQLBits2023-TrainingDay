Set-PSRepository PsGallery -InstallationPolicy Trusted
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-Module PowershellGet -Force 
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false

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