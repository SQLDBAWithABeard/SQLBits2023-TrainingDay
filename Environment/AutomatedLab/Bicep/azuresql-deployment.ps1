$resourceGroup = 'SQLBits2023-TrainingDay'

$location = 'uksouth'
$SubscriptionId = '6d8f994c-9051-4cef-ba61-528bab27d213' # Robs Beard MVP

Set-AzContext -SubscriptionId $SubscriptionId

$DatabaseNames = 'KellySmith', 'FaraWilliams', 'RachelYankey', 'JodieTaylor', 'KarenCarney', 'EllenWhite', 'AlexScott', 'EniolaAluko', 'RachelBrown-Finnis', 'ToniDuggan', 'CaseyStoney', 'NatashaDowie', 'AngharadJames', 'LianneSanderson', 'JillScott', 'GeorgiaStanway', 'KarenWalker', 'LucyBronze', 'SueSmith', 'KatieChapman', 'DionneLennon', 'FranKirby', '$location ', 'KarenBardsley', 'AlexGreenwood', 'RachelDaly', 'KeiraWalsh'

$AdminUser = 'jesspomfretobe'
$AdminPassword = 'dbatools.IO' | ConvertTo-SecureString -AsPlainText -Force

$NumberOneConfig = @{
    ResourceGroupName          = $resourceGroup
    location                   = $location
    TemplateFile               = 'Environment\AutomatedLab\Bicep\05sqlserveranddatabaseswithlooparray.bicep'
    Name                       = 'releasenumberone'
    sqlserverName              = 'hopepowell'
    administratorLogin         = $AdminUser
    administratorLoginPassword = $AdminPassword
    databaseNames              = (Get-Random -Count 7 $DatabaseNames  )
}
New-AzResourceGroupDeployment @NumberOneConfig

$NumberTwoConfig = @{
    ResourceGroupName          = $resourceGroup
    TemplateFile               = 'Environment\AutomatedLab\Bicep\05sqlserveranddatabaseswithlooparray.bicep'
    location                   = $location
    Name                       = 'releasenumbertwo'
    sqlserverName              = 'sarinawiegman'
    administratorLogin         = $AdminUser
    administratorLoginPassword = $AdminPassword
    databaseNames              = (Get-Random -Count 7 $DatabaseNames  )

}
New-AzResourceGroupDeployment @NumberTwoConfig


