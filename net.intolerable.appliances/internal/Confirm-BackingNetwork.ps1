<#
	.Description
		Confirms the specified portgroup name exists on the ESXi host. This will check for both a distributed (first) and standard (second) portgroup
#>
Function Confirm-BackingNetwork {
	# Validating port group exists
	$Status = "Confirming backing network availability"
	Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Checking vSphere Distributed Portgroups"
	$portgroup = Get-VDPortgroup -Name $Network -VDSwitch (Get-VDSwitch -VMHost $VMHost)
	
	if (!$portgroup) { 
		Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Checking vSphere Standard Portgroups"
		$portgroup = Get-VirtualPortgroup -Standard -Name $Network -VMHost $VMHost
	}
	if (!$portgroup) { throw "Network name '$($network)' not found, check and confirm that this portgroup exists on the connected vCenter Server" }
}