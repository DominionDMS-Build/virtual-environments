##Variables
$imagebuildid    = $(Build.BuildId)
$vmSize          = "Standard_B2ms"
$vnetName       = "entNetwork-East"
$subnetName     = "EntBuildEast"
$subnetid       = "/subscriptions/cecce45e-603e-48ae-9dd4-7ea90c8798ce/resourceGroups/EntMainEast/providers/Microsoft.Network/virtualNetworks/entNetwork-East/subnets/EntBuildEast"
$nicName        = "$(imagebuildid)-agent-NIC"
$ResourceGroupName = "EntAgentsEast"
$VirtualMachineName  = "$(imagebuildid)-agent"
$AdminUsername       = "super"
$AdminPassword          = "$(entpwd)"
$AzureLocation             = "eastus"
$SubscriptionId            = "$(subid)"
$ImageName               = "windows2022-70485" #"windows2022-$(imagebuildid)"
$ImageId             = "/subscriptions/cecce45e-603e-48ae-9dd4-7ea90c8798ce/resourceGroups/EntBuildEast/providers/Microsoft.Compute/images/$(ImageName)"
$osDiskSize         =  512

Write-Host "AdminPassword: $($AdminPassword)"

Write-Host "`nCreating a network interface controller (NIC)"
($nic = az network nic create -g $ResourceGroupName -l $AzureLocation -n $nicName --subnet $subnetid --subscription $subscriptionId)
$networkId = ($nic | ConvertFrom-Json).NewNIC.id

Write-Host "`nCreating the VM"
az vm create -g $ResourceGroupName --location  $AzureLocation -n $VirtualMachineName --subscription $subscriptionId --image $ImageId --size $vmSize --os-disk-size-gb $osDiskSize --admin-username $AdminUsername  --admin-password $AdminPassword

Write-Host "`nInstalling Custom Script on Agent VMs"

$protectedSettings = '{\"commandToExecute\" : \"powershell -ExecutionPolicy Unrestricted -File Install-Agent.ps1 -Pat $(Pat) -Pool $(Pool) -Agentname $(agentname) -OrganizationName $(OrganizationName) -AgentFileName $(AgentFileName) -AdminUsername $(AdminUsernames) -entpwd $(entpwd)\"}'


##Write-Host "`n Create the parameters for the extension"
az vm extension set -n 'CustomScriptExtension' --publisher 'Microsoft.Compute' --version '1.10.9' --vm-name $VirtualMachineName --resource-group $ResourceGroupName --protected-settings $protectedSettings --settings '{""fileUris"": [""https://dmsbuildimages.blob.core.windows.net/system/Install-Agent.ps1?sv=2020-08-04&ss=bfqt&srt=sco&sp=rwdlacuptfx&se=2025-08-30T20:58:44Z&st=2021-08-30T12:58:44Z&spr=https&sig=BStZrOYKiK6L9cfI1H8CxbcsuRbRcmsZhJkAutmy0ZA%3D""]}'
