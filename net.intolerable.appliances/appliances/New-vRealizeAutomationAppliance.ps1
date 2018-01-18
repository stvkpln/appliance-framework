Function New-vRealizeAutomationAppliance {
    <#
		.Synopsis
			Deploy a new vRealize Automation appliance

		.Description
			Deploys a vRealize Automation appliance from a specified OVA/OVF file

		.Parameter OVFPath
			Specifies the path to the OVF or OVA package that you want to deploy the appliance from.

		.Parameter Name
			Specifies a name for the imported appliance.

		.Parameter RootPassword
			A root password can be set if desired and will override any already set password. If not, but guest customization is running, then it will be randomly generated. Otherwise the password will be blank, and will be required to change in the console before using SSH. For security reasons, it is recommended to use a password that is a minimum of eight characters and contains a minimum of one upper, one lower, one digit, and one special character.

		.Parameter EnableSSH
			Specifies whether or not to enable SSH for remote access to the appliance. Enabling SSH service is not recommended for security reasons. The default value will leave SSH disabled.

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
				OVFPath = "c:\temp\vrealize-automation.ova"
				Name = "vRA1"
				RootPassword = "VMware1!"
				EnableSSH = $true
				VMHost = (Get-VMHost -Name "host1.example.com")
				InventoryLocation = (Get-Folder -Type VM -Name "Appliances")
				Network = "admin-network"
				IPAddress = "10.10.10.11" 
				SubnetMask = "255.255.255.0" 
				Gateway = "10.10.10.1"
				Domain = "example.com"
				DnsServers = @("10.10.1.11","10.10.1.12")
				ValidateDns = $true
				PowerOn = $true
				Verbose = $true
			}

			New-vRealizeAutomationAppliance @config

			Description
			-----------
			Deploy the vRealize Automation appliance with static IP settings and power it on after the import finishes. 
			In this example, the Verbose flag is being passed, so all OVF properties will be shown as part of the output

		.Example
			Connect-VIServer vCenter.example.com
			
			$config = @{
				OVFPath = "c:\temp\vrealize-automation.ova"
				Name = "vRA1"
				RootPassword = "VMware1!"
				EnableSSH = $true
				VMHost = (Get-VMHost -Name "host1.example.com")
				InventoryLocation = (Get-Folder -Type VM -Name "Appliances")
				Network = "admin-network"
				DHCP = $true
				PowerOn = $false
			}

			New-vRealizeAutomationAppliance @config

			Description
			-----------
			Deploy the vRealize Automation appliance with DHCP settings and and do not power it on after the import finishes
	#>
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = "Static")]
    [OutputType('VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine')]
    Param (
        [Alias("OVA", "OVF")]
        [Parameter(Mandatory = $true, ParameterSetName = "DHCP")]
        [Parameter(Mandatory = $true, ParameterSetName = "Static")]
        [ValidateScript( { Confirm-FilePath -File $_ } )]
        [System.IO.FileInfo]$OVFPath,

        [Parameter(Mandatory = $true, ParameterSetName = "DHCP")]
        [Parameter(Mandatory = $true, ParameterSetName = "Static")]
        [ValidateNotNullOrEmpty()]
        [String]$Name,

        [Parameter(Mandatory = $true, ParameterSetName = "DHCP")]
        [Parameter(Mandatory = $true, ParameterSetName = "Static")]
        [ValidateNotNullOrEmpty()]
        [String]$RootPassword,

        [Parameter(ParameterSetName = "DHCP")]
        [Parameter(ParameterSetName = "Static")]
        [bool]$EnableSSH,

        # Infrastructure Parameters
        [Parameter(ParameterSetName = "DHCP")]
        [Parameter(ParameterSetName = "Static")]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]$VMHost,

        [Parameter(ParameterSetName = "DHCP")]
        [Parameter(ParameterSetName = "Static")]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Folder]$InventoryLocation,

        [Parameter(ParameterSetName = "DHCP")]
        [Parameter(ParameterSetName = "Static")]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]$Location,

        [Parameter(ParameterSetName = "DHCP")]
        [Parameter(ParameterSetName = "Static")]
        [VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.Datastore]$Datastore,

        [Parameter(ParameterSetName = "DHCP")]
        [Parameter(ParameterSetName = "Static")]
        [ValidateSet("Thick", "Thick2GB", "Thin", "Thin2GB", "EagerZeroedThick")]
        [String]$DiskFormat = "thin",

        # Networking
        [Parameter(Mandatory = $true, ParameterSetName = "DHCP")]
        [Parameter(Mandatory = $true, ParameterSetName = "Static")]
        [String]$Network,

        [Parameter(ParameterSetName = "DHCP")]
        [Parameter(ParameterSetName = "Static")]
        [ValidateSet("IPv4", "IPv6")]
        [String]$IPProtocol = "IPv4",

        [Parameter(ParameterSetName = "DHCP")]
        [Switch]$DHCP,

        [Parameter(Mandatory = $true, ParameterSetName = "Static")]
        [ValidateScript( {$_ -match [IPAddress]$_ })]
        [String]$IPAddress,

        [Parameter(ParameterSetName = "Static")]
        [String]$SubnetMask = "255.255.255.0",

        [Parameter(ParameterSetName = "Static")]
        [ValidateScript( {$_ -match [IPAddress]$_ })]
        [String]$Gateway,

		[Parameter(Mandatory=$true,ParameterSetName="Static")]
		[ValidateCount(1,2)]
		[ValidateScript( {$_ -match [IPAddress]$_ })]
		[String[]]$DnsServers,

		[Parameter(ParameterSetName="Static")]
		[ValidateCount(1,4)]
		[String[]]$DnsSearchPath,

        [Parameter(ParameterSetName = "Static")]
        [String]$Domain,

        [Parameter(ParameterSetName = "Static")]
        [String]$FQDN,

		[Parameter(ParameterSetName="Static")]
		[bool]$ValidateDns = $true,

        # Lifecycle Parameters
        [Parameter(ParameterSetName = "DHCP")]
        [Parameter(ParameterSetName = "Static")]
        [Switch]$PowerOn,

        [Parameter(ParameterSetName = "Static")]
        [Parameter(ParameterSetName = "DHCP")]
        [Switch]$NoClobber = $true
    )

    Function New-Configuration () {
        $Status = "Configuring Appliance Values"
        Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Extracting OVF Template"
        $ovfconfig = Get-OvfConfiguration -OvF $OVFPath.FullName
        if ($ovfconfig) {
            $ApplianceType = (Get-Member -InputObject $ovfconfig.vami -MemberType "CodeProperty").Name

            # Setting Basics Up
            Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Configuring Basic Values"
            $ovfconfig.Common.varoot_password.value = $RootPassword # Setting the provided password for the root account
            if ($EnableSSH) { $ovfconfig.Common.va_ssh_enabled.value = $EnableSSH }

            # Setting Networking Values
            Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Assigning Networking Values"
            $ovfconfig.IpAssignment.IpProtocol.value = $IPProtocol # IP Protocol Value
            $ovfconfig.NetworkMapping.Network_1.value = $Network; # vSphere Portgroup Network Mapping

			if ($PsCmdlet.ParameterSetName -eq "Static") {
				$ovfconfig.Common.vami.hostname.value = $FQDN
				$ovfconfig.vami.$ApplianceType.ip0.value = $IPAddress
				$ovfconfig.vami.$ApplianceType.netmask0.value = $SubnetMask
				$ovfconfig.vami.$ApplianceType.gateway.value = $Gateway
				$ovfconfig.vami.$ApplianceType.DNS.value = $DnsServers -join ","
				if ($Domain) { $ovfconfig.vami.$ApplianceType.domain.value = $Domain }
				if ($DnsSearchPath) { $ovfconfig.vami.$ApplianceType.searchpath.value = $DnsSearchPath -join "," }
            }

            # Verbose logging passthrough
            Write-OVFValues -ovfconfig $ovfconfig -Type "Verbose" -Verbose:$VerbosePreference

            # Returning the OVF Configuration to the function
            $ovfconfig
        }

        else { throw "The provided file '$($OVFPath)' is not a valid OVA/OVF; please check the path/file and try again" }
    }

    # Workflow to provision the vRealize Automation appliance
    try {
        $Activity = "Deploying a new vRealize Automation Appliance"

        # Validating Components
        Confirm-VM -Name $Name -NoClobber $NoClobber
        $VMHost = Confirm-VMHost -VMHost $VMHost -Location $Location -Verbose:$VerbosePreference
        Confirm-BackingNetwork -Network $Network -Verbose:$VerbosePreference
        $Gateway = Set-DefaultGateway -Gateway $Gateway -Verbose:$VerbosePreference
		if ($PsCmdlet.ParameterSetName -eq "Static" -and $ValidateDns -eq $true) {
			# Adding all of the required parameters to validate DNS things
			$validate = @{
				Name       = $Name
				Domain     = $Domain
				IPAddress  = $IPAddress
				DnsServers = $DnsServers
				FQDN       = $FQDN
				ValidateDns = $ValidateDns
				Verbose    = $VerbosePreference
			}

            # Confirming DNS Settings
            $FQDN = Confirm-DNS @validate
        }

        # Configuring the OVF Template and deploying the appliance
        $ovfconfig = New-Configuration
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
New-Alias -Value New-vRealizeAutomationAppliance -Name New-vRA
Export-ModuleMember -Function New-vRealizeAutomationAppliance -Alias @("New-vRA")