# Find all the SQL Instances on your estate
Get-ADComputer -Filter * | Sort-Object Name | ForEach-Object { Resolve-DnsName -Name $_.Name }

Find-DbaInstance -DiscoveryType All -OutVariable svrs

Find-DbaInstance -DiscoveryType DomainSPN -DomainController jessdc1

$AdComputerNames = (Get-adcomputer -Filter * ).Name

$SQLInstances = $AdComputerNames | Find-DbaInstance

$AvailableSQL = $SqlInstances | ForEach-Object {
    Write-PSFMessage -Level Host -Message "Testing connection to $($_.SqlInstance)"
    $results = Test-DbaConnection -SqlInstance $_.SqlInstance -SkipPSRemoting -WarningAction SilentlyContinue
    if ($results.ConnectSuccess) {
        Write-PSFMessage -Level Host -Message "SUCCESS - Testing connection to $($_.SqlInstance)"
        $_
    }
}

# Save the results to excel - Because everyone wants excel !!

# save the results to a CMS - so everyone can use that

# Save the results to a database - so you can use it for all sorts of things

# Use the results as tab completion for your PowerShell commands
