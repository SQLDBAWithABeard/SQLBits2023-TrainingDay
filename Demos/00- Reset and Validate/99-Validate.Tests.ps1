BeforeDiscovery {
    $ADComputers = Get-ADComputer -Filter * -Properties Name | Select-Object -ExpandProperty Name
}
Describe "All Machines" {
    Context "Validating <_>" -ForEach $ADComputers {
        It "<_> should be running" -Tag Morning {
            Test-Connection -ComputerName $_  -TimeoutSeconds 1 -Count 1 -Quiet | Should -BeTrue
        }
    }
}