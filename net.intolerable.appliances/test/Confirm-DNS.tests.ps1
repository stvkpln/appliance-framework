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
	Describe 'Unit Testing Framework for Confirm-DNS' {
		Context 'Confirm-DNS' {
			$Activity = 'Invoking Pester Unit Test'
			$fqdn = 'host1.example.com'
			$dnsServersOK = '10.0.0.1'
			$badDnsServersA = '10.0.0.2'
			$badDnsServersPtr = '10.0.0.3'
			$DnsServersPtrEmpty = '10.0.0.4'
			$correctHost = 'correct.test.domain'
			$correctIP = '10.0.1.1'
			$incorrectHost = 'incorrect.test.domain'
			$incorrectIP = '10.0.1.2'

			<#
			Pester provides a set of Mocking functions making it easy to fake dependencies and also to
			verify behavior. Using these mocking functions can allow you to "shim" a data layer or mock 
			other complex functions that already have their own tests.

			Using Mocking with Resolve-DnsName lets us test DNS functions without having to have valid
			DNS records... or access to a DNS Server!
			#>
			Mock -CommandName 'Resolve-DnsName' `
			 -ParameterFilter { $Name -eq $incorrectHost } `
			 -MockWith { $null }

			Mock -CommandName 'Resolve-DnsName' `
			 -ParameterFilter { $Name -eq $incorrectIP } `
			 -MockWith { $null }

			Mock -CommandName 'Resolve-DnsName' `
				-ParameterFilter { $Name -eq $correctHost -and $DnsServers -eq $badDnsServersA } `
				-MockWith {
					@{
						Type='A'
						IPAddress=$incorrectIP
					}
				}

			Mock -CommandName 'Resolve-DnsName' `
				-ParameterFilter { $Name -eq $correctIP -and $DnsServers -eq $DnsServersPtrEmpty } `
				-MockWith { $null }

			Mock -CommandName 'Resolve-DnsName' `
				-ParameterFilter { $Name -eq $correctIP -and $DnsServers -eq $badDnsServersPtr } `
				-MockWith {
					@{
						Type='PTR'
						NameHost=$incorrectHost
					}
				}

			Mock -CommandName 'Resolve-DnsName' `
				-ParameterFilter { $Name -eq $correctHost -and ($DnsServers -eq $DnsServersOK -or $DnsServers -eq $correctDnsServersA -or $DnsServers -eq $badDnsServersPtr -or $DnsServers -eq $DnsServersPtrEmpty) } `
				-MockWith {
					@{
						Type='A'
						IPAddress=$correctIP
					}
				}

			Mock -CommandName 'Resolve-DnsName' `
				-ParameterFilter { $Name -eq $correctIP -and ($DnsServers -eq $dnsServersOK -or $DnsServers -eq $correctDnsServersA) } `
				-MockWith {
					@{
						Type='PTR'
						NameHost=$correctHost
					}
				}

			# Testing Scenarios... here we go!
			It 'Host and Domain Names are Provided, ValidateDns set to $false' -Test {
				Confirm-DNS -Name "host1" -Domain "example.com" -ValidateDns $false -Activity $Activity | 
				Should Be "$($fqdn)"
			}

			It 'FQDN is Provided, ValidateDns set to $false' -Test {
				Confirm-DNS -FQDN $fqdn -ValidateDns $false -Activity $Activity | 
				Should Be "$($fqdn)"
			}

			It 'Neither FQDN or Host and Domain Names Provided' {
				{ Confirm-DNS -Activity $Activity } | 
				Should -Throw 'A fully qualified domain name must be provided.'
			}

			It 'FQDN is Provided, ValidateDns set to $true; Correct Forward and Reverse Lookups' {
			Confirm-DNS -FQDN $correctHost -IPAddress $correctIP -DnsServers $dnsServersOK -ValidateDns $true -Activity $Activity | 
			Should -Be "$($correctHost)"
			}

			It 'FQDN is Provided, ValidateDns set to $true; No Forward (A) Record' {
				{ Confirm-DNS -FQDN $incorrectHost -DnsServers $badDnsServersA -ValidateDns $true -Activity $Activity } | 
				Should -Throw "The provided DNS servers were unable to resolve the FQDN '$($incorrectHost)'"
			}

			It 'FQDN is Provided, ValidateDns set to $true; No Reverse (PTR) Record' {
				{ Confirm-DNS -FQDN $correctHost -IPAddress $correctIP -DnsServers $DnsServersPtrEmpty -ValidateDns $true -Activity $Activity } | 
				Should -Throw "The provided DNS servers were unable to resolve the IP Address '$($correctIP)' to a FQDN."
			}		

			It 'FQDN is Provided, ValidateDns set to $true; Wrong Forward (A) Record' {
				{ Confirm-DNS -FQDN $correctHost -DnsServers $badDnsServersA -IPAddress $correctIP -ValidateDns $true -Activity $Activity } | 
				Should -Throw "The FQDN $($correctHost) is resolving to '$($incorrectIP)'"
			}

			It 'FQDN is Provided, ValidateDns set to $true; Wrong Reverse (PTR) Record' {
				{ Confirm-DNS -FQDN $correctHost -DnsServers $badDnsServersPtr -IPAddress $correctIP -ValidateDns $true -Activity $Activity } | 
				Should -Throw "The IP Address '$($correctIP)' is resolving to a hostname of '$($incorrectHost)'"
			}
		}
	}
} 
