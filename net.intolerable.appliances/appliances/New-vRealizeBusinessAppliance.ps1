Function New-vRealizeBusinessAppliance {
    <#
		.Synopsis
			Deploy a new vRealize Business virtual appliance

		.Description
			Deploys a vRealize Business Virtual Appliance from a specified OVA/OVF file

		.Parameter OVFPath
			Specifies the path to the OVF or OVA package that you want to deploy the appliance from.

		.Parameter Name
			Specifies a name for the imported appliance.

		.Parameter RootPassword
			A root password can be set if desired and will override any already set password. If not, but guest customization is running, then it will be randomly generated. Otherwise the password will be blank, and will be required to change in the console before using SSH. For security reasons, it is recommended to use a password that is a minimum of eight characters and contains a minimum of one upper, one lower, one digit, and one special character.

		.Parameter Currency 
			Currency to use. The following are valid options:

			"AED - UAE Dirham", "ALL - Albanian Lek", "ARS - Argentine Peso", "AUD - Australian Dollar", "AWG - Arubian Florin", "BBD - Barbadian Dollar", "BDT - Bangladeshi Taka", "BGN - Bulgarian Lev", "BHD - Bahraini Dinar", "BIF - Burundi Franc", "BMD - Bermudian Dollar", "BND - Brunei Dollar", "BOB - Bolivian Boliviano", "BRL - Brazilian Real", "BSD - Bahamian Dollar", "BWP - Botswana Pula", "BZD - Belize Dollar", "CAD - Canadian Dollar", "CDF - Congolese Franc", "CHF - Swiss Franc", "CLP - Chilean Peso", "CNY - China Yuan Renminbi", "COP - Colombian Peso", "CRC - Costa Rican Colon", "CUP - Cuban Peso", "CVE - Cape Verdean Escuso", "CZK - Czech Koruna", "DJF - Djiboutian Franc", "DKK - Danish Krone", "DOP - Dominican peso", "DZD - Algerian Dinar", "EGP - Egyptian Pound", "ETB - Etiopian Birr", "EUR - Euro", "FJD - Fijian Dollar", "GBP - British Pound", "GHS - Ghanaian Cedi", "GMD - Gambian Dalasi", "GNF - Guinean Franc", "GTQ - Guatemalan Quetzal", "HKD - Hong Kong Dollar", "HNL - Honduran Lempira", "HRK - Croatian Kuna", "HTG - Haitian Gourde", "HUF - Hungarian Forint", "IDR - Indonesia Rupiah", "ILS - Israeli Shekel", "INR - Indian Rupee", "IQD - Iraqi Dinar", "ISK - Icelandic Krona", "JMD - Jamaican Dollar", "JOD - Jordanian Dinar", "JPY - Japanese Yen", "KES - Kenyan Shilling", "KHR - Cambodian Riel", "KMF - Comorial Franc", "KRW - Korea(South) Won", "KWD - Kuwait Dinar", "KYD - Cayman Island Dollar", "KZT - Kazakhstani Tenge", "LAK - Lao Kip", "LBP - Lebanese Pound", "LKR - Sri Lankan Rupee", "LRD - Liberian Dollar", "LSL - Lesotho Loti", "LTL - Lithuanian Litas", "LYD - Libyan Dinar", "MAD - Moroccan Dirham", "MDL - Moldovan Leu", "MGA - Malagasy Ariary", "MKD - Macedonian Denar", "MMK - Myanmar Kyat", "MOP - Macanese Pataca", "MRO - Mauritanian Ouguiya", "MUR - Mauritian Rupee", "MVR - Maldivian Rufiyaa", "MWK - Malawian Kwacha", "MXN - Mexican Peso", "MYR - Malaysia Ringgit", "MZN - Mozambican Metical", "NAD - Nambian Dollar", "NGN - Nigerian Naira", "NIO - Nicaraguan Cordoba", "NOK - Norway Krone", "NPR - Nepalese Rupee", "NZD - New Zealand Dollar", "OMR - Omani Rial", "PAB - Panamanian Balboa", "PEN - Peruvian Sol", "PGK - Papua New Guinean Kina", "PHP - Philippine Peso", "PKR - Pakistani Rupee", "PLN - Polish Zloty", "PYG - Paraguayan Guarani", "QAR - Qatari Riyal", "RON - Romanian Leu", "RSD - Serbian Dinar", "RUB - Russia Ruble", "RWF - Rwandan Franc", "SAR - Saudi Arabian Riyal", "SCR - Seychellios Rupee", "SDG - Sudanese Pound", "SEK - Sweden Krona", "SGD - Singapore Dollar", "SHP - Saint Helena Pound", "SLL - Sierra Leonean Leone", "SOS - Somali Shilling", "STD - Sao Tome and Principe Dobra", "SVC - Salvadoran Colon", "SZL - Swazi Lilangeni", "THB - Thai Baht", "TMT - Turkmen Manat", "TND - Tunisian Dinar", "TRY - Turkey Lira", "TTD - Trinidad and Tobago Dollar", "TWD - Taiwan New Dollar", "TZS - Tanzanian Shilling", "UAH - Ukrainian Hryvnia", "UGX - Ugandan Shilling", "USD - US Dollar", "UYU - Uruguayan Peso", "UZS - Uzbekistani Som", "VEF - Venezuelan Bolivar", "VND - Vietnamese Dong", "XAF - Central African Franc", "XCD - East Caribbean Dollar", "XOF - West African Franc", "XPF - CFP Franc", "YER - Yemeni Rial", "ZAR - South Africa Rand"

		.Parameter EnableSSH
			Specifies whether or not to enable SSH for remote access to the NSX Manager. Enabling SSH service is not recommended for security reasons. The default value will leave SSH disabled.

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

		.Parameter NoClobber
			Indicates that the function will not remove and replace an existing virtual machine. By default, if a virtual machine with the specifies name exists, the function will fail. If setting this value to 'False', the existing virtual machine will be stopped and removed from the infrastructure permanently.

		.Notes
			Author: Steve Kaplan (steve@intolerable.net)
			Version History:
				- 1.0: Initial release

		.Example
			Connect-VIServer vCenter.example.com
			
			$config = @{
				OVFPath = "c:\temp\vrealize-business.ova"
				Name = "vRB1"
				RootPassword = "VMware1!"
				EnableSSH = $true
				EnableCEIP = $true
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

			New-vRealizeBusinessAppliance @config

			Description
			-----------
			Deploy the vRealize Business appliance with static IP settings and power it on after the import finishes. 
			In this example, the Verbose flag is being passed, so all OVF properties will be shown as part of the output

		.Example
			Connect-VIServer vCenter.example.com
			
			$config = @{
				OVFPath = "c:\temp\vrealize-business.ova"
				Name = "vRB1"
				RootPassword = "VMware1!"
				EnableSSH = $true
				EnableCEIP = $true
				VMHost = (Get-VMHost -Name "host1.example.com")
				InventoryLocation = (Get-Folder -Type VM -Name "Appliances")
				Network = "admin-network"
				DHCP = $true
				PowerOn = $false
			}

			New-vRealizeBusinessAppliance @config

			Description
			-----------
			Deploy the vRealize Business appliance with DHCP settings and and do not power it on after the import finishes
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

        [Parameter(ParameterSetName = "DHCP")]
        [Parameter(ParameterSetName = "Static")]
        [ValidateSet("AED", "ALL", "ARS", "AUD", "AWG", "BBD", "BDT", "BGN", "BHD", "BIF", "BMD", "BND", "BOB", "BRL", "BSD", "BWP", "BZD", "CAD", "CDF", "CHF", "CLP", "CNY", "COP", "CRC", "CUP", "CVE", "CZK", "DJF", "DKK", "DOP", "DZD", "EGP", "ETB", "EUR", "FJD", "GBP", "GHS", "GMD", "GNF", "GTQ", "HKD", "HNL", "HRK", "HTG", "HUF", "IDR", "ILS", "INR", "IQD", "ISK", "JMD", "JOD", "JPY", "KES", "KHR", "KMF", "KRW", "KWD", "KYD", "KZT", "LAK", "LBP", "LKR", "LRD", "LSL", "LTL", "LYD", "MAD", "MDL", "MGA", "MKD", "MMK", "MOP", "MRO", "MUR", "MVR", "MWK", "MXN", "MYR", "MZN", "NAD", "NGN", "NIO", "NOK", "NPR", "NZD", "OMR", "PAB", "PEN", "PGK", "PHP", "PKR", "PLN", "PYG", "QAR", "RON", "RSD", "RUB", "RWF", "SAR", "SCR", "SDG", "SEK", "SGD", "SHP", "SLL", "SOS", "STD", "SVC", "SZL", "THB", "TMT", "TND", "TRY", "TTD", "TWD", "TZS", "UAH", "UGX", "USD", "UYU", "UZS", "VEF", "VND", "XAF", "XCD", "XOF", "XPF", "YER", "ZAR")]		
        [String]$Currency,

        [Parameter(Mandatory = $true, ParameterSetName = "DHCP")]
        [Parameter(Mandatory = $true, ParameterSetName = "Static")]
        [ValidateNotNullOrEmpty()]
        [String]$RootPassword,

        [Parameter(ParameterSetName = "DHCP")]
        [Parameter(ParameterSetName = "Static")]
        [bool]$EnableSSH,
		
        [Parameter(ParameterSetName = "DHCP")]
        [Parameter(ParameterSetName = "Static")]
        [bool]$EnableCEIP,

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

        [Parameter(Mandatory = $true, ParameterSetName = "Static")]
        [ValidateCount(1, 2)]
        [ValidateScript( {$_ -match [IPAddress]$_ })]
        [String[]]$DNSServers,

        [Parameter(ParameterSetName = "Static")]
        [ValidateCount(1, 4)]
        [String[]]$DNSSearchPath,

        [Parameter(ParameterSetName = "Static")]
        [String]$Domain,

        [Parameter(ParameterSetName = "Static")]
        [bool]$ValidateDNSEntries = $true,

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
            if ($RootPassword) { $ovfconfig.Common.itfm_root_password.value = $RootPassword } # Setting the provided password for the root account
            if ($Currency) { $ovfconfig.Common.itfm_currency.value = $Currency }
            if ($EnableSSH) { $ovfconfig.Common.itfm_ssh_enabled.value = $EnableSSH }
            if ($EnableCEIP) { $ovfconfig.Common.itfm_telemetry_enabled.value = $EnableCEIP }

            # Setting Networking Values
            Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Assigning Networking Values"
            $ovfconfig.IpAssignment.IpProtocol.value = $IPProtocol # IP Protocol Value
            $ovfconfig.NetworkMapping.Network_1.value = $Network; # vSphere Portgroup Network Mapping

            if ($PsCmdlet.ParameterSetName -eq "Static") {
                $ovfconfig.vami.$ApplianceType.ip0.value = $IPAddress
                $ovfconfig.vami.$ApplianceType.netmask0.value = $SubnetMask
                $ovfconfig.vami.$ApplianceType.gateway.value = $Gateway
                $ovfconfig.vami.$ApplianceType.DNS.value = $DNSServers -join ","
                $ovfconfig.vami.$ApplianceType.domain.value = $Domain
                if ($DNSSearchPath) { $ovfconfig.vami.$ApplianceType.searchpath.value = $DNSSearchPath -join "," }
            }

            # Verbose logging passthrough
            Write-OVFValues -ovfconfig $ovfconfig -Type "Verbose" -Verbose:$VerbosePreference

            # Returning the OVF Configuration to the function
            $ovfconfig
        }
		
        else { throw "The provided file '$($OVFPath)' is not a valid OVA/OVF; please check the path/file and try again" }
    }

    # Workflow to provision the vRealize Business Virtual Appliance
    try {
        $Activity = "Deploying a new vRealize Business Appliance"

        # Validating Components
        Confirm-VM -Name $Name -NoClobber $NoClobber
        $VMHost = Confirm-VMHost -VMHost $VMHost -Location $Location -Verbose:$VerbosePreference
        Confirm-BackingNetwork -Network $Network -VMHost $VMHost -Verbose:$VerbosePreference
        $sGateway = @{
            Gateway     = $Gateway
            SubnetMask  = $SubnetMask
            FourthOctet = $FourthOctet
            IPAddress   = $IPAddress
            Verbose     = $VerbosePreference
        }
        $Gateway = Set-DefaultGateway @sGateway
        if ($PsCmdlet.ParameterSetName -eq "Static" -and $ValidateDNSEntries -eq $true) {
            # Adding all of the required parameters to validate DNS things
            $validate = @{
                Name       = $Name
                Domain     = $Domain
                IPAddress  = $IPAddress
                DNSServers = $DNSServers
                FQDN       = $FQDN
                Verbose    = $VerbosePreference
            }

            # Confirming DNS Settings
            $FQDN = Confirm-DNS @validate
        }

        # Configuring the OVF Template and deploying the appliance
        $ovfconfig = New-Configuration
        if ($ovfconfig) {
            if ($pscmdlet.ShouldProcess($OVFPath.FullName, "Import-Appliance")) { Import-Appliance -Verbose:$VerbosePreference }
            else { 
                if ($VerbosePreference -eq "SilentlyContinue") { Write-OVFValues -ovfconfig $ovfconfig -Type "Standard" }
            }
        }
		
        else { throw $noOvfConfiguration }
    }

    catch { Write-Error $_ }
}

# Adding aliases and exporting this funtion when the module gets loaded
New-Alias -Value New-vRealizeBusinessAppliance -Name New-vRB
Export-ModuleMember -Function New-vRealizeBusinessAppliance -Alias @("New-vRB")