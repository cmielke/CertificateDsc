@{
    # Version number of this module.
    moduleVersion = '4.3.0.0'

    # ID used to uniquely identify this module
    GUID              = '1b8d785e-79ae-4d95-ae58-b2460aec1031'

    # Author of this module
    Author            = 'Microsoft Corporation'

    # Company or vendor of this module
    CompanyName       = 'Microsoft Corporation'

    # Copyright statement for this module
    Copyright         = '(c) 2018 Microsoft Corporation. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'This module includes DSC resources that simplify administration of certificates on a Windows Server'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '4.0'

    # Minimum version of the common language runtime (CLR) required by this module
    CLRVersion        = '4.0'

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module
    FunctionsToExport = '*'

    # Cmdlets to export from this module
    CmdletsToExport   = '*'

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @('DesiredStateConfiguration', 'DSC', 'DSCResourceKit', 'DSCResource')

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/PowerShell/CertificateDsc/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/PowerShell/CertificateDsc'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
        ReleaseNotes = '- Updated certificate import to only use Import-CertificateEx - fixes [Issue 161](https://github.com/PowerShell/CertificateDsc/issues/161)
- Update LICENSE file to match the Microsoft Open Source Team standard -fixes
  [Issue 164](https://github.com/PowerShell/CertificateDsc/issues/164).
- Opted into Common Tests - fixes [Issue 168](https://github.com/PowerShell/CertificateDsc/issues/168):
  - Required Script Analyzer Rules
  - Flagged Script Analyzer Rules
  - New Error-Level Script Analyzer Rules
  - Custom Script Analyzer Rules
  - Validate Example Files To Be Published
  - Validate Markdown Links
  - Relative Path Length
- CertificateExport:
  - Fixed bug causing PFX export with matchsource enabled to fail - fixes
    [Issue 117](https://github.com/PowerShell/CertificateDsc/issues/117)

'

        } # End of PSData hashtable

    } # End of PrivateData hashtable

}















