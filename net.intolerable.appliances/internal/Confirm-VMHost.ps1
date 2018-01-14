<#
	.Description
		Confirms / sets the VMHost value, which is still required for Import-Vapp. Expected behavior:
		1) If a VMHost is provided, that will be returned. 
		2) If not, the cluster resource will be found based on the -Location parameter. The host with the least number of powered on VM's will be used
		3) If neither -VMHost or -Location are provided.... an exception will be generated
#>
Function Confirm-VMHost {
	if (!$VMHost -and !$Location) { throw "No infrastructure resource was provided. Please specify either a VMHost (-VMHost) or Infrastructure resource (-Location) to provision the virtual appliance to." }
	
	if ($VMHost) { $VMHost }
	elseif ($Location) { 
		Write-Warning "A VMHost was not provided, but a resource location was... the host with the least number of powered on VM's will be selected for provisioning destination."
		$Status = "Confirming VMHost for deployment"
		Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Getting the vSphere Cluster tied to provided location"
		if ($Location.GetType().Name -eq "ClusterImpl") { $Cluster = $Location }
		else { $Cluster = Get-Cluster -Location $Location }

		Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Getting all hosts in the vSphere Cluster"
		$VMHosts = Get-VMHost -Location $Cluster | Select-Object Name,@{Name="VMs";Expression={ (Get-VM -Location $_ | Where-Object { $_.PowerState -eq "PoweredOn" }).count }} | Sort-Object VMs

		Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Returning the VMHost with the least number of registered VM's on it"
		Get-VMHost -Name $VMHosts[0].Name
	}
}