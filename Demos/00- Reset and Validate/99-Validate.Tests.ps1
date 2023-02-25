BeforeDiscovery {
    $ADComputers = Get-ADComputer -Filter * -Properties Name | Select-Object -ExpandProperty Name
    $FileShare = '\\poshfs1\SQLBackups'
    $SQLServers = 'Jess2016', 'Jess2017', 'Jess2019'
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

Describe "Jess2019 should be behind on a patch" {
    Context "Validating <_>" -ForEach @('Jess2019') {
        It "<_> should be behind on a patch" -Tag Morning {
            (Test-DbaBuild -SqlInstance $_ -Latest).Compliant | Should -Be $false
        }
    }
}

Describe "SQL servers should have 25 online databases" -Tag test {
    Context "Validating <_>" -ForEach $SQLServers {
        It "<_> should have 25 databases" -Tag Morning {
            ( Get-DbaDatabase -SqlInstance $_ -ExcludeSystem | Measure-Object ).Count | Should -Be 25
        }
        It "<_> should have all the databases online" -Tag Morning {
            ( Get-DbaDatabase -SqlInstance $_ -ExcludeSystem | Where-Object Status -ne 'Normal') | Should -BeNullOrEmpty
        }
    }
}