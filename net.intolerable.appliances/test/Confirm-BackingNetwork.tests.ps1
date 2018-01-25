# Dynamically finding the paths / content for the testing verison of the module
$pesterTestsPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Path
$testModulePath = (Get-Item -Path $pesterTestsPath).Parent.FullName
$testModuleFile = Get-ChildItem -Path $testModulePath -Filter *.psm1
$ModuleName = $testModuleFile.BaseName

# Making sure that the loaded version of the module is the one in the testing module's path; reloading if necessary
$module = Get-Module -ListAvailable -Name $moduleName
$modulePath = (Get-Item -Path $module.Path).DirectoryName
if ($testModulePath -eq $modulePath) { Import-Module -Name $ModuleName -Force }
else {
	Write-Warning -Message "The testing version of the module is not in the same path as loaded module; removing the module and loading from the testing path"
	Get-Module -Name $moduleName | Remove-Module -Force
	Import-Module $testModuleFile.FullName -Force
}

<#
Pester documentation can be found at the Pester Wiki (https://github.com/pester/Pester/wiki/Pester).

The basic idea is that Pester tests shall check the logic in a script/function.
In an ideal world, that actually does Test Driven Development (TDD), one would first write the tests that cover all possible flows in the script/function.
Then while writing the code, the Pester tests confirm that code is handling all possibilities correctly.

The basic layout of a Pester script is quite simple (i'll limit this to the broad layout).

	Describe <== a logical collection of tests (in this script, the first Describe will host all Unit Tests)
		Context <== allows to group tests (the It entries together. I group by Internal function for now)
			Mock <== During test runs one does not want to actually execute some of the (destructive) cmdlets/functions. To avoid this, one can Mock such a cmdlet/function
			It <== the meat of the testing. These are the actual tests that are performed. 
				   The collection of It block should ideally cover all possible paths that can be taken through the code
#>

InModuleScope -ModuleName $moduleName {
	Describe 'Unit Testing Framework for Confirm-BackingNetwork' {
		Context 'Confirm-BackingNetwork' {
			$Activity = 'Invoking Pester Unit Test'
			$dvPortgroup = 'DistributedPortgroup'
			$stPortgroup = 'StandardPortgroup'
			$dvVMHost = 'DistributedSwitch'
			$stVMHost = 'StandardSwitch'

			<#
			When we use PowerCLI cmdlets, we don't want the tests to actually call a PowerCLI cmdlet.
			For that reason, we overwrite the PowerCLI cmdlets we are going to mock with dummy code to 
			simulate the intended result. Due to some PowerCLI objects having read-only properties, 
			New-MockObject can't be used for this capability.
			#>
			Function Get-VDSwitch {
				param(
					[string]$VMHost
				)

				switch ($VMhost) {
					$dvVMHost {  
						@{ Name = $VMHost } 
					}
					Default { $null }
				}		
			 }
			 
			Function Get-VDPortgroup {
				param(
					[System.Collections.Hashtable]$VDSwitch,
					[string]$Name
				)

				if($VDSwitch.Name -eq $dvPortgroup) {
					@{ Name = $Name }
				}
				
				else { $null }
			}
			
			Function Get-VirtualPortGroup{
				param(
					[string]$VMHost,
					[string]$Name,
					[switch]$Standard
				)

				if ($VMHost -eq $stPortgroup) {
					@{ Name = $Name }
				}
				
				else { Throw 'No standard portgroup found' }
			}

			<#
			Pester provides a set of Mocking functions making it easy to fake dependencies and also to
			verify behavior. Using these mocking functions can allow you to "shim" a data layer or mock 
			other complex functions that already have their own tests.
			#>
			Mock -Command 'Get-VDSwitch' `
				-ParameterFilter { $VMHost -eq $dvVMHost } `
				-MockWith {
					@{ Name = $VMHost }
				}

			Mock -Command 'Get-VDSwitch' `
				-ParameterFilter { $VMHost -eq $stVMHost } `
				-MockWith { $null }

			Mock -Command 'Get-VDPortgroup' `
				-ParameterFilter { $Network -eq $dvPortgroup } `
				-MockWith {
					@{ Name = $Name }
				}

			Mock -Command 'Get-VDPortgroup' `
				-ParameterFilter { $Name -eq $stPortgroup } `
				-MockWith { $null }
			
			Mock -Command 'Get-VirtualPortGroup' `
				-ParameterFilter { $Name -eq $stPortgroup } `
				-MockWith {  Throw 'Looking for a standard portgroup' }

			Mock -Command 'Get-VirtualPortGroup' `
				-ParameterFilter { $Name -eq $stPortgroup } `
				-MockWith {
					@{ Name = $Name }
				}

			Mock -Command 'Get-VirtualPortGroup' `
			-ParameterFilter { $Name -eq $BadNetwork } `
			-MockWith { throw "Mocking through a bad network!" }

			# Testing Scenarios... here we go!
			It 'Distributed Virtual Portgroup Discovered' {
				Confirm-BackingNetwork -Network $dvPortgroup -VMHost $dvVMHost -Activity $Activity | 
				Should -BeNullOrEmpty 
			}

			It 'Standard Virtual Portgroup Discovered on VMHost with dvSwitches' {
				Confirm-BackingNetwork -Network $stPortgroup -VMHost $dvVMHost -Activity $Activity | 
				Should -BeNullOrEmpty
			}

			It 'Standard Virtual Portgroup Discovered on VMHost with no dvSwitches' {
				Confirm-BackingNetwork -Network $stPortgroup -VMHost $stVMHost -Activity $Activity | 
				Should -BeNullOrEmpty
			} 

			It 'No Matching Portgroups Discovered with the Requested Network Name' {
				{ Confirm-BackingNetwork -Network 'BadNetwork' -VMHost $stVMHost -Activity $Activity } |
				should -Throw "Network name 'BadNetwork' is not a a valid distributed or standard portgroup attached to the VMHost being used"
			}
		}
	}
} 
