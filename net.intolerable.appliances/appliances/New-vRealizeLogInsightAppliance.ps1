Function New-vRealizeLogInsightAppliance {
	<#
		.Synopsis
			Deploy a new vRealize Log Insight virtual appliance

		.Description
			Deploys a vRealize Log Insight virtual appliance from a specified OVA/OVF file

		.Parameter OVFPath
			Specifies the path to the OVF or OVA package that you want to deploy the appliance from.

		.Parameter DeploymentSize
			The appliance hardware configuration / specification to use for provisioning of the virtual appliance. For clustered configurations, it is highly recommended to use either "medium" or "large" as the value;. The default for this function will be "medium". Available size specifications are: 
				- Extra Small (xsmall): This configuration is intended for proof-of-concept or test environments and should not be used in a production environment. This configuration supports up to 20 ESXi hosts (~200 events/second or ~3GB/day) and requires the following:
					* 2 CPUs (minimum 2.0GHz)
					* 4GB RAM
					* 132GB of storage (100GB for event storage) - thick provisioned, eager zeroed highly recommended

				- Small: This configuration supports up to 200 ESXi hosts (~2,000 events/second or ~30GB/day) and requires the following:
					* 4 CPU (minimum 2.0GHz)
					* 8GB RAM
					* 510GB of storage (490GB for event storage) - thick provisioned, eager zeroed highly recommended

				- Medium: This configuration supports up to 500 ESXi hosts (~5,000 events/second or ~75GB/day) and requires the following:
					* 8 CPU (minimum 2.0GHz)
					* 16GB RAM
					* 510GB of storage (490GB for event storage) - thick provisioned, eager zeroed highly recommended

				- Large: This configuration requires vSphere 5.0 or greater, and will support up to 1,500 ESXi hosts (~15,000 events/second or ~225GB/day) and requires the following:
					* 16 CPU (minimum 2.0GHz)
					* 32GB RAM
					* 510GB of storage (490GB for event storage) - thick provisioned, eager zeroed highly recommended

		.Parameter Name
			Specifies a name for the imported appliance.

		.Parameter RootPassword
			A root password can be set if desired and will override any already set password. If not, but guest customization is running, then it will be randomly generated. Otherwise the password will be blank, and will be required to change in the console before using SSH. For security reasons, it is recommended to use a password that is a minimum of eight characters and contains a minimum of one upper, one lower, one digit, and one special character.

		.Parameter SSHKey
			An SSH Public Key can be set if desired, disabling password authentication. If blank during initial deployment, SSH will be configured per the Root Password option above. Entering a new SSH Public Key will append to (not override) the already configured Public Key(s).

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

		.Parameter DNSServers
			The domain name servers for the imported appliance. Leave blank if DHCP is desired. WARNING: Do not specify more than two DNS entries or no DNS entries will be configured!

		.Parameter DNSSearchPath
			The domain name server searchpath for the imported appliance.

		.Parameter Domain
			The domain name server domain for the imported appliance. Note this option only works if DNS is specified above.

		.Parameter FQDN
			The hostname or the fully qualified domain name for the deployed appliance.

		.Parameter ValidateDNSEntries
			Specifies whether to perform DNS resolution validation of the networking information. If set to true, lookups for both forward (A) and reverse (PTR) records will be confirmed to match.

		.Parameter PowerOn
			Specifies whether to power on the imported appliance once the import completes.

		.Notes
			Author: Steve Kaplan (steve@intolerable.net)

		.Example
	   		$ova = "c:\temp\vrealize-log-insight.ova"
			$dnsservers = @("10.10.1.11","10.10.1.12")
			Connect-VIServer vCenter.example.com
			$VMHost = Get-VMHost host1.example.com
			New-vRealizeLogInsightAppliance -OVFPath $ova -Name "LogInsight1" -VMHost $VMHost -Network "admin-network" -IPAddress "10.10.10.11" -SubnetMask "255.255.255.0" -Gateway "10.10.10.1" -DNSServers $dnsservers -Domain example.com -PowerOn

   			Description
   			-----------
			Deploy the vRealize Log Insight Appliance with static IP settings and power it on after the import finishes
	#>
	[CmdletBinding(DefaultParameterSetName="Static")]
	[OutputType('VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine')]
	Param (
		[Alias("OVA","OVF")]
		[Parameter(Mandatory=$true,ParameterSetName="DHCP")]
		[Parameter(Mandatory=$true,ParameterSetName="Static")]
		[ValidateScript( { Confirm-FilePath $_ } )][
		System.IO.FileInfo]$OVFPath,

		[Alias("Size","DeploymentType")]
		[Parameter(Mandatory=$true,ParameterSetName="DHCP")]
		[Parameter(Mandatory=$true,ParameterSetName="Static")]
		[ValidateSet("xsmall","small","medium","large")]
		[String]$DeploymentSize = "small",
		
		[Parameter(Mandatory=$true,ParameterSetName="DHCP")]
		[Parameter(Mandatory=$true,ParameterSetName="Static")]
		[ValidateNotNullOrEmpty()]
		[String]$Name,

		[Parameter(Mandatory=$true,ParameterSetName="DHCP")]
		[Parameter(Mandatory=$true,ParameterSetName="Static")]
		[ValidateNotNullOrEmpty()]
		[String]$RootPassword,
		
		[Parameter(ParameterSetName="DHCP")]
		[String]$SSHKey,

		# Infrastructure Parameters
		[Parameter(ParameterSetName="DHCP")]
		[Parameter(ParameterSetName="Static")]
		[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]$VMHost,

		[Parameter(ParameterSetName="DHCP")]
		[Parameter(ParameterSetName="Static")]
		[VMware.VimAutomation.ViCore.Types.V1.Inventory.Folder]$InventoryLocation,

		[Parameter(ParameterSetName="DHCP")]
		[Parameter(ParameterSetName="Static")]
		[VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]$Location,

		[Parameter(ParameterSetName="DHCP")]
		[Parameter(ParameterSetName="Static")]
		[VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.Datastore]$Datastore,

		[Parameter(ParameterSetName="DHCP")]
		[Parameter(ParameterSetName="Static")]
		[ValidateSet("Thick","Thick2GB","Thin","Thin2GB","EagerZeroedThick")]
		[String]$DiskFormat = "thin",

		# Networking
		[Parameter(Mandatory=$true,ParameterSetName="DHCP")]
		[Parameter(Mandatory=$true,ParameterSetName="Static")]
		[String]$Network,

		[Parameter(ParameterSetName="DHCP")]
		[Parameter(ParameterSetName="Static")]
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
		[String[]]$DNSServers,

		[Parameter(ParameterSetName="Static")]
		[ValidateCount(1,4)]
		[String[]]$DNSSearchPath,

		[Parameter(ParameterSetName="Static")]
		[String]$Domain,
		
		[Parameter(ParameterSetName="Static")]
		[String]$FQDN,

		[Parameter(ParameterSetName="Static")]
		[bool]$ValidateDNSEntries = $true,

		# Lifecycle Parameters
		[Parameter(ParameterSetName="DHCP")]
		[Parameter(ParameterSetName="Static")]
		[Switch]$PowerOn 
	)

	Function New-Configuration () {
		$Status = "Configuring Appliance Values"
		Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Extracting OVF Template"
		$ovfconfig = Get-OvfConfiguration -OvF $OVFPath.FullName
		if ($ovfconfig) {
			$ApplianceType = (Get-Member -InputObject $ovfconfig.vami -MemberType "CodeProperty").Name

			# Setting Basics Up
			Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Configuring Basic Values"
			$ovfconfig.DeploymentOption.value = $DeploymentSize.toLower(); # Value for the deployment size
			if ($RootPassword) { $ovfconfig.vm.rootpw.value = $RootPassword } # Setting the provided password for the root account
			if ($SSHKey) { $ovfconfig.vm.sshkey.value = $SSHKey } # Setting the provided SSH Public Key			

			# Setting Networking Values
			Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Assigning Networking Values"
			$ovfconfig.IpAssignment.IpProtocol.Value = $IPProtocol # IP Protocol Value
			$ovfconfig.NetworkMapping.Network_1.value = $Network; # vSphere Portgroup Network Mapping

			if ($PsCmdlet.ParameterSetName -eq "Static") {
				$ovfconfig.vami.$vami.ip0.value = $IPAddress
				$ovfconfig.vami.$vami.netmask0.value = $SubnetMask
				$ovfconfig.vami.$vami.gateway.value = $Gateway
				$ovfconfig.vami.$vami.hostname.value = $FQDN
				$ovfconfig.vami.$vami.DNS.value = $DNSServers -join ","
				if ($DNSSearchPath) { $ovfconfig.vami.$vami.searchpath.value = $DNSSearchPath -join "," }
				if ($Domain) { $ovfconfig.vami.$vami.domain.value = $Domain }
			}

			# Returning the OVF Configuration to the function
			$ovfconfig
		}
		
		else { throw "The provided file '$($OVFPath)' is not a valid OVA/OVF; please check the path/file and try again" }
	}

	# Workflow to provision the vRealize Log Insight Virtual Appliance
	try {
		$Activity = "Deploying a new vRealize Log Insight Appliance"
		
		# Validating Components
		$VMHost = Confirm-VMHost
		$Gateway = Set-DefaultGateway
		Confirm-BackingNetwork
		if (!$DHCP) { $FQDN = Confirm-DNS }

		# Configuring the OVF Template and deploying the appliance
		$ovfconfig = New-Configuration
		#if ($ovfconfig) { $ovfconfig }
		if ($ovfconfig) { Import-Appliance }
		else { throw "an OVF configuration was not passed back into "}
	}

	catch { Write-Error $_ }
}

# Adding aliases and exporting this funtion when the module gets loaded
New-Alias -Value New-vRealizeLogInsightAppliance -Name New-LogInsight
New-Alias -Value New-vRealizeLogInsightAppliance -Name New-vRLI
New-Alias -Value New-vRealizeLogInsightAppliance -Name New-LI
Export-ModuleMember -Function New-vRealizeLogInsightAppliance -Alias @("New-LI","New-LogInsight","New-vRLI")