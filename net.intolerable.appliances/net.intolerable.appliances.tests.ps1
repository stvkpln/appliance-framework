$modulePath = Split-Path -Parent -Path $MyInvocation.MyCommand.Path
$moduleName = (Split-Path -Leaf  -Path $MyInvocation.MyCommand.Path) -replace '.tests.ps1'

Get-Module -Name $moduleName | Remove-Module -Force
Import-Module "$($modulePath)\$($moduleName).psm1" -Force

InModuleScope -ModuleName $moduleName {
    Describe 'Unit Testing Internal Functions' {
        Context 'Confirm-DNS' {
            $Activity = 'Deploying a new xyz Appliance'
            $fqdn = 'host1.test.domain'
            $dnsServersOK = '10.0.0.1'
            $badDnsServersA = '10.0.0.2'
            $badDnsServersPtr = '10.0.0.3'
            $DnsServersPtrEmpty = '10.0.0.4'
            $correctHost = 'correct.test.domain'
            $correctIP = '10.0.1.1'
            $incorrectHost = 'incorrect.test.domain'
            $incorrectIP = '10.0.1.2'

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

            It 'Confirm-DNS - no FQDN and no Domain' {
                {Confirm-DNS} | Should -Throw 'A fully qualified domain name must be provided'}
            It 'Confirm-DNS - ValidateDns is $false' {
                Confirm-DNS -FQDN $fqdn -ValidateDns $false | Should -Be "$($FQDN)"}
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
    }
}
