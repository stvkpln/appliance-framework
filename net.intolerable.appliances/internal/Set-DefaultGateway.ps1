<#
	.Description
		This will configure a default gateway if an IP address is provided and the netmask is a /24 (255.255.255.0). The default gateway provided will be .1 of the /24 network.

	.Notes
		This is intended to be a convenience function in case you don't want to provide a value and you use .1 as your gateway of choice. 
		If there is a different default value, this can be configured inside the config.json file in the module root and it will be configured at module load time.
		If you change this value in the config.json, please import the module again with the -force parameter
#>
Function Set-DefaultGateway {
	Param (
		[string]$IPAddress,
		[string]$FourthOctet,
		[string]$SubnetMask,
		[String]$Gateway
	)

	# Setting the name of the function and invoking opening verbose logging message
	Write-Verbose -Message (Get-FormattedMessage -Message "$($MyInvocation.MyCommand) Started execution")

	# Returning the Gateway if one is specified
	if ($Gateway) { $Gateway }

	<# Defining a Gateway if one is not provided *if*:
		1) There is a defined default fourth octet in the config.json file
		2) The subnet mask is a standard class C (/24 or 255.255.255.0) #>
	elseif (!$Gateway -and $SubnetMask -eq "255.255.255.0" -and $FourthOctet) { 
		Write-Progress -Activity $Activity -Status "Setting default gateway for Class C IP Address"
		$ipaddr = $IPAddress.split(".")
		$ipaddr[3] = $FourthOctet
		$ipaddr -join "."
	}

	else { throw "Default gateway must be provided due to the subnet mask not being a standard /24. Provide using the -Gateway parameter" }

	# Verbose logging output to finish things off
	Write-Verbose -Message (Get-FormattedMessage -Message "$($MyInvocation.MyCommand) Finished execution")
}
