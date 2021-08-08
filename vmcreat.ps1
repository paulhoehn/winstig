
Login-AzureRmAccount


#-ResourceGroupName Paul-RG -Location EastUS

#create RG
# New-AzureRmResourceGroup -ResourceGroupName Paul-RG -Location EastUS

# Create Subnet
$subnetConfig = New-AzureRmVirtualNetworkSubnetConfig `
-Name PaulSubnet `
-AddressPrefix 172.100.1.0/24

# Create Vnet
$vnet = New-AzureRmVirtualNetwork `
-ResourceGroupName Paul-RG `
-Location EastUS `
-Name PSVnet `
-AddressPrefix 172.100.0.0/16 `
-Subnet $subnetConfig

# Create PIP
$pip = New-AzureRmPublicIpAddress `
-ResourceGroupName Paul-RG `
-Location EastUS `
-AllocationMethod Static `
-Name PSPIP

# Create NIC
$nic = New-AzureRmNetworkInterface `
-ResourceGroupName Paul-RG`
-Location EastUS `
-Name PSNic `
-SubnetId $vnet.Subnets[0].Id `
-PublicIpAddressId $pip.Id

# Create NSG Rule
$nsgRule = New-AzureRmNetworkSecurityRuleConfig `
-Name PaulGRuleRDP `
-Protocol Tcp `
-Direction Inbound `
-Priority 1000 `
-SourceAddressPrefix * `
-SourcePortRange * `
-DestinationAddressPrefix * `
-DestinationPortRange 3389 `
-Access Allow

$nsgRule1 = New-AzureRmNetworkSecurityRuleConfig `
-Name PSNSGRuleAny `
-Protocol Tcp `
-Direction Inbound `
-Priority 1001 `
-SourceAddressPrefix * `
-SourcePortRange * `
-DestinationAddressPrefix * `
-DestinationPortRange * `
-Access Allow

# Create NSG
$nsg = New-AzureRmNetworkSecurityGroup `
-ResourceGroupName Paul-RG `
-Location EastUS `
-Name PSNSG `
-SecurityRules $nsgRule,$nsgRule1

# Assign NSG to Subnet
Set-AzureRmVirtualNetworkSubnetConfig `
-Name PaulSubnet `
-VirtualNetwork $vnet `
-NetworkSecurityGroup $nsg `
-AddressPrefix 172.100.1.0/24

#Update subnet with NSG
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet

#Set Cred for VM
$cred = Get-Credential

#Set Vm config, name and Size
$vmconfig = New-AzureRmVMConfig -VMName testvm -VMSize Standard_A1 | `
Set-AzureRmVMOperatingSystem -Windows -ComputerName twstvm -Credential $cred | `
Set-AzureRmVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2016-Datacenter -Version latest | Add-AzureRmVMNetworkInterface -Id $nic.Id

#Create VM
New-AzureRmVM -ResourceGroupName PSRG -Location EastUS -VM $vmconfig