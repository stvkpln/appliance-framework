Function New-vRealizeSuiteLifecycleManagerAppliance {
	<#
		.Synopsis
			Deploy a new vRealize Suite Lifecycle Manager appliance

		.Description
			Deploys a vRealize Suite Lifecycle Manager appliance from a specified OVA/OVF file

		.Parameter OVFPath
			Specifies the path to the OVF or OVA package that you want to deploy the appliance from.

		.Parameter Name
			Specifies a name for the imported appliance.

		.Parameter EnableCEIP
			Specifies whether to enable VMware's Customer Experience Improvement Program ("CEIP"). The default will enable CEIP.

			VMware's Customer Experience Improvement Program ("CEIP") provides VMware with information that enables VMware to improve its products and services, to fix problems, and to advise you on how best to deploy and use our products.  As part of the CEIP, VMware collects technical information about your organization's use of VMware products and services on a regular basis in association with your organization's VMware license key(s). This information does not personally identify any individual. For additional information regarding the data collected through CEIP and the purposes for which it is used by VMware is set forth in the Trust & Assurance Center at http://www.vmware.com/trustvmware/ceip.html.

		.Parameter CertCommonName
			The fully qualified domain name (FQDN) for the generated certificate. If this field is left blank and using a static IP, the auto-generated FQDN (VM name + domain) will be used for this field.

		.Parameter CertOrgName
			The name of the organization for the generated certificate.

		.Parameter CertOrgUnit
			The name of the organization unit / division for the generated ceritifcate.

		.Parameter CertCountryCode
			Country code for the generated certificate. This field contains the 2-character ISO format country code. For example, GB is the valid country code for Great Britain, and US is the valid code for the United States. 

			To locate a specific country code, you may take a look at this page: http://www.nationsonline.org/oneworld/country_code_list.htm

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

		.Parameter ValidateDNSEntries
			Specifies whether to perform DNS resolution validation of the networking information. If set to true, lookups for both forward (A) and reverse (PTR) records will be confirmed to match.

		.Parameter PowerOn
			Specifies whether to power on the imported appliance once the import completes.

		.Notes
			Author: Steve Kaplan (steve@intolerable.net)

		.Example
			Connect-VIServer vCenter.example.com
			
			$config = @{
				OVFPath = "c:\temp\vrealize-lcm.ova"
				Name = "vRSLCM1"
				EnableCEIP = $true
				CertCommonName = "vrslcm1.example.com"
				CertOrgName = "Example Corp"
				CertOrgUnit = "Example Org"
				CertCountryCode = "US"
				VMHost = (Get-VMHost -Name "host1.example.com")
				InventoryLocation = (Get-Folder -Type VM -Name "Appliances")
				Network = "admin-network"
				IPAddress = "10.10.10.11" 
				SubnetMask = "255.255.255.0" 
				Gateway = "10.10.10.1"
				Domain = "example.com"
				DNSServers = @("10.10.1.11","10.10.1.12")
				ValidateDNSEntries = $true
				PowerOn = $true
				Verbose = $true
			}

			New-vRealizeSuiteLifecycleManagerAppliance @config

   			Description
   			-----------
			Deploy the vRealize Suite Lifecycle Manager appliance with static IP settings and power it on after the import finishes. 
			In this example, the Verbose flag is being passed, so all OVF properties will be shown as part of the output

		.Example
			Connect-VIServer vCenter.example.com
			
			$config = @{
				OVFPath = "c:\temp\vrealize-lcm.ova"
				Name = "vRSLCM1"
				EnableCEIP = $true
				CertCommonName = "vrslcm1.example.com"
				CertOrgName = "Example Corp"
				CertOrgUnit = "Example Org"
				CertCountryCode = "US"
				VMHost = (Get-VMHost -Name "host1.example.com")
				InventoryLocation = (Get-Folder -Type VM -Name "Appliances")
				Network = "admin-network"
				DHCP = $true
				PowerOn = $false
			}

			New-vRealizeSuiteLifecycleManagerAppliance @config

			Description
			-----------
			Deploy the vRealize Suite Lifecycle Manager appliance with DHCP settings and and do not power it on after the import finishes
	#>
	[CmdletBinding(SupportsShouldProcess=$true,DefaultParameterSetName="Static")]
	[OutputType('VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine')]
	Param (
		[Alias("OVA","OVF")]
		[Parameter(Mandatory=$true,ParameterSetName="DHCP")]
		[Parameter(Mandatory=$true,ParameterSetName="Static")]
		[System.IO.FileInfo]$OVFPath,

		[Parameter(Mandatory=$true,ParameterSetName="DHCP")]
		[Parameter(Mandatory=$true,ParameterSetName="Static")]
        [ValidateNotNullOrEmpty()]
		[String]$Name,

		[Parameter(ParameterSetName="DHCP")]
        [Parameter(ParameterSetName="Static")]
		[bool]$EnableCEIP,

		# SSL Certificate Parameters
		[Alias("CommonName","CN")]
		[Parameter(ParameterSetName="DHCP")]
        [Parameter(ParameterSetName="Static")]
		[String]$CertCommonName,

		[Alias("OrgName","Org")]
		[Parameter(ParameterSetName="DHCP")]
        [Parameter(ParameterSetName="Static")]
		[String]$CertOrgName,

		[Alias("OU","OrgUnit")]
		[Parameter(ParameterSetName="DHCP")]
        [Parameter(ParameterSetName="Static")]
		[String]$CertOrgUnit,

		[Alias("Country","CountryCode")]
		[Parameter(ParameterSetName="DHCP")]
        [Parameter(ParameterSetName="Static")]
		[ValidateLength(2,2)]
		[ValidateSet("AD","AE","AF","AG","AI","AL","AM","AN","AO","AQ","AR","AS","AT","AU","AW","AX","AZ","BA","BB","BD","BE","BF","BG","BH","BI","BJ","BL","BM","BN","BO","BR","BS","BT","BV","BW","BY","BZ","CA","CC","CD","CF","CG","CH","CI","CK","CL","CM","CN","CO","CR","CU","CV","CX","CY","CZ","DE","DJ","DK","DM","DO","DZ","EC","EE","EG","EH","ER","ES","ET","FI","FJ","FK","FM","FO","FR","GA","GB","GD","GE","GF","GG","GH","GI","GL","GM","GN","GP","GQ","GR","GS","GT","GU","GW","GY","HK","HM","HN","HR","HT","HU","ID","IE","IL","IM","IN","IO","IQ","IR","IS","IT","JE","JM","JO","JP","KE","KG","KH","KI","KM","KN","KP","KR","KW","KY","KZ","LA","LB","LC","LI","LK","LR","LS","LT","LU","LV","LY","MA","MC","MD","ME","MF","MG","MH","MK","ML","MM","MN","MO","MP","MQ","MR","MS","MT","MU","MV","MW","MX","MY","MZ","NA","NC","NE","NF","NG","NI","NL","NO","NP","NR","NU","NZ","OM","PA","PE","PF","PG","PH","PK","PL","PM","PN","PR","PS","PT","PW","PY","QA","RE","RO","RS","RU","RW","SA","SB","SC","SD","SE","SG","SH","SI","SJ","SK","SL","SM","SN","SO","SR","SS","ST","SV","SY","SZ","TC","TD","TF","TG","TH","TJ","TK","TL","TM","TN","TO","TR","TT","TV","TW","TZ","UA","UG","UM","US","UY","UZ","VA","VC","VE","VG","VN","VU","WF","WS","YE","YT","ZA","ZM","ZW")]
		[String]$CertCountryCode = "US",

		# Infrastructure Parameters
		[Parameter(ParameterSetName="DHCP")]
        [Parameter(ParameterSetName="Static")]
		[ValidateNotNullOrEmpty()]
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

		[Parameter(Mandatory=$true,ParameterSetName="DHCP")]
        [Parameter(Mandatory=$true,ParameterSetName="Static")]
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

		[Parameter(Mandatory=$true,ParameterSetName="Static")]
		[String]$Domain,

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
			if ($EnableCEIP) { $ovfconfig.common.va_telemetry_enabled.value = $EnableCEIP }

			# SSL Certificate Values
			if ($CertCommonName) { $ovfconfig.Common.vlcm.cert.commonname.value = $CertCommonName }
			else { $ovfconfig.Common.vlcm.cert.commonname.value = $FQDN }

			if ($CertOrgName) { $ovfconfig.Common.vlcm.cert.orgname.value = $CertOrgName }
			if ($CertOrgUnit) { $ovfconfig.Common.vlcm.cert.orgunit.value = $CertOrgUnit }
			if ($CertCountryCode) { $ovfconfig.Common.vlcm.cert.countrycode.value = $CertCountryCode }

			# Setting Networking Values
			Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Assigning Networking Values"
			$ovfconfig.IpAssignment.IpProtocol.value = $IPProtocol # IP Protocol Value
			$ovfconfig.NetworkMapping.Network_1.value = $Network; # vSphere Portgroup Network Mapping

			if ($PsCmdlet.ParameterSetName -eq "Static") {
				$ovfconfig.Common.vami.hostname.value = $FQDN
				$ovfconfig.vami.$ApplianceType.ip0.value = $IPAddress
				$ovfconfig.vami.$ApplianceType.netmask0.value = $SubnetMask
				$ovfconfig.vami.$ApplianceType.gateway.value = $Gateway
				$ovfconfig.vami.$ApplianceType.DNS.value = $DNSServers -join ","
				$ovfconfig.vami.$ApplianceType.domain.value = $Domain
				if ($DNSSearchPath) { $ovfconfig.vami.$ApplianceType.searchpath.value = $DNSSearchPath -join "," }
            }

            # Verbose logging passthrough
            Write-OVFValues -ovfconfig $ovfconfig -Verbose:$VerbosePreference

			# Returning the OVF Configuration to the function
			$ovfconfig
		}

		else { throw "The provided file '$($OVFPath)' is not a valid OVA/OVF; please check the path/file and try again" }
	}

	# Workflow to provision the vRealize Suite Lifecycle Manager appliance
	try {
		$Activity = "Deploying a new vRealize Suite Lifecycle Manager Appliance"

		# Validating Components
        $VMHost = Confirm-VMHost -VMHost $VMHost -Location $Location -Verbose:$VerbosePreference
        Confirm-BackingNetwork -Network $Network -Verbose:$VerbosePreference
        $Gateway = Set-DefaultGateway -Gateway $Gateway -Verbose:$VerbosePreference
		if ($PsCmdlet.ParameterSetName -eq "Static") {
			# Adding all of the required parameters to validate DNS things
			$validate = @{
				Name = $Name
				Domain = $IPAddress
				DNSServers = $DNSServers
                Verbose = $VerbosePreference
			}

			if ($Domain) { $validate.Domain = $Domain }
			if ($FQDN) { $validate.FQDN = $FQDN }

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
New-Alias -Value New-vRealizeSuiteLifecycleManagerAppliance -Name New-vRSLCM
Export-ModuleMember -Function New-vRealizeSuiteLifecycleManagerAppliance -Alias @("New-vRSLCM")