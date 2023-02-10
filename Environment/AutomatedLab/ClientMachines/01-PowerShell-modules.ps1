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
    'Pester',
    'ImportExcel',
    'posh-git',
    'Terminal-Icons'
)
foreach ($module in $modules) {
    if ($module -eq 'Pester') {
        if ((Get-Module pester -ListAvailable | sort Version -Descending | select -First 1).Version.Major -ge 5) {
            Write-Host "Module $module is already installed - Updating"
            Update-Module $module
        } else {
            Write-Host "Installing module $module"
            Install-Module $module -Scope AllUsers -Force -SkipPublisherCheck -AllowClobber
        }
    } else {
        if (Get-Module $module -ListAvailable) {
            Write-Host "Module $module is already installed - Updating"
            Update-Module $module
        } else {
            Write-Host "Installing module $module"
            Install-Module $module -Scope AllUsers -Force
        }
    }

}



switch ($eNV:computername) {
    RainbowDragon {
        if (( Get-WindowsCapability -Name Rsat.ActiveDirectory*  -Online).State -eq 'NotPresent') {
            Write-Host "Installing RSAT"
            Get-WindowsCapability -Name Rsat.ActiveDirectory*  -Online | Add-WindowsCapability -Online
        } else {
            Write-Host "RSAT installed"
        }

        if (oh-my-posh) {
            Write-Host "oh-my-posh installed"

        } else {
            Write-Host "installing oh-my-posh "
            Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))
        }
    }
    POSHClient1 {
        if ((Get-WindowsFeature -Name RSAT).InstallState -ne 'Installed') {
            Write-Host "Installing RSAT"
            Install-WindowsFeature RSAT
        } else {
            Write-Host "RSAT installed"
        }
    }
}
