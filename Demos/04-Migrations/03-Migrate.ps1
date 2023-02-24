# go sql cmnd - its pretty cool

# find out more at GitHub

start msedge 'https://github.com/microsoft/go-sqlcmd'


# Check out the latest releases
start msedge 'https://github.com/microsoft/go-sqlcmd/releases'

gh auth login

gh release list --repo microsoft/go-sqlcmd

gh release download --repo microsoft/go-sqlcmd v0.14.0 --dir c:\temp

Invoke-Item C:\temp\sqlcmd_0.14.0-1.msi

$env:path += ";C:\Program Files\sqlcmd"

sqlcmd --help

sqlcmd create mssql --accept-eula --using https://aka.ms/AdventureWorksLT.bak
sqlcmd query "select @@version"
sqlcmd open ads

sqlcmd delete --force

sqlcmd create mssql --accept-eula --using \\poshfs1\SQLBackups\Jess2016\Accelerate\FULL\Jess2016_Accelerate_FULL_20230212_112031.bak

$resourceGroup = 'SQLBits2023-TrainingDay'
$SubscriptionName = 'Beards Microsoft Azure Sponsorship'
$StorageAccountName = 'beard2019agstorage'
$tenantId = 'add02cc8-7eaf-4746-902a-53d0ceeff326'
Connect-AzAccount -Tenant $tenantId
Select-AzSubscription -SubscriptionName $SubscriptionName
$context = (Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $StorageAccountName).context
$containername = 'sqlbackups'
$policyName = 'backup-policy' 
$credName = "https://{0}.blob.core.windows.net/{1}" -f $StorageAccountName, $containername
$SasToken = New-AzStorageAccountSASToken -Context $context -Service Blob -ResourceType Container -Permission rwdl -ExpiryTime (Get-Date).AddHours(1) | ConvertTo-SecureString -AsPlainText -Force


# Sets up a Stored Access Policy and a Shared Access Signature for the new container  
$policy = New-AzStorageContainerStoredAccessPolicy -Container $containerName -Policy $policyName -Context $context -ExpiryTime $(Get-Date).ToUniversalTime().AddDays(30) -Permission "rwld"
$SasToken = New-AzStorageContainerSASToken -Policy $policyName -Context $context -Container $containerName
  


$SQlInstance = 'Jess2017'
New-DbaCredential -SqlInstance $SQlInstance -Name $credName -Identity 'SHARED ACCESS SIGNATURE' -SecurePassword $SasToken

Backup-DbaDatabase -SqlInstance $SQlInstance -Database 'Accelerate' -Type Full -AzureBaseUrl $credName -OutputScriptOnly
Backup-DbaDatabase -SqlInstance $SQlInstance -Database 'Accelerate' -Type Full -AzureBaseUrl $credName 

# Sets up a Stored Access Policy and a Shared Access Signature for the new container  
$policy = New-AzStorageContainerStoredAccessPolicy -Container $containerName -Policy $policyName -Context $storageContext -ExpiryTime $(Get-Date).ToUniversalTime().AddYears(10) -Permission "rwld"
$sas = New-AzStorageContainerSASToken -Policy $policyName -Context $storageContext -Container $containerName
Write-Host 'Shared Access Signature= '$($sas.Substring(1))''  


# Outputs the Transact SQL to the clipboard and to the screen to create the credential using the Shared Access Signature  
Write-Host 'Credential T-SQL'  
$tSql = "CREATE CREDENTIAL [{0}] WITH IDENTITY='Shared Access Signature', SECRET='{1}'" -f $cbc.Uri,$sas.Substring(1)   
$tSql | clip  
Write-Host $tSql  