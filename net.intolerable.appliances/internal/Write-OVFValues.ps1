Function Write-OVFValues {
	Param (
		[VMware.VimAutomation.ViCore.Types.V1.Ovf.OvfConfiguration]$ovfconfig,
		[String]$Type
	)

	# Setting the name of the function and invoking opening verbose logging message
	Write-Verbose -Message (Get-FormattedMessage -Message "$($MyInvocation.MyCommand) Started execution")

	# Converting to a hashtable for easier presentation
	$ovfvalues = $ovfconfig.ToHashTable()
	
	# Creating the text that will be outputted to the console
	$output = "OVF Values are:" + ($ovfvalues | Out-String)

	switch ($Type) {
		# Using Write-Verbose if the 'Type' passed in is set to "Verbose"
		"Verbose" { 
			Write-Verbose -Message (Get-FormattedMessage -Message $output)
			break
		} 

		# Using Write-Host if the 'Type' passed in is set to anything other than "Verbose"
		Default { Write-Host $output }
	}

	# Verbose logging output to finish things off
	Write-Verbose -Message (Get-FormattedMessage -Message "$($MyInvocation.MyCommand) Finished execution")
}
