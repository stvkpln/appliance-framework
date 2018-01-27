# OVA/OVF Appliance Import Framework
  * Version: 0.7.1-BETA
  * Last Update: 2018-JAN-27

## General Information
This module provides a framework to provide a normalized set of parameters to import virtual appliances in OVA or OVF formats into VMware vSphere environments via PowerCLI. In addition to normalized inputs, this framework provides validation of specific infrastructure actions to reduce the possibility of an error:

* Validation that the provided file has a valid file extension and exists
* Validation that a VM with the same name does not exist, and optionally the ability to remove it permanently from the infrastructure
* Validation that a VMHost is provided, or the (likely) least taxed host in a provided infrastructure container is used
* Validation that the provided network (portgroup) exists and is configured on the VMHost where the appliance will be deployed
* Validation that DNS has been properly configured for both forward (A) and reverse (PTR) records
* Configuration of a default gateway if all of the following conditions are met:
	1) A default gateway is not provided
	2) The subnet mask is 255.255.255.0 (/24)
	3) A valid fourth octet is set in the config.json file in the root of the module; this will default to "1"

For more information about specific appliance options, please use Get-Help <function> to get specific information about what is available for each type of appliance.

## Current Appliances Supported:
* Identity Manager 2.9.x
* NSX-V Manager 6.3.x
* vRealize Automation 7.x
* vRealize Business 7.x
* vRealize Log Insight 4.x
* vRealize Network Insight Platform 3.x
* vRealize Network Insight Proxy 3.x
* vRealize Operations 6.x
* vRealize Suite Lifecycle Manager 1.x
	
## Installation Instructions  
Clone the repository to the local machine and copy the 'net.intolerable.appliances' to a module directory specified in the environmental path. To review which paths have been specified in the current environment:
`[Environment]::GetEnvironmentVariable("PSModulePath")`  
`$Env:PSModulePath`

Alternatively, if you don't want to maintain the github repo separately from your preferred PowerShell module path... then you can create a symlink.. All you need to do is start up an administrator-elevated PowerShell session and enter the following:

`New-Item -ItemType SymbolicLink -Name <path-to-powershell-module-location>\net.intolerable.appliances -Target <path-to-module-local-repo>\net.intolerable.appliances`