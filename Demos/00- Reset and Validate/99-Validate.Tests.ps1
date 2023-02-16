BeforeDiscovery {
    $ADComputers = Get-ADComputer -Filter * -Properties Name | Select-Object -ExpandProperty Name
    $FileShare = '\\poshfs1\SQLBackups'

}
Describe "All Machines" {
    Context "Validating <_>" -ForEach $ADComputers {
        It "<_> should be running" -Tag Morning {
            Test-Connection -ComputerName $_  -TimeoutSeconds 1 -Count 1 -Quiet | Should -BeTrue
        }
    }
}

Describe "File share" {
    Context "Validating <_>" -ForEach $FileShare {
        It "<_> should be accessible" -Tag Morning {
            (Invoke-Command -scriptblock { Get-SmbShare -Name SQLBackups } -ComputerName POSHFS1).Name | Should -Be 'SQLBackups'
        }
    }
}
