$rg = 'bits-rg'
$location = 'uksouth'
$stgName = 'bitsstorage7777'

## create the resource group
# New-AzResourceGroup -Name $rg -Location uksouth -Tag @{'trainingday' = $true}

$deployment = @{
    ResourceGroupName = $rg
    TemplateFile      =  '.\Environment\main.bicep'
    name              = ('deployment-{0}' -f (Get-Date –format 'yyyyMMdd_HHmmss'))
    Tags              = @{'TrainingDay' = $true}

    # sqlVm stuff
    sqlName           = 'bits-sqlvm-1'
    imageOffer        = 'sql2019-ws2019'
    sqlSku            = 'SQLDEV'

    # jumpbox vm stuff
    jumpName          = 'bits-jump'


    # both VM stuff
    VirtualNetworkName = 'bits-net'
    adminUserName     = 'sqladmin'
    adminPassword     = $('dbatools.IO' | ConvertTo-SecureString -asPlainText -Force)
}
New-AzResourceGroupDeployment @deployment

##TODO: jumpbox - newer OS version?
