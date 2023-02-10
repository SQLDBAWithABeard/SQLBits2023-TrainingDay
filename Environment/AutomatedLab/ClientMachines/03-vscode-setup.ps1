oh-my-posh font install Meslo

Write-Host "Setting up Windows Terminal"

$WindowsTerminalSettingsFile = Get-Item $env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal*\LocalState\settings.json
$WindowsTerminalSettings = Get-Content $WindowsTerminalSettingsFile.FullName | ConvertFrom-Json
$WindowsTerminalSettings.profiles.defaults = @{font = @{ face= "MesloLGM NF"}}
$WindowsTerminalSettings| ConvertTo-Json -Depth 5 |Set-Content  $WindowsTerminalSettingsFile

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