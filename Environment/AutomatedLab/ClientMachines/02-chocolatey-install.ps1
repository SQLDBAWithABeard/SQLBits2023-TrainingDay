[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install azure-data-studio -y
choco install azure-functions-core-tools-3 -y
choco install azure-cli -y
choco install bicep -y

choco install git.install -y
choco install git-credential-manager-for-windows -y

choco install microsoftazurestorageexplorer -y
choco install powershell-core -y -install-arguments='"ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 REGISTER_MANIFEST=1 ENABLE_PSREMOTING=1"'

choco install sql-server-management-studio -y
choco install sysinternals -y

choco install vscode -y
choco install vscode-powershell -y
choco install vscode-settingssync -y
choco install vscode.install -y


choco install microsoft-windows-terminal -y
choco install wsl2 -y
choco install gh -y
choco install podman-desktop -y