<#
	.Description
		Confirms the specified portgroup name exists on the ESXi host. This will check for both a distributed (first) and standard (second) portgroup
#>

Function Confirm-BackingNetwork {
	[CmdletBinding()]
	param(
		[string]$Network,
		
		[ValidateScript({$_ -is [System.String] -or $_ -is [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]})]
		[PSObject]$VMHost,
		
		[string]$Activity
	)

	# Setting the name of the function and invoking opening verbose logging message
	Write-Verbose -Message (Get-FormattedMessage -Message "$($MyInvocation.MyCommand) Started execution")

	# Validating port group exists
	$Status = "Confirming backing network availability"
	Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Checking vSphere Distributed Portgroups"
	Try {
		# First, checking against distributed portgroups that are on the assigned VMHost
		$vdswitches = Get-VDSwitch -VMHost $VMHost -ErrorAction SilentlyContinue
		if ($vdswitches) { $vdportgroup = Get-VDPortgroup -Name $Network -VDSwitch $vdswitches -ErrorAction SilentlyContinue }
		
		# If a distributed portgroup is not found, check whether the VMHost has a standard portgroup with the 
		if (!$vdportgroup) { Get-VirtualPortGroup -Name $Network -VMHost $VMHost -Standard -ErrorAction Stop | Out-Null }
	}

	Catch {
		# Error handling if a portgroup is not found matching the name
		#throw $_
		throw "Network name '$($Network)' is not a a valid distributed or standard portgroup attached to the VMHost being used, check and confirm that this portgroup exists on the selected host or all hosts associated with the resource location selected"
	}

	# Verbose logging output to finish things off
	Write-Verbose -Message (Get-FormattedMessage -Message "$($MyInvocation.MyCommand) Finished execution")
}
