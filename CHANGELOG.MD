# 0.5
* Initial Commit

# 0.6
* All appliance functions now export via manifest so auto-loading works!
* Added support for `-WhatIf`
* Added support for `NoClobber` to remove/replace VM's with the same name
* Added Photon OS appliance support
* Updated help content to use splat parameter presentation
* Started adding logging of things via `-Verbose` parameter
* Added parameter inputs on most of the internal functions
* Fixed plumbing for `-ValidateDns` so it actually won't check for A/PTR records

# 0.7
* Starting to add in Pester unit testing capabilities (Thanks, Luc!!)
* Moving more global logging verbiage out of functions and into the root module as variables for ease of editing
* Making some internal Write-Warning part of Verbose logging, rather than having warnings coming up
* Renamed `Confirm-FilePath` to `Confirm-FileExtension` to better reflect what it actually validates
* Renamed switch parameter `-NoClobber` to `-AllowClobber`  to better comply with switches not being 'true' by default
* Added more comments onto internal functions
* Added `-Standard` parameter on the `Get-VirtualPortgroup` check in the ```Confirm-BackingNetwork``` function
* Added all passthrough variables as parameters on Import-Appliance and fixing up code on appliance wrappers
* Added new function `Get-FormattedMessage` to format time and logging output to match up with PowerCLI date/time output
* Added $Activity input parameter on all internal functions to allow for Write-Progress to provide activities as needed 
* Updated input parameters on Confirm-BackingNetwork and Confirm-VMHost for PowerCLI objects to allow Pester tests to occur
* Pester Unit Tests for: Confirm-BackingNetwork, Confirm-DNS, Confirm-VM, and Set-DefaultGateway
* Removed Monolithic Pester tests file from module root!

# 0.7.1
* Fixing an issue introduced while working on the plumbing for Pester unit test for `Confirm-VMHost`. Under the new logic, parameters `VMHost` and `Location` will only be passed into the function if they are provided by the wrapper workflow.
* Fix parameter input from appliance functions to `Import-Appliance` for storage format for VMDK's... oops!
