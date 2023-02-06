$dbatoolsmodulebase = (Get-Module dbatools -ListAvailable | select -First 1 | select modulebase).modulebase
$PsFrameworkmodulebase = (Get-Module PSFramework -ListAvailable | select -First 1 | select modulebase).modulebase

$SQLHosts | ForEach-Object {
    $session = New-PSSession -ComputerName $_ -Credential $domaincred
    Write-Host "Copying modules over to $($_)"
    # Copy-Item $dbatoolsmodulebase  -ToSession $session -Destination $dbatoolsmodulebase -Recurse -Force
    # Copy-Item $PsFrameworkmodulebase  -ToSession $session -Destination $PsFrameworkmodulebase -Recurse -Force
}
