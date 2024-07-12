@{
    # [markdown]
    # # PowerShell keywords
    #
    # The keywords have been broken down into the following groups:
    # - Named blocks
    # - Param blocks
    # - Data blocks
    # - Try blocks
    # - Function blocks
    # - Class blocks
    # - Condition blocks
    # - Control blocks
    # - Loop blocks

    Rules = @{
        # --------------------------------------------------------------------------------
        #region Named blocks

        # [markdown]
        # # Named Blocks
        # |Keyword        | References                                          |
        # |:-------------:|:----------------------------------------------------|
        # |  begin        | {about_Functions, about_Functions_Advanced}         |
        # |  process      | {about_Functions, about_Functions_Advanced}         |
        # |  end          | {about_Functions, about_Functions_Advanced_Methods} |
        # |  clean        | {about_Functions, about_Functions_Advanced_Methods} |

        FormatNamedBlock     = @{
            Enabled = $true
            Case    = 'lower'
        }

        #endregion Named blocks
        # --------------------------------------------------------------------------------

        # --------------------------------------------------------------------------------
        #region Param blocks

        # [markdown]
        # # Param Blocks
        # |Keyword        | References                                          |
        # |:-------------:|:----------------------------------------------------|
        # |  param        | about_Functions                                     |
        # |  dynamicparam | about_Functions_Advanced_Parameters                 |

        FormatParamBlock     = @{
            Enabled          = $true
            Case             = 'lower'
            SpaceBeforeParen = $false
        }

        #endregion Param blocks
        # --------------------------------------------------------------------------------

        # --------------------------------------------------------------------------------
        #region Data blocks

        # [markdown]
        # # Data blocks
        # |Keyword        | References                                          |
        # |:-------------:|:----------------------------------------------------|
        # |  data         | about_Data_Sections                                 |

        FormatDataBlock      = @{
            Enabled = $true
            Case    = 'upper'
        }

        #endregion Data blocks
        # --------------------------------------------------------------------------------

        # --------------------------------------------------------------------------------
        #region Try blocks

        # [markdown]
        # # Try blocks
        # |Keyword        | References                                          |
        # |:-------------:|:----------------------------------------------------|
        # |  try          | about_Try_Catch_Finally                             |
        # |  catch        | about_Try_Catch_Finally                             |
        # |  finally      | about_Try_Catch_Finally                             |
        # |  throw        | {about_Throw, about_Functions_Advanced_Methods}     |
        # |  trap         | {about_Trap, about_Break, about_Try_Catch_Finally}  |

        FormatTryBlock       = @{
            Enabled = $true
            Case    = 'lower'
        }

        #endregion Try blocks
        # --------------------------------------------------------------------------------

        # --------------------------------------------------------------------------------
        #region Function blocks

        # [markdown]
        # # Function blocks
        # |Keyword        | References                                          |
        # |:-------------:|:----------------------------------------------------|
        # |  filter       | about_Functions                                     |
        # |  function     | {about_Functions, about_Functions_Advanced}         |

        FormatFunctionBlock  = @{
            Enabled = $true
            Case    = 'lower'
        }

        #endregion Function blocks
        # --------------------------------------------------------------------------------

        # --------------------------------------------------------------------------------
        #region Class blocks

        # [markdown]
        # # Class blocks
        # |Keyword        | References                                          |
        # |  class        | about_Classes                                       |
        # |  static       | about_Classes                                       |
        # |  using        | {about_Using, about_Classes}                        |
        # |  enum         | about_Enum                                          |
        # |  hidden       | about_Hidden                                        |

        FormatClassBlock     = @{
            Enabled = $true
            Case    = 'lower'
        }

        #endregion Class blocks
        # --------------------------------------------------------------------------------

        # --------------------------------------------------------------------------------
        #region Condition blocks

        # [markdown]
        # # Condition blocks
        # |Keyword        | References                                          |
        # |  if           | about_If                                            |
        # |  elseif       | about_If                                            |
        # |  else         | about_If                                            |

        FormatConditionBlock = @{
            Enabled = $true
            Case    = 'lower'
        }

        #endregion Condition blocks
        # --------------------------------------------------------------------------------

        # --------------------------------------------------------------------------------
        #region Control blocks

        # [markdown]
        # # Control blocks
        # |Keyword        | References                                          |
        # |:-------------:|:----------------------------------------------------|
        # |  break        | {about_Break, about_Trap}                           |
        # |  continue     | {about_Continue, about_Trap}                        |
        # |  return       | about_Return                                        |

        FormatControlBlock   = @{
            Enabled = $true
            Case    = 'lower'
        }

        #endregion Control blocks
        # --------------------------------------------------------------------------------

        # --------------------------------------------------------------------------------
        #region Loop blocks

        # [markdown]
        # # Loop blocks
        # |Keyword        | References                                          |
        # |:-------------:|:----------------------------------------------------|
        # |  for          | about_For                                           |
        # |  foreach      | about_ForEach                                       |
        # |  in           | about_ForEach                                       |
        # |  do           | {about_Do, about_While}                             |
        # |  while        | {about_While, about_Do}                             |
        # |  until        | about_Do                                            |
        # |  switch       | about_Switch                                        |

        FormatLoopBlocks     = @{
            Enabled = $true
            Case    = 'lower'
        }

        #endregion Loop blocks
        # --------------------------------------------------------------------------------
    }
}
