<#
    .Description
        Confirms that the specified file is either an OVA/OVF and that it exists at the specified path.
#>
Function Confirm-FileExtension {
    Param ( 
        [System.IO.FileInfo]$File
    )

    # Setting the name of the function and invoking opening verbose logging message
    Write-Verbose -Message (Get-FormattedMessage -Message "$($MyInvocation.MyCommand) Started execution")

    # Verifying that the file extension is either '.ova' or '.ovf' for the used
    if ($file.Extension.toLower() -notmatch ".ova|.ovf") {
        throw "The provided file '$($File.FullName)' has an incorrect file extension. If this is a valid appliance file, rename to a valid extension (.OVA or .OVF, depending on format)." 
    }

    else { $true }

    # Verbose logging output to finish things off
    Write-Verbose -Message (Get-FormattedMessage -Message "$($MyInvocation.MyCommand) Finished execution")
}
