$script:ModuleName = 'CertificateDsc.Common'

#region HEADER
# Unit Test Template Version: 1.1.0
[string] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
Import-Module -Name (Join-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Modules' -ChildPath $script:ModuleName)) -ChildPath "$script:ModuleName.psm1") -Force
Import-Module -Name (Join-Path -Path (Join-Path -Path (Split-Path $PSScriptRoot -Parent) -ChildPath 'TestHelpers') -ChildPath 'CommonTestHelper.psm1') -Global
#endregion HEADER

# Begin Testing
try
{
    InModuleScope $script:ModuleName {
        $DSCResourceName = 'CertificateCommon'
        $invalidThumbprint = 'Zebra'
        $validThumbprint = (
            [System.AppDomain]::CurrentDomain.GetAssemblies().GetTypes() | Where-Object {
                $_.BaseType.BaseType -eq [System.Security.Cryptography.HashAlgorithm] -and
                ($_.Name -cmatch 'Managed$' -or $_.Name -cmatch 'Provider$')
            } | Select-Object -First 1 | ForEach-Object {
                (New-Object $_).ComputeHash([String]::Empty) | ForEach-Object {
                    '{0:x2}' -f $_
                }
            }
        ) -join ''

        $testFile = 'test.pfx'

        $invalidPath = 'TestDrive:'
        $validPath = "TestDrive:\$testFile"

        Describe "$($script:ModuleName)\Test-CertificatePath" {

            $null | Set-Content -Path $validPath

            Context 'a single existing file by parameter' {
                $result = Test-CertificatePath -Path $validPath
                It 'should return true' {
                    ($result -is [bool]) | Should Be $true
                    $result | Should Be $true
                }
            }
            Context 'a single missing file by parameter' {
                It 'should throw an exception' {
                    # directories are not valid
                    { Test-CertificatePath -Path $invalidPath } | Should Throw
                }
            }
            Context 'a single missing file by parameter with -Quiet' {
                $result = Test-CertificatePath -Path $invalidPath -Quiet
                It 'should return false' {
                    ($result -is [bool]) | Should Be $true
                    $result | Should Be $false
                }
            }
            Context 'a single existing file by pipeline' {
                $result = $validPath | Test-CertificatePath
                It 'should return true' {
                    ($result -is [bool]) | Should Be $true
                    $result | Should Be $true
                }
            }
            Context 'a single missing file by pipeline' {
                It 'should throw an exception' {
                    # directories are not valid
                    { $invalidPath | Test-CertificatePath } | Should Throw
                }
            }
            Context 'a single missing file by pipeline with -Quiet' {
                $result =  $invalidPath | Test-CertificatePath -Quiet
                It 'should return false' {
                    ($result -is [bool]) | Should Be $true
                    $result | Should Be $false
                }
            }
        }

        Describe "$($script:ModuleName)\Test-Thumbprint" {

            Context 'a single valid thumbrpint by parameter' {
                $result = Test-Thumbprint -Thumbprint $validThumbprint
                It 'should return true' {
                    ($result -is [bool]) | Should Be $true
                    $result | Should Be $true
                }
            }
            Context 'a single invalid thumbprint by parameter' {
                It 'should throw an exception' {
                    # directories are not valid
                    { Test-Thumbprint -Thumbprint $invalidThumbprint } | Should Throw
                }
            }
            Context 'a single invalid thumbprint by parameter with -Quiet' {
                $result = Test-Thumbprint $invalidThumbprint -Quiet
                It 'should return false' {
                    ($result -is [bool]) | Should Be $true
                    $result | Should Be $false
                }
            }
            Context 'a single valid thumbprint by pipeline' {
                $result = $validThumbprint | Test-Thumbprint
                It 'should return true' {
                    ($result -is [bool]) | Should Be $true
                    $result | Should Be $true
                }
            }
            Context 'a single invalid thumborint by pipeline' {
                It 'should throw an exception' {
                    # directories are not valid
                    { $invalidThumbprint | Test-Thumbprint } | Should Throw
                }
            }
            Context 'a single invalid thumbprint by pipeline with -Quiet' {
                $result =  $invalidThumbprint | Test-Thumbprint -Quiet
                It 'should return false' {
                    ($result -is [bool]) | Should Be $true
                    $result | Should Be $false
                }
            }
        }

        Describe "$($script:ModuleName)\Find-Certificate" {

            # Download and dot source the New-SelfSignedCertificateEx script
            . (Install-NewSelfSignedCertificateExScript)

            # Generate the Valid certificate for testing but remove it from the store straight away
            $certDNSNames = @('www.fabrikam.com', 'www.contoso.com')
            $certSubject = 'CN=contoso, DC=com'
            $certFriendlyName = 'Contoso Test Cert'
            $validCert = New-SelfSignedCertificateEx `
                -Subject $certSubject `
                -KeyUsage 'DigitalSignature','DataEncipherment','KeyEncipherment' `
                -KeySpec 'Exchange' `
                -EKU 'Server Authentication','Client authentication' `
                -SubjectAlternativeName $certDNSNames `
                -FriendlyName $certFriendlyName `
                -StoreLocation 'CurrentUser'
            # Pull the generated certificate from the store so we have the friendlyname
            $validThumbprint = $validCert.Thumbprint
            $validCert = Get-Item -Path "cert:\CurrentUser\My\$validThumbprint"
            Remove-Item -Path $validCert.PSPath -Force

            # Generate the Expired certificate for testing but remove it from the store straight away
            $expiredCert = New-SelfSignedCertificateEx `
                -Subject $certSubject `
                -KeyUsage 'DigitalSignature','DataEncipherment','KeyEncipherment' `
                -KeySpec 'Exchange' `
                -EKU 'Server Authentication','Client authentication' `
                -SubjectAlternativeName $certDNSNames `
                -FriendlyName $certFriendlyName `
                -NotBefore ((Get-Date) - (New-TimeSpan -Days 2)) `
                -NotAfter ((Get-Date) - (New-TimeSpan -Days 1)) `
                -StoreLocation 'CurrentUser'
            # Pull the generated certificate from the store so we have the friendlyname
            $expiredThumbprint = $expiredCert.Thumbprint
            $expiredCert = Get-Item -Path "cert:\CurrentUser\My\$expiredThumbprint"
            Remove-Item -Path $expiredCert.PSPath -Force

            $nocertThumbprint = '1111111111111111111111111111111111111111'

            Mock `
                -CommandName Get-ChildItem `
                -MockWith { @( $validCert ) } `
                -ParameterFilter { $Path -eq 'cert:\LocalMachine\My' } `
                -Verifiable

            Context 'Thumbprint only is passed and matching certificate exists' {
                It 'should not throw exception' {
                    { $script:result = Find-Certificate -Thumbprint $validThumbprint } | Should Not Throw
                }
                It 'should return expected certificate' {
                    $script:result.Thumbprint | Should Be $validThumbprint
                }
                It 'should call expected mocks' {
                    Assert-VerifiableMocks
                }
            }

            Context 'Thumbprint only is passed and matching certificate does not exist' {
                It 'should not throw exception' {
                    { $script:result = Find-Certificate -Thumbprint $nocertThumbprint } | Should Not Throw
                }
                It 'should return null' {
                    $script:result | Should BeNullOrEmpty
                }
                It 'should call expected mocks' {
                    Assert-VerifiableMocks
                }
            }

            Context 'FriendlyName only is passed and matching certificate exists' {
                It 'should not throw exception' {
                    { $script:result = Find-Certificate -FriendlyName $certFriendlyName } | Should Not Throw
                }
                It 'should return expected certificate' {
                    $script:result.Thumbprint | Should Be $validThumbprint
                }
                It 'should call expected mocks' {
                    Assert-VerifiableMocks
                }
            }

            Context 'FriendlyName only is passed and matching certificate does not exist' {
                It 'should not throw exception' {
                    { $script:result = Find-Certificate -FriendlyName 'Does Not Exist' } | Should Not Throw
                }
                It 'should return null' {
                    $script:result | Should BeNullOrEmpty
                }
                It 'should call expected mocks' {
                    Assert-VerifiableMocks
                }
            }

            Context 'Subject only is passed and matching certificate exists' {
                It 'should not throw exception' {
                    { $script:result = Find-Certificate -Subject $certSubject } | Should Not Throw
                }
                It 'should return expected certificate' {
                    $script:result.Thumbprint | Should Be $validThumbprint
                }
                It 'should call expected mocks' {
                    Assert-VerifiableMocks
                }
            }

            Context 'Subject only is passed and matching certificate does not exist' {
                It 'should not throw exception' {
                    { $script:result = Find-Certificate -Subject 'CN=Does Not Exist' } | Should Not Throw
                }
                It 'should return null' {
                    $script:result | Should BeNullOrEmpty
                }
                It 'should call expected mocks' {
                    Assert-VerifiableMocks
                }
            }

            Context 'Issuer only is passed and matching certificate exists' {
                It 'should not throw exception' {
                    { $script:result = Find-Certificate -Issuer $certSubject } | Should Not Throw
                }
                It 'should return expected certificate' {
                    $script:result.Thumbprint | Should Be $validThumbprint
                }
                It 'should call expected mocks' {
                    Assert-VerifiableMocks
                }
            }

            Context 'Issuer only is passed and matching certificate does not exist' {
                It 'should not throw exception' {
                    { $script:result = Find-Certificate -Issuer 'CN=Does Not Exist' } | Should Not Throw
                }
                It 'should return null' {
                    $script:result | Should BeNullOrEmpty
                }
                It 'should call expected mocks' {
                    Assert-VerifiableMocks
                }
            }

            Context 'DNSName only is passed and matching certificate exists' {
                It 'should not throw exception' {
                    { $script:result = Find-Certificate -DnsName $certDNSNames } | Should Not Throw
                }
                It 'should return expected certificate' {
                    $script:result.Thumbprint | Should Be $validThumbprint
                }
                It 'should call expected mocks' {
                    Assert-VerifiableMocks
                }
            }

            Context 'DNSName only is passed and matching certificate exists' {
                It 'should not throw exception' {
                    { $script:result = Find-Certificate -DnsName @('www.fabrikam.com', 'www.contoso.com') } | Should Not Throw
                }
                It 'should return expected certificate' {
                    $script:result.Thumbprint | Should Be $validThumbprint
                }
                It 'should call expected mocks' {
                    Assert-VerifiableMocks
                }
            }

            Context 'DNSNames only is passed and matching certificate does not exist' {
                It 'should not throw exception' {
                    { $script:result = Find-Certificate -DnsName @('www.fabrikam.com') } | Should Not Throw
                }
                It 'should return null' {
                    $script:result | Should BeNullOrEmpty
                }
                It 'should call expected mocks' {
                    Assert-VerifiableMocks
                }
            }

            Mock `
                -CommandName Get-ChildItem `
                -ParameterFilter { $Path -eq 'cert:\LocalMachine\CA' } `
                -Verifiable

            Context 'Thumbprint only is passed and matching certificate does not exist in CA store' {
                It 'should not throw exception' {
                    { $script:result = Find-Certificate -Thumbprint $validThumbprint -Store 'CA'} | Should Not Throw
                }
                It 'should return null' {
                    $script:result | Should BeNullOrEmpty
                }
                It 'should call expected mocks' {
                    Assert-VerifiableMocks
                }
            }

        }
    }
}
finally
{
    #region FOOTER
    #endregion
}
