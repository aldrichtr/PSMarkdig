@{
    #-------------------------------------------------------------------------------
    #region IncludeDefaultRules
    <# Invoke default rules along with Custom rules.
    #>
    IncludeDefaultRules = $true
    #endregion IncludeDefaultRules
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region IncludeRules
    <# Runs only the specified rules in the Script Analyzer test. By default, PSScriptAnalyzer
       runs all rules.

       Enter a comma-separated list of rule names, a variable that contains rule names, or a command that gets rule
       names. Wildcard characters are supported. You can also specify rule names in a Script Analyzer profile file.

       When you use the **CustomizedRulePath** parameter, you can use this parameter to include standard rules and
       rules in the custom rule paths.

       If a rule is specified in both the **ExcludeRule** and **IncludeRule** collections, the rule is excluded.

       The **Severity** parameter takes precedence over **IncludeRule**. For example, if **Severity** is `Error`, you
       cannot use **IncludeRule** to include a `Warning` rule.
    #>
    IncludeRules        = @('*')
    #endregion IncludeRules
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region ExcludeRules

    <#
     Omits the specified rules from the Script Analyzer test. Wildcard characters are supported.

     Enter a comma-separated list of rule names, a variable that contains rule names, or a command that gets rule
     names. You can also specify a list of excluded rules in a Script Analyzer profile file. You can exclude
     standard rules and rules in a custom rule path.

     When you exclude a rule, the rule does not run on any of the files in the path. To exclude a rule on a
     particular line, parameter, function, script, or class, adjust the Path parameter or suppress the rule. For
     information about suppressing a rule, see the examples.

     If a rule is specified in both the ExcludeRule and IncludeRule collections, the rule is excluded.
     #>
    ExcludeRules = @(
        'PSDSC*'
    )
    #endregion ExcludeRules
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Rules
    <# Some rules have their own settings.  Rules is a hash of Rule names with the rule settings as a
       hash, like:

       ``` powershell
       @{
           'Rules' = @{
               'PSAvoidUsingCmdletAliases' = @{
                   'allowlist' = @('cd')
               }
           }
       }
       ```
    #>

    Rules               = @{
        PSAvoidUsingCmdletAliases = @{
            allowlist = @(
                'task'
            )
        }
        AvoidOverwritingBuiltInCmlets = @{
            PowerShellVersion = 'core-6-1.0-windows'
        }

        PSAvoidExclaimOperator = @{
            Enabled = $true
        }

        PSAvoidLongLines = @{
            Enable            = $true
            MaximumLineLength = 120
        }

        PSAvoidSemicolonsAsLineTerminators = @{
            Enable = $true
        }

        PSAvoidUsingPositionalParameters   = @{
            CommandAllowList = 'Join-Path'
            Enable           = $true
        }

        PSProvideCommentHelp = @{
            Enable                  = $true
            ExportedOnly            = $false
            BlockComment            = $true
            VSCodeSnippetCorrection = $false
            Placement               = 'before'
        }

        PSReviewUnusedParameter = @{
            CommandsToTraverse = @(
                'Invoke-PSFProtectedCommand'
            )
        }

        PSUseCompatibleSyntax = @{
            Enable         = $true
            TargetVersions = @(
                '6.0',
                '5.1',
                '4.0'
            )
        }

        PSUseCompatibleTypes = @{
            Enable         = $true
            TargetProfiles = @(
                'win-48_x64_10.0.17763.0_5.1.17763.316_x64_4.0.30319.42000_framework'
            )
            # You can specify types to not check like this, which will also ignore methods and members on it:
            IgnoreTypes    = @(
                'System.IO.Compression.ZipFile'
            )
        }

        PSUseSingularNouns = @{
            Enable        = $true
            NounAllowList = 'Data', 'Windows', 'Foos'
        }
    }
    #endregion Rules
    #-------------------------------------------------------------------------------
}
