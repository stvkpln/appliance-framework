<#
	.Description
		Wrapper function to invoke the OVA/OVF import. A hashtable will be generated with all of the required parameters and then invoked.
		If the 'PowerOn' flag is provided, the imported appliance will be powered on
#>
Function Import-Appliance {
	# Defining Execution Parameters to pass into Import-VApp
	$import_params = @{
		DiskStorageFormat = $DiskFormat
		Name = $Name 
		OvfConfiguration = $ovfconfig
		Source = $OVFPath.FullName
		VMHost = $VMHost
	}
	
	# All of the below are optional
	if ($Datastore) { $import_params.add("Datastore",$Datastore) } 
	if ($InventoryLocation) { $import_params.add("InventoryLocation",$InventoryLocation) }
	if ($Location) { $import_params.add("Location",$Location) }

	# Deploy the OVF/OVA with the config parameters
	Write-Progress -Activity $Activity
	$appliance = Import-VApp @import_params
	if ($PowerOn) { Start-VM -VM $appliance }
	else { Get-VM -Name $Name }
}