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
        $ProfileTxt = @"
        function Load-Profile {
            Import-Module posh-git
            Import-Module -Name Terminal-Icons
            `$env:POSH_THEMES_PATH = '{0}\Programs\oh-my-posh\themes' -f `$env:LOCALAPPDATA

            function global:Set-PoshPrompt {
                param(
                    `$theme
                )
                & oh-my-posh.exe init pwsh --config "`$env:POSH_THEMES_PATH\`$theme.omp.json" | Invoke-Expression
            }
            # Create scriptblock that collects information and name it
            Register-PSFTeppScriptblock -Name "poshthemes" -ScriptBlock { Get-ChildItem `$env:POSH_THEMES_PATH | Select-Object -ExpandProperty Name -Unique | ForEach-Object { `$_ -replace '\.omp\.json$', '' } }
            #Assign scriptblock to function
            Register-PSFTeppArgumentCompleter -Command Set-PoshPrompt -Parameter theme -Name poshthemes

            Set-PoshPrompt -Theme sonicboom_dark

            if (`$psstyle) {
                `$psstyle.FileInfo.Directory = `$psstyle.FileInfo.Executable = `$psstyle.FileInfo.SymbolicLink = ""
                `$PSStyle.FileInfo.Extension.Clear()
                `$PSStyle.Formatting.TableHeader = ""
                `$PsStyle.Formatting.FormatAccent = ""
            }
        }
        "Load-Profile for full profile"
        function prompt {
            #Load-Profile
         "PS > "
        }

"@
        $ProfilePath = 'C:\Program Files\PowerShell\7\profile.ps1'

        if (-not (Test-Path $ProfilePath)) {
            Write-Host "Creating Profile"
            New-Item -ItemType File -Path $ProfilePath
        }
        Write-Host "Set Profile"
        $ProfileTxt | Set-Content $ProfilePath
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

