Function New-IdentityManagerAppliance {
	<#
		.Synopsis
			Deploy a new Identity Manager virtual appliance

		.Description
			Deploys an Identity Manager appliance from a specified OVA/OVF file

		.Parameter OVFPath
			Specifies the path to the OVF or OVA package that you want to deploy the appliance from.

		.Parameter Name
			Specifies a name for the imported appliance.

		.Parameter Timezone
			Configured timezone value. The following are valid options: "Africa/Cairo", "America/Argentina/Buenos_Aires", "America/Caracas", "America/Recife", "Asia/Baku", "Asia/Bangkok", "Asia/Calcutta", "Asia/Dacca", "Asia/Hong_Kong", "Asia/Karachi", "Asia/Tokyo", "Australia/Sydney", "Etc/GMT-1", "Etc/UTC", "Europe/London", "Europe/Moscow", "Europe/Paris", "Pacific/Fiji", "Pacific/Noumea", "Pacific/Samoa", "US/Alaska", "US/Central", "US/Eastern", "US/Hawaii", "US/Mountain", "US/Pacific"

		.Parameter EnableCEIP
			Specifies whether to enable VMware's Customer Experience Improvement Program ("CEIP"). The default will enable CEIP.

			VMware's Customer Experience Improvement Program ("CEIP") provides VMware with information that enables VMware to improve its products and services, to fix problems, and to advise you on how best to deploy and use our products.  As part of the CEIP, VMware collects technical information about your organization's use of VMware products and services on a regular basis in association with your organization's VMware license key(s). This information does not personally identify any individual. For additional information regarding the data collected through CEIP and the purposes for which it is used by VMware is set forth in the Trust & Assurance Center at http://www.vmware.com/trustvmware/ceip.html.

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

		.Parameter IPProtocol
			The IP Protocol to use for the deployed appliance. The available values are: "IPv4" or "IPv6".

		.Parameter DHCP
			Indicates that the provided network has DHCP and static IP entries should not be used. No network settings will be passed into the deployment configuration.

		.Parameter IPAddress
			The IP address for the imported appliance.

		.Parameter SubnetMask
			The netmask or prefix for the imported appliance. The default value, if left blank, will be "255.255.255.0"

		.Parameter Gateway
			The default gateway address for the imported appliance. If a value is not provided, and the subnet mask is a standard Class C address, the default gateway value will be configured as x.x.x.1 of the provided network.

		.Parameter DnsServers
			The domain name servers for the imported appliance. Leave blank if DHCP is desired. WARNING: Do not specify more than two DNS entries or no DNS entries will be configured!

		.Parameter DnsSearchPath
			The domain name server searchpath for the imported appliance.

		.Parameter Domain
			The domain name server domain for the imported appliance. Note this option only works if DNS is specified above.

		.Parameter FQDN
			The hostname or the fully qualified domain name for the deployed appliance.

		.Parameter ValidateDns
			Specifies whether to perform DNS resolution validation of the networking information. If set to true, lookups for both forward (A) and reverse (PTR) records will be confirmed to match.

		.Parameter Secure
			Specifies whether to apply virtual machine VMX advanced option hardening specifications once the import completes.

		.Parameter Tags
			Specifies the vSphere Tag(s) to apply to the imported virtual appliance.

		.Parameter PowerOn
			Specifies whether to power on the imported appliance once the import completes.

		.Parameter AllowClobber
			Indicates whether or not to replace an existing virtual machine, if discovered. The default behavior (set to 'False'), the function will fail with an error that there is an esisting virtual machine. If set to true, the discovered virtual machine will be stopped and removed permanently from the infrastructure *WITHOUT PROMPTING*. Use careuflly!

		.Notes
			Author: Steve Kaplan (steve@intolerable.net)
			Version History:
				- 1.0: Initial release

		.Example
			Connect-VIServer vCenter.example.com
			
			$config = @{
				OVFPath = "c:\temp\identity-manager.ova"
				Name = "vIDM1"
				VMHost = (Get-VMHost -Name "host1.example.com")
				InventoryLocation = (Get-Folder -Type VM -Name "Appliances")
				Network = "admin-network"
				IPAddress = "10.10.10.31" 
				SubnetMask = "255.255.255.0" 
				Gateway = "10.10.10.1"
				Domain = "example.com"
				DnsServers = @("10.10.1.11","10.10.1.12")
				ValidateDns = $true
				PowerOn = $true
				Verbose = $true
			}

			New-IdentityManagerAppliance @config

			Description
			-----------
			Deploy the Identity Manager appliance with static IP settings and power it on after the import finishes. 
			In this example, the Verbose flag is being passed, so all OVF properties will be shown as part of the output

		.Example
			Connect-VIServer vCenter.example.com
			
			$config = @{
				OVFPath = "c:\temp\identity-manager.ova"
				Name = "vIDM1"
				VMHost = (Get-VMHost -Name "host1.example.com")
				InventoryLocation = (Get-Folder -Type VM -Name "Applianceas")
				Network = "admin-network"
				DHCP = $true
				PowerOn = $false
			}

			New-IdentityManagerAppliance @config

			Description
			-----------
			Deploy the Identity Manager appliance with DHCP settings and and do not power it on after the import finishes
	#>
    [CmdletBinding(SupportsShouldProcess = $true,DefaultParameterSetName = "Static")]
	[OutputType('VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine')]
	Param (
		[Parameter(Mandatory=$true,ParameterSetName="Static")]
		[Parameter(Mandatory=$true,ParameterSetName="DHCP")]
		[ValidateScript( { Confirm-FileExtension -File $_ } )]
		[System.IO.FileInfo]$OVFPath,

		[Parameter(Mandatory=$true,ParameterSetName="Static")]
		[Parameter(Mandatory=$true,ParameterSetName="DHCP")]
		[ValidateNotNullOrEmpty()]
		[String]$Name,

		[Parameter(ParameterSetName="DHCP")]
		[Parameter(ParameterSetName="Static")]
		[bool]$EnableCEIP = $true,

		[Parameter(ParameterSetName="DHCP")]
		[Parameter(ParameterSetName="Static")]
        [ValidateSet("Africa/Cairo", "America/Argentina/Buenos_Aires", "America/Caracas", "America/Recife", "Asia/Baku", "Asia/Bangkok", "Asia/Calcutta", "Asia/Dacca", "Asia/Hong_Kong", "Asia/Karachi", "Asia/Tokyo", "Australia/Sydney", "Etc/GMT-1", "Etc/UTC", "Europe/London", "Europe/Moscow", "Europe/Paris", "Pacific/Fiji", "Pacific/Noumea", "Pacific/Samoa", "US/Alaska", "US/Central", "US/Eastern", "US/Hawaii", "US/Mountain","US/Pacific")]
        [string]$Timezone = "Etc/UTC",

		# Infrastructure Parameters
		[Parameter(ParameterSetName="Static")]
		[Parameter(ParameterSetName="DHCP")]
		[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]$VMHost,

		[Parameter(ParameterSetName="Static")]
		[Parameter(ParameterSetName="DHCP")]
		[VMware.VimAutomation.ViCore.Types.V1.Inventory.Folder]$InventoryLocation,

		[Parameter(ParameterSetName="Static")]
		[Parameter(ParameterSetName="DHCP")]
		[VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]$Location,

		[Parameter(ParameterSetName="Static")]
		[Parameter(ParameterSetName="DHCP")]
		[VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.Datastore]$Datastore,

		[Parameter(ParameterSetName="Static")]
		[Parameter(ParameterSetName="DHCP")]
		[ValidateSet("Thick","Thick2GB","Thin","Thin2GB","EagerZeroedThick")]
		[String]$DiskFormat = "thin",

		# Networking
		[Parameter(Mandatory=$true,ParameterSetName="DHCP")]
		[Parameter(Mandatory=$true,ParameterSetName="Static")]
		[String]$Network,

		[Parameter(ParameterSetName="Static")]
		[Parameter(ParameterSetName="DHCP")]
		[ValidateSet("IPv4","IPv6")]
		[String]$IPProtocol = "IPv4",

		[Parameter(ParameterSetName="DHCP")]
		[Switch]$DHCP,

		[Parameter(Mandatory=$true,ParameterSetName="Static")]
		[ValidateScript( {$_ -match [IPAddress]$_ })]
		[String]$IPAddress,

		[Parameter(ParameterSetName="Static")]
		[String]$SubnetMask = "255.255.255.0",

		[Parameter(ParameterSetName="Static")]
		[ValidateScript( {$_ -match [IPAddress]$_ })]
		[String]$Gateway,

		[Parameter(Mandatory=$true,ParameterSetName="Static")]
		[ValidateCount(1,2)]
		[ValidateScript( {$_ -match [IPAddress]$_ })]
		[String[]]$DnsServers,

		[Parameter(ParameterSetName="Static")]
		[ValidateCount(1,4)]
		[String[]]$DnsSearchPath,

		[Parameter(ParameterSetName="Static")]
		[String]$Domain,

		[Parameter(ParameterSetName="Static")]
		[String]$FQDN,

		[Parameter(ParameterSetName="Static")]
		[bool]$ValidateDns = $true,

		# Lifecycle Parameters
		[Parameter(ParameterSetName="Static")]
		[Parameter(ParameterSetName="DHCP")]
		[VMware.VimAutomation.ViCore.Types.V1.Tagging.Tag[]]$Tags,

		[Parameter(ParameterSetName="Static")]
		[Parameter(ParameterSetName="DHCP")]
		[Switch]$PowerOn,

		[Parameter(ParameterSetName="Static")]
		[Parameter(ParameterSetName="DHCP")]
		[Switch]$AllowClobber = $false
	)

	Function New-Configuration {

		# Setting the name of the function and invoking opening verbose logging message
		Write-Verbose -Message (Get-FormattedMessage -Message "$($MyInvocation.MyCommand) Started execution")
		
		$Status = "Configuring Appliance Values"
		Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Extracting OVF Template"
		$ovfconfig = Get-OvfConfiguration -OvF $OVFPath.FullName
		if ($ovfconfig) {
			$ApplianceType = (Get-Member -InputObject $ovfconfig.vami -MemberType "CodeProperty").Name

            # Setting Basics Up
			Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Configuring Basic Values"
			$ovfconfig.Common.ceip.enabled.Value = $EnableCEIP
			$ovfconfig.Common.vamitimezone.Value = $Timezone
			
			# Setting Networking Values
			Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Assigning Networking Values"
			$ovfconfig.IpAssignment.IpProtocol.Value = $IPProtocol # IP Protocol Value
			$ovfconfig.NetworkMapping.Network_1.Value = $Network; # vSphere Portgroup Network Mapping

			if ($PsCmdlet.ParameterSetName -eq "Static") {
                $ovfconfig.common.vami.hostname.Value = $FQDN
				$ovfconfig.vami.$ApplianceType.ip0.Value = $IPAddress
				$ovfconfig.vami.$ApplianceType.netmask0.Value = $SubnetMask
				$ovfconfig.vami.$ApplianceType.gateway.Value = $Gateway
				$ovfconfig.vami.$ApplianceType.DNS.Value = $DnsServers -join ","
				if ($DnsSearchPath) { $ovfconfig.vami.$ApplianceType.searchpath.Value = $DnsSearchPath -join "," }
				if ($Domain) { $ovfconfig.vami.$ApplianceType.domain.Value = $Domain }
            }

            # Verbose logging passthrough
            Write-OVFValues -ovfconfig $ovfconfig -Type "Verbose" -Verbose:$VerbosePreference

			# Returning the OVF Configuration to the function
			$ovfconfig
		}

		else { throw "$($invalidFile) $($OVFPath)" }

		# Verbose logging output to finish things off
		Write-Verbose -Message (Get-FormattedMessage -Message "$($MyInvocation.MyCommand) Finished execution")
	}

	try {
		$Activity = "Deploying a new Identity Manager Appliance"

        # Checking whether a virtual machine already exists in the infrastructure
        Confirm-VM -Name $Name -AllowClobber $AllowClobber -Activity $Activity -Verbose:$VerbosePreference

        # Validating / Setting Import Location
        $ImportValidation = @{ Activity = $Activity; Verbose = $VerbosePreference }
        if ($VMHost) { $ImportValidation.VMHost = $VMHost }
        if ($Location) { $ImportValidation.Location = $Location }
        $VMHost = Confirm-VMHost @ImportValidation

        # Confirming that the requested network name exists and resides on the host that will be used for import
        Confirm-BackingNetwork -Network $Network -VMHost $VMHost -Activity $Activity -Verbose:$VerbosePreference
		
		# Confirming / Setting Default Gateway
		$GatewayParams = @{
			IPAddress = $IPAddress
			FourthOctet = $FourthOctet
			SubnetMask = $SubnetMask
			Gateway = $Gateway
			Activity = $Activity
			Verbose = $VerbosePreference
		}
		$Gateway = Set-DefaultGateway @GatewayParams

		# What to do if a static IP is provided
		if ($PsCmdlet.ParameterSetName -eq "Static") {
			# Adding all of the required parameters to validate DNS things
			$validate = @{
				Name       = $Name
				Domain     = $Domain
				IPAddress  = $IPAddress
				DnsServers = $DnsServers
				FQDN       = $FQDN
				ValidateDns = $ValidateDns
				Activity = $Activity
				Verbose    = $VerbosePreference
			}

			# Confirming DNS Settings
			$FQDN = Confirm-DNS @validate
		}

		# Configuring the OVF Template and deploying the appliance
		$ovfconfig = New-Configuration
		if ($ovfconfig) {
			if ($PsCmdlet.ShouldProcess($OVFPath.FullName, "Import-Appliance")) {
				$AppliancePayload = @{
					OVFPath = $OVFPath.FullName
					ovfconfig = $ovfconfig
					Name = $Name
					VMHost = $VMHost
					InventoryLocation = $InventoryLocation
					Location = $Location
					Datastore = $Datastore
					DiskStorageFormat = $DiskFormat
					Tags = $Tags
                    Activity = $Activity
					Verbose = $VerbosePreference
				}
				Import-Appliance @AppliancePayload
			}
			
			else { 
				# Logging out the OVF Configuration values if -WhatIf is invoked
				if ($VerbosePreference -eq "SilentlyContinue") { Write-OVFValues -ovfconfig $ovfconfig -Type "Standard" }
			}
		}

		else { throw $noOvfConfiguration }
	}

	catch { Write-Error $_ }
}

# Adding aliases and exporting this funtion when the module gets loaded
New-Alias -Value New-IdentityManagerAppliance -Name New-vIDM
Export-ModuleMember -Function New-IdentityManagerAppliance -Alias @("New-vIDM")
