Function New-vRealizeOperationsAppliance {
	<#
		.Synopsis
			Deploy a new vRealize Operations virtual appliance

		.Description
			Deploys a vRealize Operations virtual appliance from a specified OVA/OVF file

		.Parameter OVFPath
			Specifies the path to the OVF or OVA package that you want to deploy the appliance from.

		.Parameter DeploymentSize
			Available size specifications for Managers are:   
				- Extra Small (xsmall):  Use this configuration for single node non-HA and two node HA setups in non-production environments.  
					* 2 vCPU
					* 8GB RAM

				- Small:  Use this configuration for environments less than 2000 VMs.  
					* 4 vCPU
					* 16GB RAM

				- Medium: Use this configuration for environments between 2000 to 4000 VMs.
					* 8 vCPU
					* 32GB RAM

				- Large: Use this configuration for environments larger than 4000 VMs.  
					* 16 vCPU
					* 48GB RAM

				- Extra Large (xlarge): Use this configuration for environments between 12000 to 40000 VMs. 
					* 24 vCPU
					* 128GB RAM

			Remote Collectors:
				- Small (smallrc): Use this configuration for remote collector deployments within small or medium environments.
					* 2 vCPU
					* 4GB RAM

				- Large (largerc): Use this configuration for remote collector deployments within large environments.
					* 4 vCPU
					* 16GB RAM

		 .Parameter Name
			Specifies a name for the imported appliance.

		.Parameter Timezone
			Configured timezone value. The following are valid options: America/Argentina/Buenos_Aires, Etc/GMT-1, Africa/Abidjan, Africa/Accra, Africa/Addis_Ababa, Africa/Algiers, Africa/Asmara, Africa/Asmera, Africa/Bamako, Africa/Bangui, Africa/Banjul, Africa/Bissau, Africa/Blantyre, Africa/Brazzaville, Africa/Bujumbura, Africa/Cairo, Africa/Cape Verde, Africa/Casablanca, Africa/Ceuta, Africa/Conakry, Africa/Dakar, Africa/Dar_es_Salaam, Africa/Djibouti, Africa/Douala, Africa/El_Aaiun, Africa/Freetown, Africa/Gaborone, Africa/Harare, Africa/Johannesburg, Africa/Juba, Africa/Kampala, Africa/Khartoum, Africa/Kigali, Africa/Kinshasa, Africa/Lagos, Africa/Libreville, Africa/Lome, Africa/Luanda, Africa/Lubumbashi, Africa/Lusaka, Africa/Malabo, Africa/Maputo, Africa/Maseru, Africa/Mbabane, Africa/Mogadishu, Africa/Monrovia, Africa/Nairobi, Africa/Ndjamena, Africa/Niamey, Africa/Nouakchott, Africa/Ouagadougou, Africa/Porto-Novo, Africa/Sao_Tome, Africa/Seychelles, Africa/Timbuktu, Africa/Tripoli, Africa/Tunis, Africa/Windhoek, America/Adak, America/Amazon, America/Anchorage, America/Anguilla, America/Antigua, America/Araguaina, America/Argentina/Catamarca, America/Argentina/ComodRivadavia, America/Argentina/Cordoba, America/Argentina/Jujuy, America/Argentina/La_Rioja, America/Argentina/Mendoza, America/Argentina/Rio_Gallegos, America/Argentina/Salta, America/Argentina/San_Juan, America/Argentina/San_Luis, America/Argentina/Tucuman, America/Argentina/Ushuaia, America/Aruba, America/Asuncion, America/Atikokan, America/Atka, America/Bahia, America/Baker Island, America/Bahia_Banderas, America/Barbados, America/Belem, America/Belize, America/Blanc-Sablon, America/Boa_Vista, America/Bogota, America/Boise, America/Bolivia, America/Brasilia, America/Buenos_Aires, America/Cambridge_Bay, America/Campo_Grande, America/Cancun, America/Caracas, America/Catamarca, America/Cayenne, America/Cayman, America/Chicago, America/Chihuahua, America/Colombia Summer, America/Colombia, America/Coral_Harbour, America/Cordoba, America/Costa_Rica, America/Creston, America/Cuiaba, America/Curacao, America/Danmarkshavn, America/Dawson, America/Dawson_Creek, America/Denver, America/Detroit, America/Dominica, America/Edmonton, America/Eirunepe, America/El_Salvador, America/Ensenada, America/Ecuador, America/Falkland Islands Standard, America/Falkland Islands Summer, America/Falkland Islands, America/Fernando de Noronha, America/Fort_Wayne, America/Fortaleza, America/Glace_Bay, America/Godthab, America/Goose_Bay, America/Grand_Turk, America/Grenada, America/Guadeloupe, America/Guatemala, America/Guayaquil, America/Guyana, America/Halifax, America/Havana, America/Hawaii-Aleutian Daylight, America/Hawaii-Aleutian Standard, America/Hermosillo, America/Indiana/Indianapolis, America/Indiana/Knox, America/Indiana/Marengo, America/Indiana/Petersburg, America/Indiana/Tell_City, America/Indiana/Vevay, America/Indiana/Vincennes, America/Indiana/Winamac, America/Indianapolis, America/Inuvik, America/Iqaluit, America/Jamaica, America/Jujuy, America/Juneau, America/Kentucky/Louisville, America/Kentucky/Monticello, America/Knox_IN, America/Kralendijk, America/La_Paz, America/Lima, America/Los_Angeles, America/Louisville, America/Lower_Princes, America/Maceio, America/Managua, America/Manaus, America/Marigot, America/Martinique, America/Matamoros, America/Mazatlan, America/Mendoza, America/Menominee, America/Merida, America/Metlakatla, America/Mexico_City, America/Miquelon, America/Moncton, America/Monterrey, America/Montevideo, America/Montreal, America/Montserrat, America/Nassau, America/New_York, America/Nipigon, America/Nome, America/Noronha, America/North_Dakota/Beulah, America/North_Dakota/Center, America/North_Dakota/New_Salem, America/Ojinaga, America/Panama, America/Pangnirtung, America/Paraguay Summer, America/Paraguay, America/Paramaribo, America/Peru, America/Phoenix, America/Port_of_Spain, America/Port-au-Prince, America/Porto_Acre, America/Porto_Velho, America/Puerto_Rico, America/Rainy_River, America/Rankin_Inlet, America/Recife, America/Regina, America/Resolute, America/Rio_Branco, America/Rosario, America/Saint Pierre and Miquelon Standard, America/Santa_Isabel, America/Santarem, America/Santiago, America/Santo_Domingo, America/Sao_Paulo, America/Scoresbysund, America/Shiprock, America/Sitka, America/St_Barthelemy, America/St_Johns, America/St_Kitts, America/St_Lucia, America/St_Thomas, America/St_Vincent, America/Suriname, America/Swift_Current, America/Tegucigalpa, America/Thule, America/Thunder_Bay, America/Tijuana, America/Toronto, America/Tortola, America/Uruguay Summer, America/Uruguay Standard, America/Vancouver, America/Venezuelan Standard, America/Virgin, America/Whitehorse, America/Winnipeg, America/Yakutat, America/Yellowknife, Antarctica/Casey, Antarctica/Davis, Antarctica/DumontDUrville, Antarctica/Macquarie, Antarctica/Mawson, Antarctica/McMurdo, Antarctica/Palmer, Antarctica/Rothera, Antarctica/Showa Station, Antarctica/South_Pole, Antarctica/Syowa, Antarctica/Troll, Antarctica/Vostok, Arctic/Longyearbyen, Asia/Aden, Asia/Afghanistan, Asia/Almaty, Asia/Amman, Asia/Anadyr, Asia/Aqtau, Asia/Aqtobe, Asia/Armenia,Asia/Ashgabat, Asia/Ashkhabad, Asia/Azerbaijan, Asia/Baghdad, Asia/Bahrain, Asia/Baku, Asia/Bangkok, Asia/Beirut, Asia/Bhutan, Asia/Bishkek, Asia/Brunei, Asia/Calcutta, Asia/Central Indonesia, Asia/China Standard, Asia/China, Asia/Choibalsan, Asia/Chongqing, Asia/Chungking, Asia/Colombo, Asia/Dacca, Asia/Damascus, Asia/Dhaka, Asia/Dili, Asia/Dubai, Asia/Dumont d'Urville, Asia/Dushanbe, Asia/Gaza, Asia/Gulf Standard, Asia/Harbin, Asia/Hebron, Asia/Ho_Chi_Minh, Asia/Hong Kong, Asia/Hovd, Asia/Indochina, Asia/Irkutsk, Asia/Istanbul, Asia/Jakarta, Asia/Jayapura, Asia/Jerusalem, Asia/Kabul, Asia/Kamchatka, Asia/Karachi, Asia/Kashgar, Asia/Kathmandu, Asia/Katmandu, Asia/Khandyga, Asia/Khovd, Asia/Kolkata, Asia/Krasnoyarsk, Asia/Kuala_Lumpur, Asia/Kyrgyzstan, Asia/Kuching, Asia/Kuwait, Asia/Macao, Asia/Macau, Asia/Magadan, Asia/Makassar, Asia/Malaysia, Asia/Malaysia Standard, Asia/Manila, Asia/Muscat, Asia/Myanmar, Asia/Nepal, Asia/Nicosia, Asia/Novokuznetsk, Asia/Novosibirsk, Asia/Omsk, Asia/Oral, Asia/Pakistan Standard, Asia/Philippine, Asia/Phnom_Penh, Asia/Pontianak, Asia/Pyongyang, Asia/Qatar, Asia/Qyzylorda, Asia/Rangoon, Asia/Riyadh, Asia/Saigon, Asia/Sakhalin, Asia/Samarkand, Asia/Seoul, Asia/Shanghai, Asia/Singapore, Asia/South Georgia and the South Sandwich Islands, Asia/Sri Lanka, Asia/Taipei, Asia/Tajikistan, Asia/Tashkent, Asia/Tbilisi, Asia/Tehran, Asia/Tel_Aviv, Asia/Thailand Standard, Asia/Thimbu, Asia/Thimphu, Asia/Timor Leste, Asia/Tokyo, Asia/Turkmenistan, Asia/Ujung_Pandang, Asia/Ulaanbaatar, Asia/Ulan_Bator, Asia/Urumqi, Asia/Ust-Nera, Asia/Uzbekistan, Asia/Vientiane, Asia/Vladivostok, Asia/Yakutsk, Asia/Yekaterinburg, Asia/Yerevan, Atlantic/Azores, Atlantic/Bermuda, Atlantic/Canary, Atlantic/Cape_Verde, Atlantic/Faeroe, Atlantic/Faroe, Atlantic/Jan_Mayen, Atlantic/Madeira, Atlantic/Reykjavik, Atlantic/South_Georgia, Atlantic/St_Helena, Atlantic/Stanley, Australia/ACT, Australia/Adelaide, Australia/Brisbane, Australia/Broken_Hill, Australia/Canberra, Australia/Currie, Australia/Darwin, Australia/Eucla, Australia/Heard and McDonald Islands, Australia/Hobart, Australia/LHI, Australia/Lindeman, Australia/Lord Howe Standard, Australia/Lord Howe Summer, Australia/Melbourne, Australia/North, Australia/NSW, Australia/Perth, Australia/Queensland, Australia/South,Australia/Sydney, Australia/Tasmania, Australia/Victoria, Australia/West, Australia/Yancowinna, Brazil/Acre, Brazil/DeNoronha, Brazil/East, Brazil/West, Canada/Atlantic, Canada/Central, Canada/Eastern, Canada/East-Saskatchewan, Canada/Mountain, Canada/Newfoundland, Canada/Pacific, Canada/Saskatchewan, Canada/Yukon, Caribbean/Eastern Caribbean, Chile/Continental, Chile/EasterIsland, Cuba, Egypt, Eire, Etc/GMT, Etc/GMT+0, Etc/UCT, Etc/Universal, Etc/UTC, Etc/Zulu, Europe/AIX specific equivalent of Central European, Europe/Amsterdam, Europe/Andorra, Europe/Athens, Europe/Belfast, Europe/Belgrade, Europe/Berlin, Europe/Bratislava, Europe/British Summer, Europe/Brussels, Europe/Bucharest, Europe/Budapest, Europe/Busingen, Europe/Chisinau, Europe/Copenhagen, Europe/Dublin, Europe/Gibraltar, Europe/Guernsey, Europe/Helsinki, Europe/Heure Avancée d'Europe Centrale francised name for CEST, Europe/Irish Standard, Europe/Isle_of_Man, Europe/Istanbul, Europe/Jersey, Europe/Kaliningrad, Europe/Kiev, Europe/Lisbon, Europe/Ljubljana, Europe/London, Europe/Luxembourg, Europe/Madrid, Europe/Malta, Europe/Mariehamn, Europe/Minsk, Europe/Monaco, Europe/Moscow, Europe/Nicosia, Europe/Oslo, Europe/Paris, Europe/Podgorica, Europe/Prague, Europe/Riga, Europe/Rome, Europe/Samara, Europe/San_Marino, Europe/Sarajevo, Europe/Simferopol, Europe/Skopje, Europe/Sofia, Europe/Stockholm, Europe/Tallinn, Europe/Tirane, Europe/Tiraspol, Europe/Uzhgorod, Europe/Vaduz, Europe/Vatican, Europe/Vienna, Europe/Vilnius, Europe/Volgograd, Europe/Warsaw, Europe/Zagreb, Europe/Zaporozhye, Europe/Zurich, GB, GB-Eire, GMT, GMT+0, GMT0, GMT-0, Greenwich, Hongkong, Iceland, Indian/Antananarivo, Indian/Chagos, Indian/British Indian Ocean, Indian/Christmas, Indian/Cocos, Indian/Comoro, Indian/Indian Standard, Indian/Kerguelen, Indian/Mahe, Indian/Maldives, Indian/Mauritius, Indian/Mayotte, Indian/Reunion, Iran, Israel, Jamaica, Japan, Kwajalein, Libya, Mexico/BajaNorte, Mexico/BajaSur, Mexico/General, Navajo, NZ, NZ-CHAT, Pacific/Apia, Pacific/Auckland, Pacific/Chamorro, Pacific/Chatham, Pacific/Chuuk, Pacific/Clipperton, Pacific/Cook Island, Pacific/Easter Island Standard, Pacific/EasterIsland Summer, Pacific/Efate, Pacific/Enderbury, Pacific/Fakaofo, Pacific/Fiji, Pacific/Funafuti, Pacific/Galapagos, Pacific/Gambier, Pacific/Gilbert Island, Pacific/Guadalcanal, Pacific/Guam, Pacific/Honolulu, Pacific/Johnston, Pacific/Kiritimati, Pacific/Kosrae, Pacific/Kwajalein, Pacific/Line Islands, Pacific/Majuro, Pacific/Marquesas, Pacific/Marshall Islands, Pacific/Midway, Pacific/Nauru, Pacific/New Caledonia, Pacific/New Zealand Daylight, Pacific/NewZealand Standard, Pacific/Niue, Pacific/Norfolk, Pacific/Noumea, Pacific/Pago_Pago, Pacific/Palau, Pacific/Papua New Guinea, Pacific/Pitcairn, Pacific/Pohnpei, Pacific/Ponape, Pacific/Port_Moresby, Pacific/Rarotonga, Pacific/Saipan, Pacific/Samoa, Pacific/Solomon Islands, Pacific/Tahiti, Pacific/Tarawa, Pacific/Tokelau, Pacific/Tongatapu, Pacific/Truk, Pacific/Tuvalu, Pacific/Vanuatu, Pacific/Wake, Pacific/Wallis, Pacific/Yap, Poland, Portugal, PRC, ROC, ROK, Singapore, Turkey, UCT, Universal/Universal Time Coordinated, US/Alaska, US/Aleutian, US/Arizona, US/Central, US/Eastern, US/East-Indiana, US/Hawaii, US/Indiana-Starke, US/Michigan, US/Mountain, US/Pacific, US/Samoa, UTC, W-SU, Zulu

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

		.Parameter ValidateDNSEntries
			Specifies whether to perform DNS resolution validation of the networking information. If set to true, lookups for both forward (A) and reverse (PTR) records will be confirmed to match.

		.Parameter PowerOn
			Specifies whether to power on the imported appliance once the import completes.

		.Notes
			Author: Steve Kaplan (steve@intolerable.net)

		.Example
			Connect-VIServer vCenter.example.com
			
			$config = @{
				OVFPath = "c:\temp\vrealize-operations.ova"
				DeploymentSize = "small"
				Name = "vROPS1"
				Timezone = "US/Pacific"
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
			New-vRealizeOperationsAppliance @config

   			Description
   			-----------
			Deploy the vRealize Operations appliance with static IP settings and power it on after the import finishes. 
			In this example, the Verbose flag is being passed, so all OVF properties will be shown as part of the output

		.Example
			Connect-VIServer vCenter.example.com
			
			$config = @{
				OVFPath = "c:\temp\vrealize-operations.ova"
				DeploymentSize = "small"
				Timezone = "US/Pacific"
				Name = "vROPS1"
				VMHost = (Get-VMHost -Name "host1.example.com")
				InventoryLocation = (Get-Folder -Type VM -Name "Appliances")
				Network = "admin-network"
				DHCP = $true
				PowerOn = $true
				Verbose = $true
			}
			New-vRealizeOperationsAppliance @config

   			Description
   			-----------
			Deploy the vRealize Operations appliance with DHCP settings and and do not power it on after the import finishes
	#>
	[CmdletBinding(SupportsShouldProcess=$true,DefaultParameterSetName="Static")]
	[OutputType('VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine')]
	Param (
		[Alias("OVA","OVF")]
		[Parameter(Mandatory=$true,ParameterSetName="DHCP")]
		[Parameter(Mandatory=$true,ParameterSetName="Static")]
		[System.IO.FileInfo]$OVFPath,

		[Alias("Size","DeploymentType")]
		[Parameter(Mandatory=$true,ParameterSetName="DHCP")]
		[Parameter(Mandatory=$true,ParameterSetName="Static")]
		[ValidateSet("xsmall","small","medium","large","xlarge","smallrc","largerc")]
		[String]$DeploymentSize = "small",

		[Parameter(Mandatory=$true,ParameterSetName="DHCP")]
		[Parameter(Mandatory=$true,ParameterSetName="Static")]
		[ValidateNotNullOrEmpty()]
		[String]$Name,

		[Parameter(ParameterSetName="DHCP")]
		[Parameter(ParameterSetName="Static")]
		[ValidateSet("America/Argentina/Buenos_Aires","Etc/GMT-1","Africa/Abidjan","Africa/Accra","Africa/Addis_Ababa","Africa/Algiers","Africa/Asmara","Africa/Asmera","Africa/Bamako","Africa/Bangui","Africa/Banjul","Africa/Bissau","Africa/Blantyre","Africa/Brazzaville","Africa/Bujumbura","Africa/Cairo","Africa/Cape Verde","Africa/Casablanca","Africa/Ceuta","Africa/Conakry","Africa/Dakar","Africa/Dar_es_Salaam","Africa/Djibouti","Africa/Douala","Africa/El_Aaiun","Africa/Freetown","Africa/Gaborone","Africa/Harare","Africa/Johannesburg","Africa/Juba","Africa/Kampala","Africa/Khartoum","Africa/Kigali","Africa/Kinshasa","Africa/Lagos","Africa/Libreville","Africa/Lome","Africa/Luanda","Africa/Lubumbashi","Africa/Lusaka","Africa/Malabo","Africa/Maputo","Africa/Maseru","Africa/Mbabane","Africa/Mogadishu","Africa/Monrovia","Africa/Nairobi","Africa/Ndjamena","Africa/Niamey","Africa/Nouakchott","Africa/Ouagadougou","Africa/Porto-Novo","Africa/Sao_Tome","Africa/Seychelles","Africa/Timbuktu","Africa/Tripoli","Africa/Tunis","Africa/Windhoek","America/Adak","America/Amazon","America/Anchorage","America/Anguilla","America/Antigua","America/Araguaina","America/Argentina/Catamarca","America/Argentina/ComodRivadavia","America/Argentina/Cordoba","America/Argentina/Jujuy","America/Argentina/La_Rioja","America/Argentina/Mendoza","America/Argentina/Rio_Gallegos","America/Argentina/Salta","America/Argentina/San_Juan","America/Argentina/San_Luis","America/Argentina/Tucuman","America/Argentina/Ushuaia","America/Aruba","America/Asuncion","America/Atikokan","America/Atka","America/Bahia","America/Baker Island","America/Bahia_Banderas","America/Barbados","America/Belem","America/Belize","America/Blanc-Sablon","America/Boa_Vista","America/Bogota","America/Boise","America/Bolivia","America/Brasilia","America/Buenos_Aires","America/Cambridge_Bay","America/Campo_Grande","America/Cancun","America/Caracas","America/Catamarca","America/Cayenne","America/Cayman","America/Chicago","America/Chihuahua","America/Colombia Summer","America/Colombia","America/Coral_Harbour","America/Cordoba","America/Costa_Rica","America/Creston","America/Cuiaba","America/Curacao","America/Danmarkshavn","America/Dawson","America/Dawson_Creek","America/Denver","America/Detroit","America/Dominica","America/Edmonton","America/Eirunepe","America/El_Salvador","America/Ensenada","America/Ecuador","America/Falkland Islands Standard","America/Falkland Islands Summer","America/Falkland Islands","America/Fernando de Noronha","America/Fort_Wayne","America/Fortaleza","America/Glace_Bay","America/Godthab","America/Goose_Bay","America/Grand_Turk","America/Grenada","America/Guadeloupe","America/Guatemala","America/Guayaquil","America/Guyana","America/Halifax","America/Havana","America/Hawaii-Aleutian Daylight","America/Hawaii-Aleutian Standard","America/Hermosillo","America/Indiana/Indianapolis","America/Indiana/Knox","America/Indiana/Marengo","America/Indiana/Petersburg","America/Indiana/Tell_City","America/Indiana/Vevay","America/Indiana/Vincennes","America/Indiana/Winamac","America/Indianapolis","America/Inuvik","America/Iqaluit","America/Jamaica","America/Jujuy","America/Juneau","America/Kentucky/Louisville","America/Kentucky/Monticello","America/Knox_IN","America/Kralendijk","America/La_Paz","America/Lima","America/Los_Angeles","America/Louisville","America/Lower_Princes","America/Maceio","America/Managua","America/Manaus","America/Marigot","America/Martinique","America/Matamoros","America/Mazatlan","America/Mendoza","America/Menominee","America/Merida","America/Metlakatla","America/Mexico_City","America/Miquelon","America/Moncton","America/Monterrey","America/Montevideo","America/Montreal","America/Montserrat","America/Nassau","America/New_York","America/Nipigon","America/Nome","America/Noronha","America/North_Dakota/Beulah","America/North_Dakota/Center","America/North_Dakota/New_Salem","America/Ojinaga","America/Panama","America/Pangnirtung","America/Paraguay Summer","America/Paraguay","America/Paramaribo","America/Peru","America/Phoenix","America/Port_of_Spain","America/Port-au-Prince","America/Porto_Acre","America/Porto_Velho","America/Puerto_Rico","America/Rainy_River","America/Rankin_Inlet","America/Recife","America/Regina","America/Resolute","America/Rio_Branco","America/Rosario","America/Saint Pierre and Miquelon Standard","America/Santa_Isabel","America/Santarem","America/Santiago","America/Santo_Domingo","America/Sao_Paulo","America/Scoresbysund","America/Shiprock","America/Sitka","America/St_Barthelemy","America/St_Johns","America/St_Kitts","America/St_Lucia","America/St_Thomas","America/St_Vincent","America/Suriname","America/Swift_Current","America/Tegucigalpa","America/Thule","America/Thunder_Bay","America/Tijuana","America/Toronto","America/Tortola","America/Uruguay Summer","America/Uruguay Standard","America/Vancouver","America/Venezuelan Standard","America/Virgin","America/Whitehorse","America/Winnipeg","America/Yakutat","America/Yellowknife","Antarctica/Casey","Antarctica/Davis","Antarctica/DumontDUrville","Antarctica/Macquarie","Antarctica/Mawson","Antarctica/McMurdo","Antarctica/Palmer","Antarctica/Rothera","Antarctica/Showa Station","Antarctica/South_Pole","Antarctica/Syowa","Antarctica/Troll","Antarctica/Vostok","Arctic/Longyearbyen","Asia/Aden","Asia/Afghanistan","Asia/Almaty","Asia/Amman","Asia/Anadyr","Asia/Aqtau","Asia/Aqtobe","Asia/Armenia","Asia/Ashgabat","Asia/Ashkhabad","Asia/Azerbaijan","Asia/Baghdad","Asia/Bahrain","Asia/Baku","Asia/Bangkok","Asia/Beirut","Asia/Bhutan","Asia/Bishkek","Asia/Brunei","Asia/Calcutta","Asia/Central Indonesia","Asia/China Standard","Asia/China","Asia/Choibalsan","Asia/Chongqing","Asia/Chungking","Asia/Colombo","Asia/Dacca","Asia/Damascus","Asia/Dhaka","Asia/Dili","Asia/Dubai","Asia/Dumont d'Urville","Asia/Dushanbe","Asia/Gaza","Asia/Gulf Standard","Asia/Harbin","Asia/Hebron","Asia/Ho_Chi_Minh","Asia/Hong Kong","Asia/Hovd","Asia/Indochina","Asia/Irkutsk","Asia/Istanbul","Asia/Jakarta","Asia/Jayapura","Asia/Jerusalem","Asia/Kabul","Asia/Kamchatka","Asia/Karachi","Asia/Kashgar","Asia/Kathmandu","Asia/Katmandu","Asia/Khandyga","Asia/Khovd","Asia/Kolkata","Asia/Krasnoyarsk","Asia/Kuala_Lumpur","Asia/Kyrgyzstan","Asia/Kuching","Asia/Kuwait","Asia/Macao","Asia/Macau","Asia/Magadan","Asia/Makassar","Asia/Malaysia","Asia/Malaysia Standard","Asia/Manila","Asia/Muscat","Asia/Myanmar","Asia/Nepal","Asia/Nicosia","Asia/Novokuznetsk","Asia/Novosibirsk","Asia/Omsk","Asia/Oral","Asia/Pakistan Standard","Asia/Philippine","Asia/Phnom_Penh","Asia/Pontianak","Asia/Pyongyang","Asia/Qatar","Asia/Qyzylorda","Asia/Rangoon","Asia/Riyadh","Asia/Saigon","Asia/Sakhalin","Asia/Samarkand","Asia/Seoul","Asia/Shanghai","Asia/Singapore","Asia/South Georgia and the South Sandwich Islands","Asia/Sri Lanka","Asia/Taipei","Asia/Tajikistan","Asia/Tashkent","Asia/Tbilisi","Asia/Tehran","Asia/Tel_Aviv","Asia/Thailand Standard","Asia/Thimbu","Asia/Thimphu","Asia/Timor Leste","Asia/Tokyo","Asia/Turkmenistan","Asia/Ujung_Pandang","Asia/Ulaanbaatar","Asia/Ulan_Bator","Asia/Urumqi","Asia/Ust-Nera","Asia/Uzbekistan","Asia/Vientiane","Asia/Vladivostok","Asia/Yakutsk","Asia/Yekaterinburg","Asia/Yerevan","Atlantic/Azores","Atlantic/Bermuda","Atlantic/Canary","Atlantic/Cape_Verde","Atlantic/Faeroe","Atlantic/Faroe","Atlantic/Jan_Mayen","Atlantic/Madeira","Atlantic/Reykjavik","Atlantic/South_Georgia","Atlantic/St_Helena","Atlantic/Stanley","Australia/ACT","Australia/Adelaide","Australia/Brisbane","Australia/Broken_Hill","Australia/Canberra","Australia/Currie","Australia/Darwin","Australia/Eucla","Australia/Heard and McDonald Islands","Australia/Hobart","Australia/LHI","Australia/Lindeman","Australia/Lord Howe Standard","Australia/Lord Howe Summer","Australia/Melbourne","Australia/North","Australia/NSW","Australia/Perth","Australia/Queensland","Australia/South","Australia/Sydney","Australia/Tasmania","Australia/Victoria","Australia/West","Australia/Yancowinna","Brazil/Acre","Brazil/DeNoronha","Brazil/East","Brazil/West","Canada/Atlantic","Canada/Central","Canada/Eastern","Canada/East-Saskatchewan","Canada/Mountain","Canada/Newfoundland","Canada/Pacific","Canada/Saskatchewan","Canada/Yukon","Caribbean/Eastern Caribbean","Chile/Continental","Chile/EasterIsland","Cuba","Egypt","Eire","Etc/GMT","Etc/GMT+0","Etc/UCT","Etc/Universal","Etc/UTC","Etc/Zulu","Europe/AIX specific equivalent of Central European","Europe/Amsterdam","Europe/Andorra","Europe/Athens","Europe/Belfast","Europe/Belgrade","Europe/Berlin","Europe/Bratislava","Europe/British Summer","Europe/Brussels","Europe/Bucharest","Europe/Budapest","Europe/Busingen","Europe/Chisinau","Europe/Copenhagen","Europe/Dublin","Europe/Gibraltar","Europe/Guernsey","Europe/Helsinki","Europe/Heure Avancée d'Europe Centrale francised name for CEST","Europe/Irish Standard","Europe/Isle_of_Man","Europe/Istanbul","Europe/Jersey","Europe/Kaliningrad","Europe/Kiev","Europe/Lisbon","Europe/Ljubljana","Europe/London","Europe/Luxembourg","Europe/Madrid","Europe/Malta","Europe/Mariehamn","Europe/Minsk","Europe/Monaco","Europe/Moscow","Europe/Nicosia","Europe/Oslo","Europe/Paris","Europe/Podgorica","Europe/Prague","Europe/Riga","Europe/Rome","Europe/Samara","Europe/San_Marino","Europe/Sarajevo","Europe/Simferopol","Europe/Skopje","Europe/Sofia","Europe/Stockholm","Europe/Tallinn","Europe/Tirane","Europe/Tiraspol","Europe/Uzhgorod","Europe/Vaduz","Europe/Vatican","Europe/Vienna","Europe/Vilnius","Europe/Volgograd","Europe/Warsaw","Europe/Zagreb","Europe/Zaporozhye","Europe/Zurich","GB","GB-Eire","GMT","GMT+0","GMT0","GMT-0","Greenwich","Hongkong","Iceland","Indian/Antananarivo","Indian/Chagos","Indian/British Indian Ocean","Indian/Christmas","Indian/Cocos","Indian/Comoro","Indian/Indian Standard","Indian/Kerguelen","Indian/Mahe","Indian/Maldives","Indian/Mauritius","Indian/Mayotte","Indian/Reunion","Iran","Israel","Jamaica","Japan","Kwajalein","Libya","Mexico/BajaNorte","Mexico/BajaSur","Mexico/General","Navajo","NZ","NZ-CHAT","Pacific/Apia","Pacific/Auckland","Pacific/Chamorro","Pacific/Chatham","Pacific/Chuuk","Pacific/Clipperton","Pacific/Cook Island","Pacific/Easter Island Standard","Pacific/EasterIsland Summer","Pacific/Efate","Pacific/Enderbury","Pacific/Fakaofo","Pacific/Fiji","Pacific/Funafuti","Pacific/Galapagos","Pacific/Gambier","Pacific/Gilbert Island","Pacific/Guadalcanal","Pacific/Guam","Pacific/Honolulu","Pacific/Johnston","Pacific/Kiritimati","Pacific/Kosrae","Pacific/Kwajalein","Pacific/Line Islands","Pacific/Majuro","Pacific/Marquesas","Pacific/Marshall Islands","Pacific/Midway","Pacific/Nauru","Pacific/New Caledonia","Pacific/New Zealand Daylight","Pacific/New Zealand Standard","Pacific/Niue","Pacific/Norfolk","Pacific/Noumea","Pacific/Pago_Pago","Pacific/Palau","Pacific/Papua New Guinea","Pacific/Pitcairn","Pacific/Pohnpei","Pacific/Ponape","Pacific/Port_Moresby","Pacific/Rarotonga","Pacific/Saipan","Pacific/Samoa","Pacific/Solomon Islands","Pacific/Tahiti","Pacific/Tarawa","Pacific/Tokelau","Pacific/Tongatapu","Pacific/Truk","Pacific/Tuvalu","Pacific/Vanuatu","Pacific/Wake","Pacific/Wallis","Pacific/Yap","Poland","Portugal","PRC","ROC","ROK","Singapore","Turkey","UCT","Universal/Universal Time Coordinated","US/Alaska","US/Aleutian","US/Arizona","US/Central","US/Eastern","US/East-Indiana","US/Hawaii","US/Indiana-Starke","US/Michigan","US/Mountain","US/Pacific","US/Samoa","UTC","W-SU","Zulu")]
		[string]$Timezone = "Etc/UTC",

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
			if ($Timezone) { $ovfconfig.Common.vamitimezone.value = $Timezone }	

			# Setting Networking Values
			Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Assigning Networking Values"
			$ovfconfig.IpAssignment.IpProtocol.Value = "IPv4" # IP Protocol Value
			if ($IPProtocol -eq "IPv6") { $ovfconfig.Common.forceIpv6.value = $true }
			$ovfconfig.NetworkMapping.Network_1.value = $Network; # vSphere Portgroup Network Mapping

			if ($PsCmdlet.ParameterSetName -eq "Static") {
				$ovfconfig.vami.$vami.ip0.value = $IPAddress
				$ovfconfig.vami.$vami.netmask0.value = $SubnetMask
				$ovfconfig.vami.$vami.gateway.value = $Gateway
				$ovfconfig.vami.$vami.DNS.value = $DNSServers -join ","
			}

            # Verbose logging passthrough
            Write-OVFValues -ovfconfig $ovfconfig -Verbose:$VerbosePreference

			# Returning the OVF Configuration to the function
			$ovfconfig
		}

		else { throw "The provided file '$($OVFPath)' is not a valid OVA/OVF; please check the path/file and try again" }
	}

	try {
		$Activity = "Deploying a new vRealize Operations Appliance"
		
		# Validating Components
        $VMHost = Confirm-VMHost -VMHost $VMHost -Location $Location -Verbose:$VerbosePreference
        Confirm-BackingNetwork -Network $Network -Verbose:$VerbosePreference
        $Gateway = Set-DefaultGateway -Gateway $Gateway -Verbose:$VerbosePreference

		# Configuring the OVF Template and deploying the appliance
		$ovfconfig = New-Configuration
		if ($ovfconfig) {
			if ($PSCmdlet.ShouldProcess($OVFPath.FullName, "Import-Appliance")) { Import-Appliance -Verbose:$VerbosePreference }
			else { 
				if ($VerbosePreference -eq "SilentlyContinue") { Write-OVFValues -ovfconfig $ovfconfig -Type "Standard" }
			}
		}
		
		else { throw $noOvfConfiguration }
	}
	
	catch { Write-Error $_ }
}

# Adding aliases and exporting this funtion when the module gets loaded
New-Alias  -Value New-vRealizeOperationsAppliance -Name New-vROPS
Export-ModuleMember -Function New-vRealizeOperationsAppliance -Alias @("New-vROPS")