Function New-PhotonOSAppliance {
	<#
		.Synopsis
			Deploy a new Photon OS virtual appliance

		.Description
			Deploys an Photon OS appliance from a specified OVA/OVF file

		.Parameter OVFPath
			Specifies the path to the OVF or OVA package that you want to deploy the appliance from.

		.Parameter Name
			Specifies a name for the imported appliance.

		.Parameter VMHost
			Specifies a host where you want to run the appliance.

		.Parameter InventoryLocation
			Specifies a datacenter or a virtual machine folder where you want to place the new appliance. This folder serves as a logical container for inventory organization. The Location parameter serves as a compute resource that powers the imported vApp.

		.Parameter Location
			Specifies a vSphere inventory container where you want to import the deployed appliance. It must be a vApp, a resource pool, or a cluster.

		.Parameter Datastore
			Specifies a datastore or a datastore cluster where you want to store the imported appliance.

		.Parameter DiskFormat
			Specifies the storage format for the disks of the imported appliance. By default, the storage format is thick. When you set this parameter, you set the storage format for all virtual machine disks in the OVF package. This parameter accepts Thin, Thick, and EagerZeroedThick values. The default option will be Thin.

		.Parameter Network
			The name of the virtual portgroup to place the imported appliance. The portgroup can be either a standard or distributed virtual portgroup.

		.Parameter PowerOn
			Specifies whether to power on the imported appliance once the import completes.

		.Parameter NoClobber
			Indicates that the function will not remove and replace an existing virtual machine. By default, if a virtual machine with the specifies name exists, the function will fail. If setting this value to 'False', the existing virtual machine will be stopped and removed from the infrastructure permanently.

		.Notes
			Author: Steve Kaplan (steve@intolerable.net)
			Version History:
				- 1.0: Initial release

		.Example
			Connect-VIServer vCenter.example.com
			
			$config = @{
				OVFPath = "c:\temp\photon-os.ova"
				Name = "PhotonOS1"
				VMHost = (Get-VMHost -Name "host1.example.com")
				InventoryLocation = (Get-Folder -Type VM -Name "Appliances")
				Network = "admin-network"
				PowerOn = $true
			}
			
			New-PhotonOSAppliance @config

			Description
			-----------
			Deploy the Photon OS appliance and power it on after the import finishes
	#>
	[CmdletBinding(SupportsShouldProcess=$true)]
	[OutputType('VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine')]
	Param (
		[Parameter(Mandatory=$true)]
		[ValidateScript( { Confirm-FilePath $_ } )]
		[System.IO.FileInfo]$OVFPath,

		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[String]$Name,

		# Infrastructure Parameters
		[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]$VMHost,
		[VMware.VimAutomation.ViCore.Types.V1.Inventory.Folder]$InventoryLocation,
		[VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]$Location,
		[VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.Datastore]$Datastore,

		[ValidateSet("Thick","Thick2GB","Thin","Thin2GB","EagerZeroedThick")]
		[String]$DiskFormat = "thin",

		# Networking
		[Parameter(Mandatory=$true)]
		[String]$Network,

		# Lifecycle Parameters
		[Switch]$PowerOn,
		[Switch]$NoClobber = $true
	)

	Function New-Configuration () {
		$Status = "Configuring Appliance Values"
		Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Extracting OVF Template"
		$ovfconfig = Get-OvfConfiguration -OvF $OVFPath.FullName
		if ($ovfconfig) {

			# Setting Networking Values
			Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Assigning Networking Values"
			$ovfconfig.NetworkMapping.None.value = $Network; # vSphere Portgroup Network Mapping

			# Verbose logging passthrough
            Write-OVFValues -ovfconfig $ovfconfig -Type "Verbose" -Verbose:$VerbosePreference
			
			# Returning the OVF Configuration to the function
			$ovfconfig
		}

		else { throw "The provided file '$($OVFPath)' is not a valid OVA/OVF; please check the path/file and try again" }
	}

	try {
		$Activity = "Deploying a new Photon OS Appliance"

		# Validating Components
        Confirm-VM -NoClobber $NoClobber
        $VMHost = Confirm-VMHost -VMHost $VMHost -Location $Location -Verbose:$VerbosePreference
        Confirm-BackingNetwork -Network $Network -VMHost $VMHost -Verbose:$VerbosePreference

		# Configuring the OVF Template and deploying the appliance
        $ovfconfig = New-Configuration -Verbose:$VerbosePreference
		if ($ovfconfig) {
			if ($PsCmdlet.ShouldProcess($OVFPath.FullName, "Import-Appliance")) { Import-Appliance -Verbose:$VerbosePreference }
			else { 
				if ($VerbosePreference -eq "SilentlyContinue") { Write-OVFValues -ovfconfig $ovfconfig -Type "Standard" }
			}
		}
		else { throw $noOvfConfiguration }
	}

	catch { Write-Error $_ }
}

# Adding aliases and exporting this funtion when the module gets loaded
New-Alias -Value New-PhotonOSAppliance -Name New-PhotonOS
Export-ModuleMember -Function New-PhotonOSAppliance -Alias @("New-PhotonOS")