@{
    #---------------------------------------------------------------------------
    #region Module Info

    ModuleVersion = '0.1.0'
    Description = 'Manage markdown content using the markdig objects'
    GUID = 'df99648d-8550-4f30-af46-4d874f6b1622'
    # HelpInfoURI = ''

    #endregion Module Info
    #---------------------------------------------------------------------------

    #---------------------------------------------------------------------------
    #region Module Components

    RootModule = 'PSMarkdig.psm1'
    # ScriptsToProcess = @()
    # TypesToProcess = @()
    # FormatsToProcess = @()
    # NestedModules = @()
    # ModuleList = ''
    # FileList = @()

    #endregion Module Components
    #---------------------------------------------------------------------------

    #---------------------------------------------------------------------------
    #region Public Interface

    CmdletsToExport = '*'
    FunctionsToExport = '*'
    VariablesToExport = '*'
    AliasesToExport = '*'
    # DSCResourcesToExport = @()
    # DefaultCommandPrefix = ''

    #endregion Public Interface
    #---------------------------------------------------------------------------

    #---------------------------------------------------------------------------
    #region Requirements

    # CompatiblePSEditions = @()
    # PowerShellVersion = ''
    # PowershellHostName = ''
    # PowershellHostVersion = ''
    # RequiredModules = ''
    # RequiredAssemblies = ''
    # ProcessorArchitecture = ''
    # DotNetFrameworkVersion = ''
    # CLRVersion = ''

    #endregion Requirements
    #---------------------------------------------------------------------------

    #---------------------------------------------------------------------------
    #region Author

    Author = 'Timothy Aldrich'
    CompanyName = 'aldrichtr'
    Copyright = '(c) Timothy Aldrich. All rights reserved.'

    #endregion Author
    #---------------------------------------------------------------------------

    PrivateData = @{
        PSData = @{
        #---------------------------------------------------------------------------
        #region Project

        Tags = @('Parser', 'Markdown')
        LicenseUri = 'https://github.com/aldrichtr/PSMarkdig/blob/main/LICENSE.md'
        ProjectUri = 'https://github.com/aldrichtr/PSMarkdig'
        # IconUri = ''
        PreRelease = '0001'
        RequireLicenseAcceptance = $false
        ExternalModuleDependencies = @()
        ReleaseNotes = ''

        #endregion Project
        #---------------------------------------------------------------------------

        } # end PSData
    } # end PrivateData
} # end hashtable