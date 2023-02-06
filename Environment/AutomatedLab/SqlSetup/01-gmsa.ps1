# SQL Standalone gMSA
if ($null -eq (Get-ADGroup -Identity SQLInstancesgMSAs)) {
    Write-PSFMessage -Level Host -Message "Creating SQLInstancesgMSAs security group"
    New-ADGroup -Name SQLInstancesgMSAs -Description “Security group for SQLInstances” -GroupCategory Security -GroupScope Global
} else {
    Write-PSFMessage -Level Host -Message "SQLInstancesgMSAs security group already exists"
}

$SASQLHosts | ForEach-Object {
    if ((Get-ADGroupMember -Identity SQLInstancesgMSAs).Name -notcontains $_) {
        Write-PSFMessage -Level Host -Message "Adding $($_)$ to SQLInstancesgMSAs security group"
        Add-ADGroupMember -Identity SQLInstancesgMSAs -Members "$_$"
    } else {
        Write-PSFMessage -Level Host -Message "$($_)$ is already a member of SQLInstancesgMSAs security group"
    }
}

try {
    Get-ADServiceAccount -Identity SQLgMSA -ErrorAction Stop | Out-Null
    Write-PSFMessage -Level Host -Message "SQLgMSA service account already exists"
} catch {
    Write-PSFMessage -Level Host -Message "Creating SQLgMSA service account"
    New-ADServiceAccount -Name SQLgMSA -PrincipalsAllowedToRetrieveManagedPassword SQLInstancesgMSAs -Enabled:$true -DNSHostName SQLgMSA.jessandbeard.local -SamAccountName SQLgMSA -ManagedPasswordIntervalInDays 90
}

# AG gMSA
#TODO: `Get-ADGroup -Identity SQLInstancesgMSAs` throws an error if the group doesn't exist - even if you do -ea silently continue - this seems more reliable.)
try {
    # see if we can create the group or it already exists
    Write-PSFMessage -Level Host -Message "Creating SQLAGgMSAs security group"
    New-ADGroup -Name SQLAGgMSAs -Description “Security group for SQLAGs” -GroupCategory Security -GroupScope Global
} catch [Microsoft.ActiveDirectory.Management.ADException] {
    switch ( $_.Exception.Message ) {
        "The specified group already exists" { Write-PSFMessage -Level Host -Message "SQLAGgMSAs security group already exists" }
        default { Write-Host "Unhandled ADException: $_" }
    }
 }
catch {
    Write-Host "Unhandled Error!  Figure out what went wrong and how to handle it in your code so we never get to this point."
    Write-Error $_
}

$SQLAgs | ForEach-Object {
    if ((Get-ADGroupMember -Identity SQLAggMSAs).Name -notcontains $_) {
        Write-PSFMessage -Level Host -Message "Adding $($_)$ to SQLAggMSAs security group"
        Add-ADGroupMember -Identity SQLAggMSAs -Members "$_$"
    } else {
        Write-PSFMessage -Level Host -Message "$($_)$ is already a member of SQLAggMSAs security group"
    }
}

try {
    Get-ADServiceAccount -Identity SQLAGgMSA -ErrorAction Stop | Out-Null
    Write-PSFMessage -Level Host -Message "SQLAGgMSA service account already exists"
} catch {
    Write-PSFMessage -Level Host -Message "Creating SQLAGgMSA service account"
    New-ADServiceAccount -Name SQLAGgMSA -PrincipalsAllowedToRetrieveManagedPassword SQLAggMSAs -Enabled:$true -DNSHostName SQLAGgMSA.jessandbeard.local -SamAccountName SQLAGgMSA -ManagedPasswordIntervalInDays 90
}
