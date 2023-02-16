
$shareName = 'SQLBackups'
$path = "E:\SQLBackups"
$changeAccess = "jessandbeard\SQLgMSA$","jessandbeard\SQLAGgMSA$"
$FullAccess = "jessandbeard\Domain Admins"
$shared = '\\poshfs1\SQLBackups\Shared'  # for migrations and ags

if(-not (Test-Path $path)) {
    Write-Host ('Creating the {0} folder' -f $path)
    New-Item -Path $path -ItemType Directory -Force
}

if(-not (Get-SmbShare -name $shareName)) {
    Write-Host ('Creating the Smb share {0} for {1}' -f $shareName, $path)
    New-SmbShare -Name $shareName -Path $path -ChangeAccess $changeAccess -FullAccess $FullAccess
} else {
    Write-Host ('Share {0} exists - just set access' -f $shareName)
    Write-Host ("Cher?!? If I could turn back time.. we wouldn't need to be idempotent")


    $changeSet = Get-SmbShareAccess -Name $shareName | Where-Object AccessRight -eq 'change'
    $chgDiffs = Compare-Object $changeset.AccountName $changeAccess -PassThru

    $fullSet = Get-SmbShareAccess -Name $shareName | Where-Object AccessRight -eq 'Full'
    $fullDiffs = Compare-Object $fullSet.AccountName $FullAccess -PassThru

    if($chgDiffs -or $fullDiffs) {
        Write-Host ('Share {0} - permissions do not match - revoke and reapply' -f $shareName)
        # revoke and reapply - could work out what needs to be reapplied...
        Revoke-SmbShareAccess -Name $shareName -AccountName (Get-SmbShareAccess -Name $shareName).AccountName -Confirm:$false

        Grant-SmbShareAccess -Name $shareName -AccountName $changeAccess -AccessRight Change -Confirm:$false
        Grant-SmbShareAccess -Name $shareName -AccountName $fullAccess -AccessRight Full -Confirm:$false
    }
}

if(-not (Test-Path $shared)) {
    Write-Host ('Creating the {0} folder' -f $shared)
    New-Item -Path $shared -ItemType Directory -Force
}

# Copy-LabFileItem -Path F:\BackupShare\AdventureWorks_FULL_COPY_ONLY.bak -ComputerName POSHFS1 -DestinationFolderPath E:\SQLBackups