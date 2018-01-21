# Environmental variables imported from config.json
$ApplianceConfiguration = Get-Content -Path "$($psScriptRoot)\config.json" | ConvertFrom-Json
$FourthOctet = $ApplianceConfiguration.FourthOctet

# Importing all internal framework functions that get used by all of the appliances
$internals = Get-ChildItem -Path "$($psScriptRoot)\internal" -Filter *.ps1
foreach ($internal in $internals) {
	Write-Progress -Activity "Importing internal functions" -Status $internal.BaseName
	. $internal.FullName 
}

# Importing all Appliance Deployment Wrapper Functions
$appliances = Get-ChildItem -Path "$($psScriptRoot)\appliances" -Filter *.ps1
foreach ($appliance in $appliances) { 
	Write-Progress -Activity "Importing virtual appliance wrapper functions" -Status $appliance.BaseName
	. $appliance.FullName 
}

# Common error messages generated across the module
$noOvfConfiguration = "A generated OVF configuration was not passed back into the function; check the New-Configuration function for this appliance"
$invalidFile = "The file provided in the OVFPath parameter is not valid. Verify this is a valid file with the correct checksum from the OEM. The file location is: "
