Function New-NSXTManager {
	<#
		.Synopsis
			Deploy a new NSX-T Manager

		.Description
			Deploys a NSX-T Manager from a specified OVA/OVF file. Today, this function only supports provisioning to IPv4 networks.

		.Parameter OVFPath
			Specifies the path to the OVF or OVA package that you want to deploy the appliance from.

		.Parameter DeploymentSize
			The appliance hardware configuration / specification to use for provisioning of the NSX-T Manager. Available size specifications are:

			- Small: This configuration is intended for proof-of-concept or test environments and should not be used in a production environment.
				* 2 vCPU
				* 8GB RAM
				* 140GB Storage

			- Medium
				* 4 vCPU
				* 16GB RAM
				* 140GB Storage

			- Large
				* 8 vCPU
				* 32GB RAM
				* 140GB Storage

		.Parameter Name
			Specifies a name for the imported appliance.

		.Parameter Role
			The role for the NSX Manager. The current options are either 'Manager' or 'Policy Manager'. The default is Manager if this value is not provided.

		.Parameter RootPassword
			Specifies the password to be used for the root user account. Please follow the password complexity rule as below:
				* Min of 8 characters
				* >=1 lower case letter
				* >=1 upper case letter
				* >=1 number digit
				* >=1 special char
				* At least five different characters
				* No dictionary words
				* No palindromes

			NOTE: Password strength validation will occur during VM boot.  If the password does not meet the above criteria then login as root user for the change password prompt to appear.

		.Parameter AdminUser
			Specifies the name of the initial administrator account to be created. If a value is not specified, the default value is 'admin'.

		.Parameter AdminPassword
			Specifies the password for the initial administrator account. Please follow the password complexity rule as below:
				* Min of 8 characters
				* >=1 lower case letter
				* >=1 upper case letter
				* >=1 number digit
				* >=1 special char
				* At least five different characters
				* No dictionary words
				* No palindromes

			NOTE: Password strength validation will occur during VM boot.  If the password does not meet the above criteria then login as admin user for the change password prompt to appear.

		.Parameter AuditUser
			Specifies the name of the initial audit account to be created. If a value is not specified, the default value is 'audit'.

		.Parameter AuditPassword
			Specifies the password for the initial audit account. If a value is not provided, the password provided for the admin user will be used. Please follow the password complexity rule as below:
				* Min of 8 characters
				* >=1 lower case letter
				* >=1 upper case letter
				* >=1 number digit
				* >=1 special char
				* At least five different characters
				* No dictionary words
				* No palindromes

			NOTE: Password strength validation will occur during VM boot.  If the password does not meet the above criteria then login as admin user for the change password prompt to appear.

		.Parameter EnableSSH
			Specifies whether or not to enable SSH for remote access to the NSX-T Manager. Enabling SSH service is not recommended for security reasons. The default value will leave SSH disabled.

		.Parameter AllowRootSSH
			Specifies whether to enable the root user to be able to SSH into the imported appliance.

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
			The Network Time Protocol (NTP) servers to define for the imported appliance. Default NTP Servers to be used if none are specified are: 0.north-america.pool.ntp.org, 1.north-america.pool.ntp.org

		.Parameter Tags
			Specifies the vSphere Tag(s) to apply to the imported virtual appliance.

		.Parameter PowerOn
			Specifies whether to power on the imported appliance once the import completes.

		.Parameter AllowClobber
			Indicates whether or not to replace an existing virtual machine, if discovered. The default behavior (set to 'False'), the function will fail with an error that there is an esisting virtual machine. If set to true, the discovered virtual machine will be stopped and removed permanently from the infrastructure *WITHOUT PROMPTING*. Use careuflly!

		.Notes
			Author: Steve Kaplan (skaplan@kovarus.com)

		.Example
			Connect-VIServer vCenter.example.com

			$config = @{
				OVFPath = "c:\temp\nsx-t-manager.ova"
				Name = "NSXTM1"
				Role = "Manager"
				RootPassword = "VMware1!"
				AdminUser = "admin"
				AdminPassword = "VMware2!"
				AuditUser = "audit"
				"AuditPassword" = "VMware3!"
				EnableSSH = $true
				AllowRootSSH = $true
				VMHost = (Get-VMHost -Name "host1.example.com")
				InventoryLocation = (Get-Folder -Type VM -Name "Appliances")
				Network = "admin-network"
				IPAddress = "10.10.10.11"
				SubnetMask = "255.255.255.0"
				Gateway = "10.10.10.1"
				Domain = "example.com"
				DnsServers = @("10.10.1.11","10.10.1.12")
				ValidateDns = $true
				NTPServers = @("0.north-america.pool.ntp.org", "1.north-america.pool.ntp.org")
				PowerOn = $true
				Verbose = $true
			}

			New-NSXTManager @config

			Description
			-----------
			Deploy a NSX-T Manager appliance with static IP settings and power it on after the import finishes.
			In this example, the Verbose flag is being passed, so all OVF properties will be shown as part of the output

	#>
	[CmdletBinding(SupportsShouldProcess=$true,DefaultParameterSetName="Manager")]
	[OutputType('VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine')]
	Param (
		[ValidateScript( { Confirm-FileExtension -File $_ } )]
		[System.IO.FileInfo]$OVFPath,

		[Alias("Size", "DeploymentType")]
		[ValidateSet("small", "medium", "large")]
		[String]$DeploymentSize = "small",

		[ValidateNotNullOrEmpty()]
		[String]$Name,

		[ValidateSet("Manager","Policy Manager")]
		[String]$Role = "Manager",

		# User / Authentication Values
		[ValidateNotNullOrEmpty()]
		[String]$RootPassword,

		[String]$AdminUser = "admin",

		[ValidateNotNullOrEmpty()]
		[String]$AdminPassword,

		[String]$AuditUser = "audit",

		[String]$AuditPassword = $AdminPassword,

		# SSH Properties
		[Switch]$EnableSSH = $false,

		[Switch]$AllowRootSSH = $false,

		# Infrastructure Parameters
		[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]$VMHost,

		[VMware.VimAutomation.ViCore.Types.V1.Inventory.Folder]$InventoryLocation,

		[VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]$Location,

		[VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.Datastore]$Datastore,

		[ValidateSet("Thick", "Thick2GB", "Thin", "Thin2GB", "EagerZeroedThick")]
		[String]$DiskFormat = "Thin",

		# Networking
		[String]$Network,

		[ValidateScript( {$_ -match [IPAddress]$_ })]
		[String]$IPAddress,

		[String]$SubnetMask = "255.255.255.0",

		[ValidateScript( {$_ -match [IPAddress]$_ })]
		[String]$Gateway,

		[ValidateCount(1, 2)]
		[ValidateScript( {$_ -match [IPAddress]$_ })]
		[String[]]$DnsServers,

		[String]$Domain,

		[String]$FQDN,

		[bool]$ValidateDns = $true,

		[ValidateCount(1, 4)]
		[String[]]$NTPServers = @("0.north-america.pool.ntp.org", "1.north-america.pool.ntp.org"),

		# Lifecycle Parameters
		[VMware.VimAutomation.ViCore.Types.V1.Tagging.Tag[]]$Tags,

		[Switch]$PowerOn,

        [Switch]$AllowClobber = $false
	)

	Function New-Configuration () {
		$Status = "Configuring Appliance Values"
		Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Extracting OVF Template"
		$ovfconfig = Get-OvfConfiguration -OvF $OVFPath.FullName
		if ($ovfconfig) {
			# Setting Basics Up
			Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Configuring Basic Values"

			# Setting authentication values
			$ovfconfig.Common.nsx_passwd_0.Value = $RootPassword
			$ovfconfig.Common.nsx_cli_username.Value = $AdminUser
			$ovfconfig.Common.nsx_cli_passwd_0.Value = $AdminPassword
			$ovfconfig.Common.nsx_cli_audit_username.Value = $AuditUser
			$ovfconfig.Common.nsx_cli_audit_passwd_0.Value = $AuditPassword

			# Setting SSH Enablement value
			$ovfconfig.Common.nsx_isSSHEnabled.Value = $EnableSSH
			$ovfconfig.Common.nsx_allowSSHRootLogin.Value = $AllowRootSSH

			# Setting Networking Values
			Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Assigning Networking Values"
			$ovfconfig.Common.nsx_ip_0.Value = $IPAddress
			$ovfconfig.Common.nsx_netmask_0.Value = $SubnetMask
			$ovfconfig.Common.nsx_gateway_0.Value = $Gateway
			$ovfconfig.Common.nsx_dns1_0.Value = $DnsServers -join ","
			$ovfconfig.Common.nsx_domain_0.Value = $Domain
			$ovfconfig.Common.nsx_hostname.Value = $FQDN
			$ovfconfig.Common.nsx_ntp_0.Value = $NTPServers -join ","

			$ovfconfig.IpAssignment.IpProtocol.value = $IPProtocol # IP Protocol Value
			$ovfconfig.NetworkMapping.Network_1.value = $Network; # vSphere Portgroup Network Mapping

			# NSX-T Manager Deployment Values
			Write-Progress -Activity $Activity -Status "Appliance Deployment Values"
			$ovfconfig.DeploymentOption.Value = $DeploymentSize.ToLower() # Setting Deployment Size

			# Setting NSX-T Manager Role
			switch ($Role) {
				"Policy Manager" { $ovfconfig.Common.nsx_role.Value =  "nsx-policy-manager" }
				Default  { $ovfconfig.Common.nsx_role.Value =  "nsx-manager" }
			}

			# Verbose logging passthrough
			Write-OVFValues -ovfconfig $ovfconfig -Type "Verbose" -Verbose:$VerbosePreference

			# Returning the OVF Configuration to the function
			$ovfconfig
		}

		else { throw "The provided file '$($OVFPath)' is not a valid OVA/OVF; please check the path/file and try again" }
	}

	# Workflow to provision the NSX-T Manager
	try {
		$Activity = "Deploying a new NSX-T Appliance"

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
New-Alias -Value New-NSXTManager -Name New-NSXT
Export-ModuleMember -Function New-NSXTManager -Alias @("New-NSXT")