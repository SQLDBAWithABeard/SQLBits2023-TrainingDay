##TODO: Can we run a post VM build script with bicep? 🤔

# install choco
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

## install packages
choco install vscode -y
choco install vscode-powershell -y
choco install git -y
choco install azure-data-studio -y
choco install ssms -y
choco install zoomit -y
choco install sysinternals -y
choco install sysinternals -y
choco install microsoft-windows-terminal -y

## some modules
install-module dbatools
install-module dbachecks
