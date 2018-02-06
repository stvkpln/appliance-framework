Function New-vRealizeNetworkInsightAppliance {
	<#
		.Synopsis
			Deploy a new vRealize Network Insight Platform or Proxy virtual appliance

		.Description
			Deploys a vRealize Network Insight appliance from a specified OVA/OVF file. This function covers the deployment of either a Platform or Proxy appliance.

		.Parameter OVFPath
			Specifies the path to the OVF or OVA package that you want to deploy the appliance from.

		.Parameter Type
			Specifies whether the virtual appliance being provisioned is a Platform or Proxy.

		.Parameter DeploymentSize
			The appliance hardware configuration / specification to use for provisioning of the virtual appliance. The following details the configuration for each type of appliance:

			- Medium:
				* Platform: 8 vCPU, 32GB RAM
				* Proxy: 4 vCPU, 10GB RAM

			- Large:
				* Platform: 12 vCPU, 48GB RAM **Recommended for multi-node cluster configurations**
				* Proxy: 6 vCPU, 12GB RAM

		.Parameter Name
			Specifies a name for the imported appliance.

		.Parameter AllowHealthTelemetry
			 Specifies whether to allow Health Telemetry to VMware (not CEIP). By default, this is disabled and is only enabled if this switch is provided.

			 Health telemetry provides VMware with product performance data that enables VMware to improve its products and services, to fix problems and to advise you on how best to deploy and use our products. Note: the health telemetry data we collect is different than the CEIP that VMware collects. CEIP data is the subject of a separate disclosure.

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

		.Parameter IPAddress
			The IP address for the imported appliance.

		.Parameter SubnetMask
			The netmask or prefix for the imported appliance. The default value, if left blank, will be "255.255.255.0"

		.Parameter Gateway
			The default gateway address for the imported appliance. If a value is not provided, and the subnet mask is a standard Class C address, the default gateway value will be configured as x.x.x.1 of the provided network.

		.Parameter DnsServers
			The domain name servers for the imported appliance. Leave blank if DHCP is desired. WARNING: Do not specify more than two DNS entries or no DNS entries will be configured!

		.Parameter Domain
			The domain name server domain for the imported appliance. Note this option only works if DNS is specified above.

		.Parameter FQDN
			The hostname or the fully qualified domain name for the deployed appliance.

		.Parameter ValidateDns
			Specifies whether to perform DNS resolution validation of the networking information. If set to true, lookups for both forward (A) and reverse (PTR) records will be confirmed to match.

		.Parameter NTPServers
			The Network Time Protocol (NTP) servers to define for the imported appliance. Default NTP Servers to be used if none are specified are: 0.north-america.pool.ntp.org, 1.north-america.pool.ntp.org.

		.Parameter ProxyIP
			The fully qualified domain name (FQDN) or IP address of the internet-facing proxy server.

		.Parameter ProxyPort
			The listening port of the internet-facing proxy server.

		.Parameter ProxySharedSecret
			The shared secret generated on the platform on the onboarding page. This is only applicable to proxy appliances.

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
				OVFPath = "c:\temp\vrealize-network-insight-platform.ova"
				Type = "Platform"
				DeploymentSie = "medium"
				Name = "vRNI1"
				AllowHealthTelemetry = $true
				VMHost = (Get-VMHost -Name "host1.example.com")
				InventoryLocation = (Get-Folder -Type VM -Name "Appliances")
				Network = "admin-network"
				IPAddress = "10.10.10.11" 
				SubnetMask = "255.255.255.0" 
				Gateway = "10.10.10.1"
				Domain = "example.com"
				DnsServers = @("10.10.1.11","10.10.1.12")
				ValidateDns = $true
				NTPServers = 
				ProxyIP = "10.10.5.12"
				ProxyPort = "8080"
				PowerOn = $true
				Verbose = $true
			}

			New-vRealizeNetworkInsightAppliance @config

			Description
			-----------
			Deploy the vRealize Network Insight Platform appliance with static IP settings and power it on after the import finishes. 
			In this example, the Verbose flag is being passed, so all OVF properties will be shown as part of the output

		.Example
			Connect-VIServer vCenter.example.com
			
			$config = @{
				OVFPath = "c:\temp\vrealize-network-insight-proxy.ova"
				Type = "Proxy"
				DeploymentSie = "medium"
				Name = "vRNI2"
				AllowHealthTelemetry = $true
				VMHost = (Get-VMHost -Name "host1.example.com")
				InventoryLocation = (Get-Folder -Type VM -Name "Appliances")
				Network = "admin-network"
				IPAddress = "10.10.10.12" 
				SubnetMask = "255.255.255.0" 
				Gateway = "10.10.10.1"
				Domain = "example.com"
				DnsServers = @("10.10.1.11","10.10.1.12")
				ValidateDns = $true
				NTPServers = 
				ProxyIP = "10.10.5.12"
				ProxyPort = "8080"
				PowerOn = $true
				Verbose = $true
			}

			New-vRealizeNetworkInsightAppliance @config

			Description
			-----------
			Deploy the vRealize Network Insight Proxy appliance with static IP settings and power it on after the import finishes. 
			In this example, the Verbose flag is being passed, so all OVF properties will be shown as part of the output
	#>
	[CmdletBinding(SupportsShouldProcess=$true,DefaultParameterSetName="Platform")]
	[OutputType('VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine')]
	Param (
		[Alias("OVA", "OVF")]
		[Parameter(Mandatory=$true,ParameterSetName="Platform")]
		[Parameter(Mandatory=$true,ParameterSetName="Proxy")]
		[ValidateScript( { Confirm-FileExtension -File $_ } )]
		[System.IO.FileInfo]$OVFPath,

		[Parameter(Mandatory=$true,ParameterSetName="Platform")]
		[Parameter(Mandatory=$true,ParameterSetName="Proxy")]
		[ValidateSet("Platform", "Proxy")]
		[String]$Type,

		[Alias("Size", "DeploymentType")]
		[Parameter(Mandatory=$true,ParameterSetName="Platform")]
		[Parameter(Mandatory=$true,ParameterSetName="Proxy")]
		[ValidateSet("medium", "large")]
		[String]$DeploymentSize = "medium",

		[Parameter(Mandatory=$true,ParameterSetName="Platform")]
		[Parameter(Mandatory=$true,ParameterSetName="Proxy")]
		[ValidateNotNullOrEmpty()]
		[String]$Name,

		[Parameter(ParameterSetName="Platform")]
		[Parameter(ParameterSetName="Proxy")]
		[Switch]$AllowHealthTelemetry,

		# Infrastructure Parameters
		[Parameter(ParameterSetName="Platform")]
		[Parameter(ParameterSetName="Proxy")]
		[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]$VMHost,

		[Parameter(ParameterSetName="Platform")]
		[Parameter(ParameterSetName="Proxy")]
		[VMware.VimAutomation.ViCore.Types.V1.Inventory.Folder]$InventoryLocation,

		[Parameter(ParameterSetName="Platform")]
		[Parameter(ParameterSetName="Proxy")]
		[VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]$Location,

		[Parameter(ParameterSetName="Platform")]
		[Parameter(ParameterSetName="Proxy")]
		[VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.Datastore]$Datastore,

		[Parameter(Mandatory=$true,ParameterSetName="Platform")]
		[Parameter(Mandatory=$true,ParameterSetName="Proxy")]
		[ValidateSet("Thick", "Thick2GB", "Thin", "Thin2GB", "EagerZeroedThick")]
		[String]$DiskFormat = "Thin",

		# Networking
		[Parameter(Mandatory=$true,ParameterSetName="Platform")]
		[Parameter(Mandatory=$true,ParameterSetName="Proxy")]
		[String]$Network,

		[Parameter(Mandatory=$true,ParameterSetName="Platform")]
		[Parameter(Mandatory=$true,ParameterSetName="Proxy")]
		[ValidateScript( {$_ -match [IPAddress]$_ })]
		[String]$IPAddress,

		[Parameter(ParameterSetName="Platform")]
		[Parameter(ParameterSetName="Proxy")]
		[String]$SubnetMask = "255.255.255.0",

		[Parameter(ParameterSetName="Platform")]
		[Parameter(ParameterSetName="Proxy")]
		[ValidateScript( {$_ -match [IPAddress]$_ })]
		[String]$Gateway,

		[Parameter(Mandatory=$true,ParameterSetName="Platform")]
		[Parameter(Mandatory=$true,ParameterSetName="Proxy")]
		[ValidateCount(1,2)]
		[ValidateScript( {$_ -match [IPAddress]$_ })]
		[String[]]$DnsServers,

		[Parameter(ParameterSetName="Platform")]
		[Parameter(ParameterSetName="Proxy")]
		[String]$Domain,

		[Parameter(ParameterSetName="Platform")]
		[Parameter(ParameterSetName="Proxy")]
		[bool]$ValidateDns = $true,

		[Parameter(ParameterSetName="Platform")]
		[Parameter(ParameterSetName="Proxy")]
		[ValidateCount(1, 4)]
		[String[]]$NTPServers = @("0.north-america.pool.ntp.org", "1.north-america.pool.ntp.org"),

		# Proxy Values
		[Parameter(ParameterSetName="Platform")]
		[Parameter(ParameterSetName="Proxy")]
		[ValidateScript( {$_ -match [IPAddress]$_ })]
		[String]$ProxyIP,
		
		[Parameter(ParameterSetName="Platform")]
		[Parameter(ParameterSetName="Proxy")]
		[String]$ProxyPort,
		
		[Parameter(Mandatory=$true,ParameterSetName="Proxy")]
		[String]$ProxySharedSecret,

		# Lifecycle Parameters
		[Parameter(ParameterSetName="Platform")]
		[Parameter(ParameterSetName="Proxy")]
		[VMware.VimAutomation.ViCore.Types.V1.Tagging.Tag[]]$Tags,

		[Parameter(ParameterSetName="Platform")]
		[Parameter(ParameterSetName="Proxy")]
		[Switch]$PowerOn,

		[Parameter(ParameterSetName="Platform")]
		[Parameter(ParameterSetName="Proxy")]
		[Switch]$AllowClobber = $false
	)

	Function New-Configuration {
		# Setting the name of the function and invoking opening verbose logging message
		Write-Verbose -Message (Get-FormattedMessage -Message "$($MyInvocation.MyCommand) Started execution")

		$Status = "Configuring Appliance Values"
		Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Extracting OVF Template"
		$ovfconfig = Get-OvfConfiguration -OvF $OVFPath.FullName
		if ($ovfconfig) {
			# Setting Basics Up
			Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Configuring Basic Values"
			$ovfconfig.DeploymentOption.value = $DeploymentSize.toLower(); # Value for the deployment size
			if ($AllowHealthTelemetry) { $ovfconfig.Common.Health_Telemetry_Push.value = $true } # Enabling if the Health Telemetry switch is passed in

			# Setting Networking Values
			Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Assigning Networking Values"

			# Network Backing; the code property seems to change with each release, so making this particular bit dynamic
			$NetworkMapping = (Get-Member -InputObject $ovfconfig.NetworkMapping -MemberType "CodeProperty").Name
			$ovfconfig.NetworkMapping.$NetworkMapping.value = $Network

			# IP Networking
			$ovfconfig.Common.IP_Address.value = $IPAddress
			$ovfconfig.Common.Netmask.value = $SubnetMask
			$ovfconfig.Common.Default_Gateway.value = $Gateway
			$ovfconfig.Common.DNS.value = $DnsServers -join ","
			$ovfconfig.Common.Domain_Search.value = 
			$ovfconfig.Common.NTP.value = $NTPServers -join ","
			$ovfconfig.Common.Web_Proxy_IP.value = $ProxyIP
			$ovfconfig.Common.Web_Proxy_Port.value = $ProxyPort
			if ($Type -eq "Proxy") { $ovfconfig.Common.Proxy_Shared_Secret.value = $ProxySharedSecret }

			# Verbose logging passthrough
			Write-OVFValues -ovfconfig $ovfconfig -Type "Verbose" -Verbose:$VerbosePreference

			# Returning the OVF Configuration to the function
			$ovfconfig
		}

		else { throw "$($invalidFile) $($OVFPath)" }

		# Verbose logging output to finish things off
		Write-Verbose -Message (Get-FormattedMessage -Message "$($MyInvocation.MyCommand) Finished execution")
	}

	# Workflow to provision the NSX-V Virtual Appliance
	try {
		$Activity = "Deploying a new vRealize Network Insight appliance"
		
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
		Write-Host $FQDN
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
New-Alias -Value New-vRealizeNetworkInsightAppliance -Name New-vRNI
#New-Alias -Value "New-vRealizeNetworkInsightAppliance -Type Platform" -Name New-vRNIPlatform
#New-Alias -Value "New-vRealizeNetworkInsightAppliance -Type Proxy" -Name New-vRNIProxy
#Export-ModuleMember -Function New-vRealizeNetworkInsightAppliance -Alias @("New-VRNI","New-vRNIPlatform","New-vRNIProxy")
Export-ModuleMember -Function New-vRealizeNetworkInsightAppliance -Alias @("New-VRNI")
