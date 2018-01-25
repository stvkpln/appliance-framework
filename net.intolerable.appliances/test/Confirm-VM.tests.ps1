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
	Describe 'Unit Testing Framework for Confirm-VM' {
		Context 'Confirm-VM' { 
			$Activity = 'Invoking Pester Unit Test'
			$vmExistPoweredOn = 'VMExistPoweredOn'
			$vmExistPoweredOff = 'VMExistPoweredOff'
			$vmExistSuspended = 'VMExistSuspended'
			$vmNotExist = 'VMNotExist'

			<#
			When we use PowerCLI cmdlets, we don't want the tests to actually call a PowerCLI cmdlet.
			For that reason, we overwrite the PowerCLI cmdlets we are going to mock with dummy code to 
			simulate the intended result. Due to some PowerCLI objects having read-only properties, 
			New-MockObject can't be used for this capability.
			#>
			Function Stop-VM {
				param(
					[System.Collections.Hashtable]$VM
				)

				$vm.PowerState = 'PoweredOff'
				$vm
			}
			function Remove-VM {
				param(
					[System.Collections.Hashtable]$VM
				)
			}

			<#
			Pester provides a set of Mocking functions making it easy to fake dependencies and also to
			verify behavior. Using these mocking functions can allow you to "shim" a data layer or mock 
			other complex functions that already have their own tests.
			#>
			Mock -CommandName 'Get-VM' `
				-ParameterFilter { $Name -eq $vmExistPoweredOn } `
				-MockWith {
					@{ 
						Name = $vmExistPoweredOn 
						PowerState = 'PoweredOn' 
					} 
				}

			Mock -CommandName 'Get-VM' `
				-ParameterFilter { $Name -eq $vmExistPoweredOff } `
				-MockWith { 
					@{ 
						Name = $vmExistPoweredOff 
						PowerState = 'PoweredOff' 
					}
				}

			Mock -CommandName 'Get-VM' `
				-ParameterFilter { $Name -eq $vmExistSuspended } `
				-MockWith { 
					@{ 
						Name = $vmExistPoweredOff 
						PowerState = 'Suspended' 
					}
				}

			Mock -CommandName 'Get-VM' `
				-ParameterFilter { $Name -eq $vmNotExist } `
				-MockWith { $null }
			

			Mock -CommandName 'Stop-VM' `
				-ParameterFilter {$VM -is [System.Collections.Hashtable]} `
				-MockWith {}

			Mock -CommandName 'Remove-VM' `
				-ParameterFilter {$VM -is [System.Collections.Hashtable]} `
				-MockWith {}

			# Testing Scenarios... here we go!
			It 'No Virtual Machine Was Discovered in Inventory' {
				Confirm-VM -Name $vmNotExist -Activity $Activity -WarningAction:SilentlyContinue |
				Should -BeNullOrEmpty
			}

			It 'Virtual Machine Discovered; Powered On, AllowClobber not passed' { 
				{ Confirm-VM -Name $vmExistPoweredOn -Activity $Activity -WarningAction:SilentlyContinue } | 
				Should -Throw "There is already a VM with the name $($vmExistPoweredOn)."
			}

			It 'Virtual Machine Discovered; Powered On, AllowClobber set to $false' { 
				{ Confirm-VM -Name $vmExistPoweredOn -AllowClobber $false -Activity $Activity -WarningAction:SilentlyContinue } |
				Should -Throw "There is already a VM with the name $($vmExistPoweredOn)." 
			}

			It 'Virtual Machine Discovered; Powered On, AllowClobber set to $true' { 
				Confirm-VM -Name $vmExistPoweredOn -AllowClobber $true -Activity $Activity -WarningAction:SilentlyContinue | 
				Should -BeNullOrEmpty
			}

			It 'Virtual Machine Discovered; Powered Off, AllowClobber not passed' { 
				{ Confirm-VM -Name $vmExistPoweredOff -Activity $Activity -WarningAction:SilentlyContinue } |
				Should -Throw "There is already a VM with the name $($vmExistPoweredOff)."
			}

			It 'Virtual Machine Discovered; Powered Off, AllowClobber set to $false' { 
				{ Confirm-VM -Name $vmExistPoweredOff -AllowClobber:$false -Activity $Activity -WarningAction:SilentlyContinue } |
				Should -Throw "There is already a VM with the name $($vmExistPoweredOff)."
			}

			It 'Virtual Machine Discovered; Powered Off, AllowClobber set to $true' { 
				Confirm-VM -Name $vmExistPoweredOff -AllowClobber:$true -Activity $Activity -WarningAction:SilentlyContinue |
				Should -BeNullOrEmpty
			}

			It -Skip 'Virtual Machine Discovered; Suspended, AllowClobber not passed' { 
				{ Confirm-VM -Name $vmExistSuspended -Activity $Activity -WarningAction:SilentlyContinue } |
				Should -Throw "There is already a VM with the name $($vmExistSuspended)."
			}

			It -Skip 'Virtual Machine Discovered; Suspended, AllowClobber set to $false' { 
				{ Confirm-VM -Name $vmExistSuspended -AllowClobber:$false -Activity $Activity -WarningAction:SilentlyContinue } |
				Should -Throw "There is already a VM with the name $($vmExistSuspended)."
			}

			It -Skip 'Virtual Machine Discovered; Suspended, AllowClobber set to $true' { 
				Confirm-VM -Name $vmExistSuspended -AllowClobber:true -Activity $Activity -WarningAction:SilentlyContinue |
				Should -BeNullOrEmpty
			}
		}
	}
} 
