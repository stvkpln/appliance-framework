<#
    .Description
        Confirms that the specified file is either an OVA/OVF and that it exists at the specified path.
#>
Function Confirm-FilePath {
	Param ( [System.IO.FileInfo]$File )
	if ($file.Extension.toLower() -notmatch ".ova|.ovf") { 
		throw "The provided file '$($File.FullName)' has an incorrect file extension. If this is a valid appliance file, rename to a valid extension (.OVA or .OVF, depending on format)." 
	}
	else { $true }
}