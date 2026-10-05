@{
  Severity              = @(
    'Information',
    'Warning',
    'Error'
  )
  IncludeDefaultRules   = $true

  CustomRulePath        = @(
    '~/projects/AnalyzerRules/source/AnalyzerRules'
  )

  RecurseCustomRulePath = $true

  IncludeRules          = @('*')

  ExcludeRules          = @(
    'PSDSC*',
    'ParameterAttributeIsFalse',
    'ParameterAttributeIsTrue'
  )

  Rules = @{

    PSUseConstrainedLanguageMode = @{ Enable = $false }

    #region Formatting
    PSPlaceOpenBrace = @{
      Enable             = $true
      OnSameLine         = $true
      NewLineAfter       = $true
      IgnoreOneLineBlock = $true
    }

    PSPlaceCloseBrace = @{
      Enable             = $true
      NoEmptyLineBefore  = $true
      IgnoreOneLineBlock = $true
      NewLineAfter       = $true
    }

    PSAlignAssignmentStatement = @{
      Enable                                  = $true
      CheckHashtable                          = $false
      AlignHashtableKvpWithInterveningComment = $true
      CheckEnum                               = $true
      AlignEnumMemberWithInterveningComment   = $true
      IncludeValuelessEnumMembers             = $true
    }
    PSAvoidLongLines = @{
      Enable            = $true
      MaximumLineLength = 108
    }

    PSUseConsistentIndentation = @{
      Enable              = $true
      IndentationSize     = 2
      PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
      Kind                = 'space'
    }

    PSAvoidOverwritingBuiltInCmdlets          = @{
      Enable            = $true
      PowerShellVersion = @('core-7.0.0-windows')
    }

    PSUseConsistentWhitespace = @{
      Enable                                  = $true
      CheckInnerBrace                         = $true
      CheckOpenBrace                          = $true
      CheckOpenParen                          = $true
      CheckOperator                           = $true
      CheckPipe                               = $true
      CheckPipeForRedundantWhitespace         = $true
      CheckSeparator                          = $true
      CheckParameter                          = $true
      IgnoreAssignmentOperatorInsideHashTable = $false
    }

    PSAvoidSemicolonsAsLineTerminators = @{
      Enable = $true
    }

    PSAvoidUsingDoubleQuotesForConstantString = @{
      Enable = $true
    }
    #endregion

    PSProvideCommentHelp = @{
      Enable                  = $true
      ExportedOnly            = $false
      BlockComment            = $true
      VSCodeSnippetCorrection = $true
      Placement               = 'begin'
    }

    PSReviewUnusedParameter = @{
      CommandsToTraverse = @()
    }

    #region Compatibility
    PSUseCompatibleCmdlets = @{
      'compatibility' = @('core-6.1.0-windows')
    }

    PSUseCompatibleCommands = @{
      Enable         = $true
      TargetProfiles = @(
        'win-48_x64_10.0.17763.0_5.1.17763.316_x64_4.0.30319.42000_framework'
      )
      # You can specify commands to not check like this, which also will ignore its parameters:
      IgnoreCommands = @()
    }
    PSUseCompatibleSyntax = @{
      Enable         = $true
      TargetVersions = @( '6.0', '5.1')
    }

    PSUseCompatibleTypes = @{
      Enable         = $true
      TargetProfiles = @(
        'ubuntu_x64_18.04_6.1.3_x64_4.0.30319.42000_core',
        'win-48_x64_10.0.17763.0_5.1.17763.316_x64_4.0.30319.42000_framework'
      )
      # You can specify types to not check like this, which will also ignore methods and members on it:
      IgnoreTypes    = @()
    }
    #endregion

    #region Parameters
    PSUseConsistentParameterSetName = @{ Enable = $true }

    PSUseConsistentParametersKind             = @{
      Enable         = $true
      # Inline or ParamBlock
      ParametersKind = 'ParamBlock'
    }

    PSUseSingleValueFromPipelineParameter = @{ Enable = $true }

    PSAvoidUsingPositionalParameters = @{
      Enable           = $true
      CommandAllowList = @( 'Join-Path' )
    }

    FormatKeyword = @{
      # TODO: Need to align this with other rules.  'Enable' not 'Enabled'
      Enabled = $true
      Case = 'lower'
    }

    FormatParameterAttributeBlock = @{
      Enabled                = $true
      useNewLine             = $true
      useTrueExpression      = $false
      useFalseExpression     = $false
      excludeFalseExpression = @(
        'HelpMessageBaseName',
        'HelpMessageResourceId'

      )
      argumentList           = @(
        'ParameterSetName',
        'Mandatory',
        'Position',
        'DontShow',
        'ValueFromPipeline',
        'ValueFromPipelineByPropertyName',
        'ValueFromRemainingArguments',
        'HelpMessage'
      )
    }
    #endregion

    #region Commands
    PSUseCorrectCasing                        = @{
      Enable        = $true
      CheckCommands = $true
      CheckKeyword  = $true
      CheckOperator = $true
    }

    PSUseSingularNouns                        = @{
      Enable        = $true
      NounAllowList = @('Data', 'Windows')
    }


    PSAvoidUsingCmdletAliases                 = @{
      allowlist = @( 'task')
    }
    #endregion
  }
  #endregion Rules
}
