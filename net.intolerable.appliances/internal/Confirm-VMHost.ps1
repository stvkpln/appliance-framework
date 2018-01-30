<#
	.Description
		Confirms / sets the VMHost value, which is still required for Import-Vapp. Expected behavior:
		1) If a VMHost is provided, that will be returned. 
		2) If not, the cluster resource will be found based on the -Location parameter. The host with the least number of powered on VM's will be used
		3) If neither -VMHost or -Location are provided.... an exception will be generated
#>
Function Confirm-VMHost {
	Param (
		[ValidateScript({$_ -is [System.Collections.Hashtable] -or $_ -is [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]})]
		[PSObject]$VMHost,
		
		[ValidateScript({$_ -is [System.Collections.Hashtable] -or $_ -is [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]})]
		[PSObject]$Location,
		
		[string]$Activity
	)

	# Setting the name of the function and invoking opening verbose logging message
	Write-Verbose -Message (Get-FormattedMessage -Message "$($MyInvocation.MyCommand) Started execution")

	# Error out if there's no host or no resource pool / cluster to find a host for...
	if (!$VMHost -and !$Location) { 
		Throw "No infrastructure resource was provided. Please specify either a VMHost (-VMHost) or Infrastructure resource (-Location) to provision the virtual appliance to." 
	}
	if($VMHost){
		if(-not (Get-VMHost -Name $VMHost.Name)){
			Throw "Can not reach VMHost $($VMHost.Name)"
		}
	}
	if ($Location) {
	Write-Verbose "A VMHost was not provided, but a resource location was... the host with the least number of powered on VM's will be selected for provisioning destination."

		$Status = "Getting VMHost for virtual appliance import operation"
		Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Getting the vSphere Cluster tied to resource location"
		if($Location -is [VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster]){
			$cluster = $Location
		}
		Else{
			$cluster = Get-Cluster -Location $Location | Get-Random
		}
		if(-not $cluster){
			Throw "No cluster provided, or no cluster found under $($Location)"
		}
		$esx = Get-VMHost -Location $cluster
		if(-not $esx){
			Throw "No ESXi nodes found in cluster $($cluster)"
		}
		$VMHost = $esx | 
			Sort-Object -Property {(Get-VM -VMHost $_ | Where-Object{$_.PowerState -eq 'poweredon'}).Count} -Descending |
			Select-Object -First 1

		Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Returning the VMHost with the least number of powered on VM's on it"
	}

	# Verbose logging output to finish things off
	Write-Verbose -Message (Get-FormattedMessage -Message "$($MyInvocation.MyCommand) Finished execution")
	return $VMHost
}
