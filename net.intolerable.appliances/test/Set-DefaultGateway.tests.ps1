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
	Describe 'Unit Testing Framework for Set-DefaultGateway' {
		Context 'Set-DefaultGateway' {
			$Activity = 'Invoking Pester Unit Test'
			$FourthOctet = "1"
			$Gateway = "10.0.0.1"
			$IPAddress = "10.0.0.100"
			$Mask23 = "255.255.254.0"
			$Mask24 = "255.255.255.0"

			# Testing and validation... The reason why we use Pester
			It 'Default Gateway Defined Statically' {
				Set-DefaultGateway -Gateway $Gateway |
				Should -BeExactly $Gateway
			}
			
			It 'Confgured From Defaults With a Class C Mask' {
				Set-DefaultGateway -IPAddress $IPAddress -SubnetMask $Mask24 -FourthOctet $FourthOctet -Activity $Activity |
				Should -BeExactly $Gateway
			}

			It 'Configuration Not Possible: Non-Class C Subnet Mask' {
				{ Set-DefaultGateway -IPAddress $IPAddress -SubnetMask $Mask23 -FourthOctet $FourthOctet -Activity $Activity } |
				Should -Throw "A default gateway could not be automatically configured due to the subnet mask not being a standard class C (/24). Provide a default gateway using the -Gateway parameter."
			}
		
			It 'Configuration Not Possible: Fourth Octet Value Not Set' {
				{ Set-DefaultGateway -IPAddress $IPAddress -SubnetMask $Mask24 -Activity $Activity } |
				Should -Throw "A default gateway could not be automatically configured due to the default fourth octet value not being defined. Either define in the config.json file in the module root directory or provide a default gateway value using the '-Gateway' parameter."
			}
		}
	}
} 
