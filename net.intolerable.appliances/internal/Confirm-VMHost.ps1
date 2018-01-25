<#
	.Description
		Confirms / sets the VMHost value, which is still required for Import-Vapp. Expected behavior:
		1) If a VMHost is provided, that will be returned. 
		2) If not, the cluster resource will be found based on the -Location parameter. The host with the least number of powered on VM's will be used
		3) If neither -VMHost or -Location are provided.... an exception will be generated
#>
Function Confirm-VMHost {
	Param (
		[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]$VMHost,
		[VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]$Location,
		[string]$Activity
	)

	# Setting the name of the function and invoking opening verbose logging message
	Write-Verbose -Message (Get-FormattedMessage -Message "$($MyInvocation.MyCommand) Started execution")

	# Error out if there's no host or no resource pool / cluster to find a host for...
	if (!$VMHost -and !$Location) { throw "No infrastructure resource was provided. Please specify either a VMHost (-VMHost) or Infrastructure resource (-Location) to provision the virtual appliance to." }

	if ($VMHost) { $VMHost } # If a host was provided in the wrapper function, return it and move on with our day...

	# Getting a VMHost from the cluster / resource pool based on which of the associated has the least number of powered on VM's 
	# Open to better logic here if anybody has thoughts.. i.e. CPU/Memory consumption, etc... feel free to update!
	elseif ($Location) {
		Write-Verbose "A VMHost was not provided, but a resource location was... the host with the least number of powered on VM's will be selected for provisioning destination."

		$Status = "Getting VMHost for virtual appliance import operation"
		Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Getting the vSphere Cluster tied to resource location"
		if ($Location.GetType().Name -eq "ClusterImpl") { $Cluster = $Location }
		else { $Cluster = Get-Cluster -Location $Location }

		Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Getting all of the hosts in the vSphere Cluster"
		$VMs = Get-VM -Location $Cluster | Where-Object { $_.PowerState -eq "PoweredOn" }
		$VMHosts = Get-VMHost -Location $Cluster | Select-Object Name,@{Name="VMs";Expression={ $VMs.count }} | Sort-Object VMs

		Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Returning the VMHost with the least number of registered VM's on it"
		Get-VMHost -Name $VMHosts[0].Name
	}

	# Verbose logging output to finish things off
	Write-Verbose -Message (Get-FormattedMessage -Message "$($MyInvocation.MyCommand) Finished execution")
}
