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
        Write-Host "No Windows Terminal for you rotten server OS"
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
    `$__Date = Get-Date -Format 'dd-MM'
    if(`$__Date -eq '14-03'){
        Set-PoshPrompt -Theme lambdageneration
    }else{
        `$themes = @(
            'neko',
            'sonicboom_dark',
            'neko',
            'easy-term',
            'if_tea',
            'neko',
            'kushal'
            'nigfht-owl',
            'neko',
            'powerlevel10k_rainbow',
            'quick-term',
            'neko',
            'stelbent.minimal',
            'tokyo',
            'neko',
            'unicorn',
            'wholespace'
        )
        Set-PoshPrompt -Theme (Get-Random -InputObject `$themes)
    }


    if (`$psstyle) {
        `$psstyle.FileInfo.Directory = `$psstyle.FileInfo.Executable = `$psstyle.FileInfo.SymbolicLink = ""
        `$PSStyle.FileInfo.Extension.Clear()
        `$PSStyle.Formatting.TableHeader = ""
        `$PsStyle.Formatting.FormatAccent = ""
    }
}
function Invoke-PubsApplication {
    # This will randomly insert rows into the pubs.dbo.sales table on dbatools1 to simulate sales activity
    # It'll run until you kill it
    `$SqlInstance = 'Jess2017'

    # app connection
    `$securePassword = ('PubsAdmin' | ConvertTo-SecureString -asPlainText -Force)
    `$appCred = New-Object System.Management.Automation.PSCredential('PubsAdmin', `$securePassword)
    `$appConnection = Connect-DbaInstance -SqlInstance `$SqlInstance -ClientName 'PubsApplication'

    while (`$true) {
    Write-PSFHostColor -String "Pubs application is running...forever... Ctrl+C to get out of here" -DefaultColor Green

        `$newOrder = [PSCustomObject]@{
        stor_id  = Get-Random (Invoke-DbaQuery -SqlInstance `$appConnection -Database pubs -Query 'select stor_id from stores').stor_id
        ord_num  = Get-DbaRandomizedValue -DataType int -Min 1000 -Max 99999
        ord_date = get-date
        qty      = Get-Random -Minimum 1 -Maximum 30
        payterms = Get-Random (Invoke-DbaQuery -SqlInstance `$appConnection -Database pubs -Query 'select distinct payterms from pubs.dbo.sales').payterms
        title_id = Get-Random (Invoke-DbaQuery -SqlInstance `$appConnection -Database pubs -Query 'select title_id from titles').title_id
        }
        Write-DbaDataTable -SqlInstance `$appConnection -Database pubs -InputObject `$newOrder -Table sales

        Start-sleep -Seconds (Get-Random -Maximum 10)
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