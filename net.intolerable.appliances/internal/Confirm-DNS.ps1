<#
	.Description
		Performs a few checks!
			1) Will set the FQDN value to name of appliance + provided domain *if* both are provided and FQDN is not provided separately.
			2) Will confirm that the DNS A record for the FQDN resolves to the provided IP address
			3) Will confirm that the DNS PTR record for the IP Address resolves to the FQDN

		#2 and #3 will only occur *if* the -ValidateDns switch is passed via the appliance wrapper function
#>
Function Confirm-DNS {
	Param (
        [ValidateNotNullOrEmpty()]
		[String]$Name,
        [String]$Domain,
        [String]$FQDN,
        [String]$IPAddress,
        [String[]]$DnsServers,
        [bool]$ValidateDns
	)
	
	$Status = "DNS Validation"
	# Checking / Setting the FQDN
	if (!$FQDN) {
		Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Setting FQDN for the appliance"
		if ($Domain) { $FQDN = $Name, $Domain -join "." }
		else { throw "A fully qualified domain name must be provided. Either pass in the FQDN using the -FQDN parameter or pass in a domain name using the -Domain parameter and it will be appended to the name provided for the appliance" }
	}

	if ($ValidateDns -eq $true) {
		# Verifying forward DNS Record
		Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Validating forward DNS record is correct"
		$forwardLookup = Resolve-DnsName -Name $FQDN -Server $DnsServers -DnsOnly -ErrorAction SilentlyContinue | Where-Object { $_.Type -eq "A" }
		if (!$forwardLookup) { throw "The provided DNS servers were unable to resolve the FQDN '$($FQDN)'. Please make sure there is an A record and it can be resolved by the DNS servers specified in this request." }
		else {
			if ($IPAddress -ne $forwardLookup.IPAddress) { throw "The FQDN $($FQDN) is resolving to '$($forwardLookup.IPAddress)', not the expected value of $($IPAddress). Confirm whether the record is correct." }
		}
		# Verifying reverse DNS Record
		Write-Progress -Activity $Activity -Status $Status -CurrentOperation "Validating reverse DNS record is correct"
		$reverseLookup = Resolve-DnsName -Name $IPAddress -Server $DnsServers -DnsOnly -ErrorAction SilentlyContinue | Where-Object { $_.Type -eq "PTR" }
		if (!$reverseLookup) { throw "The provided DNS servers were unable to resolve the IP Address '$($IPAddress)' to a FQDN. Please make sure there is a PTR record and it can be resolved by the DNS servers specified in this request." }
		else {
			if ($FQDN -ne $reverseLookup.NameHost) { throw "The IP Address '$($IPAddress)' is resolving to a hostname of '$($reverseLookup.NameHost)', rather than the expected value of '$($FQDN)', from the provided DNS servers. Confirm whether the record is correct." }
		}
	}

	# Returning the FQDN
	$FQDN
}