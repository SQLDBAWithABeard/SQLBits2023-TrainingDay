New-Item -Path "E:\SQLBackups" -ItemType Directory -Force
New-SmbShare -Name SQLBackups -Path "E:\SQLBackups" -ChangeAccess "jessandbeard\SQLgMSA$" -FullAccess "jessandbeard\Domain Admins"
    

# Copy-LabFileItem -Path F:\BackupShare\AdventureWorks_FULL_COPY_ONLY.bak -ComputerName POSHFS1 -DestinationFolderPath E:\SQLBackups