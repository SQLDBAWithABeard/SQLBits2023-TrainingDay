$PSDefaultParameterValues = @{
    '*dba*:SqlCredential' = $domaincred
}

$Message = "Installing maintenance solution on {0}" -f ($SQLHosts -join ', ')
Write-PSFMessage -Level Host -Message $Message

Install-DbaWhoIsActive -SqlInstance $SQLHosts -Database master -Confirm:$false