Function Confirm-VM {
    [CmdletBinding(SupportsShouldProcess = $true)]
	Param (
		[string]$Name,
		[bool]$AllowClobber
	)

	# Setting the name of the function and invoking opening verbose logging message
	Write-Verbose -Message (Get-FormattedMessage -Message "$($MyInvocation.MyCommand) Started execution")

#	if ($AllowClobber -eq $true) { Write-Warning -Message (Get-FormattedMessage) "The 'AllowClobber' parameter has been set to 'True'. If a virtual machine with the requested name is discovered, it will automatically be destroyed." }

	# Checking whether there is a virtual machine with this name in the inventory of all currently connected vCenter servers
	$vm = Get-VM -Name $Name -ErrorAction SilentlyContinue

	# Checking behavior if there is already a virtual machine in the inventory....
	if ($vm) {
		switch ($AllowClobber) {
			$false { 
				throw "There is already a VM with the name $($Name). To overwrite, set the AllowClobber parameter to $true and retry" 
				break
			}
			
			$true {
				if ($PSCmdlet.ShouldProcess($Name, "Remove-VM")) {
					Write-Warning -Message "A virtual machine matching the name $($Name) was discovered; it will now be stopped and removed from the infrastructure."
					if ($vm.PowerState -eq "PoweredOn") { Stop-VM -VM $vm -Confirm:$false > $null }
					Remove-VM -VM $vm -DeletePermanently -Confirm:$false
				}
				break
			}
		}
	}

	# Verbose logging output to finish things off
	Write-Verbose -Message (Get-FormattedMessage -Message "$($MyInvocation.MyCommand) Finished execution")
}
