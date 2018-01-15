<#
	.Description
		Confirms the specified portgroup name exists on the ESXi host. This will check for both a distributed (first) and standard (second) portgroup
#>

Function Confirm-BackingNetwork {
	[CmdletBinding()]
    param(
        [string]$Network
    )

    Process{
    	# Validating port group exists
    	$Status = "Confirming backing network availability"
    	Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Checking vSphere Distributed Portgroups"

        Try{
            Get-VirtualPortGroup -Name $Network -VMHost $VMHost -ErrorAction Stop
        }
        Catch{
    	    throw "Network name '$($network)' not found, check and confirm that this portgroup exists on the connected vCenter Server"
        }
    }
}
