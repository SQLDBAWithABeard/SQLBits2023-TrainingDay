oh-my-posh font install Meslo
switch ($eNV:computername) {
    RainbowDragon {
        Write-Host "Setting up Windows Terminal"

        $WindowsTerminalSettingsFile = Get-Item $env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal*\LocalState\settings.json
        $WindowsTerminalSettings = Get-Content $WindowsTerminalSettingsFile.FullName | ConvertFrom-Json
        $WindowsTerminalSettings.profiles.defaults = @{font = @{ face = "MesloLGM NF" } }
        $WindowsTerminalSettings | ConvertTo-Json -Depth 5 | Set-Content  $WindowsTerminalSettingsFile
    }
    PoshClient1 {
        Write-Host "No Windows Termainal for you rotten server OS"
    }
}

code --install-extension BeardedBear.beardedtheme
code --install-extension eamodio.gitlens
code --install-extension gerane.Theme-Blackboard
code --install-extension GitHub.codespaces
code --install-extension GitHub.copilot
code --install-extension GitHub.vscode-pull-request-github
code --install-extension hediet.vscode-drawio
code --install-extension LouisWT.regexp-preview
code --install-extension medo64.render-crlf
code --install-extension mhutchie.git-graph
code --install-extension ms-azuretools.azure-dev
code --install-extension ms-azuretools.vscode-azureappservice
code --install-extension ms-azuretools.vscode-azurefunctions
code --install-extension ms-azuretools.vscode-azureresourcegroups
code --install-extension ms-azuretools.vscode-azurestaticwebapps
code --install-extension ms-azuretools.vscode-azurestorage
code --install-extension ms-azuretools.vscode-azurevirtualmachines
code --install-extension ms-azuretools.vscode-bicep
code --install-extension ms-azuretools.vscode-cosmosdb
code --install-extension ms-mssql.data-workspace-vscode
code --install-extension ms-mssql.mssql
code --install-extension ms-mssql.sql-bindings-vscode
code --install-extension ms-mssql.sql-database-projects-vscode
code --install-extension ms-vscode.azure-account
code --install-extension ms-vscode.azurecli
code --install-extension ms-vscode.powershell
code --install-extension ms-vsliveshare.vsliveshare
code --install-extension oderwat.indent-rainbow
code --install-extension PKief.material-icon-theme
code --install-extension rangav.vscode-thunder-client
code --install-extension redhat.vscode-commons
code --install-extension redhat.vscode-yaml
code --install-extension streetsidesoftware.code-spell-checker
code --install-extension TylerLeonhardt.vscode-inline-values-powershell
code --install-extension vsls-contrib.codetour

Write-Host "Setting up Repo"
$Repo = 'C:\TheGoodStuff'

if (-not (Test-Path $Repo)) {
    Write-Host "Creating Profile"
    New-Item -ItemType Directory -Path $Repo
}

Set-Location $repo
git clone https://github.com/SQLDBAWithABeard/SQLBits2023-TrainingDay.git

Set-Location $repo\SQLBits2023-TrainingDay
git pull
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
function Start-Demo {
    Write-PSfMessage -Level Significant -Message "Starting The Good Stuff"
    `$repo = 'C:\TheGoodStuff'
    Set-Location `$repo
    git clone https://github.com/SQLDBAWithABeard/SQLBits2023-TrainingDay.git
    Set-Location `$repo\SQLBits2023-TrainingDay
    git pull
    code `$repo\SQLBits2023-TrainingDay
}
"Load-Profile for full profile"
"Then Start-Demo for the Good Stuff"
function prompt {
    #Load-Profile
 "PS > "
}

"@ + (Get-Content -Path Environment\AutomatedLab\global\01-variables.ps1 -Raw)


$ProfilePath = 'C:\Program Files\PowerShell\7\profile.ps1'

if (-not (Test-Path $ProfilePath)) {
    Write-Host "Creating Profile"
    New-Item -ItemType File -Path $ProfilePath
}
Write-Host "Set Profile"
$ProfileTxt | Set-Content $ProfilePath