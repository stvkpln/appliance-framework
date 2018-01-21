<#
	.Description
		Wrapper function to invoke the OVA/OVF import. A hashtable will be generated with all of the required parameters and then invoked.
		If the 'PowerOn' flag is provided, the imported appliance will be powered on
#>
Function Import-Appliance {
	param(
		[String]$OVFPath,
		[VMware.VimAutomation.ViCore.Types.V1.Ovf.OvfConfiguration]$ovfconfig,
		[string]$Name,
		[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]$VMHost,
		[VMware.VimAutomation.ViCore.Types.V1.Inventory.Folder]$InventoryLocation,
		[VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]$Location,
		[VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.Datastore]$Datastore,
		[string]$DiskFormat
	)

	# Defining Execution Parameters to pass into Import-VApp
	$import_params = @{
		Source = $OVFPath
		OvfConfiguration = $ovfconfig
		Name = $Name
		VMHost = $VMHost
		DiskStorageFormat = $DiskFormat
	}
	# Setting the name of the function and invoking opening verbose logging message
	Write-Verbose -Message (Get-FormattedMessage -Message "$($MyInvocation.MyCommand) Started execution")

	# All of the below are optional
	if ($Datastore) { $import_params.add("Datastore",$Datastore) } 
	if ($InventoryLocation) { $import_params.add("InventoryLocation",$InventoryLocation) }
	if ($Location) { $import_params.add("Location",$Location) }

	# Deploy the OVF/OVA with the config parameters
	Write-Progress -Activity $Activity
	$appliance = Import-VApp @import_params
	if ($PowerOn) { Start-VM -VM $appliance }
	else { Get-VM -Name $Name }

	# Verbose logging output to finish things off
	Write-Verbose -Message (Get-FormattedMessage -Message "$($MyInvocation.MyCommand) Finished execution")
}
