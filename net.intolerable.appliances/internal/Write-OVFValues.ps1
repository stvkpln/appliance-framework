Function Write-OVFValues {
	Param (
		$ovfconfig,
		[String]$Type
	) 
	
	$ovfvalues = $ovfconfig.ToHashTable()
	$output = "OVF Values are:" + ($ovfvalues | Out-String)

	switch ($Type) {
		"Verbose" { Write-Verbose -Message $output }
		Default { Write-Host $output }
	}
}