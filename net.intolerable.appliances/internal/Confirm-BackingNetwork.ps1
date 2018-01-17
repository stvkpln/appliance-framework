<#
	.Description
		Confirms the specified portgroup name exists on the ESXi host. This will check for both a distributed (first) and standard (second) portgroup
#>

Function Confirm-BackingNetwork {
    [CmdletBinding()]
    param(
        [string]$Network,
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]$VMHost
    )

    Process {
        # Validating port group exists
        $Status = "Confirming backing network availability"
        Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Checking vSphere Distributed Portgroups"
        Try {
            $vdswitches = Get-VDSwitch -VMHost $VMHost -ErrorAction SilentlyContinue > $null
            if ($vdswitches) { $vdportgroup = Get-VDPortgroup -Name $Network -VDSwitch $vdswitches > $null}
            if (!$vdportgroup) { Get-VirtualPortGroup -Name $Network -VMHost $VMHost -ErrorAction Stop > $null }
        }
        Catch {
            throw "Network name '$($Network)' not found, check and confirm that this portgroup exists on the connected vCenter Server"
        }
    }
}
