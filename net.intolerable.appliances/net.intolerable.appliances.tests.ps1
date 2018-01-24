<#
Pester documentation can be found at the Pseter Wiki (https://github.com/pester/Pester/wiki/Pester).

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

$modulePath = Split-Path -Parent -Path $MyInvocation.MyCommand.Path
$moduleName = (Split-Path -Leaf  -Path $MyInvocation.MyCommand.Path) -replace '.tests.ps1'

# Make sure the module is loaded, even when it is not in a folder that is defined in $env:PSModulePath
Get-Module -Name $moduleName | Remove-Module -Force
Import-Module "$($modulePath)\$($moduleName).psm1" -Force

# This allows the tests to call private (not-exported) functions in the module <== the Internals
InModuleScope -ModuleName $moduleName {
    Describe 'Unit Testing Internal Functions' {
# the $Activity variable is used, but not passed through a function, hence the assignment in here
# Notice that scope concept. This $Activity variable will be available in all Context and It blocks in this Describe block
        $Activity = 'Pester tests'

        Context 'Confirm-DNS' {
# In short, the It tests will call the function (Confirm-Dns in this case) with all possible permutations of the parameters
# To make that easier, also easier to read, it is handy to use meaningfull variables.
# When we pass a Name with $correctHost, we can assume that this is used in test cases where the Name represents an existing host.
# This is done in combination with the DNS servers that we pass to the function
            $fqdn = 'host1.test.domain'
            $dnsServersOK = '10.0.0.1'
            $badDnsServersA = '10.0.0.2'
            $badDnsServersPtr = '10.0.0.3'
            $DnsServersPtrEmpty = '10.0.0.4'
            $correctHost = 'correct.test.domain'
            $correctIP = '10.0.1.1'
            $incorrectHost = 'incorrect.test.domain'
            $incorrectIP = '10.0.1.2'

# We 'Mock' the Resolve-DnsName cmdlet.
# This allows us to do tests without actually making changes to the DNS
# Notice that we can have multiple Mocks for the same cmdlet. The distinction is in the parameeters that are passed (see ParameterFilter)
# The MockWith part defines what we will actually return to the caller
            Mock -CommandName 'Resolve-DnsName' -ParameterFilter {$Name -eq $incorrectHost} -MockWith {$null}
            Mock -CommandName 'Resolve-DnsName' -ParameterFilter {$Name -eq $incorrectIP} -MockWith {$null}
            Mock -CommandName 'Resolve-DnsName' `
                -ParameterFilter {$Name -eq $correctHost -and $DnsServers -eq $badDnsServersA} `
                -MockWith {
                    @{
                        Type='A'
                        IPAddress=$incorrectIP
                    }
                }
            Mock -CommandName 'Resolve-DnsName' `
                -ParameterFilter {$Name -eq $correctIP -and $DnsServers -eq $DnsServersPtrEmpty} `
                -MockWith {$null}
            Mock -CommandName 'Resolve-DnsName' `
                -ParameterFilter {$Name -eq $correctIP -and $DnsServers -eq $badDnsServersPtr} `
                -MockWith {
                    @{
                        Type='PTR'
                        NameHost=$incorrectHost
                    }
                }
            Mock -CommandName 'Resolve-DnsName' `
                -ParameterFilter {$Name -eq $correctHost -and ($DnsServers -eq $DnsServersOK -or $DnsServers -eq $correctDnsServersA -or $DnsServers -eq $badDnsServersPtr -or $DnsServers -eq $DnsServersPtrEmpty)} `
                -MockWith {
                    @{
                        Type='A'
                        IPAddress=$correctIP
                    }
                }
            Mock -CommandName 'Resolve-DnsName' `
                -ParameterFilter {$Name -eq $correctIP -and ($DnsServers -eq $dnsServersOK -or $DnsServers -eq $correctDnsServersA)} `
                -MockWith {
                    @{
                        Type='PTR'
                        NameHost=$correctHost
                    }
                }

# The actual test cases
# This is where we have to make sure that all possible paths in the code are tested.
# In this particular set of tests, we vary the host (existing or not) with the presence of DNS entries (A and PTR records present or not) and the requirement to test the DNS entries ($ValidateDns)
# A test defines what shall be returned by the code.
# We have several tests where we expect the code to Throw an exception, which is defined by the Should -Throw text
# Other options for the returned data by the function are nothing ($null) or the FQDN of the host

            It 'Confirm-DNS - no FQDN and no Domain' {
                {Confirm-DNS} | Should -Throw 'A fully qualified domain name must be provided.'}
            It 'Confirm-DNS - ValidateDns is $false' -Test {
                Confirm-DNS -FQDN $fqdn -ValidateDns $false | Should Be "$($FQDN)"}
            It 'Confirm-DNS - ValidateDns is $true - No A-record DNS resoution' {
                {Confirm-DNS -FQDN $incorrectHost -DnsServers $badDnsServersA -ValidateDns $true} | 
                Should -Throw "The provided DNS servers were unable to resolve the FQDN '$($incorrectHost)'"}
            It 'Confirm-DNS - ValidateDns is $true - DNS resolution - Incorrect A-record IPAddress from DNS' {
                {Confirm-DNS -FQDN $correctHost -DnsServers $badDnsServersA -ValidateDns $true -IPAddress $correctIP}   | 
                Should -Throw "The FQDN $($correctHost) is resolving to '$($incorrectIP)'"}
            It 'Confirm-DNS - ValidateDns is $true - No PTR-record DNS resoution' {
                {Confirm-DNS -FQDN $correctHost -IPAddress $correctIP -DnsServers $DnsServersPtrEmpty -ValidateDns $true} | 
                Should -Throw "The provided DNS servers were unable to resolve the IP Address '$($correctIP)' to a FQDN."}
            It 'Confirm-DNS - ValidateDns is $true - DNS resolution - Incorrect PTR-record HostName from DNS' {
                {Confirm-DNS -FQDN $correctHost -DnsServers $badDnsServersPtr -ValidateDns $true -IPAddress $correctIP}   | 
                Should -Throw "The IP Address '$($correctIP)' is resolving to a hostname of '$($incorrectHost)'"}
            It 'Confirm-DNS - ValidateDns is $true - DNS resolution - Correct A-record & PTR-record from DNS' {
                Confirm-DNS -FQDN $correctHost -IPAddress $correctIP -DnsServers $dnsServersOK -ValidateDns $true | 
                Should -Be "$($correctHost)"}
        }
 
        Context 'Confirm-VM' { 
            $vmExistPoweredOn = 'VMExistPoweredOn' 
            $vmExistPoweredOff = 'VMExistPoweredOff' 
            $vmExistSuspended = 'VMExistSuspended' 
            $vmNotExist = 'VMNotExist' 

# When we use PowerCLI cmdlets, we don't want the tests to actually call a PowerCLI cmdlet.
# For that reason we overwrite the PowerCLI cmdlets we are going to mock.
# Basically this is required because we can't really use New-MockObject for PowerCLI objects (since some of the properties are read-only)

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

# Again tests shall cover all possibilities that the function code can encounter
# Since the PowerState of a VM is used in the code, in theory we would have to foresee tests for all
# possible PowerStates (including Suspended).
# But since Stop-VM works the same for a PoweredOn and a Suspended VM, we don't really need to test the
# Suspended cases (hence the -Skip option I used)

# Again we Mock the cmdlets that are used in the code
# In most cases it is sufficient to return a hash table that only holds the properties that are used in the code.
# The Stop-VM cmdlet does check the type of the object passed on the VM parameter.
# That will not work with a hash table, hence we overwrite the Stop-VM function by our own local version.
# And avoid the type-check on the parameter

            Mock -CommandName 'Get-VM' `
                -ParameterFilter {$Name -eq $vmExistPoweredOn} `
                -MockWith {
                    @{ 
                        Name = $vmExistPoweredOn 
                        PowerState = 'PoweredOn' 
                    } 
                } 
            Mock -CommandName 'Get-VM' `
                -ParameterFilter {$Name -eq $vmExistPoweredOff} `
                -MockWith { 
                    @{ 
                        Name = $vmExistPoweredOff 
                        PowerState = 'PoweredOff' 
                    } 
                } 
            Mock -CommandName 'Get-VM' `
                -ParameterFilter {$Name -eq $vmExistSuspended} `
                -MockWith { 
                    @{ 
                        Name = $vmExistPoweredOff 
                        PowerState = 'Suspended' 
                    } 
                } 
            Mock -CommandName 'Get-VM' `
                -ParameterFilter {$Name -eq $vmNotExist} `
                -MockWith {$null}
            Mock -CommandName 'Stop-VM' `
                -ParameterFilter {$VM -is [System.Collections.Hashtable]} `
                -MockWith {}
            Mock -CommandName 'Remove-VM' `
                -ParameterFilter {$VM -is [System.Collections.Hashtable]} `
                -MockWith {}
            It 'VM exists - PoweredOn - AllowClobber (default)' { 
                {Confirm-VM -Name $vmExistPoweredOn} | 
                Should -Throw "There is already a VM with the name $($vmExistPoweredOn)."} 
            It 'VM exists - PoweredOn - AllowClobber is $false' { 
                {Confirm-VM -Name $vmExistPoweredOn -AllowClobber $false} |
                Should -Throw "There is already a VM with the name $($vmExistPoweredOn)." } 
            It 'VM exists - PoweredOn - AllowClobber is $true' { 
                Confirm-VM -Name $vmExistPoweredOn -AllowClobber $true | 
                Should -BeNullOrEmpty} 
            It 'VM exists - PoweredOff - AllowClobber (default)' { 
                {Confirm-VM -Name $vmExistPoweredOff} |
                Should -Throw "There is already a VM with the name $($vmExistPoweredOff)."} 
            It 'VM exists - PoweredOff - AllowClobber is $false' { 
                {Confirm-VM -Name $vmExistPoweredOff -AllowClobber:$false} |
                Should -Throw "There is already a VM with the name $($vmExistPoweredOff)."} 
            It 'VM exists - PoweredOff - AllowClobber is $true' { 
                Confirm-VM -Name $vmExistPoweredOff -AllowClobber:$true |
                Should -BeNullOrEmpty} 
            It -Skip 'VM exists - Suspended - AllowClobber (default)' { 
                {Confirm-VM -Name $vmExistSuspended} |
                Should -Throw "There is already a VM with the name $($vmExistSuspended)."} 
            It -Skip 'VM exists - Suspended - AllowClobber is $false' { 
                {Confirm-VM -Name $vmExistSuspended -AllowClobber:$false} |
                Should -Throw "There is already a VM with the name $($vmExistSuspended)."} 
            It -Skip 'VM exists - Suspended - AllowClobber is $true' { 
                Confirm-VM -Name $vmExistSuspended -AllowClobber:true |
                Should -BeNullOrEmpty} 
        }

        Context 'Set-DefaultGateway' {
			$FourthOctet = "1"
			$Gateway = "10.0.0.1"
			$IPAddress = "10.0.0.100"
			$Mask23 = "255.255.254.0"
			$Mask24 = "255.255.255.0"
			
			It 'Static Assignment' {
				Set-DefaultGateway -Gateway $Gateway |
				Should -BeExactly $Gateway
			}
			
			It 'Confgured From Defaults With a Class C Mask' {
				Set-DefaultGateway -IPAddress $IPAddress -SubnetMask $Mask24 -FourthOctet $FourthOctet |
				Should -BeExactly $Gateway
			}

			It 'Confgured From Defaults With a non-Class C Mask' {
				{ Set-DefaultGateway -IPAddress $IPAddress -SubnetMask $Mask23 -FourthOctet $FourthOctet } |
				Should -Throw "A default gateway could not be automatically configured due to the subnet mask not being a standard class C (/24). Provide a default gateway using the -Gateway parameter."
			}
		
			It 'No available fourth octet value' {
				{ Set-DefaultGateway -IPAddress $IPAddress -SubnetMask $Mask24 } |
				Should -Throw "A default gateway could not be automatically configured due to the default fourth octet value not being defined. Either define in the config.json file in the module root directory or provide a default gateway value using the '-Gateway' parameter."
			}
		}

        Context 'Confirm-BackingNetwork' {
			$dvVMHdvPG = 'DistributedPortgroup'
			$dvVMHstPG = 'StandardPortgroup'
			$dvVMHstPG = 'StandardPortgroup'
			$stVMHstPG = 'StandardPortgroup'

			Mock -Command 'Get-VDSwitch' `
				-ParameterFilter { $Network  } `
				-MockWith {
					@{ Name = 'DistributedSwitch' }
				}

			Mock -Command 'Get-VDSwitch' `
				-ParameterFilter { $VMHost -eq $stVMHost } `
				-MockWith { $null }

			Mock -Command 'Get-VDPortgroup' `
				-ParameterFilter { $Name -eq $dvPortgroup } `
				-MockWith {
					@{ Name = 'DistributedPortgroup' }
				}

			Mock -Command 'Get-VDPortgroup' `
				-ParameterFilter { $Name -eq $stPortgroup }`
				-MockWith { $null }

			It 'Backing Network - VMHost with Distributed vSwitch(es) - Distributed Portgroup' {
				Confirm-BackingNetwork -Network $dvPortgroup -VMHost $dvVMHost | Should -BeNullOrEmpty
			}

			It 'Backing Network - VMHost with Distributed vSwitch(es) - Standard Portgroup' {
				Confirm-BackingNetwork -Network $stPortgroup -VMHost $dvVMHost
			}
		}
    }
} 
