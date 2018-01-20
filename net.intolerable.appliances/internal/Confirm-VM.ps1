Function Confirm-VM {
	Param (
		[string]$Name,
		[bool]$NoClobber
	)
	
	if ($NoClobber -eq $false) { Write-Verbose -Message "The 'NoClobber' parameter was set to 'False'. If a virtual machine with the requested name is discovered, it will automatically be destroyed." }
	
	# Finding the virtual machine
	$vm = Get-VM -Name $Name -ErrorAction SilentlyContinue
	
	# Checking the behavior
	if($vm -and $NoClobber -eq $true) { throw "There is already a VM with the name $($Name). To overwrite, set the NoClobber parameter to $false and retry" }
	elseif($vm -and $NoClobber -eq $false) {
		if ($PSCmdlet.ShouldProcess($Name, "Remove-VM")) { 
			Write-Warning -Message "A virtual machine matching the name #($Name) was discovered; it will now be stopped and removed from the infrastructure."
			if ($vm.PowerState -eq "PoweredOn") { Stop-VM -VM $vm -Confirm:$false > $null }
			Remove-VM -VM $vm -DeletePermanently -Confirm:$false
		}
	}
}