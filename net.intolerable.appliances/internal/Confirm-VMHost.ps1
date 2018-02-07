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
	if (!$VMHost -and !$Location) { Throw "No infrastructure resource was provided. Please specify either a VMHost (-VMHost) or Infrastructure resource (-Location) to provision the virtual appliance to." }
	if($VMHost) { 
		if(-not (Get-VMHost -Name $VMHost.Name)) { Throw "Can not reach VMHost $($VMHost.Name)" }
	}

	# What to do if the Location parameter is provided but a VMHost is not
	if ($Location -and !$VMHost) {
		Write-Verbose "A VMHost was not provided, but a resource location was... the host with the least number of powered on VM's will be selected for provisioning destination."
		$Status = "Getting VMHost for virtual appliance import operation"
		Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Getting the vSphere Cluster tied to resource location"

		# If the provided location is a vSphere Cluster
		if ($Location -is [VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster]) { 
			$Cluster = $Location
			Write-Verbose -Message "Location parameter passed in a vSphere Cluster; proceeding with acquiring " 
		}

		# If the provided location is a vSphere Resource Pool
		elseif ($Location -is [VMware.VimAutomation.ViCore.Types.V1.Inventory.ResourcePool]) {
			if ($Location.Parent -is [VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster]) { $Cluster = $Location.Parent }
			else { 
				do { $Location = $Location.Parent }
				until ($Location -is [VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster])
				$Cluster = $Location
			}
		}
	
		# If it's not a Cluster or Resource Pool..
        else {
            $Cluster = Get-Cluster -Location $Location | Sort-Object -Property { (Get-VM -Location $_ | Where-Object { $_.PowerState -eq 'poweredon' }).Count } -Descending |
			Select-Object -First 1
		}
		if(-not $Cluster) { Throw "No cluster provided, or no cluster found under $($Location)"	}
		
		# Finding the host with least number of powered on VM's -- thanks to LucD for streamlining this!
		$VMHosts = Get-VMHost -Location $Cluster
		if(-not $VMHosts) { Throw "No ESXi Hosts are present in $($Cluster)" }
		$VMHost = $VMHosts | 
			Sort-Object -Property { (Get-VM -Location $_ | Where-Object { $_.PowerState -eq 'poweredon' }).Count } -Descending |
			Select-Object -First 1

		Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Returning the VMHost with the least number of powered on VM's on it"
	}

	# Verbose logging output to finish things off
	Write-Verbose -Message (Get-FormattedMessage -Message "$($MyInvocation.MyCommand) Finished execution")
	$VMHost
}
